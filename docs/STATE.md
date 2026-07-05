# STATE.md — Fable optimization (guardrails kit)

## Goal
Build a portable CLAUDE.md + docs kit that makes Opus/Sonnet perform near Fable level (fewer logic errors/bugs, fewer tokens), plus MIGRATE.md to retrofit existing projects.

## Now
Kit v1.0 complete: authored, adversarially reviewed (13 reviewers, 193 findings), all blocker/major fixes applied, budgets verified, committed.

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
- Kit root: C:\Users\Laptop\Documents\Fable optimization (git repo, branch main)
- Kit files (installable): CLAUDE.md, MIGRATE.md, docs/guardrails/{_FORMAT,PLAN,CODE,TRAPS,DEBUG,VERIFY,EFFICIENCY,SESSION}.md (8 docs)
- Budgets verified: 35 kit lines / 12 iron rules / 4 CAPS / 7 routing rows; docs ~830-1210 words each
- Research: docs/research-digest.md (155 findings); review: docs/review-digest.md (193 findings)
- Workflows: research wf_f57b6575, review wf_aeae1114

## Done
- Research workflow (8 lenses) — RESULT: 155 findings in docs/research-digest.md.
- Kit v1 draft — RESULT: commit 85d7fd5.
- Adversarial review (13 reviewers) — RESULT: 19 blockers / 94 majors / 80 minors; all blockers+majors and substantive minors applied in the v1.0 rewrite.
- Verification — RESULT: broken doc paths none; missing rule IDs none; paired trigger lists byte-identical in all owning files.

## Open items
(none)

## Failed attempts
(none)
