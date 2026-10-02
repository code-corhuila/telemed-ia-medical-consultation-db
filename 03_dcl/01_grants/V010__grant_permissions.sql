-- V010__grant_permissions.sql
-- The domain grants its own users access to its own schema.

GRANT USAGE ON SCHEMA medical_consultation
    TO medical_consultation_reader, medical_consultation_writer;

GRANT SELECT ON ALL TABLES IN SCHEMA medical_consultation
    TO medical_consultation_reader;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA medical_consultation
    TO medical_consultation_writer;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA medical_consultation
    TO medical_consultation_writer;
