-- V015__harden_outbox_event.sql
-- Mueve el endurecimiento que se aplicó in-place a V014 (bff1e93)
-- a una migración nueva, para no romper el checksum en entornos que
-- ya tenían aplicada la V014 original.

ALTER TABLE medical_consultation.outbox_event
    ADD COLUMN event_id uuid NOT NULL DEFAULT gen_random_uuid(),
    ADD COLUMN attempts integer NOT NULL DEFAULT 0,
    ADD COLUMN last_error text,
    ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now(),
    ADD CONSTRAINT uq_outbox_event_event_id UNIQUE (event_id),
    ADD CONSTRAINT ck_outbox_event_attempts_non_negative CHECK (attempts >= 0);

-- Backfill de correlation_id NULL antes del SET NOT NULL
UPDATE medical_consultation.outbox_event
SET correlation_id = gen_random_uuid()::text
WHERE correlation_id IS NULL;

ALTER TABLE medical_consultation.outbox_event
    ALTER COLUMN correlation_id SET NOT NULL,
    ALTER COLUMN correlation_id SET DEFAULT gen_random_uuid()::text;

CREATE INDEX idx_outbox_event_failed
    ON medical_consultation.outbox_event (created_at)
    WHERE status = 'FAILED';

CREATE INDEX idx_outbox_event_event_type
    ON medical_consultation.outbox_event (event_type);
