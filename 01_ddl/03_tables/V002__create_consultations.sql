-- V002__create_consultations.sql
-- Root aggregate of the domain: a medical consultation.
-- No foreign keys here; they are added in V005.

CREATE TABLE medical_consultation.consultations (
    id                bigserial   PRIMARY KEY,
    appointment_id    bigint      NOT NULL,
    patient_id        bigint      NOT NULL,
    professional_id   bigint      NOT NULL,
    status            text        NOT NULL DEFAULT 'IN_PROGRESS',
    completed_at      timestamptz,
    created_at        timestamptz NOT NULL DEFAULT NOW(),
    updated_at        timestamptz NOT NULL DEFAULT NOW(),
    deleted_at        timestamptz,
    CONSTRAINT chk_consultations_status
        CHECK (status IN ('IN_PROGRESS', 'COMPLETED')),
    CONSTRAINT uq_consultations_appointment UNIQUE (appointment_id)
);
