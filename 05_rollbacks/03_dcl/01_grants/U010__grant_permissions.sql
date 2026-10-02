-- U010__grant_permissions.sql
-- Reverses V010. Must run before U009 (drop roles) and U001 (drop schema).

REVOKE ALL ON ALL TABLES IN SCHEMA medical_consultation
    FROM medical_consultation_reader, medical_consultation_writer;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA medical_consultation
    FROM medical_consultation_writer;

REVOKE ALL ON SCHEMA medical_consultation
    FROM medical_consultation_reader, medical_consultation_writer;
