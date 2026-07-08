<!-- guardrails-kit: v1.0.1 -->
# Guardrails Kit v1.0

A portable CLAUDE.md + documentation set that makes Claude Opus / Sonnet operate as close to
frontier (Fable) level as possible inside Claude Code: fewer logic errors, fewer introduced bugs,
fewer wasted tokens. It works by converting the implicit judgment a stronger model applies
automatically into explicit, checkable, event-triggered procedures a weaker model can execute
mechanically.

New to the project? Start with [how-it-works.md](how-it-works.md) — a plain-language walkthrough
of the kit's architecture, design principles, and an honest assessment of what it can and cannot
transfer. Planned improvements (enforcement hooks, compliance auditing, evals, and new guardrail
docs for security/performance/frontend/trust/data/tests) live in
[docs/improvement-roadmap.md](docs/improvement-roadmap.md).

## What's in the kit

| File | Role |
|---|---|
| `CLAUDE.md` | Always-loaded core: 12 iron rules, an event-phrased routing table, 4 hard stops. Deliberately small (~45 kit lines, hard cap 60) — always-on compliance is roughly constant-sum, so every extra line taxes obedience to all the others. |
| `docs/guardrails/PLAN.md` | Before starting non-trivial work: TASK block, premise check, prior-art search, baseline, decomposition, ask-vs-decide. |
| `docs/guardrails/CODE.md` | While editing: read-before-edit gates, twin/generated-file checks, and the REFERENCE SWEEP procedure (RS1-RS5). |
| `docs/guardrails/TRAPS.md` | Lookup tables for the classic reasoning traps: dates, epochs, mutation-vs-copy, async, floats/money, sort, division/modulo, regex, familiar-API lookalikes, closures, boolean logic. Read on demand via CODE.md C7. |
| `docs/guardrails/DEBUG.md` | When anything fails: reproduce-first loop, CAUSE line, failed-attempts ledger with the ESCALATION LADDER, red-flag table keyed on the model's own rationalization phrases. |
| `docs/guardrails/VERIFY.md` | Before claiming done/committing: 12-item echo protocol — every claim needs output quoted from a real tool result in the same turn. |
| `docs/guardrails/EFFICIENCY.md` | Token/context discipline as paired rules: every "read less" rule has a "read enough" floor. |
| `docs/guardrails/SESSION.md` | Long-session survival: docs/STATE.md template (S2), same-turn update triggers (S3), post-compaction recovery (S1), ANCHOR/DETOUR/DECISION ledger keywords. |
| `docs/guardrails/_FORMAT.md` | Authoring contracts for editing the kit itself (budgets, trigger phrasing, single-sourcing, sanctioned iron-rule pairs). |
| `MIGRATE.md` | The transport procedure for retrofitting a project that already has a CLAUDE.md — line-accounted, backup-first, verbatim-carry, user-checkpointed, idempotent, with an UPGRADE mode. |

Not part of the installable kit (kit-source and companion materials only): `how-it-works.md`
(plain-language explanation of the kit), `docs/improvement-roadmap.md` (the approved improvement
roadmap), `docs/research-digest.md` (the 155-finding failure-mode research behind every rule),
`docs/review-digest.md` (the 193-finding adversarial review that hardened it), and
`docs/superpowers/specs/` (the design record).

## Install — fresh project (no existing CLAUDE.md)

From the project root — POSIX (Linux/macOS):

```bash
cp <kit>/CLAUDE.md CLAUDE.md
mkdir -p docs/guardrails
cp <kit>/docs/guardrails/*.md docs/guardrails/
```

or PowerShell (Windows):

```powershell
Copy-Item <kit>/CLAUDE.md CLAUDE.md
New-Item -ItemType Directory -Force docs/guardrails | Out-Null
Copy-Item <kit>/docs/guardrails/*.md docs/guardrails/
```

Then fill the `## Project` section of CLAUDE.md with your run/test commands and hard project
constraints (cap: 40 lines — everything conditional goes in `docs/guardrails/PROJECT.md` with a
pointer line in `## Project`). Never edit inside the `BEGIN/END KIT` markers.

