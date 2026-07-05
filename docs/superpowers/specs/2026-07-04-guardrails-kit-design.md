# Guardrails Kit — Design Record

Date: 2026-07-04
Author: Claude (Fable 5), commissioned by collin3000
Status: approved-by-request (user commissioned the deliverable explicitly; built autonomously)

## Goal

A portable documentation kit that makes Claude Opus / Sonnet operate as close to
Fable-level as possible inside Claude Code: fewer logic errors, fewer introduced
bugs, less token waste. Plus a migration procedure so an Opus can retrofit an
existing project's CLAUDE.md into this structure without losing anything.

## Core thesis

The gap between a frontier model and a mid-tier model is mostly *implicit
judgment*: knowing when to re-read, when to sweep call sites, when a "done"
claim is premature. Judgment cannot be transferred through documentation, but
*procedure* can. The kit converts Fable's implicit judgment into explicit,
checkable, triggered procedures that a weaker model can execute mechanically.

Every rule in the kit must be:
1. **Checkable** — compliance is visible in the transcript.
2. **Triggered** — the activating situation is named exactly.
3. **Cheap relative to payoff** — always-on rules cost few tokens.
4. **Literal rule text** — imperative voice, no aspirational prose.

## Architecture: lean core + on-demand playbooks

- `CLAUDE.md` (always loaded, tight budget): iron rules (~one line each) + a
  trigger→document routing table. This is the only always-on token cost.
- `docs/guardrails/*.md` (read on demand at the trigger moment):
  - `PLAN.md` — before starting non-trivial work
  - `CODE.md` — while writing or editing code
  - `DEBUG.md` — when anything fails or behaves unexpectedly
  - `VERIFY.md` — before claiming done / committing
  - `EFFICIENCY.md` — token & context discipline
  - `SESSION.md` — long-session state management (STATE.md convention)
- `MIGRATE.md` — mechanical migration procedure for existing projects.
- `README.md` — human-facing: what the kit is, fresh install vs migration.

Biggest structural risk: an on-demand doc that never gets opened is worth zero.
The routing table is therefore the most engineered part of CLAUDE.md, and the
phase-2 review includes a "fresh-install simulation" agent that tests whether
routing actually fires.

## Migration design constraints

- Kit files are copied **verbatim** — the migrating model must never paraphrase
  them (paraphrase is where rules die).
- Line-accounting: every line of the original CLAUDE.md ends up
  kept / replaced-by-kit-rule / dropped-with-stated-reason.
- Backup before touching anything; verification checklist before deleting it.
- Conflicts: explicit project-specific rules win over kit defaults, and each
  conflict is surfaced in a migration-notes section for the human.
- Idempotent: re-running on a migrated project is a detected no-op.

## Build process

1. Phase-1 workflow: 8 parallel research lenses (reasoning errors, bug
   injection, false completion, token efficiency, context degradation,
   instruction-format engineering, process failures, migration risks).
2. Fable authors all files from the research (synthesis stays in the main
   session per collin3000's delegation policy).
3. Phase-2 workflow: adversarial review — per-doc compliance realism, cross-doc
   consistency, always-loaded token audit, migration dry-run on a synthetic
   legacy CLAUDE.md, fresh-install routing simulation.
4. Fable applies fixes; final report.
