-- V007__create_indexes.sql
-- Indexes for the queries the API will run.

CREATE INDEX idx_consultations_patient
    ON medical_consultation.consultations (patient_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_consultations_professional
    ON medical_consultation.consultations (professional_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_consultations_status
    ON medical_consultation.consultations (status);

CREATE INDEX idx_attention_summaries_consultation
    ON medical_consultation.attention_summaries (consultation_id);

CREATE INDEX idx_post_summaries_patient
    ON medical_consultation.post_summaries (patient_id);
