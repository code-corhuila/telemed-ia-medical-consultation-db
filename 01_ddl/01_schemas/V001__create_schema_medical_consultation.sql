-- V001__create_schema_medical_consultation.sql
-- Creates the dedicated schema for the medical-consultation domain.
-- Per Anexo J.3.2, this domain writes only to its own schema.

CREATE SCHEMA IF NOT EXISTS medical_consultation;
