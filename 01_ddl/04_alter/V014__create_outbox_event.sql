-- V014__create_outbox_event.sql
-- Transactional Outbox para PostConsultationSummaryGenerated.
--
-- Cambios respecto a la version original:
--   - correlation_id NOT NULL con default (varchar gen_random_uuid()::text).
--   - event_id uuid UNIQUE (envelope comun, idempotencia downstream).
--   - attempts integer, last_error text (diagnostico de fallos sin perder
--     el evento; el poller puede hacer backoff exponencial).
--   - updated_at (trazabilidad de status/attempts).
--   - indices parciales por status y por event_type.

CREATE TABLE medical_consultation.outbox_event (
    id              uuid         NOT NULL DEFAULT gen_random_uuid(),
    event_id        uuid         NOT NULL DEFAULT gen_random_uuid(),
    event_type      varchar(100) NOT NULL,
    payload         jsonb        NOT NULL,
    correlation_id  varchar(100) NOT NULL DEFAULT gen_random_uuid()::text,
    status          varchar(20)  NOT NULL DEFAULT 'PENDING',
    attempts        integer      NOT NULL DEFAULT 0,
    last_error      text,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    published_at    timestamptz,

    CONSTRAINT pk_outbox_event PRIMARY KEY (id),
    CONSTRAINT uq_outbox_event_event_id UNIQUE (event_id),
    CONSTRAINT ck_outbox_event_status CHECK (status IN ('PENDING', 'PUBLISHED', 'FAILED')),
    CONSTRAINT ck_outbox_event_payload_object CHECK (jsonb_typeof(payload) = 'object'),
    CONSTRAINT ck_outbox_event_attempts_non_negative CHECK (attempts >= 0)
);

CREATE INDEX idx_outbox_event_pending
    ON medical_consultation.outbox_event (created_at)
    WHERE status = 'PENDING';

CREATE INDEX idx_outbox_event_failed
    ON medical_consultation.outbox_event (created_at)
    WHERE status = 'FAILED';

CREATE INDEX idx_outbox_event_event_type
    ON medical_consultation.outbox_event (event_type);
