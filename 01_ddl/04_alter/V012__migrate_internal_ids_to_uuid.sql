-- V012__migrate_internal_ids_to_uuid.sql
-- Migra los IDs internos de medical_consultation a UUID.
--
-- Motivo:
--   - El contrato `_shared.yaml` ya declara PostSummary.id,
--     PostSummary.consultationId, PostSummary.attentionSummaryId y
--     AttentionSummary.id como `Id` (UUID).
--   - `document-service` recibe `summaryId` (UUID) por el evento
--     `PostConsultationSummaryGenerated` y necesita hacer lookup en
--     `GET /api/post-summaries/{summaryId}`. Con `int64` no puede.
--
-- Alcance:
--   - consultations.id, post_summaries.id, attention_summaries.id
--     bigserial -> uuid con DEFAULT gen_random_uuid().
--   - attention_summaries.consultation_id, post_summaries.consultation_id
--     bigint -> uuid.
--   - post_summaries.attention_summary_id
--     bigint NULL -> uuid NULL.
--   - Las tres FKs internas se dropean, cambian tipo y se recrean.
--
-- Preservacion de datos:
--   - No hay datos productivos en este corte.
--   - Los IDs se regeneran con gen_random_uuid(). No se preservan
--     los valores originales.
--
-- Reversion:
--   Ver U012. La reversion de tipo uuid -> bigint no es simetrica.

-- ---------------------------------------------------------------------------
-- 1. Drop FKs internas
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries
    DROP CONSTRAINT fk_attention_summaries_consultation;

ALTER TABLE medical_consultation.post_summaries
    DROP CONSTRAINT fk_post_summaries_consultation,
    DROP CONSTRAINT fk_post_summaries_attention;

-- ---------------------------------------------------------------------------
-- 2. consultations.id -> uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.consultations
    ALTER COLUMN id DROP DEFAULT;

ALTER TABLE medical_consultation.consultations
    ALTER COLUMN id TYPE uuid USING gen_random_uuid();

ALTER TABLE medical_consultation.consultations
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 3. attention_summaries.id -> uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN id DROP DEFAULT;

ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN id TYPE uuid USING gen_random_uuid();

ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 4. post_summaries.id -> uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN id DROP DEFAULT;

ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN id TYPE uuid USING gen_random_uuid();

ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 5. FK internas -> uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN consultation_id TYPE uuid USING gen_random_uuid();

ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN consultation_id TYPE uuid USING gen_random_uuid(),
    ALTER COLUMN attention_summary_id TYPE uuid USING NULL;

-- ---------------------------------------------------------------------------
-- 6. Recrear FKs internas
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries
    ADD CONSTRAINT fk_attention_summaries_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES medical_consultation.consultations(id)
        ON DELETE CASCADE;

ALTER TABLE medical_consultation.post_summaries
    ADD CONSTRAINT fk_post_summaries_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES medical_consultation.consultations(id)
        ON DELETE CASCADE;

ALTER TABLE medical_consultation.post_summaries
    ADD CONSTRAINT fk_post_summaries_attention
        FOREIGN KEY (attention_summary_id)
        REFERENCES medical_consultation.attention_summaries(id)
        ON DELETE SET NULL;
