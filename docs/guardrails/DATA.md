<!-- guardrails-kit: v1.1 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C19 fired: you are writing SQL/ORM mutations, a migration, or a bulk-update script.

- DA1. UPDATE/DELETE: WHERE clause present, or the full-table effect is stated and user-approved. Predict the affected row count in one line, run, paste predicted vs actual — a mismatch stops the task.
- DA2. Bulk mutation: run the matching SELECT COUNT(*) (or the tool's dry-run flag) first and paste it; only then mutate.
- DA3. Never edit an already-applied migration -> write a new forward migration; state the rollback (down-migration, or `IRREVERSIBLE: <why>`).
- DA4. DROP/TRUNCATE/destructive schema change: paste the exact target list and wait for the user's approval in this conversation.
- DA5. Multi-statement mutations run inside a transaction -> cannot (DDL/engine limits): say so in one line before running.
- DA6. MongoDB update without `$set` REPLACES the whole document -> always `$set`/`$unset`; state updateOne vs updateMany and why.

--- reference ---

## Injection, N+1, and correctness lookups live elsewhere
Parametrization: docs/guardrails/SECURITY.md SEC1. Query cost: docs/guardrails/PERFORMANCE.md PERF1/PERF5. SQL correctness rows: docs/guardrails/TRAPS-SQL.md. NoSQL rows: docs/guardrails/TRAPS-NOSQL.md.
