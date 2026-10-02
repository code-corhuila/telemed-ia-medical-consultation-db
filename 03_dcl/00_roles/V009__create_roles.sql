-- V009__create_roles.sql
-- Roles of the domain. Users are created by the infrastructure (Anexo J.7).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'medical_consultation_reader') THEN
        CREATE ROLE medical_consultation_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'medical_consultation_writer') THEN
        CREATE ROLE medical_consultation_writer NOLOGIN;
    END IF;
END$$;
