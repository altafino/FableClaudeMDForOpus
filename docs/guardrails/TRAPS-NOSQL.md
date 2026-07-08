<!-- guardrails-kit: v1.1 | Rows verified against MongoDB 8 / Redis 8 docs, 2026-07-08. Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C7 pack dispatch fired: you are writing MongoDB, Redis, DynamoDB, or other non-relational store code.

## MongoDB
- update without `$set` REPLACES the whole document (data loss) -> `$set`/`$unset` always; the destructive twin is docs/guardrails/DATA.md DA6.
- updateOne vs updateMany: state which and why — the wrong default mutates a different number of documents than intended.
- Schema drift: old documents lack new fields, so queries on the new field silently miss them -> state the backfill plan or the tolerance.
- ObjectId vs string: `_id` comparisons fail across the type boundary -> convert explicitly at the edge.
- Unbounded array growth per document (push-per-event) hits the 16MB document cap -> bucket or reference (PERFORMANCE.md PERF4 pattern).

## Redis
- KEYS blocks the server in production -> SCAN with a cursor.
- check-then-set across two commands races -> atomic ops (SET NX, INCR) or a Lua script; name which.
- Every cache write names a TTL, or `UNBOUNDED (by choice): <reason>` (PERFORMANCE.md PERF4).

## Distributed reads
- Read-after-write on eventually-consistent reads (DynamoDB default, replicas) can return stale data -> use a strongly-consistent read where the logic depends on it, and say so.
