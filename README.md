# telemed-ia-medical-consultation-db

Database schema of the **medical-consultation** bounded context.

Part of team `telemed-ia`, Grupo 2.

## What this repo is

Owns the structure and migrations of the `medical_consultation` schema
inside the single PostgreSQL instance defined by `-infra-postgres`.

**This repo does not define a database instance.** Per Anexo J.3.1,
the instance is owned by the infra repo. This repo only ships the
migration executor.

## Stack

| Component | Version |
|---|---|
| PostgreSQL | 16 |
| Flyway | 10.20.1 |
| Docker | latest |

## Structure

```text
01_ddl/          definition (schema, tables, FKs, triggers, indexes)
02_dml/          data (seed, patches)
03_dcl/          access (roles, grants)
04_tcl/          transactions
05_rollbacks/    reversals (U<n>__*.sql)
deploy/          compose.yml with only the Flyway executor
flyway.toml      Flyway configuration
```

## How to apply migrations

From `-infra-postgres`:

```bash
docker compose --env-file env/dev.env --profile tooling run --rm medical-consultation-db-migrate
```

## Rules

- The schema is `medical_consultation`; nothing lives in `public`.
- No FK to other domains (Anexo J.3.4).
- A migration already applied is never edited.
- Every V has a U in `05_rollbacks/` with the same number.
- `flyway_history_medical_consultation` is the control table for this domain.

## Cross-domain identifiers (UUID)

Since `V011__migrate_cross_domain_ids_to_uuid.sql`, all cross-domain
identifiers in `medical_consultation` are `uuid`:

- `consultations.appointment_id`, `patient_id`, `professional_id`.
- `post_summaries.appointment_id`, `patient_id`,
  `preconsultation_summary_id`.

Internal identifiers remain `bigserial` / `bigint`:

- `consultations.id`, `post_summaries.id`, `attention_summaries.id`.
- `post_summaries.consultation_id`, `attention_summary_id`.

Rationale: alignment with `identity-and-access` (the JWT `sub` is a
UUID), `intelligent-agent-db`, `appointment-scheduling-db` (which already
migrated in V009) and the course rule "camelCase JSON and UUID ids".

Development seed: `V008` values are translated to deterministic UUIDs
so the seed remains reproducible across environments:

| Old bigint | New UUID |
|---|---|
| `9001` (appointment) | `00000000-0000-0000-0000-000000009001` |
| `1001` (patient) | `00000000-0000-0000-0000-000000001001` |
| `5001` (professional) | `00000000-0000-0000-0000-000000005001` |

`professional_id = 5001` uses the same deterministic UUID as
`appointment-scheduling-db`, so the seed stays consistent across
repositories.

Rollback: `U011` only documents that the type reversal is not
symmetric. See the comment inside the script.

## Related documentation

- `telemed-ia-docs/02-domain/domain-map.md`
- `telemed-ia-docs/09-microservices/services/07-consultation-service/data-model.md`
- `telemed-ia-docs/05-architecture/decisions/records/ADR-010-clinical-document-separation.md`
- Anexo J of the repo norm.
