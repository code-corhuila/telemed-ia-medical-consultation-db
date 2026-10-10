-- V006__create_updated_at_triggers.sql
-- Keeps updated_at in sync on every UPDATE.

CREATE OR REPLACE FUNCTION medical_consultation.set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_consultations_updated_at
    BEFORE UPDATE ON medical_consultation.consultations
    FOR EACH ROW EXECUTE FUNCTION medical_consultation.set_updated_at();

CREATE TRIGGER trg_attention_summaries_updated_at
    BEFORE UPDATE ON medical_consultation.attention_summaries
    FOR EACH ROW EXECUTE FUNCTION medical_consultation.set_updated_at();
