# Guardrails enforcement companion (optional)

Deterministic enforcement for the kit's highest-stakes rules (roadmap Phase B1/B2) plus the
transcript compliance auditor (B3). The kit itself stays a pure documentation set — this layer
is opt-in and lives outside the `docs/guardrails/` kit docs.

## What is enforced, mechanically

| Hook | Enforces | Kit rule |
|---|---|---|
| `guard.py` (PreToolUse, Edit) | no Edit of a file with no Read recorded this session | iron rule 1 / CODE.md C1 |
| `guard.py` (PreToolUse, Write) | no Write over an existing file | iron rule 2 (rewrite procedure is the exception) |
| `guard.py` (PreToolUse, Edit/Write) | no edits under generated/vendored paths or lockfiles | CODE.md C2 |
| `guard.py` (PreToolUse, Bash) | no `pkill`/`killall`/`taskkill /IM` by image name | hard stop 3 |
| `guard.py` (PreToolUse, Bash) | `git push` only after the user runs `scripts/allow-push` (one push, 30 min) | hard stop 2 |
| `guard.py` (PreToolUse, Bash) | `git commit` blocked when the staged diff matches secret-assignment patterns | SECURITY.md SEC4 |
| `track.py` (PostToolUse) | records Read/Edit/Write paths per session (state for C1) | — |
| `stop_verify.py` (Stop) | turn may not end on a done-claim without a legal VERIFY form, if files were edited | VERIFY.md echo protocol |

## Install (per project, opt-in)

Merge `hooks/settings-snippet.json` into the project's `.claude/settings.json` (or
`settings.local.json`), with this repo's `hooks/` directory copied into the project. Requires
`python3` on PATH. POSIX-first; Windows parity is roadmap Open Question 2.

This repo does NOT enable the hooks on itself by default — enable deliberately after reading
the limitations below.

## Bypass + log convention (roadmap B1)

Every deny names its rule and its escape: set `GUARDRAILS_BYPASS=1` for the single call that is
a false positive. Bypasses append to `<project>/.claude/guardrails-bypass.log`, which the
auditor reads — overrides are visible, never silent.

## Auditor (B3)

```bash
python3 scripts/audit-transcript.py --latest          # newest transcript for this cwd
python3 scripts/audit-transcript.py <session.jsonl>   # explicit file
```

Prints a scorecard: trigger checks (CODE routing before first edit, TASK block at 3+ files,
DEBUG markers after failures, VERIFY evidence beside done-claims) plus a marker census.
Heuristic and format-coupled by design (Open Question 3): unparseable entries are skipped, so
results are a lower bound.

## Test suite

```bash
hooks/test_hooks.sh
```

Covers every deny's trigger case AND its bypass path — the roadmap's Phase B done-criterion
for hooks.

## Validation status

- `rearm.py` **live-verified 2026-07-09** (Haiku 4.5, throwaway workspace, ~$0.12): on `--resume`,
  the resumed model quoted the injected re-arm text verbatim; on a forced `/compact`, the
  transcript shows a real `compact_boundary`, `SessionStart:compact` fired the hook, and the
  post-compaction model quoted the injection from its rebuilt context. Nuances: compaction was
  forced via `/compact` (auto-compaction under context pressure uses the same `source=compact`
  path but was not separately triggered); delivery is proven — whether a model then *obeys* S1
  before editing is behavioral and belongs to the field test.
- `guard.py`/`track.py`/`stop_verify.py`: scripted-suite verified (23 cases); live-session
  validation pending.

## Known limitations (deliberate, tracked in the roadmap)

- Read-state lives in the OS temp dir keyed by session id; after a crash the first Edit of a
  known file may false-positive — that is what the logged bypass is for (Open Question 5).
- `stop_verify.py` claim matching is heuristic v0: prose-only, code fences stripped, active
  only when the session edited files. Expect and report false positives/negatives.
- Windows (PowerShell) parity not yet built (Open Question 2).
