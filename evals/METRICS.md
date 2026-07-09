# Eval metrics — guardrails kit (roadmap B4)

Fixed task set under `evals/tasks/`, run per condition (with-kit / without-kit), per model
(opus / sonnet), **N >= 5 runs each** — models are stochastic; report mean with min/max spread,
never single runs. Runner: `evals/run.py`. Raw rows land in `evals/results/*.jsonl`.

| Metric | Definition | Source |
|---|---|---|
| task pass rate | acceptance script exit 0 after the session ends | per-task `## acceptance` block |
| marker-fire rate | auditor trigger checks FIRED / (FIRED + MISSED) | `scripts/audit-transcript.py` on the run's transcript |
| false-done rate | done-claim messages without VERIFY evidence / all done-claim messages | auditor "VERIFY evidence" check |
| cost per task | total_cost_usd from `claude -p --output-format json` | runner capture |
| turns per task | num_turns from the same JSON | runner capture |

Interpretation rules: a with-kit run only counts as kit-attributable if the transcript shows at
least one kit marker (`TRIGGER:` / V-lines) — otherwise the kit never engaged and the row is
labeled `kit-not-engaged` (an important result in itself: routing failed). Comparisons are
per-task, same model, same N. Publish results in README's model-compat section (roadmap A4).

The auditor's checks are heuristic (its own header says so): treat metric *deltas* between
conditions as the signal, not absolute values.
