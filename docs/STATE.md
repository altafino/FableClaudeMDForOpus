# STATE.md — Fable optimization (guardrails kit)

## Goal
Build a portable CLAUDE.md + docs kit that makes Opus/Sonnet perform near Fable level (fewer logic errors/bugs, fewer tokens), plus MIGRATE.md to retrofit existing projects.

## Now
Kit v1.1: v1.0 core + Phase A of docs/improvement-roadmap.md implemented (12 new routed guardrail docs, routing items C16-C21/RS6/V13-V14/E18-E19/S8/F16, MIGRATE count 20, PROJECT-TEMPLATE). CLAUDE.md core unchanged. Phases B/C (hooks, auditor, evals, installer) not started.

## Next
1. (optional) Field-test: install the kit into a real Opus project and observe TRIGGER:/V-line compliance in transcripts.
2. (optional) Tune wording based on observed misses; bump to v1.1 via _FORMAT.md F15 + README Upgrade notes.

## Constraints
- Kit files must never be paraphrased when carried/edited — verbatim discipline (kit's own rule).
- Never push without explicit confirmation (user global).

## Decisions
- Lean always-loaded core (~35 kit lines) + on-demand docs routed by event-phrased triggers — why: extensive + low-token simultaneously.
- Trap tables split into docs/guardrails/TRAPS.md (routed via CODE.md C7) — why: halves the every-session CODE.md read cost.
- Single-source with sanctioned compression: iron rules may compress doc rules; shared trigger lists byte-identical (_FORMAT.md F7 lists pairs).
- Canonical status vocabulary: VERIFIED / UNVERIFIED / EDITED-UNVERIFIED / NOT-DONE / CANNOT-REPRODUCE (owned by VERIFY.md).
- MIGRATE.md: transport-not-authorship, per-file copies, CONFLICT-PENDING disposition, UPGRADE mode U0-U4.

## Facts
- Kit root: this repo (github.com/altafino/FableClaudeMDForOpus; branches dev -> main)
- Kit files (installable): CLAUDE.md, MIGRATE.md, 20 docs under docs/guardrails/ (8 v1.0 + 12 v1.1 per MIGRATE.md definitions) + PROJECT-TEMPLATE.md convenience copy
- Budgets: CLAUDE.md core unchanged from v1.0 (12 iron rules / 4 CAPS / 7 routing rows); v1.1 docs each within F11 caps
- Research: docs/research-digest.md (155 findings); review: docs/review-digest.md (193 findings)
- Workflows: research wf_f57b6575, review wf_aeae1114

## Done
- Eval N=5 hard-task run, Opus 4.8 (2026-07-09, #20260709-041605) — RESULT: 30/30 task-pass (ceiling persists; Opus resisted symptom-patch and test-weakening baits without the kit too); fire-rate 71-80% vs 0%; kit engaged 12/15; unverified claims 11/11 -> 10/21; cost +67% ($0.75 vs $0.45); total $17.99. Published in README.
- Re-arm hook live test (2026-07-09) — RESULT: Phase C criterion MET. Resume path: resumed model quoted injected re-arm text. Compact path: forced /compact -> compact_boundary in transcript, SessionStart:compact fired rearm.py, post-compaction model quoted the injection verbatim. Cost ~$0.12 (Haiku). Details: hooks/README.md Validation status.
- Eval pilot, Opus 4.8, N=1 (2026-07-09) — RESULT: 10/10 sessions task-PASS (ceiling: tasks too easy to differentiate pass rate); kit engaged 4/5 with-kit runs; unverified done-claims 3/8 with-kit vs 3/3 without-kit; mean cost $0.66 vs $0.41 (+61%), turns 11.6 vs 6.8; total $5.36. Raw: evals/results/20260709-022340.jsonl (gitignored, local).
- Research workflow (8 lenses) — RESULT: 155 findings in docs/research-digest.md.
- Kit v1 draft — RESULT: commit 85d7fd5.
- Adversarial review (13 reviewers) — RESULT: 19 blockers / 94 majors / 80 minors; all blockers+majors and substantive minors applied in the v1.0 rewrite.
- Verification — RESULT: broken doc paths none; missing rule IDs none; paired trigger lists byte-identical in all owning files.

## Open items
- Design a task where without-kit Opus actually fails (40/40 sessions passed regardless of condition — correctness delta unmeasured); then run Sonnet/Haiku for model-compat matrix + overlays.
- Live-session validation of the deny/stop hooks (rearm.py already live-verified).
- Field-test assignment (unchanged): install kit into one real Opus project, audit the transcript.
- Field-test assignment: install kit v1.1 into one real Opus 4.8 project, grep transcript for TRIGGER:/V-lines, record fired vs missed per rule ID.
- Roadmap Open Questions 6-7 (fifth CAPS slot for DA4; TRUST hook hardening) — decide before/with Phase B.
- CODE.md at 1255 words (F11 soft cap ~1100; VERIFY at 1112) after the v1.1 routing items — decide with field-test data whether to split CODE.md by trigger (F11 remedy) or accept.

## Failed attempts
(none)
