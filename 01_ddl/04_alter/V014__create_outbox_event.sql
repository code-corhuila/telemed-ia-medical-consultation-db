-- V014__create_outbox_event.sql
-- Implementa el Patron Transactional Outbox para la publicacion de eventos.
-- Permite que el evento PostConsultationSummaryGenerated se guarde en la misma
-- transaccion que el post-resumen, garantizando que no se pierda el evento.

CREATE TABLE medical_consultation.outbox_event (
    id              uuid         NOT NULL DEFAULT gen_random_uuid(),
    event_type      varchar(100) NOT NULL,
    payload         jsonb        NOT NULL,
    correlation_id  varchar(100),
    status          varchar(20)  NOT NULL DEFAULT 'PENDING',
    created_at      timestamptz  NOT NULL DEFAULT now(),
    published_at    timestamptz,
    
    CONSTRAINT pk_outbox_event PRIMARY KEY (id),
    CONSTRAINT ck_outbox_event_status CHECK (status IN ('PENDING', 'PUBLISHED', 'FAILED')),
    CONSTRAINT ck_outbox_event_payload_object CHECK (jsonb_typeof(payload) = 'object')
);

-- Indice para buscar rapidamente los eventos pendientes
CREATE INDEX idx_outbox_event_pending
    ON medical_consultation.outbox_event (created_at)
    WHERE status = 'PENDING';
