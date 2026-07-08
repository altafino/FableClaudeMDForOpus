<!-- guardrails-kit: v1.1 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C17 fired: you are writing a loop containing an I/O/DB/network call, a nested loop over collections that can grow, or a list query/endpoint.

- PERF1. I/O, DB, or network call inside a loop: write N's realistic upper bound in a comment; N unbounded -> batch/bulk API, or justify in one line (the N+1 classic).
- PERF2. Nested loops over collections that can grow: write the O() in a comment; worse than O(n log n) on unbounded input -> restructure or justify.
- PERF3. Optimization claims need numbers: paste the same measurement command's output BEFORE and AFTER the change; no numbers -> the claim is UNVERIFIED (docs/guardrails/VERIFY.md forms).
- PERF4. Cache/map/list that only grows: name its eviction policy or size bound in a comment -> none exists: add one, or write `UNBOUNDED (by choice): <reason>`.
- PERF5. List query or endpoint without LIMIT/pagination: add it, or justify in one line why the result set is bounded.
- PERF6. Synchronous blocking I/O on a request/UI hot path: move it async/background, or justify in one line.

--- reference ---

## Ownership boundary
Language-level micro-traps (string concat in loops, `+=` on str) live in docs/guardrails/TRAPS.md; this file owns systemic patterns (N+1, unbounded growth, missing pagination, measure-before/after). A rule never appears in both (_FORMAT.md F7).
