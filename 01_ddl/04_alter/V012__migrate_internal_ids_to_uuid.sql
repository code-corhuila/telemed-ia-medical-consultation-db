-- V012__migrate_internal_ids_to_uuid.sql
-- Migra los IDs internos de medical_consultation a UUID.
--
-- Estrategia: md5(<col>::text)::uuid es determinista y preserva la relacion
-- padre-hijo entre consultations, attention_summaries y post_summaries.
-- Un gen_random_uuid() por columna rompia las FKs internas porque cada
-- columna recibia un UUID distinto de forma independiente. Esta version
-- corrige ese bug: si consultations.id = 42, el UUID resultante es siempre
-- el mismo, y attention_summaries.consultation_id = 42 se convierte al
-- mismo UUID. Las FKs se preservan sin necesidad de tablas de mapeo.
--
-- Alcance:
--   - consultations.id, attention_summaries.id, post_summaries.id
--       bigserial -> uuid con DEFAULT gen_random_uuid() (para futuros inserts)
--   - attention_summaries.consultation_id -> uuid
--   - post_summaries.consultation_id -> uuid
--   - post_summaries.attention_summary_id (nullable) -> uuid (nullable)
--
-- Lo que NO cambia:
--   - Los IDs cross-domain ya migraron en V011.
--   - preconsultation_summary_id ya es uuid desde V011.
--   - attention_summaries, post_summaries no se borran ni se truncan.
--
-- Preservacion de datos: el seed de V008 (una fila en consultations) se
-- traduce de forma determinista; los UUIDs son reproducibles entre entornos.
--
-- Reversion: ver U012. La reversion determinista requiere convertir el md5
-- de vuelta a bigint; solo es posible si los ids originales estaban en el
-- rango < 2^63 (siempre en este corte, pero no es simetrico en general).

-- ---------------------------------------------------------------------------
-- 1. Drop FKs internas (se recrean al final).
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries
    DROP CONSTRAINT IF EXISTS fk_attention_summaries_consultation;

ALTER TABLE medical_consultation.post_summaries
    DROP CONSTRAINT IF EXISTS fk_post_summaries_consultation,
    DROP CONSTRAINT IF EXISTS fk_post_summaries_attention;

-- ---------------------------------------------------------------------------
-- 2. consultations.id: bigserial -> uuid (determinista)
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.consultations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE medical_consultation.consultations
    ALTER COLUMN id TYPE uuid USING md5(id::text)::uuid;
ALTER TABLE medical_consultation.consultations
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- ---------------------------------------------------------------------------
-- 3. attention_summaries: id + consultation_id
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.attention_summaries ALTER COLUMN id DROP DEFAULT;
ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN id TYPE uuid USING md5(id::text)::uuid;
ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE medical_consultation.attention_summaries
    ALTER COLUMN consultation_id TYPE uuid USING md5(consultation_id::text)::uuid;

-- ---------------------------------------------------------------------------
-- 4. post_summaries: id + consultation_id + attention_summary_id (nullable)
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.post_summaries ALTER COLUMN id DROP DEFAULT;
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN id TYPE uuid USING md5(id::text)::uuid;
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN consultation_id TYPE uuid USING md5(consultation_id::text)::uuid;
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN attention_summary_id TYPE uuid
    USING CASE
        WHEN attention_summary_id IS NULL THEN NULL
        ELSE md5(attention_summary_id::text)::uuid
    END;

-- ---------------------------------------------------------------------------
-- 5. Recrear FKs internas.
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
