-- V003__create_attention_summaries.sql
-- Stores the clinical information recorded by the healthcare professional.

CREATE TABLE medical_consultation.attention_summaries (
    id                bigserial   PRIMARY KEY,
    consultation_id   bigint      NOT NULL,
    diagnosis         text,
    recommendations   text,
    medications       jsonb       NOT NULL DEFAULT '[]'::jsonb,
    observations      text,
    referral          text,
    follow_up         jsonb,
    created_at        timestamptz NOT NULL DEFAULT NOW(),
    updated_at        timestamptz NOT NULL DEFAULT NOW()
);
