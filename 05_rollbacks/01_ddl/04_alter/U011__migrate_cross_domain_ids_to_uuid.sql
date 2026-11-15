-- U011__migrate_cross_domain_ids_to_uuid.sql
-- Rollback de V011.
--
-- IMPORTANTE: la reversión de tipo uuid -> bigint no es simétrica.
-- uuid no se puede convertir a bigint sin perder información.
-- Este script no revierte tipos.
--
-- Para reconstruir el esquema original en dev, ejecutar manualmente:
--   psql -c "DROP SCHEMA medical_consultation CASCADE;"
-- y volver a aplicar todas las V desde V001.
--
-- flyway.cleanDisabled=true impide usar flyway clean.

-- Sin DROP INDEX: V011 no añade índices nuevos.
-- Los índices de V007 (patient_id, professional_id) siguen válidos
-- sobre columnas uuid.

-- No se revierte el tipo de columna.
-- Documentar en el PR que la reversión de datos requiere procedimiento
-- manual y que, en este corte, no hay datos productivos.
