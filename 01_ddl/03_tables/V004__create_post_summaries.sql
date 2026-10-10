-- V004__create_post_summaries.sql
-- Structured post-consultation summary.

CREATE TABLE medical_consultation.post_summaries (
    id                           bigserial   PRIMARY KEY,
    consultation_id              bigint      NOT NULL,
    appointment_id               bigint      NOT NULL,
    patient_id                   bigint      NOT NULL,
    preconsultation_summary_id   bigint,
    attention_summary_id         bigint,
    generated_at                 timestamptz NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_post_summaries_consultation UNIQUE (consultation_id)
);
