-- V005__add_foreign_keys.sql
-- FKs within the medical_consultation schema only.
-- Cross-domain references (appointment_id, patient_id, professional_id)
-- remain as external identifiers with no FK (Anexo J.3.4).

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
