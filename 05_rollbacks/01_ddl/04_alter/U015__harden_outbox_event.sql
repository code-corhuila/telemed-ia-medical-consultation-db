DROP INDEX IF EXISTS medical_consultation.idx_outbox_event_event_type;
DROP INDEX IF EXISTS medical_consultation.idx_outbox_event_failed;

ALTER TABLE medical_consultation.outbox_event
    DROP CONSTRAINT IF EXISTS ck_outbox_event_attempts_non_negative,
    DROP CONSTRAINT IF EXISTS uq_outbox_event_event_id,
    ALTER COLUMN correlation_id DROP NOT NULL,
    ALTER COLUMN correlation_id DROP DEFAULT,
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS last_error,
    DROP COLUMN IF EXISTS attempts,
    DROP COLUMN IF EXISTS event_id;
