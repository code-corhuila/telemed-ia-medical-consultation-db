ALTER TABLE IF EXISTS medical_consultation.attention_summaries
    DROP CONSTRAINT IF EXISTS fk_attention_summaries_consultation;
ALTER TABLE IF EXISTS medical_consultation.post_summaries
    DROP CONSTRAINT IF EXISTS fk_post_summaries_consultation;
ALTER TABLE IF EXISTS medical_consultation.post_summaries
    DROP CONSTRAINT IF EXISTS fk_post_summaries_attention;