## Install — project with an existing CLAUDE.md

Tell the model (Opus is fine — the procedure is designed for it):

> Read MIGRATE.md in <kit path> and execute it exactly, phase by phase.

MIGRATE.md is built so nothing is lost: snapshot first, every original line gets a logged
disposition, kit files are installed by per-file copy (never retyped), rule conflicts are surfaced
instead of silently resolved, and it stops for your approval before installing kit docs or
composing the new CLAUDE.md. Re-running it on a migrated project is detected and switches to
UPGRADE mode.

## Design principles (why it looks like this)

1. **Lean core + on-demand playbooks.** Only ~45 kit lines are always loaded. The extensive
   material is read at the moment its trigger fires — that is how "extensive" and "fewer tokens"
   coexist.
2. **Event-phrased routing.** Models route on what they literally experience ("a test failed",
   "about to type done"), not on topic labels ("debugging", "verification"). A doc that never
   gets opened is worth zero, so the routing table is the most engineered block in the kit —
   and its contract makes the doc-Read the next tool call, alone in its message.
3. **Paste, don't check.** Every rule produces a transcript artifact (a pasted grep, a quoted
   summary line, a `TRIGGER:`/`ANCHOR:`/`V3: PASS` line), and VERIFY requires quoted lines to
   exist verbatim in a tool result in the same turn. Compliance is visible; "ensure" is not.
4. **Numbers, not judgment.** "10 messages", "2 failures", ">50 hits", ">300 lines" — weaker
   models comply with countable thresholds and rationalize their way around graded ones.
5. **Prohibitions carry replacements.** Every NEVER has its replacement on the same line,
   because a banned action with no named alternative gets taken anyway under pressure.
6. **Single source with sanctioned compression.** Each rule lives in exactly one file; a
   CLAUDE.md iron rule may compress a doc rule, but shared trigger lists stay byte-identical
   (_FORMAT.md F7 lists the sanctioned pairs).

## Auditing compliance

The kit's markers are greppable in any session transcript. To see which rules fired and which
were skipped, search a transcript for: `TRIGGER:`, `GOAL:`, `FILES:`, `EST:`, `DONE-WHEN:`,
`BASELINE:`, `ASSUMPTION:`, `PLAN CHANGE:`, `CAUSE:`, `WORKAROUND:`, `ATTEMPT `, `ANCHOR:`,
`DETOUR(`, `RETURNING:`, `DECISION:`, `CONSTRAINT CHECK:`, `HANDLED FAILURES:`,
`NOTED (not done)`, `EDITED-UNVERIFIED`, `CANNOT-REPRODUCE`, `SIGNATURE UNVERIFIED`,
`P1:`–`P9:`, `C1:`–`C15:`, `D1:`–`D10:`, `V1:`–`V12:`, `E1:`–`E17:`, `S1:`–`S7:`, `RS1`–`RS5`.
Missing markers at the moments their triggers occurred are the non-compliance you should tune for.

## Upgrading the kit

Kit text in an installed project lives inside `<!-- BEGIN/END KIT CORE -->` and
`<!-- BEGIN/END KIT FOOTER -->` markers and as verbatim files under `docs/guardrails/`.
Upgrades are wholesale block/file swaps — see UPGRADE mode (U0–U4) at the bottom of MIGRATE.md —
which is exactly why project content must never be interleaved into kit blocks, and why kit
files must never be paraphrased. When editing kit content itself, follow
`docs/guardrails/_FORMAT.md`.

## Upgrade notes

- v1.0.1 — README only (no rule changes): POSIX install commands added beside PowerShell;
  pointers to the new companion docs `how-it-works.md` and `docs/improvement-roadmap.md`.
  Kit core and guardrail docs remain v1.0.
- v1.0 — initial release: 8 guardrail docs + CLAUDE.md core + MIGRATE.md, hardened by a
  13-reviewer adversarial pass (193 findings applied: observable routing events, single-source
  ownership with byte-identical trigger lists, canonical status vocabulary, cross-platform
  command pairs, TRAPS.md split, MIGRATE collision/idempotency/verbatim repairs).
