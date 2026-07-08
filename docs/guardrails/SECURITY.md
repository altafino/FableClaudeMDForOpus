<!-- guardrails-kit: v1.1 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C16 fired: the code touches user input, SQL, shell/command construction, file paths from external input, secrets/env vars, auth/session logic, or deserialization.

Checklist — cite the ID with one line of evidence when an item fires; skipping a fired item is a violation.

- SEC1. User input reaching SQL: parametrized queries only. Grep the diff for string-built SQL (concatenation, interpolation, f-strings near SELECT|INSERT|UPDATE|DELETE) and paste the hit list — a zero-hit result is pasted, never asserted.
- SEC2. Shell command built from variables: never string-interpolate -> arg-array APIs (execFile, subprocess list form, exec.Command); paste the call site.
- SEC3. File path from external input: resolve it, then prefix-check against the allowed root BEFORE use; trace one `../` input in a comment.
- SEC4. Commit touches config/env/credentials: grep the staged diff for `password|secret|token|api[_-]?key|BEGIN .*PRIVATE` and paste the result. `.env`-like files are never staged -> instead: add them to .gitignore and say so.
- SEC5. Never log or echo a value read from a secret-named variable (key, token, password, secret) -> log a redacted marker (`***`) instead.
- SEC6. Crypto or auth primitives are never hand-rolled -> use a maintained library and name it + its pinned version (CODE.md C6). No MD5/SHA-1 where security matters.
- SEC7. Deserializing external data: safe loaders only (`yaml.safe_load`, `JSON.parse`) -> never pickle/eval/`yaml.load`/unserialize on untrusted input.
- SEC8. New endpoint/handler/route: write `AUTH: <who may call> — enforced at <file:line>`; no line to point at means default-deny is missing — add it before continuing.

--- reference ---

## You are about to claim done on a diff that fired any SEC item
docs/guardrails/VERIFY.md V13 owns the echo: the SEC4 grep output must be quoted in the same turn as the claim.

## Injection vs. irreversibility
This file owns injection and secrets. Destructive database operations (row counts, DROP approval, migrations) are owned by docs/guardrails/DATA.md.
