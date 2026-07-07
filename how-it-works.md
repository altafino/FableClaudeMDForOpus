# How the Guardrails Kit Works

I've read the whole kit (it's docs-only, ~2,750 lines across 15 markdown files — no code to run, so I'm skipping the skill-generation part per your instruction and just explaining). Here's what this project is.

## TL;DR

**FableClaudeMDForOpus is a "Guardrails Kit" v1.0** — a portable `CLAUDE.md` + eight on-demand guardrail documents + a migration procedure. Its explicit goal (stated in the design record, [2026-07-04-guardrails-kit-design.md](docs/superpowers/specs/2026-07-04-guardrails-kit-design.md), authored by a Fable 5 session) is to make **Opus/Sonnet-class models operate as close to Fable-level as possible** inside Claude Code: fewer logic errors, fewer introduced bugs, fewer wasted tokens.

The core thesis: the gap between a frontier model and a mid-tier model is mostly *implicit judgment* — knowing when to re-read a file, when to sweep call sites after a rename, when a "done" claim is premature. Judgment can't be transferred through documentation, but **procedure can**. So the kit converts that judgment into explicit, event-triggered, mechanically checkable procedures.

## Architecture: lean core + routed playbooks

The trick that lets it be both extensive and cheap:

- **[CLAUDE.md](CLAUDE.md)** (~45 lines, always loaded) contains only three things: a **routing table**, **12 iron rules**, and **4 hard stops**. It's deliberately tiny because always-on compliance is roughly constant-sum — every extra always-loaded line taxes obedience to all the others.
- **The routing table** is the most engineered piece. Each row is an *observable event* ("a test you expected to pass failed", "about to write 'done'", "about to Read a 3rd file over 300 lines") that forces the model's *next tool call* to be a Read of the matching playbook, announced with a greppable `TRIGGER:` line. Rows are event-phrased, not topic-phrased, because weaker models route on what they literally experience, not on labels like "debugging."
- **Eight playbooks in `docs/guardrails/`**, each read only at its trigger moment:

| Doc | Fires when | Core content |
|---|---|---|
| [PLAN.md](docs/guardrails/PLAN.md) | task needs >2 file edits | P1–P9: premise check, prior-art grep, TASK block (GOAL/FILES/EST/DONE-WHEN/CONSTRAINTS), baseline run, YAGNI tests |
| [CODE.md](docs/guardrails/CODE.md) | first file write of a session | C1–C15: read-before-edit, generated-file/twin checks, signature pasting, and the **REFERENCE SWEEP** (RS1–RS5) after any contract change |
| [TRAPS.md](docs/guardrails/TRAPS.md) | via CODE.md C7 | lookup tables for classic reasoning traps: dates/DST, epoch units, mutation-vs-copy, async, floats/money, sort comparators, negative modulo, regex, `map(parseInt)`, closures in loops, boolean logic |
| [DEBUG.md](docs/guardrails/DEBUG.md) | any failure/traceback | D1–D10: reproduce-first, CAUSE line, failed-attempts ledger with an **ESCALATION LADDER**, and a red-flag table keyed on the model's *own rationalization phrases* ("probably unrelated", "test is probably flaky") |
| [VERIFY.md](docs/guardrails/VERIFY.md) | about to say "done"/commit | V1–V12 echo protocol: every claim must quote output that exists verbatim in a tool result *in the same turn*; only two legal statuses — `Verified: <cmd> -> <line>` or `UNVERIFIED — to confirm, run: <cmd>` |
| [EFFICIENCY.md](docs/guardrails/EFFICIENCY.md) | heavy reads / >50 search hits | paired rules: every "read less" rule (grep-then-ranged-read, never read lockfiles) has a "read enough" floor (never edit from a grep snippet) |
| [SESSION.md](docs/guardrails/SESSION.md) | compaction//resume/pause | the `docs/STATE.md` convention (9 fixed headers), same-turn update triggers, ANCHOR/DETOUR/DECISION ledger keywords for context-loss survival |
| [_FORMAT.md](docs/guardrails/_FORMAT.md) | editing the kit itself | F1–F15 authoring contracts: one-line rules, observable triggers only, hard budgets, every prohibition carries its replacement, greppable literal tokens |

