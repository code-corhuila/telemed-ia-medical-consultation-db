-- V008__seed_consultations.sql
-- Development seed. Idempotent.

INSERT INTO medical_consultation.consultations
    (appointment_id, patient_id, professional_id, status)
VALUES
    (9001, 1001, 5001, 'IN_PROGRESS')
ON CONFLICT (appointment_id) DO NOTHING;
