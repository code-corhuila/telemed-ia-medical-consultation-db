-- V013__unique_attention_consultation.sql
-- Previene que se registren multiples atenciones para una misma consulta.

-- Opcional: si hay datos duplicados en entorno de desarrollo, la migracion fallara.
-- Se debe limpiar manualmente o marcar los duplicados como borrados antes de aplicar.

ALTER TABLE medical_consultation.attention_summaries
    ADD CONSTRAINT uq_attention_summaries_consultation UNIQUE (consultation_id);