- **[MIGRATE.md](MIGRATE.md)** is a 9-phase procedure (M0–M9 plus UPGRADE mode U0–U4) for retrofitting a project that already has a CLAUDE.md. Its governing principle is "migration is transport, not authorship": every original line gets a logged disposition (KEPT-VERBATIM / MOVED / SUPERSEDED-BY / …), kit files are installed by file copy and hash-verified — never retyped, because "paraphrase is where rules die." It's backup-first, user-checkpointed at Phase 5, and idempotent.

## The design principles that make it work

1. **Paste, don't check.** Every rule produces a transcript artifact (`TRIGGER:`, `CAUSE:`, `V3: PASS — <quoted output>`), so compliance is greppable in the transcript after the fact — the README even lists all the markers to audit for. "Ensure" invites assertion; "paste" is self-enforcing.
2. **Numbers, not judgment.** "250 lines", "2 failures", ">50 hits" — because weaker models comply with countable thresholds and rationalize their way around graded ones ("probably fine").
3. **Prohibitions carry replacements.** Every NEVER has its alternative on the same line, because a banned action with no named alternative gets taken anyway under pressure.
4. **Single-sourcing with sanctioned compression.** Each rule lives in exactly one file; a CLAUDE.md iron rule may compress a doc rule, but shared phrase lists must stay byte-identical (F7 enumerates the legal pairs).
5. **The kit polices its own rationalizations.** The DEBUG red-flag table is the most distinctive idea: it triggers on phrases the model itself is about to write ("should work now", "must be a caching issue") and maps each to a mandatory replacement action.

## Provenance and status

Per [STATE.md](docs/STATE.md) and the digests: the kit was built by a Fable 5 session from an 8-lens research pass (155 findings in [research-digest.md](docs/research-digest.md)), then hardened by a 13-reviewer adversarial review (193 findings in [review-digest.md](docs/review-digest.md); all blockers and majors applied). v1.0 is complete and committed; the remaining "Next" items are optional field-testing on a real Opus project and tuning to v1.1. The two digests and the spec are kit-source material, not part of what gets installed. Note the `## Facts` section still names a Windows path (`C:\Users\Laptop\...`) as the kit root — a leftover from where it was authored, not this Linux checkout.

One nice detail: **the repo is self-hosting** — its own CLAUDE.md *is* the installed kit, which is why I've been operating under these exact rules in this session.

## My honest read, as the model it's imitating

Since you asked whether it gets a model "to be like Fable 5, or nearby" — my assessment:

**What it captures well.** The failure modes it targets are real and well-chosen: editing from a grep snippet, hallucinated API signatures, missed callers after a rename, "should work now" without running anything, silently weakening a failing test, post-compaction amnesia, rationalizing a contradicting result. Those are exactly the behaviors that separate model tiers, and the mechanisms (transcript artifacts, countable thresholds, phrase-triggered tripwires) are the right enforcement shape for a model that can't be trusted to self-assess. The VERIFY echo protocol and the DEBUG escalation ladder in particular encode things a stronger model does silently.

**What it can't transfer.** Procedure substitutes for judgment only where the judgment is *recognizable as a checklist moment*. The residual gap is upstream of any trigger: choosing the right decomposition, noticing that a requirement is subtly self-contradictory, knowing which of 50 grep hits is the load-bearing one. The kit's own design record admits this ("judgment cannot be transferred through documentation"). It also carries a real cost: a mid-tier model following this faithfully spends meaningful tokens and turns on ceremony (TRIGGER lines, echo protocols, ledgers), and the constant-sum compliance problem it cites applies to itself — under pressure, the rules most likely to be dropped are exactly the ones guarding the moment of pressure. So "nearby Fable on bug-injection and false-completion rates" is a plausible outcome; "nearby Fable on architecture and problem-solving" is not what this can buy. The optional field-test in `## Next` — grep real transcripts for missing markers and tune — is the right way to find out how much it actually closes.
