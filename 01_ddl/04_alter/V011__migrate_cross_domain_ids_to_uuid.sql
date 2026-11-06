-- V011__migrate_cross_domain_ids_to_uuid.sql
-- Migración de los identificadores cross-domain de medical-consultation a UUID.
--
-- Motivo:
--   - identity-and-access emite UUID (sub del JWT).
--   - intelligent-agent-db exige UUID en appointmentId y patientId.
--   - appointment-scheduling-db ya migró a UUID (V009).
--   - Norma del curso: "camelCase JSON and UUID ids".
--
-- Alcance:
--   - consultations.appointment_id, patient_id, professional_id -> uuid
--   - post_summaries.appointment_id, patient_id,
--     preconsultation_summary_id -> uuid
--
-- Lo que NO cambia:
--   - consultations.id, post_summaries.id, attention_summaries.id:
--     son PKs internas del dominio, siguen bigserial.
--   - post_summaries.consultation_id, attention_summary_id:
--     son FKs internas al dominio, siguen bigint.
--   - La FK interna de V005 se mantiene intacta.
--   - attention_summaries no tiene IDs cross-domain, no se toca.
--
-- Preservación de datos:
--   - V008 siembra appointment_id=9001, patient_id=1001,
--     professional_id=5001. Se traducen a UUIDs deterministas para
--     que el seed siga siendo reproducible entre entornos.
--   - post_summaries no tiene seed; sus UUIDs se generan.
--   - preconsultation_summary_id es nullable; se pone NULL.
--
-- Reversión:
--   Ver 05_rollbacks/01_ddl/04_alter/U011__migrate_cross_domain_ids_to_uuid.sql.
--   La reversión de tipos no es simétrica: uuid no se puede convertir a
--   bigint sin perder información.

-- ---------------------------------------------------------------------------
-- 1. consultations: cross-domain IDs a uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.consultations
    ALTER COLUMN appointment_id TYPE uuid
        USING (
            CASE
                WHEN appointment_id = 9001
                THEN '00000000-0000-0000-0000-000000009001'::uuid
                ELSE gen_random_uuid()
            END
        ),
    ALTER COLUMN patient_id TYPE uuid
        USING (
            CASE
                WHEN patient_id = 1001
                THEN '00000000-0000-0000-0000-000000001001'::uuid
                ELSE gen_random_uuid()
            END
        ),
    ALTER COLUMN professional_id TYPE uuid
        USING (
            CASE
                WHEN professional_id = 5001
                THEN '00000000-0000-0000-0000-000000005001'::uuid
                ELSE gen_random_uuid()
            END
        );

-- ---------------------------------------------------------------------------
-- 2. post_summaries: cross-domain IDs a uuid
-- ---------------------------------------------------------------------------
ALTER TABLE medical_consultation.post_summaries
    ALTER COLUMN appointment_id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN patient_id TYPE uuid
        USING gen_random_uuid(),
    ALTER COLUMN preconsultation_summary_id TYPE uuid
        USING NULL;
