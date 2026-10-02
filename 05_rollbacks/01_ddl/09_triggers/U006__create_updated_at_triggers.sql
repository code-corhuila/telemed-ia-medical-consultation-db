DROP TRIGGER IF EXISTS trg_consultations_updated_at ON medical_consultation.consultations;
DROP TRIGGER IF EXISTS trg_attention_summaries_updated_at ON medical_consultation.attention_summaries;
DROP FUNCTION IF EXISTS medical_consultation.set_updated_at();
