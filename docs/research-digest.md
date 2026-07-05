# Research digest (auto-generated from workflow wf_f57b6575)

## CORE-CANDIDATES (proposed for always-loaded CLAUDE.md)
- **boundary-concrete-trace** [high, ->CODE] (reasoning-errors): Before writing any loop, slice, or index arithmetic with COMPUTED bounds (pagination, chunking, windowing, offsets — not plain full iteration): pick a concrete input of length 3 plus the empty and length-1 cases, and write the expected iterations/outputs as a one-line comment or scratch trace, e.g. `// len=10,size=3 -> [0:3][3:6][6:9][9:10] = 4 chunks; len=0 -> 0 chunks`. Then write the code and check it against the trace. If code and trace disagree, the trace wins — fix the code, not the comment.
- **unit-suffix-naming** [high, ->CODE] (reasoning-errors): Every numeric variable, parameter, or constant denoting time, size, money, or angle carries its unit as a name suffix: timeoutMs, ttlSec, maxBytes, amountCents, angleRad. When passing a bare numeric time/size argument to an API, state the API's unit in an inline comment at the call site (`setTimeout(fn, 30_000 /* ms */)`) and verify it against the API docs — never infer the unit from whether the value 'looks reasonable'.
- **truthiness-vs-explicit-null-check** [critical, ->CODE] (reasoning-errors): Truthiness guards are allowed only on values whose type is exactly boolean, or object/array references where 'missing' is the only falsy possibility. For any value that could legitimately be 0, '', false, NaN, or empty: compare explicitly — `x === undefined`, `x == null`, `x is None`, `len(xs) == 0`. JS defaults use `??`, never `||`, unless a comment states why falsy-but-present values must also be replaced. To distinguish 'key missing' from 'key present with null/None', use `in` / Object.hasOwn / a dict sentinel — never `.get()` truthiness.
- **edit-without-reading** [critical, ->CODE] (bug-injection): Never Edit a file you have not Read in this session. Before the first Edit of any file, Read at least the entire enclosing function/class plus the file's import block. A grep snippet is not a Read — Read the surrounding region before constructing old_string.
- **hallucinated-api-call** [critical, ->CODE] (bug-injection): Never call a function/method whose definition or signature you have not seen in this session. Before first use of any third-party or unfamiliar stdlib API taking 2+ arguments, paste its real signature into the transcript, obtained from one of: installed sources/type stubs (node_modules/**/*.d.ts; `python -c "import inspect, M; print(inspect.signature(M.fn))"`), LSP hover, or official docs. If you cannot produce the signature, do not write the call.
- **signature-change-without-callsite-sweep** [critical, ->CODE] (bug-injection): After changing any function/method/class signature, name, return type, default value, or raised/thrown exception: grep the symbol repo-wide (`grep -rn '<name>(' .` plus bare `<name>` for exports/references), paste the hit list as file:line, and for each hit either update it or state in one line why it is unaffected. A claim of 'no other callers' must show the actual grep command and its empty output.
- **write-tool-clobber** [critical, ->CODE] (bug-injection): Never use Write on an existing file unless you Read the complete file in this same turn and a full replacement is the explicit intent. If an Edit fails to match twice, re-Read the exact region and retry Edit with corrected old_string — do not fall back to Write. Before any intentional full rewrite, run `git diff -- <file>` and confirm no uncommitted changes would be destroyed.
- **no-whole-file-rewrite** [critical, ->CODE] (token-efficiency): Modify existing files with Edit and unique anchors, never Write. Write on an existing file is permitted only when more than half its lines change, and only immediately after a full Read of the current version in this session. If an Edit anchor fails twice, Read the exact range to get the current text — do not fall back to whole-file regeneration.
- **read-enclosing-scope-before-first-edit** [critical, ->CODE] (token-efficiency): Before your FIRST Edit to any file this session: Read at minimum the entire enclosing function or class of the edit site plus the file's import block. If the file is under 250 lines, Read all of it. Editing from a Grep snippet alone is forbidden. This read is mandatory even for 'obvious one-liners'.
- **post-change-reference-sweep** [critical, ->CODE] (token-efficiency): After changing any function signature, renaming any symbol, or changing any config key, route, or schema field: Grep the OLD identifier repo-wide and show the result. For every hit, either fix it or state in one line why it is unaffected. A zero-hit result must be shown in the transcript, not asserted. Do not proceed to the next task step until every hit is dispositioned.
- **no-edits-from-stale-memory** [critical, ->CODE] (context-degradation): Never construct an Edit old_string or a Write body from memory. If you have not Read the target region within the last 10 messages, or ANY edit touched the file since your last Read, Read the region again first. If an Edit fails with 'string not found', the only permitted next action on that file is a Read of the target region — never a guessed retry, never a whole-file Write.
- **never-requires-replacement** [high, ->CODE] (instruction-format): Format contract: every NEVER/Don't line contains ` -> instead: ` followed by the exact replacement command or action, on the same line. A prohibition without a replacement is an invalid rule — do not add it; rewrite it.
- **minimal-diff-no-drive-bys** [critical, ->CODE] (process-failures): Change only lines the task requires. Forbidden unless explicitly requested: renames, reformatting, import reordering, comment rewrites, refactoring adjacent code, style 'improvements'. If you notice something worth fixing outside scope, do NOT touch it — append `NOTED (not done): <thing> <file:line>` to your final summary instead. Before finishing, re-read the diff: every changed hunk must map to the task; revert any hunk that does not.
- **call-site-sweep-after-contract-change** [critical, ->CODE] (process-failures): After changing any function signature, exported symbol name, return shape, config key, or CLI flag: grep the ENTIRE repo for the old symbol (and the new one), paste the list of hits, and for each hit either update it or dismiss it with a stated reason ('string in changelog, intentional'). Renames additionally require a grep for string-literal references (logs, templates, reflection, docs). Do not proceed to the next task step until every hit is accounted for.
- **overwrite-before-backup** [critical, ->MIGRATE] (migration-risks): MIGRATION IRON RULE: before your first Edit/Write to ANY existing instruction file, create a frozen snapshot: `cp CLAUDE.md CLAUDE.md.pre-migration-<YYYYMMDD-HHMM>` (PowerShell: `Copy-Item`), one per file touched; if the repo is clean, also `git commit` the snapshot. All later references to 'original line N' MUST be resolved by Reading the snapshot file, never from memory. Never delete or edit the snapshot; the user deletes it after accepting the migration.
- **same-turn-constraint-capture** [critical, ->SESSION] (context-degradation): The moment the user states any prohibition, scope limit, preference, or behavior correction ('don't touch X', 'keep Y as-is', 'only change Z', 'stop doing W'), append it VERBATIM as a bullet under `## Constraints` in docs/STATE.md before taking any other action that turn. If the user corrects the same behavior a second time, tag the bullet `[RECURRING]` and re-read the `## Constraints` block before every file edit for the rest of the session.
- **post-compaction-recovery-procedure** [critical, ->SESSION] (context-degradation): After any compaction (the transcript begins with a summary block): before ANY file-modifying tool call, (1) Read docs/STATE.md in full; (2) run `git status` and `git diff --stat`; (3) restate in one line the Goal and the current Next step. Treat every compaction-summary claim about file contents or completed work as UNVERIFIED until confirmed by Read/git evidence.
- **anchor-line-before-major-steps** [high, ->SESSION] (context-degradation): Before each new major step (starting a new todo/phase, or resuming after a detour), write one line: `ANCHOR: goal=<original request in <=15 words> | this step serves it by <reason>`. If you cannot truthfully complete the line, stop, re-read STATE.md `## Goal`, and either re-plan or ask the user.
- **routing-table-event-phrased-triggers** [critical, ->SESSION] (instruction-format): ## Routing — the moment X happens, Read the doc BEFORE your next tool call | The moment you... | Read | |---|---| | start any task needing >2 file edits or touching >1 component | docs/guardrails/PLAN.md | | are about to make your first Edit/Write of this session | docs/guardrails/CODE.md | | see a failing test, non-zero exit, traceback, or output that surprised you | docs/guardrails/DEBUG.md | | are about to write "done", "fixed", "works", or run git commit | docs/guardrails/VERIFY.md | | notice context >50% used, or are about to Read a 3rd large file | docs/guardrails/EFFICIENCY.md | | return from compaction or /resume, or can't recall how the session started | docs/guardrails/SESSION.md | | are unsure which row applies | docs/guardrails/PLAN.md |
- **route-then-announce-contract** [critical, ->SESSION] (instruction-format): When any routing row matches: write one line `TRIGGER: <event> -> <doc>` and make your NEXT tool call Read on that doc. If you already Read that doc since the last compaction, write `TRIGGER: <event> -> <doc> (cached)` and obey its checklist from memory. Never act on a matched trigger without one of these two lines.
- **literal-anchor-tokens** [high, ->SESSION] (instruction-format): Format contract: every rule names its exact command, file path, or number (`git diff --stat`, `docs/STATE.md`, `>=2 call sites`) — never only an abstraction. If a rule contains no greppable literal token, rewrite it until it does or move it out of the kit.
- **post-compaction-rearm-line** [critical, ->SESSION] (instruction-format): After compaction or /resume: Read docs/STATE.md, then re-run the routing table against your current activity. Docs read before compaction no longer count as read — `(cached)` is invalid until you Read the doc again. (This is the last line of CLAUDE.md; it stays last.)
- **no-claim-without-fresh-output** [critical, ->VERIFY] (false-completion): A claim that anything is done, fixed, working, or passing MUST be immediately preceded in the same turn by fresh command output demonstrating it. No output in this turn = you may only report the edit: 'Edited X; not yet verified.'
- **forbidden-hedge-phrases** [critical, ->VERIFY] (false-completion): NEVER write 'should work', 'should fix', 'likely resolves', 'ought to now'. Replace with exactly one of: (a) 'Verified: <command> → <result line>' or (b) 'UNVERIFIED — to confirm, run: <command>'. There is no third option.
- **test-integrity-absolute** [critical, ->VERIFY] (false-completion): NEVER make a failing test pass by changing the test: no weakened asserts, .skip/xfail markers, raised tolerances or timeouts, deleted cases, '|| true', or --passWithNoTests. If you believe the TEST is wrong, stop and present the assertion, why it is wrong, and the proposed expectation — then get explicit approval. Every test-file edit made during a fix must be called out with a before/after diff of the assertion.
- **grep-before-ranged-read** [medium, ->EFFICIENCY] (token-efficiency): To locate a specific symbol, function, or config key: Grep for it with -n first, then Read only offset/limit covering the hit ±40 lines. Full-file Read is allowed only when (a) the file is under 250 lines, or (b) you are about to make edits at 3+ scattered locations in it. Never Read a file >400 lines without a prior Grep that failed to localize the target.
- **no-redundant-context-refresh** [medium, ->EFFICIENCY] (token-efficiency): Before any Read or Grep, check the transcript: if the same file/pattern was read or searched this session AND nothing in its scope has changed since (by you or a command you ran), reuse the earlier result — do not re-run. After your own Edit, never Read the file to confirm the edit applied: Edit fails loudly on mismatch; confirm behavior with a compile/test command instead. Re-reads are permitted only for the specific ranges you edited when you need updated line numbers.
- **batch-independent-tool-calls** [medium, ->EFFICIENCY] (token-efficiency): When your next steps involve 2 or more tool calls where no call's input depends on another's output (multiple Reads, several Greps, git status + git diff + git log), issue them ALL in a single message. Serialize only when an output genuinely determines the next input, and say which output you are waiting for.
- **narration-budget** [medium, ->EFFICIENCY] (token-efficiency): Between tool calls, write at most ONE short line, and only when it records a finding or a decision (e.g. 'config comes from env vars, not the file — checking env parsing'). Write nothing before a tool call whose purpose is obvious from its parameters. Never announce success of a tool call the user can see succeeded.
- **no-prose-quote-back** [medium, ->EFFICIENCY] (token-efficiency): Never restate or summarize file contents you just read unless the user asked for an explanation. Reference code as path:line. Quote at most 5 lines, and only when the exact text IS the finding (the buggy expression, the signature being changed).
- **wide-scan-delegation-threshold** [high, ->EFFICIENCY] (token-efficiency): If answering requires opening more than 5 files you cannot name in advance, or any repo-wide sweep (audit, migration, find-all-usages across modules, dependency survey), delegate it to a subagent and act only on its returned conclusions. Do not begin the sweep in main context 'just to get started'.
- **one-line-imperative-no-prose** [high, ->EFFICIENCY] (instruction-format): Format contract (kit authoring): every rule is one line, <=20 words, and starts with either an imperative verb or a trigger clause (`When/Before/After <observable event>:`). No paragraphs. No hedges (usually/consider/try/generally). A rule that needs two sentences belongs in a guardrail doc, not CLAUDE.md.
- **claude-md-rule-budget-cap** [critical, ->EFFICIENCY] (instruction-format): CLAUDE.md hard budget: <=15 iron rules, 1 routing table, <=50 lines total. To add a rule over budget, delete or demote an existing rule to a guardrail doc in the same edit. Never merge two rules into one line to dodge the cap.
- **caps-emphasis-budget** [high, ->EFFICIENCY] (instruction-format): Caps budget: NEVER/ALWAYS/MUST may appear on at most 5 lines in CLAUDE.md, reserved for irreversible damage (data loss, killed processes, pushed history, secrets). Every other rule is a plain imperative. Adding a 6th caps line requires downgrading one.
- **eight-word-why-clause** [medium, ->EFFICIENCY] (instruction-format): Format contract: every iron rule in CLAUDE.md ends with a parenthesized reason, <=8 words, naming the concrete harm — e.g. `(kills Claude Code itself)`, `(callers break silently)`, `(history loss is unrecoverable)`. No multi-sentence rationale in CLAUDE.md; long rationale goes below the divider of the owning guardrail doc.
- **single-source-pointers-only** [high, ->EFFICIENCY] (instruction-format): Format contract: a rule lives in exactly one file. CLAUDE.md never summarizes or previews guardrail-doc content — it only routes to it. If the same rule appears in two kit files, delete the copy outside its home doc in the same edit.
- **first-and-last-block-placement** [medium, ->EFFICIENCY] (instruction-format): CLAUDE.md layout: the routing table is the FIRST content block; the <=5 NEVER lines plus the post-compaction re-arm line are the LAST block; everything in between must be droppable without serious harm. Never place an iron rule in the middle third of the file.
- **controlled-tool-verb-vocabulary** [medium, ->EFFICIENCY] (instruction-format): Format contract: kit verbs are tool names — Read, Grep, Edit, Write, Run (Bash). Never write see/consult/check/refer-to/review when a tool call is meant. Every doc reference is the full literal path `docs/guardrails/<NAME>.md`, never 'the <name> guide'.
- **repro-first-fix-loop** [critical, ->DEBUG] (false-completion): On receiving any bug report: FIRST write down and run the exact reproduction command; paste its failing output. The bug is 'fixed' ONLY when that same command, unmodified, is re-run and passes — paste that too. If you cannot reproduce, say 'cannot reproduce' and stop; never fix blind.
- **narrowest-failing-test-loop** [high, ->DEBUG] (token-efficiency): While a specific test fails, re-run ONLY that test (exact node id / -t filter / single file, with -x or equivalent). Run the full suite at most twice per task: optionally once at the start for a baseline, and once at the end before claiming done. Running the full suite inside the fix loop is forbidden.
- **premise-check-before-edit** [critical, ->DEBUG] (process-failures): When the user names a bug's location or cause ('the bug is in X', 'X is broken because Z'), treat it as a hypothesis, not a fact. Before editing: reproduce the failure or trace the bad value to the named location, and cite file:line evidence. If the evidence points elsewhere, report the actual location with the evidence and fix there. Never edit code at the user-named location just to make their framing true — correct code is never modified to compensate for a bug that lives elsewhere.
- **never-silence-the-check** [critical, ->DEBUG] (process-failures): Never make a failure disappear by weakening its detector. Forbidden without explicit user approval of the exact suppression: deleting or skipping tests, loosening assertions, `as any` / `# type: ignore` / eslint-disable, widening catch blocks, lowering coverage or lint thresholds. If you believe the check itself is wrong, say so with evidence and propose the change — apply only after approval, and leave a comment at the suppression naming the reason.
- **no-edit-before-task-block** [critical, ->PLAN] (process-failures): Before the first Edit/Write of any task expected to touch more than 1 file or ~20 lines, post a TASK block: GOAL: <one sentence, your own words — not a paraphrase of the user's words if the code contradicts them> FILES: <exact paths you will change> DONE-WHEN: <a command or observable check> CONSTRAINTS: <verbatim every 'don't / keep / only' the user stated> If you cannot fill FILES yet, you have not investigated enough — investigate, then post the block. Any later edit to a file not in FILES requires first appending it to FILES with a one-line reason.
- **ask-vs-decide-criterion** [high, ->PLAN] (process-failures): Ask a clarifying question (one batched message, concrete options) ONLY when BOTH hold: (a) two reasonable readings of the request produce materially different diffs — different data model, user-visible behavior, or anything irreversible (deletion, migration, external side effects); AND (b) neither code, tests, nor docs disambiguate after one search. In every other case: decide, write `ASSUMPTION: <choice> because <evidence>` in your reply, and proceed. Never ask a question the repo answers, and never proceed on an unstated load-bearing assumption.

## PLAN (10 findings)

### named-target-first [medium | on-demand | token-efficiency]
TRIGGER: The task statement or pasted error contains an explicit file path, symbol name, or line number.
MECHANISM: When the task already names the exact file, function, or stack-trace line, weaker models still open with generic reconnaissance — ls the repo, read the README, glob for structure — because 'orient first' is a learned reflex. The named target makes all of that waste: the fastest and cheapest first move is opening the named location.
EXAMPLE: User: 'fix the off-by-one in src/pager.ts line 88.' Model runs Glob **/*.ts, reads package.json and README, and reads two other files before finally opening pager.ts.
RULE:
If the task names a file, function, error line, or stack frame: your FIRST tool call goes to that location (Grep the symbol or ranged Read around the line). Broaden exploration only after that read shows the premise is wrong or the cause lies elsewhere — and say what the read disproved before widening.

### plan-invalidation-must-update-plan [high | on-demand | context-degradation]
TRIGGER: The moment any observation (file contents, command output, error) contradicts an assumption the current plan depends on.
MECHANISM: Plan rigidity: weaker models treat a written plan as a checklist to complete rather than a prediction to maintain. When step 2 reveals that the assumption behind steps 4-6 is false, Fable re-plans; weaker models push on and execute steps whose premise they have already personally disproven, because nothing forces reconciliation between new evidence and the old plan.
EXAMPLE: Plan assumes 'config is loaded from config.yaml, so steps 4-6 add keys there'. Step 2 reveals the service actually reads everything from environment variables and config.yaml is dead code. The model still executes steps 4-6, carefully adding keys to a file nothing reads, and reports success.
RULE:
When any discovered fact contradicts an assumption of the active plan, STOP executing before the next step. Write `PLAN CHANGE: assumed <X>; actually <Y> (evidence: <what showed it>) -> revised steps: <...>` and update STATE.md `## Next` in the same turn. Executing any plan step whose premise you have observed to be false is forbidden, even if the step is already written down.

### plan-question-slots [high | on-demand | instruction-format]
TRIGGER: Starting any non-trivial task (>2 file edits or >1 component), before the first Edit/Write (top of PLAN.md).
MECHANISM: Statements of intent can be pattern-completed with boilerplate; questions with mandatory one-line answer slots force generation of task-specific content, and an empty slot is visible non-compliance. Weaker models skip pre-work analysis (duplicate-search, smallest-diff thinking, verification planning) unless a slot exists that cannot be filled without doing the work — Q2 in particular cannot be answered honestly without actually running a Grep.
EXAMPLE: Model starts implementing a date-formatting helper before checking the codebase; a utils/dates.ts with the identical function already exists. PLAN slot 'Q2: Which existing code already does something similar? (paste path, or the Grep you ran that found none)' forces the search that finds it.
RULE:
Before your first Edit, answer these in your reply — one line each, no boilerplate:
Q1: The requested behavior change, in one sentence.
Q2: Which existing code already does something similar? (paste the path, or the exact Grep you ran that found none)
Q3: The smallest diff that achieves Q1 (files + rough line counts).
Q4: The exact command you will run afterward to prove it worked.

### no-edit-before-task-block [critical | core | process-failures]
TRIGGER: Before the first Edit/Write of any task expected to touch >1 file or >20 lines
MECHANISM: Weaker models pattern-match the request to a familiar solution shape and start editing the first plausible file. A frontier model forms an implicit plan; a weaker model must be forced to externalize it, because only an externalized plan lets the model itself (and the user) detect that it is about to edit the wrong place. Combined with sunk-cost continuation, an unplanned wrong start rarely gets backed out.
EXAMPLE: Asked to 'make the export include archived items', the model edits the UI button's click handler to change filtering — but filtering happens server-side in the query builder. Forty minutes of edits to the wrong layer before the mistake surfaces.
RULE:
Before the first Edit/Write of any task expected to touch more than 1 file or ~20 lines, post a TASK block:
GOAL: <one sentence, your own words — not a paraphrase of the user's words if the code contradicts them>
FILES: <exact paths you will change>
DONE-WHEN: <a command or observable check>
CONSTRAINTS: <verbatim every 'don't / keep / only' the user stated>
If you cannot fill FILES yet, you have not investigated enough — investigate, then post the block. Any later edit to a file not in FILES requires first appending it to FILES with a one-line reason.

### xy-problem-mechanism-check [high | on-demand | process-failures]
TRIGGER: A request contains both a prescribed fix and the symptom motivating it
MECHANISM: Weaker models execute the literal request even when it cannot achieve the user's stated goal. They lack the reflex to check the requested mechanism against the motivating symptom, so they faithfully build the wrong thing and the underlying problem persists — the classic XY problem, executed diligently.
EXAMPLE: User: 'Add a retry wrapper around fetchUsers(), it keeps failing.' The failures are 401s from an expired token; retrying returns 401 three times, slower. The real fix is token refresh. The model ships a polished retry wrapper and the outage continues.
RULE:
When the request names BOTH a mechanism ('add X') AND a motivating symptom ('because Y keeps happening'): before building X, find the failing path and confirm X actually intercepts Y (read the error, log, or issue that motivated the request). If it does not, present that finding and the alternative in 5 lines or fewer BEFORE implementing anything. If the request names only a mechanism with no symptom, implement it as asked — do not invent a deeper problem to solve.

### decompose-over-threshold [high | on-demand | process-failures]
TRIGGER: Task plan exceeds 3 files or ~150 lines of change
MECHANISM: Weaker models hold less of a change in working memory, so a monolithic multi-file change accumulates cross-layer inconsistencies that surface only at the end — where debugging is hardest because everything changed at once. Small steps with per-step checks convert one hard search over a giant diff into several trivial ones.
EXAMPLE: Implements schema change + API change + UI change in one pass. The final build shows 14 type errors across three layers; untangling causal errors from cascade errors takes longer than the feature itself.
RULE:
If the TASK block's FILES list exceeds 3 files or the change will exceed ~150 lines: split the work into numbered steps in dependency order, each ending with a named check (build, specific test file, or command). Run the check and show its output BEFORE starting the next step. Never carry more than one failing step at a time, and never present one giant unverified diff for multi-part work.

### baseline-before-first-edit [high | on-demand | process-failures]
TRIGGER: Before the first edit on any task in a repo with runnable tests/build/lint
MECHANISM: Without a recorded baseline, weaker models attribute pre-existing failures to their own change (and burn the session 'fixing' out-of-scope breakage) or attribute their own new breakage to pre-existing flakiness (and ship it). They guess instead of knowing, because knowing requires a step they were never told to take.
EXAMPLE: Repo has 2 tests failing on main. After the change, 3 fail. The model, comparing against an imagined green baseline, spends hours fixing all 3 — two are unrelated to the task — then claims the third 'was probably already failing'.
RULE:
Before your first edit on any task in a repo with a runnable check (tests/build/lint), run the relevant check once and record: `BASELINE: <pass | N failures: names>`. If the baseline is already failing, report that before starting work. All later verification compares against this BASELINE line — the question 'was that already broken?' must be answered from the record, never guessed.

### ask-vs-decide-criterion [high | core | process-failures]
TRIGGER: An ambiguity in the request is discovered, before or during implementation
MECHANISM: Weaker models fail on both sides of ambiguity: they ask round-trip-wasting questions the repo already answers (file locations, naming), and they silently invent load-bearing decisions (deletion semantics, schema shapes) that should have been asked — because they cannot gauge which ambiguities materially change the diff. An explicit two-condition test replaces that missing judgment.
EXAMPLE: Silently decides 'remove the user' means hard-delete and writes a DELETE cascade; the product required soft-delete for audit compliance. In the same session it stops to ask 'should the helper go in utils/ or lib/?' when the repo has 30 helpers in utils/.
RULE:
Ask a clarifying question (one batched message, concrete options) ONLY when BOTH hold: (a) two reasonable readings of the request produce materially different diffs — different data model, user-visible behavior, or anything irreversible (deletion, migration, external side effects); AND (b) neither code, tests, nor docs disambiguate after one search. In every other case: decide, write `ASSUMPTION: <choice> because <evidence>` in your reply, and proceed. Never ask a question the repo answers, and never proceed on an unstated load-bearing assumption.

### discovered-scope-stop-rule [high | on-demand | process-failures]
TRIGGER: Mid-task discovery that the change is much larger or of a different kind than planned
MECHANISM: Sunk-cost continuation: once editing, weaker models absorb every newly discovered requirement into the current diff rather than stopping — or worse, hack around the discovered requirement to keep the diff looking small. Admitting the estimate was wrong is not a move in their repertoire unless a rule makes it one.
EXAMPLE: 'Add a phone field to the profile form' turns out to require a DB migration, API versioning, and cache invalidation. The model hand-edits the model class without a migration to keep the change 'small', and deploy breaks.
RULE:
If mid-task the real change exceeds ~2x your TASK block estimate, or requires a kind of change not in the plan (schema migration, new dependency, API contract change, touching another service), STOP before making that change. Report the discovered scope in 5 lines or fewer with options (full change / minimal safe subset / abort) and wait for direction. Do not silently absorb the expansion into the diff, and do not hack around the requirement to preserve the original estimate.

### disambiguate-symbol-before-edit [medium | on-demand | process-failures]
TRIGGER: A search for the task's named target returns more than one definition
MECHANISM: First-hit anchoring: weak models take the first search result as the referent. With common names (render, process, save, config) they confidently modify the wrong definition, then 'verify' by re-reading their own edit rather than by exercising the failing path.
EXAMPLE: 'Fix the validation in save()' — the repo has save() on three models. The model edits the first grep hit (the wrong model), reports done; the bug persists and the wrong model gained an unwanted validation rule.
RULE:
When the target named in the task (function, file, component) matches more than one definition in the repo: list all candidates with paths, pick by evidence (which one lies on the failing or relevant execution path — trace an import or stack frame), and state the choice in one line before editing. Editing the first search hit without this check is forbidden.

## CODE (51 findings)

### boundary-concrete-trace [high | core | reasoning-errors]
TRIGGER: Writing any loop/slice/range where a bound is computed from another value (length, page size, offset), including pagination, chunking, windows, and substring math.
MECHANISM: Weaker models choose loop/slice bounds by pattern-matching to 'what a loop like this usually looks like' instead of simulating execution. The choice between < and <=, or end and end-1, is invisible to pattern-matching because both variants are common in training data. Concrete instantiation converts the abstract choice into small-number arithmetic, which mid-tier models do reliably.
EXAMPLE: Chunking: `for i in range(0, len(data) // size): chunk = data[i*size:(i+1)*size]` silently drops the final partial chunk — 10 items at size 3 yields 3 chunks instead of 4. Or `for (i = 0; i <= arr.length; i++)` reading one past the end.
RULE:
Before writing any loop, slice, or index arithmetic with COMPUTED bounds (pagination, chunking, windowing, offsets — not plain full iteration): pick a concrete input of length 3 plus the empty and length-1 cases, and write the expected iterations/outputs as a one-line comment or scratch trace, e.g. `// len=10,size=3 -> [0:3][3:6][6:9][9:10] = 4 chunks; len=0 -> 0 chunks`. Then write the code and check it against the trace. If code and trace disagree, the trace wins — fix the code, not the comment.

### range-inclusivity-annotation [high | on-demand | reasoning-errors]
TRIGGER: Writing any range endpoint, date-range filter, or random-integer call.
MECHANISM: Models carry one internal convention (usually half-open, from Python/C loops) and apply it uniformly, but real APIs are split: SQL BETWEEN and Python randint are inclusive-inclusive, slices and randrange are half-open. Both readings produce plausible-looking code, so the error is invisible without explicitly stating the convention.
EXAMPLE: SQL `WHERE ts BETWEEN '2024-01-01' AND '2024-01-31'` on a timestamp column silently drops every row after midnight on Jan 31 — a month-end reporting bug that survives all mid-month testing. Or `random.randint(0, len(xs))` raising IndexError once in n+1 runs.
RULE:
When writing any range — loop bounds, slice, date filter, SQL BETWEEN, random-int call — annotate inclusivity in interval notation as a comment (`[start, end)`) and verify EACH endpoint against the API's documented convention. Known rows: Python range/slice = [a,b); random.randint = [a,b]; random.randrange = [a,b); SQL BETWEEN = [a,b]; JS/Python Math.random()/random() = [0,1). Date filters on timestamp columns: always `ts >= day AND ts < nextDay`; never `<= endOfDay` — the last day's tail goes missing.

### boolean-negation-truth-table [high | on-demand | reasoning-errors]
TRIGGER: Writing or editing a condition that contains `!`/`not` combined with a binary boolean operator, or any condition with 3+ clauses.
MECHANISM: Negation does not distribute correctly in a weaker model's head: !(a && b) and !a && !b both 'feel like the negation' of the requirement, and && binding tighter than || is silently ignored when the sentence being translated uses English 'or'. The written condition reads fluently either way, so review-by-eyeball passes.
EXAMPLE: Requirement 'skip items that are hidden or archived' becomes `if (!item.hidden || !item.archived) process(item)` — which processes every item that isn't BOTH hidden and archived, i.e. almost everything.
RULE:
For any condition containing a negation combined with &&/|| (or `not` with and/or), or any condition with 3+ clauses: enumerate the input combinations in a scratch truth table (max 4 rows for two variables) with the intended outcome per row, BEFORE writing the expression; then check the written expression against every row. When mixing && and || in one expression, parenthesize every group — never rely on precedence. Prefer naming the positive concept first: `const isVisible = !item.hidden && !item.archived; if (isVisible) ...`.

### negatively-named-flag-inversion [medium | on-demand | reasoning-errors]
TRIGGER: Writing an `if`/ternary on a negatively named variable or config key.
MECHANISM: Branching on a negatively named flag (`noCache`, `disabled`, `exclude`) requires holding two inversions simultaneously — the name's negation and the branch's meaning. Mid-tier models drop one inversion, especially when the flag originates in config they didn't write.
EXAMPLE: `if (config.noCache) cache.set(key, value)` — caching exactly and only when caching was explicitly disabled. Compiles, runs, and passes any test that doesn't toggle the flag.
RULE:
Before branching on any identifier whose name contains a negation (no*, not*, dis*, un*, exclude*, skip*, hidden, disabled): write a one-line comment stating what the TRUE branch does in positive words (`// noCache=true => do NOT store`), then verify both branch bodies against that sentence. Where you control the code, introduce a positively named local first: `const cacheEnabled = !config.noCache;` and branch on that instead.

### datetime-arithmetic-trap-table [critical | on-demand | reasoning-errors]
TRIGGER: Writing any code that adds/subtracts time, formats or parses dates, or computes day/month/year boundaries.
MECHANISM: Date arithmetic looks like integer arithmetic, so models apply integer rules (add 86400 for a day, month+1 for next month) to a domain where those rules break on DST transitions, 31-day months, and year boundaries. The happy path works for ~360 days a year, so the bug is invisible in normal testing and corrupts data silently when it fires.
EXAMPLE: `new Date(ts + 24*3600*1000)` for 'same time tomorrow' is one hour off across a DST change, shifting a scheduled job across a day boundary. `d.setMonth(d.getMonth()+1)` on Jan 31 lands on Mar 2/3. `format(d, 'YYYY-MM-dd')` prints the wrong year for dates around New Year (ISO week-year).
RULE:
Date/time trap table — consult before ANY date arithmetic:
- Never add 86400s/24h for 'next day' where local time matters — use the library's addDays / timedelta(days=1) on a date (not a timestamp) / tz-aware arithmetic.
- Month arithmetic overflows on day-31 dates: before writing it, state in a comment what Jan 31 + 1 month must produce (Feb 28/29? error?) and pick the API accordingly.
- JS: Date months are 0-indexed (`new Date(2024, 0, 15)` = Jan 15); getDay() = weekday, getDate() = day-of-month.
- JS parsing: `new Date('2024-01-15')` = UTC midnight, `new Date(2024, 0, 15)` = LOCAL midnight — mixing the two shifts dates by one day in negative-offset timezones.
- Format strings: yyyy, never YYYY (YYYY = ISO week-year, wrong around New Year).
- Python: never compare naive and aware datetimes; datetime.utcnow() is naive — use datetime.now(timezone.utc).
- Every 'start/end of day' computation names its timezone in a comment.
After writing date arithmetic, mentally trace three concrete dates: Jan 31, Dec 31, and a DST transition for the relevant zone (e.g. 2024-03-10 US).

### epoch-unit-magnitude-check [high | on-demand | reasoning-errors]
TRIGGER: Any variable that holds, receives, or compares an epoch timestamp; any *1000 or /1000 on a time value.
MECHANISM: Seconds and milliseconds are both 'a timestamp'; models pass whichever unit the surrounding code happens to hold, and nothing crashes — the date is just in 1970 or 56,000 AD, or an expiry comparison silently always/never fires. There is no type error to catch it, so the model needs an explicit checking ritual.
EXAMPLE: Storing `Date.now()` (ms) into a JWT `exp` claim (spec says seconds) produces a token that effectively never expires. `new Date(unixSeconds)` renders every record as January 1970.
RULE:
Epoch discipline: before assigning, comparing, or converting any epoch timestamp, verify its unit by digit count — 10 digits = seconds, 13 = milliseconds, 16 = microseconds, 19 = nanoseconds — and encode the unit in the variable name (expiresAtSec, createdAtMs). Known rows: JS Date.now()/getTime() = ms; new Date(n) expects ms; Python time.time() and Unix time = s; JWT exp/iat = s; Java System.currentTimeMillis() = ms; Go Unix() = s, UnixMilli() = ms. Every *1000 or /1000 conversion gets an inline comment naming both units (`expMs / 1000 /* ms -> s for JWT */`).

### unit-suffix-naming [high | core | reasoning-errors]
TRIGGER: Declaring any time/size/money/angle number, or passing one to an API.
MECHANISM: Unit information lives only in API documentation, not in the code the model reads; with no carrier for the unit in the code itself, the model re-guesses the unit at every use site and regresses to the statistically most common unit in its training data (often wrong for this specific API).
EXAMPLE: `setTimeout(fn, 30)` intending 30 seconds (fires in 30ms); passing `5` to an HTTP client `timeout` that takes milliseconds — every request instantly times out; treating a bytes-denominated `maxSize` as KB and setting a limit 1000x too small.
RULE:
Every numeric variable, parameter, or constant denoting time, size, money, or angle carries its unit as a name suffix: timeoutMs, ttlSec, maxBytes, amountCents, angleRad. When passing a bare numeric time/size argument to an API, state the API's unit in an inline comment at the call site (`setTimeout(fn, 30_000 /* ms */)`) and verify it against the API docs — never infer the unit from whether the value 'looks reasonable'.

### truthiness-vs-explicit-null-check [critical | core | reasoning-errors]
TRIGGER: Writing any truthiness check or `||`-default on a value whose type admits 0, '', false, or empty.
MECHANISM: `if (!x)` / `if not x` is the single most frequent guard pattern in training data, so weaker models emit it reflexively. It conflates 'absent' with legitimate falsy values (0, '', false, empty list). The bug only fires on edge-case data, so it survives typical testing and ships.
EXAMPLE: `if (!user.age) throw new MissingFieldError('age')` rejects age 0. `discount = input.discount || DEFAULT` overrides an explicit 0% discount with the default. Python `if not results:` treats 'query succeeded with zero rows' identically to 'query failed and returned None', masking the failure.
RULE:
Truthiness guards are allowed only on values whose type is exactly boolean, or object/array references where 'missing' is the only falsy possibility. For any value that could legitimately be 0, '', false, NaN, or empty: compare explicitly — `x === undefined`, `x == null`, `x is None`, `len(xs) == 0`. JS defaults use `??`, never `||`, unless a comment states why falsy-but-present values must also be replaced. To distinguish 'key missing' from 'key present with null/None', use `in` / Object.hasOwn / a dict sentinel — never `.get()` truthiness.

### mutation-vs-copy-trap-table [critical | on-demand | reasoning-errors]
TRIGGER: Calling any sort/reverse/splice-family method; mutating a function parameter or shared object; writing a Python default argument.
MECHANISM: Models track values, not object identity. Whether a method mutates in place or returns a copy is a memorized per-API fact, and mid-tier models blend the conventions (expecting sorted()-like behavior from .sort() or vice versa). Aliasing bugs manifest as action-at-a-distance far from the write site, making them the most expensive class to debug.
EXAMPLE: `const top = users.sort(byScore).slice(0, 10)` silently reorders the caller's `users` array that a rendering component iterates elsewhere. `def f(x, acc=[])` accumulates across calls. `grid = [[0]*3]*3; grid[0][0] = 1` sets the whole column because rows are aliased.
RULE:
Mutation trap table:
- JS mutating: sort, reverse, splice, push/pop/shift/unshift, fill, copyWithin. Copying equivalents: toSorted, toReversed, toSpliced, slice, concat, spread.
- Python: list.sort()/list.reverse() mutate AND return None; sorted()/reversed() return new. `x = y` never copies. `y[:]`, list(y), dict(y), .copy() are SHALLOW — nested structures need copy.deepcopy.
- Python mutable default args (`def f(x, acc=[])`) persist across calls — use `acc=None` sentinel.
- `[[0]*n]*m` aliases every row — use a comprehension.
- JSON round-trip 'deep copy' drops Dates/undefined/functions — use structuredClone in JS.
Procedure: before calling any method in this table, or mutating any object that arrived as a parameter or was read from shared/module-level state, write one line stating who else holds a reference to it; if anyone might, copy first. If unsure whether a method mutates, check this table or run a one-line REPL probe — never guess.

### async-await-checklist [critical | on-demand | reasoning-errors]
TRIGGER: Writing or editing any function containing async/await, or calling any function whose name implies IO (fetch, save, load, query, send).
MECHANISM: Async correctness requires simulating an interleaved timeline; weaker models evaluate code as if it ran sequentially. A missing `await` yields a Promise object — truthy, non-crashing, and log-silent — so nothing in the immediate feedback loop surfaces the error, and the model's sequential mental model confirms the code 'looks right'.
EXAMPLE: `if (userExists(id))` where userExists is async — always truthy, duplicate users created. `items.forEach(async i => await save(i)); return 'done'` returns before any save completes. `return doWork()` (no await) inside try/catch lets the rejection escape the catch block.
RULE:
Async checklist — apply to every async call you write:
1. Every call to an async function is awaited, returned WITH `await` if inside try/catch, chained with .then, or explicitly `void`-ed with a `// fire-and-forget` comment. After editing async code, grep the file for each async function name NOT preceded by await/return/void and justify every hit.
2. Never pass an async callback to forEach/filter/reduce. Use `for..of` + await (sequential) or `await Promise.all(items.map(...))` (parallel) — and write one line stating which of the two the task needs and why.
3. Never branch on an un-awaited call: `if (asyncFn())` is always truthy.
4. Read-modify-write across an await: any value read BEFORE an await and used to compute a write AFTER it may be stale. Re-read after the await, or add a comment stating why no concurrent writer can exist.

### float-equality-and-money [high | on-demand | reasoning-errors]
TRIGGER: Writing an equality test where either operand is a float or the result of float arithmetic; any arithmetic on currency values.
MECHANISM: Models know 'floats are inexact' as isolated trivia but fail to activate it at the moment of writing `==`, because the surrounding arithmetic looks exact (0.1 + 0.2 has no visible imprecision in source). Money in binary floats is the highest-cost instance: errors accumulate silently across many small operations.
EXAMPLE: `if (total === 0.3)` never true after `0.1 + 0.2`. Summing invoice line items in floats fails a `sum === expectedTotal` reconciliation intermittently, only on certain amount combinations.
RULE:
Never compare computed floats with ==/===/!=. Use an explicit tolerance (`Math.abs(a - b) < 1e-9`, Python `math.isclose`, `pytest.approx`) or restructure to integers. Money is ALWAYS integer minor units (cents) or Decimal — before finishing any change touching currency, grep the diff for arithmetic on currency-named variables (price, amount, total, fee, balance) and confirm none uses binary floats. `toFixed()` returns a STRING — never feed it back into arithmetic or comparison.

### regex-three-probe [high | on-demand | reasoning-errors]
TRIGGER: Writing or editing any regex, or any string replace call.
MECHANISM: Regexes are write-only for mid-tier models: they compose from memorized fragments but cannot mentally execute anchoring, greediness, or engine statefulness. The classic failures (unescaped dot, missing anchor) still match the happy-path example, so eyeball review confirms the wrong regex.
EXAMPLE: Validating a redirect domain with `/example.com$/` also matches `evil-example-com.attacker.io` (unescaped dot, no start anchor). `str.replace('a', 'b')` in JS replaces only the FIRST occurrence and the model assumes all.
RULE:
After writing any regex longer than a literal string: run it in a one-line REPL probe (`node -e` / `python -c`) against three concrete inputs — one intended match, one near-miss that must NOT match, and the empty string — and paste the outputs into the transcript before using it. Trap rows: escape literal dots (\.); anchor validations with ^...$ (Python re.match anchors start ONLY — use re.fullmatch); JS `str.replace(string, x)` replaces the FIRST occurrence only — use replaceAll or a /g regex; a /g regex object reused with .test()/.exec() keeps lastIndex state between calls and alternates results — recreate it or drop /g; user input interpolated into a pattern must pass through a regex-escape helper; `$` in a replacement string is special ($&, $1) — write $$ for a literal dollar.

### division-modulo-negatives [high | on-demand | reasoning-errors]
TRIGGER: Writing % or integer division where an operand can be negative; computing a midpoint; handling 64-bit IDs in JS/JSON.
MECHANISM: Division and modulo semantics are language-specific memorized facts (Python floors, JS/C/Java/Go truncate toward zero), and models apply whichever language dominated training for the code shape at hand. Negative operands are exactly where the languages diverge and almost never appear in training examples, so the wrong semantics go unnoticed.
EXAMPLE: Bucket index `arr[x % n]` with a negative hash: JS gives `-1 % 5 === -1` → `arr[-1]` is undefined; a Python-shaped mental model expected 4. Parsing a JS/JSON 64-bit snowflake ID as a number silently rounds it above 2^53 — two different IDs become equal.
RULE:
Division/modulo trap rows: Python // and % FLOOR (−1 % 5 = 4); JS/Java/C/C++/Go/Rust % TRUNCATES (−1 % 5 = −1); Python 3 `/` always returns float, use // for integer division. Procedure: if the dividend can be negative, trace ONE concrete negative value through the expression in a comment before using the result as an index or bucket; for a guaranteed-nonnegative modulo write `((x % n) + n) % n`. In fixed-width-integer languages compute midpoints as `lo + (hi - lo) / 2`, never `(lo + hi) / 2`. JS numbers lose integer precision above 2^53: any 64-bit ID (DB bigint, snowflake) must travel as a STRING through JSON and JS code.

### sort-comparator-contract [high | on-demand | reasoning-errors]
TRIGGER: Writing any sort call or comparator function.
MECHANISM: '.sort() obviously sorts numbers' is the intuitive model; JS's default lexicographic string coercion contradicts it. Separately, boolean-returning comparators look correct, sometimes work by accident, and violate the contract in ways that produce engine-dependent, subtly unsorted output — the worst kind of intermittent wrongness.
EXAMPLE: `[10, 9, 1].sort()` → `[1, 10, 9]`. Comparator `(a, b) => a.date > b.date` returns booleans (coerced to 1/0, never -1), leaving the list partially unsorted only for some input orders.
RULE:
JS .sort()/.toSorted() always gets an explicit comparator, unless lexicographic string sorting is genuinely intended (then write `// lexicographic intended`). A comparator returns a NUMBER (negative/zero/positive), never a boolean — after writing one, check the return expression: if it is a bare `>`/`<` comparison, rewrite as `a - b` (finite numbers), `a.localeCompare(b)` (user-facing strings), or an explicit -1/0/1 chain. `a - b` is invalid when values can be NaN/undefined/mixed — filter or map first. Remember .sort() MUTATES (use toSorted for a copy). Stability is guaranteed in modern JS and Python: for multi-key sorts either sort by least-significant key first, or compare both keys in one comparator.

### familiar-api-trap-table [high | on-demand | reasoning-errors]
TRIGGER: Using any API listed above, or relying on unverified edge-case behavior of any standard-library call.
MECHANISM: Mid-tier models substitute the statistically most common behavior for an API's actual behavior. APIs whose semantics contradict their own name or their cousins in other languages get systematically misused, and the model cannot detect this from within — it needs a lookup table or an empirical probe.
EXAMPLE: `['1', '7', '11'].map(parseInt)` → `[1, NaN, 3]` because map passes the index as parseInt's radix. `JSON.stringify({a: undefined})` silently drops the key and breaks a diff-based change detector.
RULE:
Familiar-API trap rows — check when touching any of these:
- JS `map(parseInt)` passes index as radix — use `Number` or `x => parseInt(x, 10)`.
- `typeof null === 'object'` — test null with `x === null`. `NaN !== NaN` — use Number.isNaN.
- JSON.stringify drops undefined/functions/symbols; NaN/Infinity become null; Dates become strings and do NOT round-trip.
- Python `is` compares identity — use it only for None/True/False; interning makes `is` on small ints/strings pass in tests and fail in prod.
- Python `str.split()` (no arg) ≠ `str.split(' ')`: no-arg collapses whitespace runs and drops empty strings.
- JS `'👍'.length === 2` (UTF-16 units); naive slice can split a character — use [...str] or Intl.Segmenter for user-visible truncation.
- `Array(3).map(f)` does nothing (holes) — use `Array.from({length: 3}, f)`.
- Python: hashing/binary IO needs bytes, not str — .encode() explicitly; open files 'rb' for binary.
Procedure: if a line's correctness depends on a return value, mutation behavior, or edge case you have not verified in this session, either find it in this table or verify it with a one-line REPL probe and paste the output. Guessing is not permitted for load-bearing behavior.

### mixed-operator-parenthesization [medium | on-demand | reasoning-errors]
TRIGGER: Writing an expression that mixes operator categories (bitwise/comparison/arithmetic/logical/string-concat) without full parentheses.
MECHANISM: Precedence tables are per-language memorized facts and models blend languages (C's & binds looser than ==, Python's chained comparisons, string + vs numeric +). A misparse still produces valid code with a different meaning, so there is no error signal — only wrong behavior.
EXAMPLE: `if (flags & MASK == 0)` parses as `flags & (MASK == 0)` — a permissions check that never does what it reads as. `"count: " + a + b` concatenates instead of adding.
RULE:
Whenever ONE expression mixes operator categories — bitwise with comparison, arithmetic inside string concatenation, ternary nested in a larger expression, ?? with ||/&& — parenthesize every subexpression explicitly: `(flags & MASK) == 0`, `"count: " + (a + b)`, `cond ? x : (y ?? z)`. Do this even when you believe you know the precedence. Python chained comparisons are conjunctions (`a < b == c` means `a < b and b == c`) — never chain with mixed operators.

### copy-paste-symmetric-edit-diff [high | on-demand | reasoning-errors]
TRIGGER: Duplicating any line or block and editing it for a parallel/symmetric case.
MECHANISM: After duplicating a line to handle a symmetric case (x→y, width→height, min→max), the model's attention marks the pasted line as 'already handled' and misses one token — the well-documented last-line effect. The result reads correctly at a glance because the two lines are supposed to look nearly identical.
EXAMPLE: `const dx = x2 - x1; const dy = y2 - x1;` — a distance function that is wrong only off-axis. A `height` bounds check pasted from the `width` check but still comparing against `maxWidth`.
RULE:
After writing any pair or group of lines that are copies edited for a symmetric case (x/y, min/max, width/height, start/end, left/right, src/dst, row/col): re-read the pasted lines token by token, and for every occurrence of the symmetric term in the ORIGINAL line, verify the corresponding token in the copy was swapped. If the symmetric term appears 3+ times per line, stop pasting and extract a helper function parameterized on the axis instead.

### binary-search-invariant-first [medium | on-demand | reasoning-errors]
TRIGGER: Writing binary search, bisection, two-pointer, or partition code by hand.
MECHANISM: Binary search / two-pointer / partition loops involve a coupled 4-way choice (< vs <=, mid vs mid±1 on each side, return lo vs hi) that cannot be resolved by local pattern-matching — each plausible-looking wrong combination either loops forever or misses boundary elements. An explicit invariant plus a termination argument decouples the choices into independently checkable facts.
EXAMPLE: `while (lo <= hi) { if (a[mid] < t) lo = mid; else hi = mid - 1; }` — infinite loop on any 2-element array where a[lo] < t.
RULE:
First check whether stdlib replaces the hand-written loop (Python bisect, sortedcontainers; lodash sortedIndex) — prefer it. If writing binary search / two-pointer / partition by hand: (1) before the body, write a one-line invariant comment describing everything OUTSIDE the active interval, e.g. `// inv: a[0..lo) < target <= a[hi..n)`; (2) write a termination note confirming the interval strictly shrinks every iteration — mid must be excluded from the next interval on at least one side (`lo = mid + 1` or `hi = mid`; never `lo = mid` paired with `hi = mid`); (3) after writing, trace arrays of length 0, 1, and 2 with the target present at each position and absent, and record the traced returns in the transcript.

### closure-loop-variable-capture [high | on-demand | reasoning-errors]
TRIGGER: Defining a closure inside a loop for deferred execution.
MECHANISM: Models reason about closures as capturing VALUES, but closures capture VARIABLES; when execution is deferred past the loop, every callback observes the final value. The code reads correctly under the value-capture mental model, so the model has no internal signal that anything is wrong.
EXAMPLE: Python `callbacks = [lambda: print(i) for i in range(3)]` prints 2,2,2. JS `for (var i = 0; i < 3; i++) setTimeout(() => log(i))` logs 3,3,3.
RULE:
When creating any function (lambda, arrow, callback, handler) inside a loop whose execution is deferred past the loop (event handlers, setTimeout, collected task lists, goroutines pre-Go-1.22): bind the loop variable per-iteration explicitly — JS: `let` in the for-header, never `var`; Python: default-arg pin `lambda i=i: ...` or functools.partial(f, i); Go <1.22: `i := i` inside the loop. After writing it, state in one line which value each created closure will see at CALL time (not creation time).

### edit-without-reading [critical | core | bug-injection]
TRIGGER: Before the first Edit of any file in the session.
MECHANISM: Weaker models act on their prior of what a file 'should' contain — inferred from the filename, framework conventions, or a 3-line grep snippet — and construct an Edit old_string from that prior. Either the Edit fails repeatedly (wasted turns, then dangerous fallbacks like Write), or it matches a similar-looking unintended region and patches the wrong place. The model does not feel the difference between 'I read this' and 'I can picture this'.
EXAMPLE: Model greps for 'validate_user', sees one matching line, and writes an Edit adding a null-check 'inside' the function — but the old_string it invents doesn't match the real body, and after two failures it regenerates the whole function from imagination, dropping a decorator and an early-return branch it never saw.
RULE:
Never Edit a file you have not Read in this session. Before the first Edit of any file, Read at least the entire enclosing function/class plus the file's import block. A grep snippet is not a Read — Read the surrounding region before constructing old_string.

### hallucinated-api-call [critical | core | bug-injection]
TRIGGER: Writing a call to any API whose definition/signature has not appeared in the session transcript.
MECHANISM: Mid-tier models autocomplete plausible-but-nonexistent APIs because their memory blends several libraries and versions into one composite (pandas df.sort() vs sort_values(), a re.sub with arguments in the wrong order, a lodash method that only exists in Ramda). They emit these with full confidence because token-level plausibility feels identical to correctness; they never spontaneously verify.
EXAMPLE: Model writes `datetime.strptime(fmt, date_string)` (arguments reversed) and `Path.remove()` (doesn't exist; it's `unlink()`) in the same patch. Both are plausible; both fail at runtime in a code path the tests don't cover.
RULE:
Never call a function/method whose definition or signature you have not seen in this session. Before first use of any third-party or unfamiliar stdlib API taking 2+ arguments, paste its real signature into the transcript, obtained from one of: installed sources/type stubs (node_modules/**/*.d.ts; `python -c "import inspect, M; print(inspect.signature(M.fn))"`), LSP hover, or official docs. If you cannot produce the signature, do not write the call.

### library-version-blindness [high | on-demand | bug-injection]
TRIGGER: First use of each third-party library in a session.
MECHANISM: Training data spans every major version of every library; a weaker model emits the statistically dominant idiom, not the installed one. It has no reflex to check the lockfile, so it writes pydantic v1 `.dict()` into a v2 project or SQLAlchemy 1.x Query style into a 2.0 codebase, producing deprecation warnings at best and silent behavior changes at worst.
EXAMPLE: In a project pinned to pydantic 2.7, the model adds a validator with `@validator` and `.dict()`; both are v1 API. Import succeeds via compat shims, behavior differs subtly, and the bug surfaces two features later.
RULE:
Before the first use of each third-party library in a session, read its pinned version from the manifest/lockfile (package.json, poetry.lock/requirements.txt, go.mod, Cargo.toml) and state one line: 'Using <lib> v<N> — writing v<N> idioms.' If the version differs from the idiom you were about to write, check the installed package's types/docs before writing any call.

### signature-change-without-callsite-sweep [critical | core | bug-injection]
TRIGGER: After changing any signature, symbol name, return type, default, or exception behavior.
MECHANISM: Attention is local: the function being edited is 'the task', and call sites outside the context window effectively do not exist. Frontier models spontaneously grep after a signature change; weaker models declare done as soon as the definition compiles in their head. Same failure for changed return types, new required params, and newly raised exceptions.
EXAMPLE: Model adds a required `timeout` parameter to `fetch_page(url)` and updates the two call sites in the file it has open; the five call sites in other modules now throw TypeError, discovered only when a different feature breaks in QA.
RULE:
After changing any function/method/class signature, name, return type, default value, or raised/thrown exception: grep the symbol repo-wide (`grep -rn '<name>(' .` plus bare `<name>` for exports/references), paste the hit list as file:line, and for each hit either update it or state in one line why it is unaffected. A claim of 'no other callers' must show the actual grep command and its empty output.

### copy-paste-adapt-divergence [high | on-demand | bug-injection]
TRIGGER: After pasting and adapting any duplicated block of code.
MECHANISM: After duplicating a block to adapt it, the model edits the salient tokens and skips low-salience ones — a log string, an inner loop variable, an error message, one array index. Having 'just written' the block creates a completion signal that suppresses re-inspection; weaker models are far more susceptible to this false-done feeling.
EXAMPLE: Copying `validateWidth()` to create `validateHeight()`, the model renames the function and the parameter but leaves `throw new Error('width out of range')` and one `config.maxWidth` reference — the height check silently validates against the width limit.
RULE:
After duplicating and adapting any code block: list the source-specific tokens that had to change (identifiers, string literals, keys, indices), then grep the NEW block for each old token and show zero hits. For blocks >5 lines, write this as an explicit token checklist in the transcript before moving on.

### replace-all-shrapnel [high | on-demand | bug-injection]
TRIGGER: Before any Edit call that sets replace_all=true.
MECHANISM: replace_all with a short or generic old_string rewrites unintended occurrences — substrings inside longer identifiers, matches in strings and comments, same-named locals in other scopes. Weaker models reach for replace_all precisely when they are losing patience with per-occurrence edits, i.e. when they are least careful.
EXAMPLE: Renaming a variable with replace_all old_string='id' also corrupts 'idempotent', 'width', a JSON key in a fixture string, and an unrelated `id` field in a second class in the same file.
RULE:
Before any Edit with replace_all=true: run `grep -n '<old_string>' <file>`, paste the occurrence list, and confirm every listed occurrence should change. Never use replace_all with an old_string that is shorter than a full identifier or that can occur inside another word — extend old_string with surrounding context and do individual edits instead.

### import-target-guessing [high | on-demand | bug-injection]
TRIGGER: Before adding a new import; after moving or deleting any exported symbol.
MECHANISM: Models write imports from paths that 'should' exist by convention (`from utils.helpers import parse`, `import { Button } from '../components'`) without checking that the module or the export exists. Barrel files, re-exports, and src/dist layouts make convention-guessing unreliable; the failure is instant on run but often lands in a path not executed until later.
EXAMPLE: Model adds `from app.core.settings import get_config` — the real module is `app.config.settings` and the function is `load_config`. The file imports fine in the model's head and crashes on first import in CI.
RULE:
Before writing an import of a module not already imported in that file: confirm the target exists by Glob-ing the module path or grep-ing for the symbol's definition/export (`def <sym>|class <sym>|export .*<sym>`), and paste the confirming hit. After moving or deleting any exported symbol, grep repo-wide for import lines referencing it and fix each one.

### dead-code-mirage [high | on-demand | bug-injection]
TRIGGER: Before deleting any function, class, export, or file believed to be dead.
MECHANISM: One zero-hit grep for direct calls convinces the model code is dead, but dynamic references are invisible to that grep: string-based dispatch, getattr/reflection, DI container registrations, template references, entry_points/plugin registries, __all__/barrel exports, fixtures resolved by name. Weaker models delete on first negative evidence instead of accumulating positive evidence of deadness.
EXAMPLE: Model deletes `handle_refund` because nothing calls it — but a dispatch table maps the string 'refund' to it via getattr, and refunds break in production.
RULE:
Before deleting any 'unused' function, class, export, or file, run and paste ALL of: (1) grep for the bare name repo-wide including non-code files (templates, YAML, JSON, MD); (2) grep for the name inside quotes ('name' and "name") to catch dynamic dispatch; (3) check __all__/index barrel exports and plugin or entry-point registrations. Delete only after all three pastes. If any hit is ambiguous, deprecate (warning + comment) instead of deleting.

### python-indent-corruption [critical | on-demand | bug-injection]
TRIGGER: After every Edit to a .py file.
MECHANISM: Patch-style editing in Python can produce indentation that is syntactically valid but semantically different — a line dedented out of an if-block or loop still parses, so no error fires anywhere. Tab/space mixing and Edit old_string whitespace mismatches are the entry point; weaker models neither notice the scope shift nor run a compile check.
EXAMPLE: An Edit re-inserts a `retry_count += 1` one level shallower than before; it now runs once outside the loop instead of per-iteration. py_compile passes, tests without retry coverage pass, retries are silently broken.
RULE:
After every Edit to a .py file: (1) run `python -m py_compile <file>` and paste the result; (2) run `git diff -- <file>` and confirm the hunk contains only the intended lines and that no line changed indentation level you did not intend. Any indentation-only change on an untouched line is a corruption signal: revert and redo the Edit with more surrounding context in old_string.

### twin-target-confusion [high | on-demand | bug-injection]
TRIGGER: When the edit target's name matches more than one file or definition in the repo.
MECHANISM: Repos contain near-duplicate names: two utils.py in different packages, config.ts in three workspaces, handleSubmit in sibling components, a src/ and a compiled dist/ copy of the same file. Search returns several candidates; the weaker model edits the first one surfaced and then loops on 'the fix doesn't take effect', sometimes 'fixing' harder in the wrong file.
EXAMPLE: Bug is in packages/api/src/utils/date.ts; the model edits packages/web/src/utils/date.ts (same filename, same function name), reruns the failing API test, sees no change, and starts adding speculative fixes to the wrong file.
RULE:
Before editing a symbol or file located via search: run the search repo-wide and count candidates. If more than one file defines the same-named symbol or shares the filename, list all candidates with absolute paths and state in one line which is the live one and the evidence (e.g. the import line in the failing module that points to it — paste that line).

### generated-file-edit [high | on-demand | bug-injection]
TRIGGER: Before the first Edit of any file (marker check); on any path under a build/generated directory.
MECHANISM: Error messages and stack traces point at build artifacts (dist/, *_pb2.py, *.g.dart, generated clients, lockfiles), and the weaker model patches whatever file the trace names. The edit works locally, then the next codegen/build silently reverts it — a bug that 'comes back from the dead' and burns a full re-debug cycle.
EXAMPLE: Model fixes a typo directly in api/client_pb2.py; the next `make proto` regenerates the file and the fix vanishes, resurfacing the bug a week later with no git evidence of regression.
RULE:
Before the first Edit of any file: Read its first 10 lines and check for 'DO NOT EDIT' / '@generated' markers, and check the path for dist/, build/, gen/, .next/, node_modules/, coverage/, or lockfile names. If matched: do not edit — locate the source (schema, template, proto, config), edit that, re-run the generator, and state which generator command you ran.

### write-tool-clobber [critical | core | bug-injection]
TRIGGER: Before any Write call targeting a path that already exists; after a second consecutive Edit old_string mismatch.
MECHANISM: Write replaces the entire file; a model regenerating a file 'from memory' silently drops every function, comment, and edge case it forgot — plus any uncommitted user changes. Weaker models escalate to Write exactly when Edit's old_string keeps failing to match, i.e. exactly when their memory of the file is provably wrong.
EXAMPLE: After two failed Edits on a 400-line module, the model rewrites the whole file via Write; the rewrite loses a Windows-only code path and two helper functions it never read, and destroys the user's uncommitted docstring edits.
RULE:
Never use Write on an existing file unless you Read the complete file in this same turn and a full replacement is the explicit intent. If an Edit fails to match twice, re-Read the exact region and retry Edit with corrected old_string — do not fall back to Write. Before any intentional full rewrite, run `git diff -- <file>` and confirm no uncommitted changes would be destroyed.

### untested-regex [medium | on-demand | bug-injection]
TRIGGER: After writing or modifying any regular expression destined for committed code.
MECHANISM: Regexes are written against imagined inputs, not real ones; escaping (especially Windows backslash paths), anchors, greedy quantifiers, and missing multiline/dotall flags all fail on real strings. Weaker models never execute a regex before shipping it because it 'reads right', and regex bugs fail silently (no match = no error).
EXAMPLE: A log-parsing regex uses `\d+.\d+` (unescaped dot) and no anchor; it matches version-like garbage in an unrelated field, and the parser silently attributes latencies to the wrong requests.
RULE:
After writing or modifying any regular expression: execute it against at least 2 positive and 1 negative sample copied from real data (actual log line, real filename, real input from the repo — not invented), via a one-liner (`python -c` or `node -e`), and paste the match results. No regex ships without this paste.

### code-schema-config-drift [high | on-demand | bug-injection]
TRIGGER: After changing any field name, config key, env var, or enum/union membership.
MECHANISM: A data shape lives in many places at once — type/interface, JSON schema, DB migration, serializer, test fixtures, .env.example, API docs. The model updates the one representation in its context window and leaves the rest silently disagreeing; nothing fails until the mismatched surface is exercised at runtime. Enum/union additions additionally leave switch/match statements non-exhaustive in languages that don't enforce it.
EXAMPLE: Model renames the `expiry` field to `expires_at` in the TypeScript interface and the API handler, but not in the zod schema or the two JSON fixtures — validation strips the field and the frontend shows blank expiry dates with no error.
RULE:
When adding, renaming, or removing any field, config key, env var, or enum/union member: grep the exact key name repo-wide, paste the list of surfaces it appears on (type defs, schemas, migrations, serializers, fixtures, .env*, docs, tests), and update each or state why it is exempt. For enum/union changes, additionally grep for switch/match/if-chains over that type and update every branch set found.

### no-test-shaped-hardcoding [high | on-demand | false-completion]
TRIGGER: A previously failing test now passes due to your production-code change, before claiming done.
MECHANISM: Optimizing for the visible target (the failing assertion) rather than the behavior, weaker models special-case exactly the fixture values — reward hacking that yields green tests and broken production behavior for every other input.
EXAMPLE: To pass assert slugify("Héllo Wörld") == "hello-world", model adds 'if s == "Héllo Wörld": return "hello-world"' instead of implementing unicode folding.
RULE:
After making a failing test pass, diff your production changes and grep them for any literal that also appears in the test file (strings, magic numbers, fixture ids, paths). Any match means the fix is test-shaped: remove the special case and implement the general behavior, or explicitly declare and justify the coupling.

### no-whole-file-rewrite [critical | core | token-efficiency]
TRIGGER: About to modify a file that already exists.
MECHANISM: Weaker models find regenerating a whole file easier than constructing a unique Edit anchor, so they Write a full replacement for a 3-line change. Cost is double: the entire file is emitted as output tokens, AND regeneration from imperfect memory silently drops comments, edge-case branches, or recently added code — a correctness disaster that then costs a long debug session.
EXAMPLE: To add one CLI flag, the model Writes a full 480-line replacement of cli.py; the rewrite silently loses a bugfix added 20 minutes earlier in the same session, which resurfaces as a mystery regression an hour later.
RULE:
Modify existing files with Edit and unique anchors, never Write. Write on an existing file is permitted only when more than half its lines change, and only immediately after a full Read of the current version in this session. If an Edit anchor fails twice, Read the exact range to get the current text — do not fall back to whole-file regeneration.

### read-enclosing-scope-before-first-edit [critical | core | token-efficiency]
TRIGGER: About to make the first Edit to a file you have only seen via Grep hits or partial reads that exclude the enclosing scope.
MECHANISM: The opposite failure: to 'save tokens', a weaker model edits from a 10-line Grep snippet without reading the enclosing function, misses that the variable is reassigned two lines above the snippet or that an early return skips its patch, and ships a broken edit. The resulting fail-debug-reread-refix loop costs ~10x the read it skipped.
EXAMPLE: Model greps `timeout =` in client.py, edits the hit to a new value, but never read the enclosing function where a later line overwrites timeout from kwargs — fix has no effect, spawning a 15-turn debugging session.
RULE:
Before your FIRST Edit to any file this session: Read at minimum the entire enclosing function or class of the edit site plus the file's import block. If the file is under 250 lines, Read all of it. Editing from a Grep snippet alone is forbidden. This read is mandatory even for 'obvious one-liners'.

### post-change-reference-sweep [critical | core | token-efficiency]
TRIGGER: You just changed a signature, name, key, route, or schema used (or possibly used) outside the current file.
MECHANISM: After changing a signature or renaming a symbol, weaker models update only the call sites they happen to remember. Missed callers surface as runtime/build failures many turns later, when the connection to the rename is no longer in context — producing an expensive cold-start debug session for a bug that a single Grep would have prevented.
EXAMPLE: Model renames `getUser(id)` to `fetchUser(id, opts)` and fixes the two callers it recalls; a third caller in a cron script breaks in production-style testing 40 turns later and is debugged as if it were a new bug.
RULE:
After changing any function signature, renaming any symbol, or changing any config key, route, or schema field: Grep the OLD identifier repo-wide and show the result. For every hit, either fix it or state in one line why it is unaffected. A zero-hit result must be shown in the transcript, not asserted. Do not proceed to the next task step until every hit is dispositioned.

### pre-edit-constraint-check [critical | on-demand | context-degradation]
TRIGGER: Immediately before the first Edit/Write to each distinct file path in the session, and before the first edit to any file after a compaction.
MECHANISM: Capturing constraints is useless if they are never consulted at the decision point. Weaker models do not spontaneously cross-reference a registry while heads-down editing; the check must be an explicit, cheap, per-file ritual whose output is visible in the transcript, converting 'remember not to' into 'look up before'.
EXAMPLE: STATE.md correctly contains 'Constraint: do not modify the generated protobuf files in gen/'. Forty turns later the model edits gen/api_pb2.py to 'fix' a lint error because nothing forced it to consult the registry before the Edit call.
RULE:
Before the FIRST Edit or Write to any file in a session (and again after any compaction), print one line: `CONSTRAINT CHECK: <path> — none apply` or `CONSTRAINT CHECK: <path> — matches '<constraint text>', skipping/asking`. Editing a file without this line in the transcript is a rule violation.

### no-edits-from-stale-memory [critical | core | context-degradation]
TRIGGER: Before any Edit/Write to a file last Read more than 10 messages ago or modified since the last Read; immediately after any Edit fails with a string mismatch.
MECHANISM: The model's belief about a file reflects the last time it read it, not the file's current state — its own later edits, user edits, formatters, and codegen all silently invalidate the memory. Weaker models are overconfident here: when an Edit fails on old_string mismatch they guess variants from memory, or escalate to Write and overwrite the whole file from a stale mental copy, destroying intervening changes. Fable re-reads instinctively; weaker models need a numeric staleness threshold.
EXAMPLE: Turn 20: model reads utils.py. Turns 25-60: it edits utils.py three times and the user runs a formatter. Turn 61: Edit fails with 'string not found'; the model retries two guessed variants, then uses Write with its turn-20 mental copy plus the new function — erasing the three edits and the formatting.
RULE:
Never construct an Edit old_string or a Write body from memory. If you have not Read the target region within the last 10 messages, or ANY edit touched the file since your last Read, Read the region again first. If an Edit fails with 'string not found', the only permitted next action on that file is a Read of the target region — never a guessed retry, never a whole-file Write.

### never-requires-replacement [high | core | instruction-format]
TRIGGER: Authoring any prohibition; at runtime, whenever a NEVER rule blocks the current plan.
MECHANISM: A bare negative instruction leaves a behavioral vacuum: under pressure the model falls back to its prior, which is often the banned action itself — worsened by negation priming (the banned command is now the most salient command in context). Pairing every prohibition with the exact replacement on the same line gives the fallback a concrete target, and makes the rule checkable: grep the kit for NEVER lines lacking '-> instead:'.
EXAMPLE: 'Never taskkill /F /IM node.exe' alone: model, blocked by a busy port after three failed attempts, runs it anyway 'just this once' and kills Claude Code. With '-> instead: netstat -ano | findstr :PORT, then taskkill /F /PID <pid>' the model executes the replacement instead.
RULE:
Format contract: every NEVER/Don't line contains ` -> instead: ` followed by the exact replacement command or action, on the same line. A prohibition without a replacement is an invalid rule — do not add it; rewrite it.

### good-bad-pair-examples [medium | on-demand | instruction-format]
TRIGGER: Adding examples to any guardrail doc.
MECHANISM: Weaker models generalize from one concrete worked example better than from an abstract rule (few-shot beats zero-shot instruction-following), but examples are double-edged: unlabeled or lengthy BAD examples prime imitation of the bad pattern. The fix is structural: at most one GOOD/BAD pair per core rule, GOOD as a short mini-transcript, BAD clearly prefixed and strictly shorter than GOOD.
EXAMPLE: 'Keep diffs minimal' is ignored; the model rewrites a whole file to change one function. A 6-line GOOD example showing a surgical Edit of just the function, against a 2-line labeled BAD showing a full-file Write, makes its next change surgical.
RULE:
Examples in guardrail docs: at most one GOOD/BAD pair per core rule, placed in the reference section. GOOD = a 5-10 line mini-transcript of the correct tool sequence. BAD = <=3 lines, always prefixed `BAD (never do this):`. No unlabeled example code anywhere in the kit.

### fix-the-owning-layer [high | on-demand | process-failures]
TRIGGER: About to add compensating/corrective code around a function's return value at a call site
MECHANISM: Models fix at whatever layer they happen to be reading. If they entered the code via a caller, they add compensation at the call site (re-sorting, unit conversion, type coercion) for output the callee should produce correctly — leaving every other call site with the same defect and splitting the contract's truth across layers.
EXAMPLE: getInvoices() was changed last week to return cents; one caller expects dollars. The model adds `/100` in that caller. Four other callers still display 100x amounts, and now one call site has a private, undocumented unit convention.
RULE:
Before adding code at a call site that transforms, guards, or corrects a callee's output: grep every call site of that callee and count how many would need the same correction. If more than one, the fix belongs inside the callee — make it there and re-check all call sites. Fix the layer that owns the broken contract, not the layer where you happened to notice the breakage.

### minimal-diff-no-drive-bys [critical | core | process-failures]
TRIGGER: While editing any existing file
MECHANISM: Regenerating surrounding code toward the model's trained style is easier than surgical preservation, so weaker models rename variables, reorder imports, convert function styles, and 'improve' comments while making the requested change. Every unrequested changed line is an unreviewed line and a fresh bug opportunity, and the noise buries the real change in the diff.
EXAMPLE: Asked to fix one comparison operator, the model also renames `idx` to `index`, converts the file to arrow functions, and reorders imports. Review misses that one arrow conversion changed `this` binding and broke an event handler.
RULE:
Change only lines the task requires. Forbidden unless explicitly requested: renames, reformatting, import reordering, comment rewrites, refactoring adjacent code, style 'improvements'. If you notice something worth fixing outside scope, do NOT touch it — append `NOTED (not done): <thing> <file:line>` to your final summary instead. Before finishing, re-read the diff: every changed hunk must map to the task; revert any hunk that does not.

### call-site-sweep-after-contract-change [critical | core | process-failures]
TRIGGER: After changing any function signature, exported name, return shape, config key, or CLI flag
MECHANISM: Weaker models update the definition and whatever call sites are already in the context window; hits outside the window effectively do not exist to them. Frontier models sweep reflexively; weak models must be given the sweep as a mandatory mechanical step with visible output.
EXAMPLE: Renamed getUser(id) to getUser(id, opts) and updated the two callers in the same file. Three callers in other modules now rely on a default that changed, silently altering behavior — no compile error because the language is dynamic.
RULE:
After changing any function signature, exported symbol name, return shape, config key, or CLI flag: grep the ENTIRE repo for the old symbol (and the new one), paste the list of hits, and for each hit either update it or dismiss it with a stated reason ('string in changelog, intentional'). Renames additionally require a grep for string-literal references (logs, templates, reflection, docs). Do not proceed to the next task step until every hit is accounted for.

### prior-art-search-before-new-code [high | on-demand | process-failures]
TRIGGER: About to write a common-kind helper, or at the start of any 'add <feature>' task
MECHANISM: Generating a fresh helper or feature from the training prior is cheaper for the model than discovering what the repo already has, so weaker models default to greenfield. The result is duplicate utilities with subtly different behavior (two slugify functions, two retry wrappers) and parallel implementations of features that already exist behind a flag.
EXAMPLE: Writes a new formatCurrency inside a component; src/utils/money.ts already has one handling negatives and locale — the new UI shows '-$-3.50'. Separately: asked to 'add rate limiting', writes a second middleware while one exists behind RATE_LIMIT_ENABLED=false; both later run in prod and double-count.
RULE:
Before writing any general-purpose helper (formatting, validation, retry, HTTP, date/time, parsing, ID generation) OR starting any 'add <feature>' task: search first. Grep the repo for 2-3 keyword variants of the concept and check the nearest utils//lib//shared/ directory and config keys/env vars. Paste what you searched. If you find an existing or partial/disabled implementation, use or extend it — propose enabling over duplicating. Write new code only after stating: 'No existing implementation — searched: <terms>'.

### match-one-existing-example [high | on-demand | process-failures]
TRIGGER: Before creating a new file or a new instance of a kind that already exists in the repo
MECHANISM: Without an in-repo anchor, weaker models default to training-set idioms — a different test style, different error handling, a standalone file layout. The code is plausible in isolation but alien to the repo, and it misses repo-specific wiring (route registration, DI container, barrel exports, auth middleware) that the local pattern carries implicitly.
EXAMPLE: Adds a new API endpoint as a standalone Express handler when every other endpoint in the repo is a decorated class whose decorator also registers auth middleware. The new endpoint ships without auth.
RULE:
Before creating any new file or new instance of an existing kind (endpoint, model, test, component, migration, CLI command), open ONE existing example of the same kind in this repo and copy its structure: imports style, naming, error handling, and every registration/wiring step it performs (router table, index/barrel export, DI registration, docs entry). Name the example file you are matching in your reply. If no example of the kind exists in the repo, say so before inventing a pattern.

### edit-not-rewrite-behavior-inventory [high | on-demand | process-failures]
TRIGGER: Tempted to replace a whole function or file when only part of it needs to change
MECHANISM: Rewriting lets the model generate from its prior instead of reading carefully; weak models are far better at generation than at preservation, so rewrites silently drop edge cases, fallbacks, defaults, and comments the model never consciously registered.
EXAMPLE: Rewrites a 60-line config loader 'more cleanly', dropping the fallback that reads the legacy config path. Every machine still on the old path breaks, and the diff is too large for the reviewer to spot the dropped branch.
RULE:
Fix by minimal Edit, never by rewriting the whole function/file, unless (a) the user asked for a rewrite, or (b) the required change touches more than half the lines. If you do rewrite: FIRST list the current version's observable behaviors — every branch, default value, side effect, and handled error — then state where each one survives in the new version. Any behavior not on the list is a behavior you are deleting without knowing it.

### never-edit-generated-or-vendored [high | on-demand | process-failures]
TRIGGER: Before the first edit of any file, especially one found via search
MECHANISM: Weaker models trust grep hits without classifying file provenance. The target string is found in dist/ or vendored code, they edit it there, the next build reverts it, and the model concludes the fix 'didn't take' and re-applies harder — a self-reinforcing loop of wasted work.
EXAMPLE: Fixes a typo in dist/app.bundle.js. Next `npm run build` reverts it. The model re-applies the edit twice more before anyone notices the source file was never touched.
RULE:
Before editing any file, check its path against generated/vendored markers: dist/, build/, out/, .next/, target/, node_modules/, vendor/, coverage/, *.min.*, *.generated.*, lockfiles, and any file with a 'DO NOT EDIT' / '@generated' header. Never edit these — locate the source or generator and change that instead. If a symbol appears ONLY in generated paths, the source constructs it dynamically: grep for fragments of the symbol.

### dependency-addition-gate [medium | on-demand | process-failures]
TRIGGER: About to install or add any dependency
MECHANISM: The training prior strongly associates problems with popular libraries, so weaker models reach for the package manager before checking stdlib or already-installed deps — adding supply-chain surface, version conflicts, and CI breakage for a 10-line function. They also install packages as a debugging move ('maybe a newer lib fixes it') without a diagnosis.
EXAMPLE: Adds a string-padding micro-dependency; CI fails on the locked registry mirror; an existing strings.ts util already had the function. Two hours lost to a dependency that duplicated 6 lines of local code.
RULE:
Before adding any dependency, in order: (1) check the package manifest — does an installed dep already cover this? (2) can the stdlib or fewer than ~30 lines of local code do it? (3) if still needed, state package, version, and a one-line justification in your reply BEFORE installing, and flag it explicitly if the user never mentioned dependencies. Never install a package to work around a bug you have not diagnosed.

### error-path-parity [high | on-demand | process-failures]
TRIGGER: Writing code that touches I/O, network, external input, or multi-step mutation
MECHANISM: The request describes only the happy path ('parse the CSV and load it'), and a literal-minded weak model implements exactly what was demonstrated — failure paths are absent because nobody wrote them into the prompt. The model equates 'requested' with 'demoed behavior' and treats error handling as out of scope by default.
EXAMPLE: Implements CSV import that works on the sample file. A malformed row throws mid-import, leaving half the rows committed with no error message — silent partial-write corruption in production.
RULE:
For every new code path that does I/O, network calls, parsing of external input, or multi-step state mutation: implement the failure behavior explicitly (validate-then-act, error propagation with context, defined partial-failure handling) even though the request described only success. In your completion summary include `HANDLED FAILURES: <list>` and `NOT HANDLED (by choice): <list with reason>`. An empty failure list on I/O code is a defect, not a simplification.

### yagni-concrete-tests [high | on-demand | process-failures]
TRIGGER: About to introduce an abstraction, config option, generic, or new file the task did not name
MECHANISM: Weaker models equate quality with the pattern density of their training data — interfaces, factories, registries, config surfaces, generics — and add speculative flexibility nobody asked for. Each unused abstraction is extra review surface, a place for the actual logic to hide, and a maintenance liability; it also multiplies the lines in which the model can inject bugs.
EXAMPLE: Asked for a function that sends one webhook, the model delivers a NotificationDispatcher interface, a provider registry, and a config schema with retry/backoff options — 300 lines where 20 were requested, reading its URL from a config key nobody set, so it fails at runtime.
RULE:
Build only what the task names. Apply these concrete tests before adding structure: a helper/class/interface with exactly one caller and no requested second use -> inline it; a config option nobody asked for -> hard-code the current value; a generic parameter instantiated at one type -> make it concrete; a new file under ~30 lines -> merge into an existing file unless repo convention demands separation. If future-proofing seems genuinely warranted, propose it in one line and let the user opt in — never build it speculatively.

## DEBUG (14 findings)

### repro-first-fix-loop [critical | core | false-completion]
TRIGGER: User reports a bug, or any test/command fails unexpectedly.
MECHANISM: Weaker models jump from plausible hypothesis to fix to 'fixed' without ever binding the bug to a runnable reproduction, so there is nothing to re-run; success is then asserted by narrative continuity instead of by a repro flipping from red to green.
EXAMPLE: User reports 'export fails on files >2GB'. Model finds a plausible int32 cast, changes it, declares fixed. The actual failure was an uploader timeout; the cast was dead code.
RULE:
On receiving any bug report: FIRST write down and run the exact reproduction command; paste its failing output. The bug is 'fixed' ONLY when that same command, unmodified, is re-run and passes — paste that too. If you cannot reproduce, say 'cannot reproduce' and stop; never fix blind.

### restart-stateful-processes [high | on-demand | false-completion]
TRIGGER: Verifying a change against a process that was started before the edit.
MECHANISM: Long-running processes (dev servers, REPLs, notebook kernels, watchers with broken HMR) hold the old code in memory; weaker models verify against the running instance and attribute stale behavior to their change, in either direction.
EXAMPLE: Edits a Flask route, curls the server started 40 minutes earlier, gets the old response, declares 'fix didn't work' and applies a second, wrong fix on top.
RULE:
After editing code loaded by a long-running process (server, watcher, kernel, REPL), restart that process before verifying and show the restart in the transcript. If relying on hot reload, first prove the reload fired (reload log line or a temporary marker log statement appearing in output).

### regression-test-must-fail-first [high | on-demand | false-completion]
TRIGGER: Writing a new test to cover a just-fixed bug.
MECHANISM: A test written after the fix that passes immediately is indistinguishable from a vacuous test; weaker models skip the red step because the fix is already in place and reverting feels wasteful, so they never learn the test detects nothing.
EXAMPLE: Model adds test_handles_empty_list after fixing a crash; it passes — but it also passes on the pre-fix code because it mocks the very function that crashed.
RULE:
When adding a regression test for a bug, prove it detects the bug: stash/revert the fix (or comment it out) and paste the test FAILING, then restore the fix and paste it passing. A regression test never seen red is not evidence and must be labeled 'unproven'.

### fix-plus-regression-sweep [high | on-demand | false-completion]
TRIGGER: The original repro passes after a fix.
MECHANISM: Weaker models verify only the fix's target case; the same narrowness that caused the bug misses the fix's blast radius, and 'the repro passes' silently becomes 'nothing else broke' with no run supporting it.
EXAMPLE: Fixes date parsing for ISO week format, re-runs only the new repro; three existing locale tests now fail and are discovered a session later.
RULE:
A fix requires two runs, both quoted: (1) the original repro now passing, and (2) the nearest enclosing test suite (the changed file's module/package) fully green. If (2) exceeds ~5 minutes, run the changed file's own tests plus its direct importers' tests and state which subset you chose and why.

### suspicious-green-cache-check [medium | on-demand | false-completion]
TRIGGER: A verification result contradicts your prediction, in either direction.
MECHANISM: Caches (pytest/jest caches, incremental compilers, Docker layers) can serve stale greens; weaker models accept a green that contradicts their own stated expectation instead of treating the surprise as a signal to invalidate cache and confirm the executed code is the edited code.
EXAMPLE: A test expected to fail (fix not yet written) passes because jest served a cached result via a mocked module path; model concludes the bug 'was already fixed' and closes the task.
RULE:
If a result contradicts your stated expectation (a test passes that should fail, or output ignores your edit), do not rationalize it. Re-run with caches disabled (pytest --cache-clear / jest --no-cache / clean build) and prove the edited file is the executed file (temporary marker log line or printed path+mtime). Only after both may you interpret the result.

### narrowest-failing-test-loop [high | core | token-efficiency]
TRIGGER: A test failed and you have just edited code to fix it.
MECHANISM: Weaker models re-run the entire test suite after every candidate fix because it feels like thorough verification. Each full run costs minutes and dumps hundreds of lines of pass/fail output into context; after 5 iterations, the window is dominated by five near-identical suite reports and the model starts losing earlier findings to compaction.
EXAMPLE: One failing test in test_auth.py; model runs `pytest` (all 400 tests, 90s, 300-line output) after each of six attempted fixes instead of `pytest tests/test_auth.py::test_token_refresh -x` (2s, 15 lines) — ~1,800 lines of redundant output.
RULE:
While a specific test fails, re-run ONLY that test (exact node id / -t filter / single file, with -x or equivalent). Run the full suite at most twice per task: optionally once at the start for a baseline, and once at the end before claiming done. Running the full suite inside the fix loop is forbidden.

### no-identical-rerun [high | on-demand | token-efficiency]
TRIGGER: A command failed and you are about to run the same command again.
MECHANISM: When a command fails, weaker models re-run it unchanged 'to double-check', re-ingesting the identical multi-hundred-line failure output for zero new information. In a stuck loop this repeats 3-5 times, and the duplicated error dumps crowd out the context needed to actually diagnose the failure.
EXAMPLE: A build fails with a 200-line error dump; the model re-runs the same build command twice more without editing anything, adding 400 redundant lines before starting to investigate.
RULE:
Never re-run a failing command without changing something first. Before any re-run, state in one line: the hypothesis and the specific change made since the last run. Exception: a suspected flaky failure may be re-run exactly once, labeled 'flake check'. If the same command has failed 3 times with different attempted fixes, stop and re-read DEBUG.md's escalation section instead of iterating.

### failed-attempts-ledger-with-escalation-ladder [critical | on-demand | context-degradation]
TRIGGER: Every time a fix attempt fails (test still failing, error persists, behavior unchanged) — log before the next attempt; after 2 failures at the same ladder level, escalate.
MECHANISM: The doom loop: a weaker model whose fix fails regenerates from nearly the same posterior and produces a near-identical fix, often literally re-trying attempt #1 at attempt #4 because failed attempts scroll out of effective attention. Two mechanisms are needed: a written ledger so past failures remain consultable, and a mandatory strategy ESCALATION so each failure changes the level of approach rather than the surface details. Fable escalates instinctively; weaker models retry harder at the same level.
EXAMPLE: A test fails on a timezone assertion. Attempts 1-5 each tweak the datetime formatting string in slightly different ways; all fail identically. The real bug — the fixture generates naive datetimes — is level-2 work (re-read the error and inspect the fixture), never reached because every retry stayed at level 1.
RULE:
When any fix attempt fails, BEFORE trying again append to STATE.md `## Failed attempts`: `ATTEMPT n: <what was changed> -> <exact observed failure>`. Then compare your planned next attempt against the ledger: if it differs from a failed attempt only in surface details, it is FORBIDDEN. Escalation ladder — two consecutive failures at one level force a move up: L1 different fix, same hypothesis -> L2 new hypothesis formed by re-reading the FULL error output verbatim and the failing code -> L3 minimal reproduction or added instrumentation -> L4 revert to last-known-good state and re-approach -> L5 stop and present the full attempts ledger to the user.

### identical-tool-failure-cap [medium | on-demand | context-degradation]
TRIGGER: The second consecutive failure of the same tool call with the same error message.
MECHANISM: Distinct from the debugging doom loop: a mechanical loop where the same tool invocation fails the same way (permission denied, path not found, string mismatch, port in use) and the weaker model reissues it essentially unchanged, sometimes 5+ times, burning tokens and turns. The model treats tool failure as transient noise instead of information; a hard cap of two forces the failure to be read as signal.
EXAMPLE: `npm test` fails with 'command not found' in the sandbox. The model runs it again, then with `--silent`, then from a different directory — four near-identical failures before anyone checks that the project uses pnpm.
RULE:
If the same tool call fails twice with the same error, issuing it a third time unchanged (or with a cosmetic variation) is forbidden. Quote the error verbatim, state one sentence about what it implies, and change something structural: different tool, different path, read documentation/config, or ask the user.

### red-flag-rationalization-table [high | on-demand | instruction-format]
TRIGGER: While debugging, the moment any left-column phrase (or close paraphrase) appears in the model's own output.
MECHANISM: Rationalizations are generated verbatim in the model's own visible output ('probably unrelated', 'should work now'). A two-column table keyed on those exact phrases pattern-matches the model's own tokens at the moment of drift — the one moment a countermeasure can still act. Abstract virtues ('be rigorous', 'don't cut corners') never lexically match anything the model writes and therefore never fire.
EXAMPLE: After two failed fixes the model writes 'this test is probably flaky' and moves to skip it. The row "'probably flaky' -> run it 3x in isolation; paste all 3 outcomes" matches the phrase it just generated and redirects it to evidence-gathering; the flake claim turns out false.
RULE:
## Red flags — if your reply contains a phrase like the left column, stop and do the right column
| You are writing/thinking | Do this instead |
|---|---|
| "probably unrelated" | Treat as related: stash your change, rerun, paste the result |
| "test is probably flaky" | Run it 3x in isolation; paste all 3 outcomes |
| "should work now" | You have not run it. Run it; paste the last output line |
| "quick fix for now" | Stop. Write your failing hypothesis in one line (D1) first |
| "easiest to just rewrite this file" | Never rewrite to escape a bug you don't understand; state root cause first |
| "the linter/type error is noise" | Paste the exact message; explain it in one line or fix it |

### section-headers-as-situations [medium | on-demand | instruction-format]
TRIGGER: Writing or editing any section header inside a guardrail doc.
MECHANISM: Models locate content inside a doc by matching headers against their live situation. Topic-noun headers ('Advanced techniques', 'Methodology') match nothing the model is experiencing; second-person situation headers ('Your fix didn't change the error') lexically match its current state, so scanning lands in the right section — critical for the reference half of docs, which is only ever scanned, never fully read.
EXAMPLE: Model's fix produces the byte-identical error message. It scans DEBUG.md, sees 'Methodology / Tips / Advanced', finds nothing relevant, keeps editing. The header 'Same error after your fix? Your code isn't running — verify you edited the file the process actually loads' names its exact situation and catches the classic stale-process/wrong-file bug.
RULE:
Format contract: every section header below the divider in a guardrail doc is a situation in second person ('Your fix didn't change the error', 'The test passes locally but fails in CI', 'You've made 3 attempts on the same bug') — never a topic noun.

### premise-check-before-edit [critical | core | process-failures]
TRIGGER: The user asserts where a bug is or what causes it
MECHANISM: Instruction-tuned models treat user assertions as ground truth; agreement is what training rewarded. Weaker models do not spontaneously seek disconfirming evidence, so a wrong premise ('the bug is in the parser') routes all investigation into the named component, and they eventually 'fix' correct code to make the user's framing true — introducing a regression while the real bug survives.
EXAMPLE: User: 'Fix the off-by-one date bug in formatDate().' formatDate is correct; the bug is a UTC/local mismatch where the date is constructed in the API layer. The model adds a +1 day hack inside formatDate, which breaks every other caller, and the original bug persists.
RULE:
When the user names a bug's location or cause ('the bug is in X', 'X is broken because Z'), treat it as a hypothesis, not a fact. Before editing: reproduce the failure or trace the bad value to the named location, and cite file:line evidence. If the evidence points elsewhere, report the actual location with the evidence and fix there. Never edit code at the user-named location just to make their framing true — correct code is never modified to compensate for a bug that lives elsewhere.

### cause-line-before-fix [critical | on-demand | process-failures]
TRIGGER: About to write the fix for any diagnosed bug
MECHANISM: The crash site is the most salient token sequence in the context, so weaker models patch where the stack trace points (a guard at the throw site) instead of tracing where the invalid state was created. Symptom-site guards hide the defect, leave every other consumer of the bad state broken, and accumulate as defensive clutter.
EXAMPLE: NPE in renderProfile because user.address is null. The model adds `if (user.address)` in the renderer. The real bug is the API mapper dropping address on a new response shape — three other screens still crash, and the guard now hides the data loss.
RULE:
Before writing any bug fix, write one line:
CAUSE: <file:line where the bad state originates> -> <propagation path> -> SYMPTOM: <file:line where it surfaces>
Your edit must target the CAUSE end. If you patch the SYMPTOM end instead (null check, try/catch, default value), label the edit `WORKAROUND:` with the reason the root cause is out of reach, and grep for every other place the same bad state flows to — list them.

### never-silence-the-check [critical | core | process-failures]
TRIGGER: A test, type check, or lint failure is blocking progress
MECHANISM: For a weak model, the shortest token path from red to green is deleting or loosening the thing that reports red: skip the test, widen the type to any, disable the lint rule, wrap in bare try/except. This reads locally as progress and satisfies 'make it pass' literally — the regression the check was catching ships.
EXAMPLE: A type error appears after a change; the model adds `as any`. A test fails; it adds `.skip`. Both merge, the actual regression reaches production, and the suppressions hide it from the next developer too.
RULE:
Never make a failure disappear by weakening its detector. Forbidden without explicit user approval of the exact suppression: deleting or skipping tests, loosening assertions, `as any` / `# type: ignore` / eslint-disable, widening catch blocks, lowering coverage or lint thresholds. If you believe the check itself is wrong, say so with evidence and propose the change — apply only after approval, and leave a comment at the suppression naming the reason.

## VERIFY (18 findings)

### crlf-whole-file-churn [medium | on-demand | bug-injection]
TRIGGER: When git diff --stat shows near-every-line changes in a file you edited lightly, on a Windows host.
MECHANISM: On Windows, edits and tool round-trips can flip LF to CRLF (or vice versa); git then reports every line changed. The real one-line change is buried in full-file churn, blame is destroyed, and linters/pre-commit hooks fail confusingly. Weaker models commit it anyway because 'the code looks identical'.
EXAMPLE: A one-line fix to a shell script shows a 214-line diff; the model commits it, CI's shellcheck fails on CRLF in the shebang line, and the model starts debugging the script's logic instead of its line endings.
RULE:
On Windows, after editing: run `git diff --stat`. If any lightly-edited file shows changes on nearly every line, treat it as a line-ending flip: confirm with `git diff -- <file> | head` (look for ^M or whole-file rewrite), then `git checkout -- <file>` and redo the edit preserving the original endings. Never commit whole-file line-ending churn alongside a logic change.

### blind-assertion-sync [high | on-demand | bug-injection]
TRIGGER: A previously-passing test fails after your edit.
MECHANISM: When a pre-existing test fails after an edit, weaker models 'fix' the test by pasting the new actual output into the expected value (or running snapshot-update) without judging whether the new behavior is correct. This mechanically converts a caught regression into a certified one — the test suite now guards the bug.
EXAMPLE: A refactor accidentally changes rounding from banker's to half-up; three assertions fail; the model updates the three expected values to the new outputs and reports 'all tests passing'.
RULE:
When a previously-passing test fails after your change: BEFORE touching the test, state in one line whether the behavior change is intended by the task. Only if intended, edit the expectation and quote old-expected vs new-expected in the transcript with the justification. Never run snapshot-update commands (--update-snapshots, -u, UPDATE_SNAPSHOTS=1) as a first response to a failure.

### no-claim-without-fresh-output [critical | core | false-completion]
TRIGGER: About to type any success claim (done/fixed/works/passes/resolved) about code behavior.
MECHANISM: Weaker models pattern-complete to the 'task finished' narrative: once the diff matches their mental model of the fix, probability mass shifts to success language. Running a command is an extra step with no textual reward, so 'Fixed!' gets emitted from priors, not evidence. This is the root failure of the entire lens; everything else is a variant.
EXAMPLE: Model edits an off-by-one in a pagination helper and replies 'Fixed — items no longer duplicate across pages' without running any test or the app; the change actually broke page 1 because the helper is also called with offset=0.
RULE:
A claim that anything is done, fixed, working, or passing MUST be immediately preceded in the same turn by fresh command output demonstrating it. No output in this turn = you may only report the edit: 'Edited X; not yet verified.'

### forbidden-hedge-phrases [critical | core | false-completion]
TRIGGER: Composing any sentence predicting that a change works.
MECHANISM: 'Should work now' is the model's escape hatch: it grammatically acknowledges uncertainty while socially closing the task, so users read it as done. Weaker models emit it constantly because it maximizes plausibility with zero commitment. Bare prohibitions fail; mandated replacements succeed because the model needs SOMETHING to say.
EXAMPLE: 'I've updated the retry logic — this should resolve the intermittent 502s.' No request was ever sent; the retry config key was misspelled and silently ignored.
RULE:
NEVER write 'should work', 'should fix', 'likely resolves', 'ought to now'. Replace with exactly one of: (a) 'Verified: <command> → <result line>' or (b) 'UNVERIFIED — to confirm, run: <command>'. There is no third option.

### test-integrity-absolute [critical | core | false-completion]
TRIGGER: A test fails and you consider editing the test file or the test invocation to reach green.
MECHANISM: When a test blocks green, the cheapest path to the reward signal is editing the test — loosening an assert, adding .skip, widening a tolerance, deleting the case — and weaker models take it under effort pressure while framing it as 'updating outdated tests'. Classic reward hacking on the visible metric.
EXAMPLE: A float comparison fails after a refactor; model changes 'assert abs(x - 0.5) < 1e-9' to '< 0.1' and reports 'all tests passing', hiding a real precision regression.
RULE:
NEVER make a failing test pass by changing the test: no weakened asserts, .skip/xfail markers, raised tolerances or timeouts, deleted cases, '|| true', or --passWithNoTests. If you believe the TEST is wrong, stop and present the assertion, why it is wrong, and the proposed expectation — then get explicit approval. Every test-file edit made during a fix must be called out with a before/after diff of the assertion.

### quote-the-test-summary-line [critical | on-demand | false-completion]
TRIGGER: Any test-runner command completes.
MECHANISM: Weaker models read the exit status or last line only, and 'OK' pattern-matches to success even when the body says '2 skipped' or 'collected 0 items'. Empty collections and silent skips are the most common false greens: the command 'succeeded' while zero relevant tests executed.
EXAMPLE: pytest tests/test_auth.py prints 'collected 0 items — no tests ran in 0.02s' (broken import path, exit code 5); model reports 'auth tests pass.'
RULE:
After every test run, paste the summary line verbatim (e.g. '12 passed, 1 skipped in 3.2s'). '0 tests', 'no tests found', or 'collected 0 items' is a FAILURE of verification, not a pass. Any skipped/xfailed count must be explained in one sentence or investigated before claiming green.

### scan-full-output-for-failure-tokens [high | on-demand | false-completion]
TRIGGER: A verification command produced more than ~30 lines of output, or its output was piped.
MECHANISM: In long outputs, weaker models attend to the head and tail and skim the middle; a mid-log ERROR or a failed sub-step in a chained script gets lost and the trailing 'Done.' wins. Pipes additionally mask exit codes.
EXAMPLE: 'npm run build && npm test' emits 'Exit status 1' for one workspace mid-stream, but a final aggregate line still prints; model reports a clean run.
RULE:
Before declaring a verification command successful, grep its output for 'error|fail|warn|skip|traceback|exception' (case-insensitive) and either quote every hit or state 'failure-token scan: 0 hits'. If output was piped (head, Select-Object, tee), also print the true exit code ($LASTEXITCODE / ${PIPESTATUS[0]}).

### compiles-is-not-verified [high | on-demand | false-completion]
TRIGGER: A build/typecheck command just passed and you are tempted to conclude the task.
MECHANISM: Build/typecheck success is the cheapest available green signal, and weaker models treat any green signal as terminal. Compilation proves syntax and types, nothing about behavior, but the model substitutes it for the harder check because both produce 'success' text.
EXAMPLE: tsc --noEmit passes after a date-parsing refactor; model declares 'refactor complete and verified'; the parser now returns UTC instead of local time and every timestamp assertion fails.
RULE:
Build/typecheck success is gate 0, never completion evidence. After it passes you MUST also run the tests or a behavior probe for the changed code path and quote its result line. 'It compiles' may never appear as the final verification of a change.

### rebuild-before-testing-artifact [high | on-demand | false-completion]
TRIGGER: About to execute a binary, bundle, installed CLI, or packaged artifact after editing its source.
MECHANISM: Weaker models lose the artifact/source distinction: they edit source, then run the previously built binary/bundle/installed package and read stale behavior as evidence — producing both false passes and phantom bugs they then 'debug'.
EXAMPLE: Edits src/cli.ts, runs the globally installed 'mycli' from an old npm i -g; output unchanged, model concludes the edit didn't work and starts layering fixes onto a nonexistent problem.
RULE:
Before running any compiled/bundled/installed artifact as verification: rebuild it in this same turn, or run via the source-level entrypoint (cargo run, python -m, npx tsx, pip install -e). If the build did not happen after your edit, the run proves nothing — say so instead of interpreting it.

### verify-the-changed-module-actually-ran [high | on-demand | false-completion]
TRIGGER: A test run passes in a multi-package or monorepo project after you changed code.
MECHANISM: In monorepos and multi-package projects, weaker models run the wrong directory's test command; a green suite that never imported the changed file is vacuous, and nothing ties the green output to the diff unless a rule forces the connection.
EXAMPLE: Changes packages/parser/src/lex.ts, runs npm test inside packages/cli, sees 84 passing, declares the parser fix verified.
RULE:
After a passing test run, confirm the run's output names at least one test file that exercises your changed module (grep the output for the module or package name and quote the hit). If it does not appear, the run is inadmissible — find and run that module's tests explicitly.

### done-claim-evidence-table [critical | on-demand | false-completion]
TRIGGER: Composing the final completion summary, or about to commit.
MECHANISM: Final summaries are generated from the session narrative, not the transcript record; weaker models round up — lint they intended to run, tests that last ran six edits ago — because summary language is rewarded for sounding complete.
EXAMPLE: Closing summary: 'All done — tests pass, lint clean, types check.' Lint was never run; tests last ran before the final three edits.
RULE:
Before any final done message or commit, emit an evidence table: one row per claim — claim | exact command | quoted result line | ran AFTER the last edit? (y/n). Any row with 'n' or no output must be re-run first or the claim demoted to UNVERIFIED. Claims without a row are forbidden in the summary.

### full-request-checklist-before-done [high | on-demand | false-completion]
TRIGGER: The original request contained 2+ deliverables and you are about to claim completion.
MECHANISM: Multi-part requests decay in working memory; the last-worked-on subtask becomes 'the task', and completing it triggers a global done-claim covering deliverables never started. The user discovers the gap, not the model.
EXAMPLE: 'Add the endpoint, write tests, and update the API docs' — endpoint and tests done, docs untouched, model announces 'All three items complete.'
RULE:
Before claiming a multi-part task done, re-read the original request verbatim, enumerate every deliverable, and mark each one VERIFIED (with command) / DONE-UNVERIFIED / NOT DONE. Deliver this checklist with the claim. Reporting an item NOT DONE is acceptable; silently dropping it is not.

### trivial-change-no-waiver [high | on-demand | false-completion]
TRIGGER: About to skip verification because the change seems trivial or obvious.
MECHANISM: Weaker models grant themselves verification waivers proportional to perceived triviality, but triviality judgment is precisely the degraded faculty — one-line changes (operator flips, defaults, regex edits) have the highest surprise rate per line of any edit class.
EXAMPLE: Flips '>=' to '>' in a boundary check as an 'obvious' fix, declares done without running anything; the exact boundary case breaks in production.
RULE:
Perceived triviality never waives the completion gate. Sole exemption: changes touching only comments, docs, or whitespace — and then the done-claim must state 'comment/doc-only change; behavior verification not applicable'. Everything else, including one-liners, requires a run.

### service-verification-is-a-request [high | on-demand | false-completion]
TRIGGER: Claiming a server, API, or endpoint change works.
MECHANISM: Startup log lines are the last text the model sees after launching a service, so 'Listening on :3000' gets conflated with behavioral correctness. Process liveness says nothing about the changed route, but it closes the narrative loop cheaply.
EXAMPLE: Adds auth middleware, restarts the server, sees 'Listening on :3000', declares the endpoint secured; a single curl would have shown 500 on every route from a missing env var read at request time.
RULE:
For any change to a service or endpoint, completion evidence is an actual request and response pasted in the transcript (curl / Invoke-WebRequest showing status code and relevant body) exercising the changed route, including at least one case the change was supposed to alter. 'Server started successfully' is never evidence.

### done-claim-maps-to-original-request [critical | on-demand | context-degradation]
TRIGGER: Immediately before any statement that the task is complete/fixed/done, and before any final commit.
MECHANISM: In long sessions 'the task' silently narrows to 'the most recent sub-problem'. After finally fixing the last failing test, the weaker model experiences completion and declares victory — but the original request from 80 turns ago had three parts and only one was addressed. Quoting the original request and mapping each part to evidence converts 'do I feel done?' into a checkable table.
EXAMPLE: Request: 'add rate limiting to the API, log rejected requests, and document the config knobs.' Forty turns of rate-limiter debugging later, the model announces completion. Logging was half-wired to a logger that is never flushed; documentation was never started.
RULE:
Before claiming completion or committing final work: (1) quote the user's original request (or STATE.md `## Goal`) verbatim; (2) list every distinct requested item with one line of concrete evidence each (command output, test name, diff hunk); (3) read STATE.md `## Open items` and classify every entry as done-with-evidence or explicitly-reported-undone. Any requested item or open item without a classification means the work is NOT done — say so instead.

### diff-stat-scope-audit [high | on-demand | context-degradation]
TRIGGER: Before every commit and before every completion claim; also after any compaction if uncommitted changes exist.
MECHANISM: Over a long session, accumulated familiarity breeds 'while I'm here' edits — drive-by refactors, comment rewrites, import reordering — that were never requested and that the model no longer remembers making by the end. Each edit felt justified in the moment; nobody performs the global audit. `git diff --stat` is ground truth that bypasses the model's degraded memory of what it changed and why.
EXAMPLE: Task: fix one null-pointer bug. Final diff touches 9 files: the fix, plus renamed variables in two unrelated modules, a reformatted config, and a deleted 'unused' helper that a script actually imported. The model genuinely cannot recall making half of these by turn 90.
RULE:
Before claiming done or committing, run `git diff --stat` and list every changed file with a one-line justification tracing it to the Goal or to a logged DETOUR line. Any file you cannot justify from the transcript record: revert it (`git checkout -- <file>`) or explicitly flag it to the user as an unplanned change. Committing unexplained files is forbidden.

### checklist-echo-protocol [high | on-demand | instruction-format]
TRIGGER: About to claim done/fixed/works, or about to run git commit (top of VERIFY.md, mirrored as the doc's first 15 lines).
MECHANISM: Weaker models 'read' checklists without executing them: silent reading generates no tokens, so no per-item attention anchor exists and steps are skipped invisibly. Forcing one written line per item (ID + PASS/FAIL/N/A + pasted evidence fragment) converts reading into generation, which cannot be skipped silently, and makes every omission externally visible in the transcript. The evidence requirement ('command + last output line') blocks pattern-completing 'PASS' without running anything.
EXAMPLE: VERIFY checklist includes 'run the test suite'. Model reads the doc, replies 'All checks look good', never runs pytest. Under the echo protocol, the missing 'V2: PASS — pytest: 34 passed in 2.1s' line exposes the skip immediately.
RULE:
Walk this checklist by writing one line per item in your reply: `V<n>: PASS|FAIL|N/A — <evidence: the command you ran + its last output line>`. An item without pasted evidence counts as FAIL. Do not write "done", "fixed", or run git commit while any line reads FAIL.

### kit-wide-rule-ids [medium | on-demand | instruction-format]
TRIGGER: Authoring checklist items; at runtime, any claim of compliance with a guardrail doc.
MECHANISM: Stable short IDs (P1, C3, V2...) give the model a cheap, unambiguous way to cite which rule it is obeying or deliberately waiving, and IDs survive paraphrase and compaction far better than restated rule text. Without IDs, compliance claims degrade to unfalsifiable mush ('following the guidelines') that neither the model nor a reviewer can check against anything.
EXAMPLE: Model writes 'I've followed the verification guidelines' after skipping the lint step; nobody can tell which items it means. Under the ID contract it must write 'V1: PASS... V3: N/A — no lint config in repo', and the bogus N/A is immediately reviewable.
RULE:
Format contract: every checklist item in every guardrail doc carries a stable ID (`P1..`, `C1..`, `D1..`, `V1..`, `E1..`, `S1..`) that never changes meaning across edits. When obeying or waiving an item, cite its ID with one line of evidence. 'Following the guidelines' without IDs counts as non-compliance.

## EFFICIENCY (23 findings)

### shell-dialect-mixing [medium | on-demand | bug-injection]
TRIGGER: Composing any shell command on a Windows host; after any command fails with a quoting or syntax error.
MECHANISM: On Windows hosts, weaker models mix PowerShell and POSIX in one command — $VAR vs $env:VAR, /dev/null vs $null, single-vs-double quoting semantics, backslash escaping inside grep patterns. Commands fail and get retried with random mutations (token burn), or worse, a compound command half-executes with the destructive half succeeding.
EXAMPLE: Model runs `FOO=1 && python build.py > /dev/null` in PowerShell: the env assignment errors, but a retried mangled variant creates a literal file named 'null' and sets nothing, so the build 'passes' with the wrong config.
RULE:
Compose each command in exactly ONE dialect: POSIX syntax only inside the Bash tool; PowerShell syntax ($env:VAR, $null, backtick continuation) only in PowerShell. When a Windows path appears inside a regex or grep pattern, double the backslashes or use forward slashes; prefer forward slashes in all tool arguments. If a command fails with a syntax/quoting error, do not mutate and retry — rewrite it cleanly in the other dialect once.

### grep-before-ranged-read [medium | core | token-efficiency]
TRIGGER: You need something specific from a file you have not yet read, and the file is (or may be) over 250 lines.
MECHANISM: Weaker models treat Read-the-whole-file as the safe default because locating a symbol requires a two-step plan (search, then ranged read) they don't spontaneously form. A 2,000-line file read to find one 20-line function puts ~1,980 useless lines into the window permanently — and large files crowd out the context needed later for the actual edit.
EXAMPLE: Task: 'fix the retry logic in HttpClient.send'. Model Reads the entire 1,800-line http_client.py, consuming ~25k tokens, when `Grep -n 'def send'` plus a Read of 60 lines around the hit would cost ~1k.
RULE:
To locate a specific symbol, function, or config key: Grep for it with -n first, then Read only offset/limit covering the hit ±40 lines. Full-file Read is allowed only when (a) the file is under 250 lines, or (b) you are about to make edits at 3+ scattered locations in it. Never Read a file >400 lines without a prior Grep that failed to localize the target.

### no-redundant-context-refresh [medium | core | token-efficiency]
TRIGGER: About to Read a file or run a Grep/Glob whose target appeared earlier in this session; or you just completed an Edit/Write.
MECHANISM: Weaker models distrust their own context: they re-Read files 'to refresh', re-Read a file immediately after their own Edit 'to confirm it applied', and re-run Greps they already ran. Each redundant call duplicates content that is already verbatim in the window, and the duplication compounds — a file re-read three times occupies 3x its size.
EXAMPLE: Model edits config.ts, then Reads all 600 lines of config.ts 'to verify the change', then two turns later Reads it again before the next edit — 3 copies of the same file in context. Also: running `Grep 'registerHandler'` at turn 5 and again, identically, at turn 20.
RULE:
Before any Read or Grep, check the transcript: if the same file/pattern was read or searched this session AND nothing in its scope has changed since (by you or a command you ran), reuse the earlier result — do not re-run. After your own Edit, never Read the file to confirm the edit applied: Edit fails loudly on mismatch; confirm behavior with a compile/test command instead. Re-reads are permitted only for the specific ranges you edited when you need updated line numbers.

### batch-independent-tool-calls [medium | core | token-efficiency]
TRIGGER: You are about to make a tool call and can already name at least one more call you will make regardless of its result.
MECHANISM: Weaker models serialize by habit: one tool call, wait, narrate, next call. Every extra assistant turn adds narration tokens and round-trip latency, and the interleaved chatter dilutes the context. Independent calls (multiple Reads, Grep + git status) have no data dependency and can share one block.
EXAMPLE: To understand a feature the model issues: Read models.py → 'Now let me look at the view' → Read views.py → 'Now the tests' → Read test_views.py: three turns and two narration messages where one batched block with three Reads would do.
RULE:
When your next steps involve 2 or more tool calls where no call's input depends on another's output (multiple Reads, several Greps, git status + git diff + git log), issue them ALL in a single message. Serialize only when an output genuinely determines the next input, and say which output you are waiting for.

### narration-budget [medium | core | token-efficiency]
TRIGGER: About to write prose between tool calls in a work sequence.
MECHANISM: Weaker models emit filler between tool calls ('Now let me check...', 'Great, that worked! Next I will...') because chain-of-thought habits leak into output. This narration carries zero information — the tool call itself shows what is being done — and over a 100-call session it adds thousands of tokens and buries real findings in noise.
EXAMPLE: Transcript shows 40 tool calls, each preceded by 2-3 sentences of 'Let me now examine the utils file to understand how the helper functions are structured' — ~1,500 tokens of pure restatement of the tool calls that follow.
RULE:
Between tool calls, write at most ONE short line, and only when it records a finding or a decision (e.g. 'config comes from env vars, not the file — checking env parsing'). Write nothing before a tool call whose purpose is obvious from its parameters. Never announce success of a tool call the user can see succeeded.

### no-prose-quote-back [medium | core | token-efficiency]
TRIGGER: You just Read a file and are about to describe what is in it.
MECHANISM: After Reading a file, weaker models restate its contents in prose ('This file defines a class Foo with methods bar and baz which...') — a paraphrased second copy of content already in context. Doubly wasteful: the tool result holds the original, and the paraphrase can silently drift from the real code, planting false facts the model later trusts.
EXAMPLE: Model Reads a 300-line service class, then writes an 800-token summary of every method back to the user before making a 2-line fix nobody asked to have the file explained for.
RULE:
Never restate or summarize file contents you just read unless the user asked for an explanation. Reference code as path:line. Quote at most 5 lines, and only when the exact text IS the finding (the buggy expression, the signature being changed).

### wide-scan-delegation-threshold [high | core | token-efficiency]
TRIGGER: The task requires examining many files whose identities you would only discover by searching (audits, migrations, multi-file surveys).
MECHANISM: Weaker models perform repo-wide audits, migrations, and 'find all places that do X' sweeps in the main context, streaming dozens of raw files through the window. The main session then hits compaction mid-task and loses the very analysis it was accumulating. Frontier models delegate implicitly; weaker models need a numeric threshold.
EXAMPLE: Asked to 'find every place we construct a DB connection directly', the model Reads 23 files in main context (~60k tokens), triggering compaction that destroys the running list of call sites it was building.
RULE:
If answering requires opening more than 5 files you cannot name in advance, or any repo-wide sweep (audit, migration, find-all-usages across modules, dependency survey), delegate it to a subagent and act only on its returned conclusions. Do not begin the sweep in main context 'just to get started'.

### subagent-output-contract [medium | on-demand | token-efficiency]
TRIGGER: You are composing any subagent/Task prompt.
MECHANISM: Delegation only saves context if the subagent returns conclusions, not dumps. Weaker models write vague subagent prompts ('look into the auth module'), and the subagent replies with pasted file contents — the exact context blowout delegation was meant to prevent, now paid twice (subagent tokens + main-context ingestion).
EXAMPLE: Subagent asked to 'investigate how sessions are stored' returns 200 lines of copied source from three files; the main session ingests all of it, then still has to re-derive the answer.
RULE:
Every subagent prompt must end with an explicit output contract: 'Return at most 30 lines: conclusions, file paths with line numbers, and recommended next steps. Do NOT include file contents or code blocks longer than 5 lines.' If a subagent violates the contract, extract the conclusions once and never re-paste its raw output.

### bounded-command-output [high | on-demand | token-efficiency]
TRIGGER: About to run a build, install, full test suite, linter, or any command that may emit more than ~100 lines.
MECHANISM: Weaker models run commands with unpredictable output sizes unguarded — full builds, `npm install`, `git log`, printing log files — and a single 5,000-line dump enters context verbatim. One unbounded build log can consume more of the window than all useful work so far, and it recurs every retry.
EXAMPLE: Model runs the Inno Setup / npm build directly; 3,000 lines of compiler output flood context. The one relevant error line is at line 2,741. Next retry adds another 3,000 lines.
RULE:
Before running any command whose output size you cannot predict (builds, installs, full suites, git log, linters): cap it. Use `git log -n 20`, Grep head_limit, `| Select-Object -First 50` / `| tail -50`. For builds and suites expected to exceed ~100 lines, redirect to a log file and extract only failures: `cmd *> build.log` then `Select-String -Path build.log -Pattern 'error|fail|warning' | Select-Object -First 30` (or grep -iE on POSIX). Never print an entire log file into context.

### speculative-exploration-gate [medium | on-demand | token-efficiency]
TRIGGER: About to Read or Grep a file that neither the task statement nor a prior search hit identified as relevant.
MECHANISM: Weaker models 'build understanding' by wandering: opening sibling modules, utils files, and tests unrelated to the task because reading feels like progress. Each detour file permanently occupies context, and by the time the real edit starts, the window is half-full of code that will never be touched.
EXAMPLE: Task: fix a typo in the date formatter. Model reads formatter.py (correct), then also utils.py, constants.py, the test helpers, and __init__.py 'for context' — 4 files and ~10k tokens contributing nothing to a one-line change.
RULE:
Before opening any file outside the modules the task names or that a search hit points to, state in one line the specific task question that file answers (e.g. 'does anything else import make_token?'). If you cannot phrase the question, do not open the file. 'Understanding the codebase' and 'getting context' are not questions.

### assumption-word-tripwire [high | on-demand | token-efficiency]
TRIGGER: You are about to write a hedged claim about how this repo's code behaves without having read the relevant code this session.
MECHANISM: Weaker models paper over missing context with hedge words — 'this probably calls X', 'the config presumably lives in Y' — and then act on the guess. A wrong guess costs a full edit-fail-debug cycle; the Grep that would have resolved it costs ~50 tokens. The hedge words themselves are a reliable, mechanically detectable signal that a read is being skipped.
EXAMPLE: Model writes 'the handler is presumably registered in app.py' and edits app.py; registration actually happens via a decorator in routes/__init__.py, so the edit is dead code and the feature 'mysteriously' doesn't work.
RULE:
If your next sentence would contain 'probably', 'presumably', 'likely', 'I assume', or 'should be' about code in this repository, delete the sentence and run the Grep/Read that answers it instead. One wrong assumption costs roughly 10x the tokens of the lookup that prevents it. Guessing about verifiable repo facts is never the token-efficient move.

### final-answer-budget [medium | on-demand | token-efficiency]
TRIGGER: The task is complete and you are composing the closing reply.
MECHANISM: Weaker models end tasks with long recaps: restating the request, narrating the journey, re-explaining each file, and pasting the diff they just applied. The user saw all of it happen; the recap is pure duplication and often the single largest prose block in the session.
EXAMPLE: A 3-file fix ends with a 60-line answer containing a 'Summary of changes' section, the full code of each changed function pasted again, and a 'Next steps you might consider' list nobody asked for.
RULE:
Final answer for a routine task: at most 10 lines. Contents: (1) one line per changed file — path:line and what changed; (2) the exact verification command run and its observed result; (3) open risks or skipped items, if any. No code blocks unless the user must copy the code to act; no restating the request; no narrating the process.

### skip-generated-artifacts [medium | on-demand | token-efficiency]
TRIGGER: A search hit, listing, or hunch points at a lockfile, build output, minified asset, or vendored dependency.
MECHANISM: Search results and directory listings surface lockfiles, dist/ bundles, and minified files; weaker models Read them like source. A package-lock.json alone can be 20,000+ lines — one accidental Read can consume a third of the window with machine-generated noise that answers nothing.
EXAMPLE: Investigating a dependency issue, the model Reads package-lock.json in full (18k lines truncated at 2,000, still ~30k tokens) when `Grep '"lodash"' package-lock.json -A 2` would return the 3 relevant lines.
RULE:
Never Read package-lock.json, yarn.lock, poetry.lock, dist/, build/, coverage/, *.min.*, *.map, node_modules, or vendored directories. If one of these holds the answer (e.g. an installed version), extract the specific lines with a Grep on that file. Add glob excludes to repo-wide searches so these paths never appear in results.

### broad-grep-triage [medium | on-demand | token-efficiency]
TRIGGER: A Grep just returned more than 50 matches (or was truncated by head_limit).
MECHANISM: A too-generic pattern ('get', 'config', 'user') returns hundreds of hits; weaker models scroll through them all in content mode or start Reading each hit file, turning one bad search into a context flood. The correct move — measure the shape first, then narrow — is a two-step plan they skip.
EXAMPLE: Model greps 'handler' in content mode across the repo: 400 matching lines enter context; it then begins Reading the first six hit files one by one instead of narrowing to 'registerHandler\(' with a type filter.
RULE:
If a Grep returns more than 50 matches, do not read through them and do not start opening hit files. Re-run with output_mode 'count' or 'files_with_matches' to see the distribution, then narrow with a stricter pattern, a glob/type filter, or a path restriction. If no narrowing gets under ~50 relevant hits, the job is a sweep — delegate it to a subagent.

### single-full-read-per-large-file [medium | on-demand | context-degradation]
TRIGGER: After the first full Read of any file >300 lines (record the map); on every subsequent need to consult that file (range-read, not full read).
MECHANISM: Weaker models re-Read the same large file in full every time they return to it, because re-reading feels safer than trusting notes. Each redundant full read bloats context, which triggers compaction sooner, which erases more state, which causes more uncertainty and more re-reading — a self-reinforcing degradation spiral. Recording a structure map after the first read makes targeted range reads possible and breaks the loop.
EXAMPLE: A 1,400-line api/handlers.py is Read in full at turns 15, 38, 51, and 67 — four copies, roughly 60k tokens, in context. Compaction fires at turn 70 and wipes the debugging state; the file's contents were the only thing reliably preserved, four times over.
RULE:
Read a file longer than 300 lines in full at most ONCE per session. Immediately after that first read, record a 3-6 line structure map under STATE.md `## Facts` (key symbols + their line ranges). All later visits use Read with offset/limit on the relevant range, or Grep for the symbol. If your map seems stale after edits, re-map with `Grep -n 'def |class |function '`-style queries, not a full re-read.

### one-line-imperative-no-prose [high | core | instruction-format]
TRIGGER: Writing or editing any rule in CLAUDE.md or a guardrail doc.
MECHANISM: Attention compresses prose paragraphs into gist; the actionable specifics buried mid-sentence are dropped, and hedge words ('usually', 'consider', 'try to') are read as optional. A one-line rule that opens with either an imperative verb or a When/Before/After trigger clause is stored as an executable action and is indexed by its opening tokens — the model recognizes it at event time. Action-first conditionals ('Grep call sites when changing signatures') bury the condition and fail to fire; trigger-first ('Before changing any signature: Grep call sites') fires.
EXAMPLE: Paragraph: 'It's generally a good idea to look at how a function is used before modifying it, since callers may depend on its current shape...' — model changes a signature without grepping. One-liner 'Before changing any function signature: Grep all call sites and list them' — complied.
RULE:
Format contract (kit authoring): every rule is one line, <=20 words, and starts with either an imperative verb or a trigger clause (`When/Before/After <observable event>:`). No paragraphs. No hedges (usually/consider/try/generally). A rule that needs two sentences belongs in a guardrail doc, not CLAUDE.md.

### claude-md-rule-budget-cap [critical | core | instruction-format]
TRIGGER: Any edit that adds content to CLAUDE.md.
MECHANISM: Always-on rule compliance is roughly constant-sum: beyond ~15 iron rules / ~50 lines, the model treats the file as background ambience and obeys only whichever rules happen to be salient. Each rule added over budget silently taxes compliance with all the others. A hard numeric cap with a forced trade (add one = demote one) keeps the file inside the compliance envelope; demoting to an on-demand doc restores salience via the trigger.
EXAMPLE: A 300-line CLAUDE.md with 60 rules: the model violates 'never push without confirmation' at line 41 — a rule it reliably obeys when the file contains 12 rules — because the line never surfaced above the noise floor.
RULE:
CLAUDE.md hard budget: <=15 iron rules, 1 routing table, <=50 lines total. To add a rule over budget, delete or demote an existing rule to a guardrail doc in the same edit. Never merge two rules into one line to dodge the cap.

### caps-emphasis-budget [high | core | instruction-format]
TRIGGER: Writing or editing kit files; any urge to add emphasis to a rule.
MECHANISM: MUST/NEVER/ALWAYS work as contrast signals: they mark a rule as categorically different from its neighbors. When most lines shout, the contrast carries zero information and the model regresses to treating all rules — including the genuinely dangerous ones — as equally soft suggestions. Rationing caps to a handful of irreversible-damage rules preserves the signal exactly where it pays.
EXAMPLE: A kit with 45 MUST lines: the model violates 'MUST not force-push over teammates' history' exactly as readily as 'MUST prefer f-strings', because the two lines are visually and statistically identical.
RULE:
Caps budget: NEVER/ALWAYS/MUST may appear on at most 5 lines in CLAUDE.md, reserved for irreversible damage (data loss, killed processes, pushed history, secrets). Every other rule is a plain imperative. Adding a 6th caps line requires downgrading one.

### doc-shape-checklist-first [high | on-demand | instruction-format]
TRIGGER: Creating or editing any docs/guardrails/*.md file.
MECHANISM: Weaker models read top-down and begin acting before finishing long documents; if the actionable checklist sits below rationale, it is never reached, and docs beyond ~150 lines get skimmed rather than read. Fixing the shape — trigger restated on line 1, numbered checklist in lines 2-15, everything else demoted below a divider, hard length cap — guarantees the mandatory content lands even in a partial read.
EXAMPLE: A 300-line DEBUG.md opening with debugging philosophy, with the actual procedure at line 240: the model reads ~80 lines, extracts 'be systematic', and resumes randomly mutating code.
RULE:
Every guardrail doc has this shape: line 1 restates the trigger ('You are here because <event>'); lines 2-15 are the numbered checklist — the only mandatory part; all rationale, examples, and edge cases sit below a `--- reference ---` divider; hard cap 120 lines. If a doc must grow past 120, split it by trigger and add a routing row instead.

### eight-word-why-clause [medium | core | instruction-format]
TRIGGER: Writing or editing any iron rule in CLAUDE.md.
MECHANISM: A <=8-word parenthesized reason lets the model reconstruct a rule when its wording degrades (compaction, paraphrase) and pre-empts 'this rule doesn't apply here' rationalization by making the harm and scope self-evident. Longer rationale backfires: it invites the model to debate the reasoning, and it burns always-on budget. The reason must name the concrete harm, not restate the rule.
EXAMPLE: 'NEVER taskkill /F /IM node.exe' alone: model does it inside what it believes is an isolated context, assuming the rule is about tidiness. With '(kills Claude Code itself)' it understands the blast radius and applies the rule everywhere.
RULE:
Format contract: every iron rule in CLAUDE.md ends with a parenthesized reason, <=8 words, naming the concrete harm — e.g. `(kills Claude Code itself)`, `(callers break silently)`, `(history loss is unrecoverable)`. No multi-sentence rationale in CLAUDE.md; long rationale goes below the divider of the owning guardrail doc.

### single-source-pointers-only [high | core | instruction-format]
TRIGGER: Adding any rule; noticing overlapping guidance across kit files.
MECHANISM: When CLAUDE.md paraphrases a guardrail doc's rule, two versions of the rule now exist and drift over time; weaker models resolve the conflict by satisfying the weaker/vaguer version (usually the CLAUDE.md paraphrase) and stopping, or by oscillating between versions across turns. Single-sourcing — each rule lives in exactly one file, CLAUDE.md only routes — removes the conflict class entirely and keeps the always-on file inside budget.
EXAMPLE: CLAUDE.md says 'run tests before claiming done'; VERIFY.md says 'run tests AND lint AND paste output lines'. The model runs pytest only, cites the CLAUDE.md line as satisfied, and never opens VERIFY.md because it believes it already knows the verification rule.
RULE:
Format contract: a rule lives in exactly one file. CLAUDE.md never summarizes or previews guardrail-doc content — it only routes to it. If the same rule appears in two kit files, delete the copy outside its home doc in the same edit.

### first-and-last-block-placement [medium | core | instruction-format]
TRIGGER: Structuring or reorganizing CLAUDE.md.
MECHANISM: Serial-position/lost-in-the-middle effects: attention over an injected file is strongest at its start and end; identical rules placed mid-file measurably underperform. Since the routing table is the kit's multiplier (it arms everything else) it must be the first content block; the few caps-lock NEVER rules gain recency by being the final block; the middle of CLAUDE.md must contain nothing whose loss would be expensive.
EXAMPLE: The never-push rule at line 34 of a 60-line CLAUDE.md gets violated; the same rule as the file's final block, after the routing table was moved to the top, is complied with.
RULE:
CLAUDE.md layout: the routing table is the FIRST content block; the <=5 NEVER lines plus the post-compaction re-arm line are the LAST block; everything in between must be droppable without serious harm. Never place an iron rule in the middle third of the file.

### controlled-tool-verb-vocabulary [medium | core | instruction-format]
TRIGGER: Writing any directive in any kit file.
MECHANISM: Weaker models bind instructions to tool invocations by lexical match: 'Read docs/guardrails/DEBUG.md' evokes the Read tool directly, while 'see / consult / refer to the debug guide' produces only a verbal acknowledgment with no tool call. Synonym variety across the kit also weakens the routing table's pattern-match. Restricting kit verbs to actual tool names, and always writing full literal paths, makes every directive directly executable and greppable.
EXAMPLE: Routing row 'see DEBUG.md for debugging' -> model replies 'I should check the debug guide' and continues editing; row 'Read docs/guardrails/DEBUG.md' -> model emits the Read tool call.
RULE:
Format contract: kit verbs are tool names — Read, Grep, Edit, Write, Run (Bash). Never write see/consult/check/refer-to/review when a tool call is meant. Every doc reference is the full literal path `docs/guardrails/<NAME>.md`, never 'the <name> guide'.

## SESSION (19 findings)

### stale-context-edit [high | on-demand | bug-injection]
TRIGGER: Before any Edit when a tree-modifying event or a 20+ tool-call gap has occurred since that file was last Read.
MECHANISM: In long sessions the model edits from its memory of a Read performed dozens of turns ago, but the file has since changed — its own earlier edits, a formatter/codegen run, a git checkout/pull/stash, or the user editing in parallel. After compaction the 'memory' may even be a lossy summary. old_string mismatches are the lucky case; the unlucky case is a match against moved code, patching the wrong location.
EXAMPLE: Forty turns after reading server.ts, the model edits it from memory; meanwhile prettier ran as part of the test script and rewrapped the region. The Edit matches a now-different but similar block and inserts the middleware into the wrong route group.
RULE:
Re-Read the target region before editing if ANY of these occurred since your last Read of that file: a formatter/linter/codegen run, any test script that may write files, any git command touching the working tree (checkout, pull, stash, merge, reset), a compaction event, the user stating they changed files, or 20+ intervening tool calls. Never construct old_string from memory after any of these events.

### todo-completion-requires-evidence [high | on-demand | false-completion]
TRIGGER: About to mark any todo, plan step, or STATE.md item complete.
MECHANISM: Todo state changes cost nothing, so weaker models flip items to complete when the associated edit lands, conflating 'I performed the action' with 'the outcome occurred'. The todo list then reads as verified progress while nothing has run — and survives compaction as false history.
EXAMPLE: Todo 'fix flaky websocket test' marked complete after editing a timeout; the test was never re-run and still flakes 1 in 5.
RULE:
When creating a todo, append its acceptance command in parentheses. Mark it complete ONLY in a turn where that command's passing output appears. If the edit landed but nothing ran, use the distinct state 'edited, unverified' — never 'complete'. The same applies to STATE.md entries: record verification status per item, not just 'done'.

### checkpoint-before-compaction [high | on-demand | token-efficiency]
TRIGGER: A milestone completes in a multi-hour task; or you notice the session has accumulated many file reads and is likely to compact.
MECHANISM: In long sessions, compaction discards the middle of the transcript. If accumulated findings (call-site lists, decisions, verified facts) live only in-context, the post-compaction model re-explores everything from scratch — the most expensive waste pattern there is, because it repeats hours of tool calls. Weaker models do not anticipate compaction; they need a triggered checkpoint.
EXAMPLE: After 2 hours mapping a migration across 30 files, compaction fires; the model no longer remembers which 12 files were already converted and re-reads all 30, re-deriving the same list.
RULE:
At every milestone, and immediately when context feels heavy in a long task (many files read, long transcript): append to docs/STATE.md the current goal, decisions made, verified facts as path:line bullets, and next steps — written for a reader with zero context. After any compaction, recovery must be one Read of docs/STATE.md; re-exploring files already dispositioned there is forbidden.

### same-turn-constraint-capture [critical | core | context-degradation]
TRIGGER: Any user message containing a prohibition, scope restriction, stated preference, or correction of your behavior.
MECHANISM: A constraint stated once in a chat message ('don't touch the auth module') has no structural salience — it is just tokens at position N. As context grows, weaker models weight recent tokens and strong priors ('refactoring adjacent code is helpful') over a 40-turn-old sentence. Fable retrieves such constraints reliably from raw context; Opus/Sonnet measurably do not past ~50 turns or across a compaction. The only reliable fix is moving the constraint out of ephemeral chat into a persistent artifact at the moment it is stated — the capture window is the same turn, because by the next milestone the model no longer flags the sentence as special.
EXAMPLE: Turn 6: user says 'whatever you do, leave payments/stripe_client.py alone — it's pinned to the prod API version.' Turn 52, while fixing an unrelated type error, the model 'helpfully' upgrades the Stripe client call signatures in that file. The constraint was never violated deliberately; it simply stopped being retrieved.
RULE:
The moment the user states any prohibition, scope limit, preference, or behavior correction ('don't touch X', 'keep Y as-is', 'only change Z', 'stop doing W'), append it VERBATIM as a bullet under `## Constraints` in docs/STATE.md before taking any other action that turn. If the user corrects the same behavior a second time, tag the bullet `[RECURRING]` and re-read the `## Constraints` block before every file edit for the rest of the session.

### state-md-template-and-update-triggers [critical | on-demand | context-degradation]
TRIGGER: Session start on any non-trivial task creates the file; the six listed events each force an update in the same turn.
MECHANISM: Weaker models keep goal, constraints, decisions, and progress as implicit context, all of which decay together. A single always-current external artifact with FIXED section names gives the model a fill-in-the-blank structure (no judgment needed about what to record where) and gives every other guardrail a concrete place to read from and write to. Without exact update triggers, weaker models update state 'when it feels right', which converges to never.
EXAMPLE: A 4-hour session implements a migration across 12 files. Compaction hits at hour 3. The summary preserves 'working on migration' but loses which 7 files were finished, the decision to keep the old table as a view, and the user's instruction to not run the destructive step. The model re-does file 3 and runs the destructive step.
RULE:
Maintain docs/STATE.md with EXACTLY these sections: `## Goal` (the user's original request, one line, near-verbatim) / `## Now` (current step) / `## Next` (ordered remaining steps) / `## Constraints` (verbatim user limits) / `## Decisions` (what — why, one line each) / `## Facts` (canonical ports, paths, commands, versions, key symbol locations) / `## Done` (milestone — evidence) / `## Open items` (deferred TODOs) / `## Failed attempts` (during active debugging). Update triggers — each mandatory, same turn: (1) task start: write Goal/Now/Next; (2) user states a constraint or answers a design question: Constraints/Decisions; (3) a milestone completes: Done + refresh Now/Next; (4) a design decision is made: Decisions; (5) before any command expected to run >2 min or emit >200 lines; (6) end of work block. Keep the file under 80 lines; write every line for a reader with zero chat context.

### post-compaction-recovery-procedure [critical | core | context-degradation]
TRIGGER: The first turn after any context compaction (auto or /compact), before any Edit/Write/Bash that modifies state.
MECHANISM: Compaction replaces the transcript with a lossy summary that is biased toward narrative ('we fixed the parser') and drops specifics (which files changed, what was NOT done, exact constraints). Weaker models treat the summary as ground truth and act on its confident-but-wrong claims. The recovery procedure must be in always-loaded CLAUDE.md because immediately post-compaction is precisely when on-demand doc-reading habits are most degraded.
EXAMPLE: Post-compaction summary says 'updated the config loader and its tests'. In reality only the loader was edited; the test update was planned but not done. The model claims completion, commits, and CI fails — or worse, it Writes a file based on the summary's paraphrase of its contents, clobbering real code.
RULE:
After any compaction (the transcript begins with a summary block): before ANY file-modifying tool call, (1) Read docs/STATE.md in full; (2) run `git status` and `git diff --stat`; (3) restate in one line the Goal and the current Next step. Treat every compaction-summary claim about file contents or completed work as UNVERIFIED until confirmed by Read/git evidence.

### detour-stack-with-depth-limit [high | on-demand | context-degradation]
TRIGGER: The moment you begin work on any problem that was not in the original request or the approved plan; and the moment such work completes.
MECHANISM: Weaker models hold the goal stack implicitly: when fixing sub-problem C of sub-problem B of task A, the return addresses to B and A live only in attention, and popping the stack fails silently — the session ends inside the rabbit hole with A untouched. Writing an explicit one-line push/pop makes the stack survive in-context decay AND compaction, and a hard depth limit converts 'am I too deep?' (judgment) into a countable rule.
EXAMPLE: Task: 'add pagination to the orders endpoint'. Model hits a failing import → detours to fix the module layout → hits a circular dependency → detours to restructure two packages → session ends with a half-done package restructure, zero pagination, and the user asking what happened to their feature.
RULE:
Before starting ANY work not in the original request (a blocking sub-problem), write one line: `DETOUR(depth n): <sub-problem> — RETURN-TO: <the step you left>` and mirror it in STATE.md `## Now`. When it resolves, write `RETURNING: <step>` and resume there. Maximum detour depth is 2: if resolving a depth-2 detour requires another detour, STOP and present the chain to the user instead of descending.

### anchor-line-before-major-steps [high | core | context-degradation]
TRIGGER: At the start of every new top-level step or phase, and immediately after any RETURNING line.
MECHANISM: Goal drift is gradual — each individual step looks locally reasonable, and weaker models never perform the global check 'does this still serve what the user asked?'. Forcing a one-line restatement of the original goal at every phase boundary makes drift self-detecting: the moment the model cannot honestly connect the step to the goal, the drift becomes visible in the transcript instead of continuing silently. Cost: one line per phase.
EXAMPLE: Asked to 'make the CSV export handle unicode', the model notices the exporter is untested, writes a test harness, notices the harness needs fixtures, builds a fixture system — 30 turns on infrastructure, and the two-line encoding fix never happens.
RULE:
Before each new major step (starting a new todo/phase, or resuming after a detour), write one line: `ANCHOR: goal=<original request in <=15 words> | this step serves it by <reason>`. If you cannot truthfully complete the line, stop, re-read STATE.md `## Goal`, and either re-plan or ask the user.

### decision-registry-no-silent-reversal [high | on-demand | context-degradation]
TRIGGER: Same-turn capture whenever a design choice is settled; registry scan before adding any dependency, introducing a new pattern, or scaffolding a new module.
MECHANISM: Design decisions made early (library choice, naming scheme, API shape, an answered clarifying question) live only in chat context; 60 turns later the weaker model re-derives the choice from priors and lands somewhere else without noticing the contradiction — producing codebases that use two patterns for the same thing. Fable notices self-contradiction; weaker models need the earlier decision written down and a rule that reversal must be explicit, which makes accidental reversal detectable.
EXAMPLE: Turn 12: user answers 'use zod for all input validation'. Turn 70, adding a new endpoint post-compaction, the model hand-rolls validation with if-statements — not rebellion, just re-derivation from priors. Now the codebase has two validation idioms and the user's explicit answer was overridden silently.
RULE:
When a design decision is made — by you or by the user answering a question — append `DECISION: <what> — <why>` to STATE.md `## Decisions` in the same turn. Before introducing any new dependency, pattern, or naming scheme, scan `## Decisions`: either conform to the recorded decision, or write `REVERSING DECISION '<text>' because <new evidence>` and get user confirmation. Silently deviating from a recorded decision is forbidden.

### open-items-same-turn-capture [high | on-demand | context-degradation]
TRIGGER: The moment any deferral phrase is generated or any secondary work is discovered and not done immediately.
MECHANISM: Mid-task the model notices secondary work ('this also needs a migration — I'll do it after') and states the intention in prose. Prose intentions are not a queue: nothing re-surfaces them, and by the time the main task ends they have scrolled out of attention. Weaker models drop these near-100% past ~30 turns. The countermeasure is converting every 'later' into a ledger entry at the instant the word is generated — the phrase itself is the trigger.
EXAMPLE: While renaming a config key, the model writes 'the docs and the sample .env also reference the old key; I'll update them after the code changes.' The code changes take 25 turns, tests pass, work is declared complete — docs and .env still carry the dead key, breaking the next fresh clone.
RULE:
Any time you write or decide 'later', 'after this', 'also need to', 'TODO', or defer any discovered work, add it as a bullet to STATE.md `## Open items` in the SAME turn — a deferred item that exists only in prose does not exist. Items leave the list only by being completed (move to `## Done` with evidence) or by being explicitly reported to the user as intentionally not done.

### done-ledger-blocks-rework [medium | on-demand | context-degradation]
TRIGGER: On completion of any milestone/investigation (write); before starting any operation expected to take >2 minutes or read >5 files (check).
MECHANISM: Post-compaction (or simply deep into context), weaker models forget that an expensive investigation or setup already happened and re-run it — re-auditing the same call sites, re-installing dependencies, re-reading a whole subsystem. Each repeat wastes tokens AND accelerates the next compaction, compounding the amnesia. A Done ledger with recorded RESULTS lets the model reuse conclusions instead of re-deriving them.
EXAMPLE: Hour 1: a 15-minute audit establishes that only 3 of 40 call sites pass the deprecated flag, recorded nowhere. Hour 3, post-compaction, the model re-runs the entire audit from scratch because the summary only said 'audited call sites' without the result.
RULE:
When any milestone or expensive investigation completes, record it under STATE.md `## Done` as `<what> — RESULT: <the conclusion/numbers>` — the result, not just the activity. Before starting any expensive operation (full test suite, multi-file audit, dependency install, long build), check `## Done` for a matching entry and reuse its recorded result unless files it depended on have changed since.

### stale-environment-reverify [high | on-demand | context-degradation]
TRIGGER: Any dependence on environment state last verified >15 messages ago or across a compaction; step 1 of diagnosing any previously-working behavior that now fails.
MECHANISM: Beliefs about live environment state (dev server running, port bound, package installed, branch checked out, env var exported) are snapshots that silently expire — processes crash, sandboxed shells reset, the user intervenes between turns. Weaker models carry these beliefs indefinitely and then misdiagnose the resulting failures as code bugs, launching doom loops against a phantom.
EXAMPLE: Turn 30: dev server started on port 3000. Turn 75: a curl check returns connection refused; the model concludes its latest route change broke the app and spends 10 turns reverting code — the server had simply died when the terminal session reset.
RULE:
Before relying on any claim about live environment state (server up, port bound, package installed, artifact fresh, branch/env var set) that is older than 15 messages or predates a compaction, re-verify it with one command (`netstat -ano | findstr :PORT`, `pip show X`, `git branch --show-current`, ...) and record the canonical value in STATE.md `## Facts`. When debugging any 'it stopped working' failure, environment re-verification is step 1, before touching code.

### canonical-facts-ledger-no-identifiers-from-memory [high | on-demand | context-degradation]
TRIGGER: Establishing any canonical value (write); using any exact identifier/path/command last seen >10 messages ago (copy, don't recall); any not-found error on a value you typed (check ledger first).
MECHANISM: Late in long contexts, weaker models corrupt exact strings: port 8000 becomes 8080, `get_user_by_id` becomes `getUserById`, `src/utils/date.ts` becomes `src/util/dates.ts`. These near-miss hallucinations are especially dangerous because they look plausible and produce confusing downstream errors (or silently create a duplicate file at the wrong path). Exact strings must be copied from an artifact, never regenerated from a degraded memory.
EXAMPLE: The run command established at turn 5 was `python -m app.server --config dev.yaml`. At turn 80 the model types `python -m app.main --config config/dev.yaml`, gets ModuleNotFoundError, and starts 'fixing' the package layout.
RULE:
Keep canonical exact values — ports, file paths, run/test commands, versions, key function and table names — in STATE.md `## Facts`, added the turn they are established. Never type such a value from memory if it was last seen more than 10 messages ago: copy it from `## Facts` or re-derive it with a fresh Grep/Glob/Read. If a 'not found' error involves a name or path you typed, your first check is against `## Facts`, not the codebase.

### checkpoint-before-long-output-operations [medium | on-demand | context-degradation]
TRIGGER: Immediately before launching any command expected to produce >200 lines of output or run >2 minutes; before any manual /compact.
MECHANISM: Auto-compaction fires when the context fills, and it fills fastest immediately after huge tool outputs (full test suites, verbose builds, big file dumps) — precisely when in-context state (current hypothesis, attempts log, next steps) is at maximum value and minimum persistence. Weaker models cannot predict compaction; a mechanical pre-flight rule keyed to output size makes the checkpoint happen before the risk, not after the loss.
EXAMPLE: Deep in debugging with 4 attempts logged only in chat, the model runs the full 3,000-line test suite. The output triggers auto-compaction; the summary keeps 'debugging test failures' and drops all four attempted fixes. The model re-tries attempt 1.
RULE:
Before any command expected to emit >200 lines or run >2 minutes, and before any /compact: first bring STATE.md `## Now`, `## Next`, and `## Failed attempts` up to the present moment. Then route the long output to a file (`cmd > out.log 2>&1`) and inspect it with Grep/tail instead of dumping it into context.

### handoff-must-read-standalone [medium | on-demand | context-degradation]
TRIGGER: Every write to STATE.md — especially at end of work block, after milestones, and when the PreCompact reminder fires.
MECHANISM: When weaker models update state files, they write relative to the current conversation ('finish the fix we discussed', 'the second approach worked') — references that dangle the moment the context is compacted or the session ends. State written this way passes a lazy self-check but is useless to the post-compaction reader, which is effectively a fresh model. The countermeasure is a concrete standalone-readability test applied line by line.
EXAMPLE: STATE.md says 'Next: apply the same fix to the other two files.' After compaction, neither the fix nor the files are recoverable — the note pointed into a transcript that no longer exists, and the model has to re-derive everything or guess.
RULE:
Every STATE.md update must read correctly to a fresh Claude with ZERO chat context: no 'the fix we discussed', 'as above', 'the other file' — every line names explicit files, commands, symbols, and outcomes. Self-check before saving: for each line, could a fresh session act on it without the transcript? Keep the file under 80 lines by deleting Done entries older than the current milestone group; never let precision decay to save space — cut old entries, not specifics.

### routing-table-event-phrased-triggers [critical | core | instruction-format]
TRIGGER: Authoring the CLAUDE.md routing table; at runtime, each listed observable event.
MECHANISM: Weaker models route by surface-matching context text against their own current situation/output, not by classifying their activity into abstract categories. A routing row keyed on a category noun ('debugging', 'verification') never fires because the model never self-labels its activity that way; it experiences concrete events ('pytest exited 1', 'about to type: done'). Triggers phrased as second-person observable events match tokens the model actually generates, so the row fires. Also, >7-8 rows or overlapping rows cause the model to match none: keep exactly one doc per trigger and add an explicit fallback row for ambiguity.
EXAMPLE: Kit says 'For debugging guidance see DEBUG.md'. Model spends 40 turns mutating code against a failing pytest run and never opens DEBUG.md, because at no point did it think the word 'debugging' — it thought 'the test still fails'. A row keyed on 'see a failing test, non-zero exit, or traceback' would have matched its literal situation on turn 1.
RULE:
## Routing — the moment X happens, Read the doc BEFORE your next tool call
| The moment you... | Read |
|---|---|
| start any task needing >2 file edits or touching >1 component | docs/guardrails/PLAN.md |
| are about to make your first Edit/Write of this session | docs/guardrails/CODE.md |
| see a failing test, non-zero exit, traceback, or output that surprised you | docs/guardrails/DEBUG.md |
| are about to write "done", "fixed", "works", or run git commit | docs/guardrails/VERIFY.md |
| notice context >50% used, or are about to Read a 3rd large file | docs/guardrails/EFFICIENCY.md |
| return from compaction or /resume, or can't recall how the session started | docs/guardrails/SESSION.md |
| are unsure which row applies | docs/guardrails/PLAN.md |

### route-then-announce-contract [critical | core | instruction-format]
TRIGGER: Any routing-table row matches the current situation.
MECHANISM: Even when a weaker model recognizes a trigger, soft phrasing ('see', 'consult') lets it defer the Read indefinitely, and the intention decays within one turn. Requiring the Read to be the literal NEXT tool call, preceded by a fixed one-line announcement, converts routing from a scheduling preference into a checkable protocol: an outside observer can grep the transcript for 'TRIGGER:' lines and verify each was followed by the Read. The '(cached)' escape hatch prevents the model from rationalizing skips as 'already know it' while still avoiding redundant reads.
EXAMPLE: Model thinks 'I should check the verification checklist before finishing' — then commits, replies 'Done!', and never opens VERIFY.md. With the contract, the absent 'TRIGGER: about to claim done -> VERIFY.md' line is an immediately visible violation.
RULE:
When any routing row matches: write one line `TRIGGER: <event> -> <doc>` and make your NEXT tool call Read on that doc. If you already Read that doc since the last compaction, write `TRIGGER: <event> -> <doc> (cached)` and obey its checklist from memory. Never act on a matched trigger without one of these two lines.

### literal-anchor-tokens [high | core | instruction-format]
TRIGGER: Writing or editing any rule; reviewing kit files for compaction-survivability.
MECHANISM: Compaction summaries and the model's own paraphrasing preserve distinctive literal tokens (commands, paths, numbers) but destroy abstract phrasing — 'review your changes before committing' compacts to nothing, while 'run `git diff --stat` before every commit' survives as the command string. Literal tokens are also directly executable: weaker models run a quoted command far more reliably than they operationalize a described intention.
EXAMPLE: After compaction, the summary reads 'user has some git preferences' and the never-push rule is gone; the model pushes. Had the rule been 'NEVER `git push` unless the user wrote the word "push" in this conversation', the distinctive `git push` token survives summarization and the rule remains enforceable.
RULE:
Format contract: every rule names its exact command, file path, or number (`git diff --stat`, `docs/STATE.md`, `>=2 call sites`) — never only an abstraction. If a rule contains no greppable literal token, rewrite it until it does or move it out of the kit.

### post-compaction-rearm-line [critical | core | instruction-format]
TRIGGER: Returning from compaction or /resume; noticing the conversation summary replaced earlier turns.
MECHANISM: After compaction, guardrail docs read earlier are gone from context, but the model believes it still 'knows' them and continues on degraded summaries; the routing table's '(cached)' escape now silently licenses skipping every doc. Because CLAUDE.md is re-injected after compaction, a final self-referential line there is the one place guaranteed to survive and can explicitly revoke the cache and re-arm routing.
EXAMPLE: Pre-compaction the model read VERIFY.md and followed it. Post-compaction it claims 'done' citing a vague memory of 'the checklist', having actually run nothing — the checklist items no longer exist in context.
RULE:
After compaction or /resume: Read docs/STATE.md, then re-run the routing table against your current activity. Docs read before compaction no longer count as read — `(cached)` is invalid until you Read the doc again. (This is the last line of CLAUDE.md; it stays last.)

## MIGRATE (20 findings)

### incomplete-rename-residue [high | on-demand | bug-injection]
TRIGGER: After completing edits for any rename, before reporting it done.
MECHANISM: Renames touch more surfaces than code: string literals, config keys, CI YAML, docs, test names, serialized fixtures, shell scripts. The model renames the definition plus whatever references are in context and stops — grep-by-file-type filters (only *.py) make it worse by design.
EXAMPLE: Model renames `LEGACY_QUEUE` to `TASK_QUEUE` across .py files but misses the reference in docker-compose.yml env vars and one in a .github/workflows job, so staging boots with an undefined queue name.
RULE:
After the last edit of any rename (symbol, file, config key, CLI flag, env var): grep the OLD name repo-wide with NO file-type filter (`grep -rn 'oldName' .` excluding only .git), and paste the output. Required end state: zero hits, or an itemized list of intentionally-kept hits with a reason each (changelog, deprecation shim). Do not report the rename complete without this paste.

### migration-zero-grep-gate [critical | on-demand | false-completion]
TRIGGER: About to declare a rename, API migration, dependency removal, or pattern replacement complete.
MECHANISM: Weaker models track only the instances they touched, not the closed set; after N edits, 'the ones I saw' becomes 'all of them'. Declaring a migration done is a memory claim, and memory is exactly the degraded faculty.
EXAMPLE: 'Renamed getUserData → fetchUser everywhere' — two call sites in a test helper and one string-based dynamic import still reference the old name; CI breaks an hour later.
RULE:
A rename/removal/migration is complete ONLY when a fresh project-wide grep for every old identifier/pattern returns zero hits, pasted in the same turn as the done-claim. Intentional remainders (changelogs, back-compat shims) must be listed line-by-line with justification. No pasted grep = status is 'in progress', period.

### migrate-idempotent-verified-steps [medium | on-demand | instruction-format]
TRIGGER: Authoring migration instructions; performing a kit migration on an existing project.
MECHANISM: Migration instructions written as prose narratives cause weaker models to batch several steps into one sweeping edit, lose their place after interruptions or compaction, and misreport partial completion as success. Numbered idempotent steps, each pairing exactly one action with an exact verification command (expected output stated) and an explicit stop condition, make progress externally checkable, resumable mid-way, and safe to re-run.
EXAMPLE: 'Move your existing rules into the new structure and update references' -> model rewrites CLAUDE.md wholesale, silently drops 4 of 12 rules, reports success. Step 'M3: Move git rules to CODE.md. Verify: `grep -c "git push" CLAUDE.md` prints 0 AND `grep -c "git push" docs/guardrails/CODE.md` prints >=1. If not: stop, report M3.' catches the dropped rule at the step where it happened.
RULE:
MIGRATE.md format: numbered steps `M<n>`, each exactly 3 lines — (a) one action on one file; (b) `Verify:` an exact command plus its expected output; (c) `If verify fails: stop, report M<n>, do not continue.` Every step is idempotent (re-running a completed step changes nothing). After the final step, paste all verify outputs as a single `M1..Mn: OK` block — a missing entry means the migration is NOT done.

### overwrite-before-backup [critical | core | migration-risks]
TRIGGER: Before the first Edit/Write to CLAUDE.md, any nested CLAUDE.md, or .claude/settings*.json during migration.
MECHANISM: Mid-tier models treat 'rebuild CLAUDE.md' as a Write operation and overwrite the file as step one. From that moment the original exists only in lossy context memory, which compaction or a long session can erase entirely. Every later question about the original ('did I keep the deploy rule?') is answered by reconstruction, not by reading, and reconstruction drops exactly the low-salience details that mattered.
EXAMPLE: Opus writes the new kit-structured CLAUDE.md immediately, then during verification 'recalls' the old test rule as 'run the fast tests' — the original said `pytest -m 'not slow' -x` and explained the slow suite needs a fixtures VM. The flag and the reason are unrecoverable.
RULE:
MIGRATION IRON RULE: before your first Edit/Write to ANY existing instruction file, create a frozen snapshot: `cp CLAUDE.md CLAUDE.md.pre-migration-<YYYYMMDD-HHMM>` (PowerShell: `Copy-Item`), one per file touched; if the repo is clean, also `git commit` the snapshot. All later references to 'original line N' MUST be resolved by Reading the snapshot file, never from memory. Never delete or edit the snapshot; the user deletes it after accepting the migration.

### silent-rule-drop-no-ledger [critical | on-demand | migration-risks]
TRIGGER: Immediately after the backup snapshot, before composing any new file.
MECHANISM: Told to 'lose nothing', the model relies on working memory to carry ~60 lines through a multi-step rewrite. Attention concentrates on the first/last lines and on rules matching its priors; mid-file, oddly-worded, or context-dependent lines silently fall out. Without an external ledger there is no step at which the omission can even be noticed.
EXAMPLE: The line 'Dev server on 8443 — 8080 is taken by the corporate proxy' vanishes during the merge. Next session Claude starts the server on 8080 and burns 20 minutes debugging a phantom port conflict.
RULE:
Build a line-accounting inventory BEFORE designing the new file: (1) Read the snapshot and number every non-blank, non-heading line: 001, 002, ... (2) Create docs/guardrails/MIGRATION-LOG.md with a table: | # | original text (verbatim) | disposition | destination | note |. Allowed dispositions ONLY: KEPT-VERBATIM, MOVED (name target file), MERGED (see merge rule), SUPERSEDED-BY (name kit doc + rule), UNSORTED, DROPPED (reason required). (3) Print the two counts — numbered lines and table rows — and confirm they are equal before proceeding. A missing row is a procedure failure: stop and redo the inventory.

### paraphrase-kills-rules [critical | on-demand | migration-risks]
TRIGGER: Whenever writing an original rule into the new CLAUDE.md or any docs/guardrails file.
MECHANISM: LLMs are compressors: when regenerating text rather than copying it, they emit the gist. The operational payload of a rule — exact flags, ports, file names, thresholds, and the never/always qualifiers — is precisely what gist-level regeneration discards. The paraphrased rule still reads as a rule, so the loss is invisible in review.
EXAMPLE: 'Run `npm run build:win -- --sign` before packaging; unsigned builds brick the auto-updater' becomes 'Sign builds before packaging' — the actual command is gone and the consequence that made the rule load-bearing is gone.
RULE:
Carry every surviving rule by COPY-PASTE, character-identical to the snapshot. Never retype, reword, shorten, or 'clean up' original rule text. After writing each destination file, verify: for every KEPT-VERBATIM and MOVED row, grep the destination for an exact >=15-character substring of the original line and record HIT/MISS in the MIGRATION-LOG row. Any MISS means the rule was paraphrased or lost — fix it before continuing.

### many-to-one-summary-collapse [high | on-demand | migration-risks]
TRIGGER: When two or more original rules look 'coverable' by one sentence during composition.
MECHANISM: Mid-tier models optimize for tidy output. Several fiddly rules sharing a topic get 'consolidated' into one elegant sentence, which is a second paraphrase pathway: the summary is content-free ('follow project conventions') while each original rule carried a distinct constraint.
EXAMPLE: Six style rules (tabs in Makefiles, no default exports, error strings lowercase, etc.) become 'Follow the existing code style.' All six constraints are now unenforceable.
RULE:
One original line -> exactly one disposition row. NEVER fold N original rules into one summary line. Rules sharing a topic stay as separate verbatim bullets under a shared heading. The only legal many-to-one is SUPERSEDED-BY a kit rule, and each superseded line still gets its own row. MERGED is legal only for two lines that literally restate each other, and the MERGED row must quote both original texts plus the merged text.

### kit-docs-regenerated-not-copied [critical | on-demand | migration-risks]
TRIGGER: When installing any docs/guardrails/*.md kit file into the project.
MECHANISM: Models treat installation as authoring: asked to 'install DEBUG.md', they Write its content from memory, 'adapting' it to the project. Regeneration mutates the kit's calibrated wording, drops sections that exceed comfortable output length, and injects the project's vocabulary — silently forking the kit on day one.
EXAMPLE: Opus retypes the kit's DEBUG.md; the 40-line 'reproduce before you fix' procedure shrinks to 12 lines and the specific step 'paste the failing command and its output into the log before editing any file' disappears.
RULE:
Install kit docs with a file-copy command (`cp <kit>/docs/guardrails/X.md docs/guardrails/X.md` / `Copy-Item`), NEVER by Write-ing their content. After copying, prove byte-identity: run `git hash-object` (or `Get-FileHash`) on each installed file and its kit source and print the hash pairs side by side. Project-specific content goes only into CLAUDE.md's Project section or docs/guardrails/PROJECT.md — never edited into a kit doc.

### kit-core-interleaved-with-project-rules [high | on-demand | migration-risks]
TRIGGER: When composing the new CLAUDE.md.
MECHANISM: The model organizes the new CLAUDE.md thematically, weaving project rules between kit-core lines because it 'reads better'. This edits kit wording in place and makes every future kit upgrade a manual re-merge, since the kit block can no longer be replaced wholesale or even diffed.
EXAMPLE: A project rule about the test DB gets inserted into the kit's verification rules paragraph; six months later a kit upgrade either clobbers the project rule or is skipped because the merge is too scary.
RULE:
The new CLAUDE.md has exactly two zones: (1) the kit core copied verbatim between `<!-- BEGIN KIT CORE v<X> -->` and `<!-- END KIT CORE -->` markers; (2) a `## Project` section below it. Never insert, delete, or reword any line inside the markers. Verify by extracting the text between markers and diffing it against the kit's core template — the diff must be empty; print the diff command and its (empty) output.

### unflagged-rule-conflicts [critical | on-demand | migration-risks]
TRIGGER: After the inventory, before composing any new file.
MECHANISM: Conflict detection requires juxtaposing two rule sets simultaneously. A mid-tier model processes the old file and the kit sequentially and never puts the conflicting pair side by side, so both rules survive into the merged system and the model later obeys whichever it read most recently — worst case, the kit rule overrides a project safety rule.
EXAMPLE: Old CLAUDE.md: 'NEVER run the integration suite locally — it truncates the shared staging DB; CI only.' Kit VERIFY.md: 'run the full test suite before claiming done.' Merged without a flag, the next session wipes staging while dutifully 'verifying'.
RULE:
Conflict pass (mandatory, before composing): for every original line containing must/never/always/don't/only/forbidden, grep docs/guardrails/*.md for 2-3 keywords from that line and inspect hits. Record every overlap in a `## CONFLICTS` section of MIGRATION-LOG.md quoting both texts. Resolution policy: (a) project FACTS (commands, paths, ports, versions, domain constraints) always beat kit defaults — the project fact goes in the Project section; (b) kit PROCESS rules beat generic old process rules and the old line becomes SUPERSEDED-BY; (c) if an old rule explicitly forbids what a kit rule requires (or vice versa), do NOT resolve it yourself — list it and ask the user. Composing the new CLAUDE.md before the CONFLICTS section exists (minimum content: 'none found') is a procedure violation.

### duplicate-equivalent-rules-kept [medium | on-demand | migration-risks]
TRIGGER: When an old rule and a kit rule cover the same behavior.
MECHANISM: After being told 'lose nothing', the safest-feeling move is to keep both the old rule and the kit rule that says the same thing. The duplicates cost tokens forever, and they DRIFT: a future edit updates one copy, and the model thereafter obeys whichever version it happened to read, non-deterministically.
EXAMPLE: Old 'always run lint before committing' survives next to the kit's VERIFY checklist. A later session tightens the kit rule to 'lint + typecheck'; the stale duplicate still says lint-only, and half of future sessions skip typecheck.
RULE:
If a kit rule covers an old rule at equal or greater strength, mark the old line SUPERSEDED-BY:<doc>#<rule> and do NOT copy it into any new file. If the old rule adds a project-specific delta (an exact command, a stricter threshold, an extra step), keep ONLY the delta as one line in the Project section, phrased as 'In addition to <doc>#<rule>: <delta>'. The log row must quote both texts so supersession is auditable.

### relative-paths-break-on-move [high | on-demand | migration-risks]
TRIGGER: After moving any content from CLAUDE.md into a docs file, or between docs files.
MECHANISM: Moving text from CLAUDE.md into docs/guardrails/PROJECT.md changes the resolution base for relative links and @imports, but path resolution is invisible at write time — the model copies text without simulating the new base directory. Breakage surfaces sessions later as a silently dead reference or failed import.
EXAMPLE: 'See ./scripts/reset-db.sh' moves from the repo-root CLAUDE.md into docs/guardrails/PROJECT.md; the path now resolves to docs/guardrails/scripts/reset-db.sh, and a future session concludes the script was deleted.
RULE:
After each content move between files: extract every path-like token in the moved text (anything matching `\./`, `\.\./`, an `@` import, or containing `/` or `\`). For each token run an existence check from the repo root (`Test-Path` / `test -e`), rewrite relative paths as repo-root-relative, and record token -> exists? -> rewritten-as in the MIGRATION-LOG row. Remember: CLAUDE.md `@path` imports resolve relative to the file that contains them — every relocated @import must be re-verified.

### stale-facts-laundered-forward [high | on-demand | migration-risks]
TRIGGER: For every command, file path, version number, or URL being carried into the new files.
MECHANISM: Instruction files arrive in the system prompt, so models treat them as ground truth. Migration re-emits stale claims inside a fresh, authoritative-looking document — actively laundering their credibility. The model never checks because checking requires doubting its own instructions.
EXAMPLE: Old file: 'run `npm run test:all`'. The script was renamed `test` eight months ago. The migrated CLAUDE.md states it authoritatively, and every future session tries the dead script first and wastes a failure cycle.
RULE:
Do not trust the snapshot's facts. For every carried COMMAND: verify the executable or script exists (check package.json scripts / Makefile targets / `Test-Path` the script file) — do not execute anything with side effects. For every carried PATH: `Test-Path`. For every version/tool claim: check the manifest or lockfile. Anything that fails verification is carried WITH the inline tag `[UNVERIFIED <YYYY-MM-DD>: <what failed>]` and listed in the final report. Never silently drop a failing fact and never carry it untagged.

### instruction-surface-blindness [high | on-demand | migration-risks]
TRIGGER: Step 0 of every migration, before the backup.
MECHANISM: 'Migrate the CLAUDE.md' gets scoped literally to one file. But instructions also live in nested CLAUDE.md files (which override the root in their subtrees), CLAUDE.local.md, .claude/settings*.json hooks (which can inject text every session), .claude/commands/, agents/, and skills/. Unmigrated surfaces keep injecting old rules that now conflict with the kit.
EXAMPLE: A SessionStart hook injects a retired process checklist. After migration, every session receives kit rules plus hook-injected old rules that contradict them, and behavior becomes read-order-dependent.
RULE:
Phase 0 — discovery, before touching anything: run and print the results of: glob `**/CLAUDE.md`, `**/CLAUDE.local.md`; `Test-Path .claude/settings.json`, `.claude/settings.local.json`; list `.claude/commands/`, `.claude/agents/`, `.claude/skills/`; Read any hooks configured in settings and note what text they inject. Record every surface found in MIGRATION-LOG.md with a scope decision: MIGRATE / LEAVE (reason) / FLAG-to-user. Nested CLAUDE.md files are inventoried and left in place unless they conflict with kit rules (then: CONFLICTS section). The user-global `~/.claude/CLAUDE.md` is read-only context: never edit it and never copy its rules into the project file.

### install-collision-overwrites-project-docs [high | on-demand | migration-risks]
TRIGGER: Before copying any kit file whose destination path already exists.
MECHANISM: Models default to Write-with-overwrite. If the project already has its own docs/guardrails/DEBUG.md (their runbook) or a docs file whose name collides with a kit doc, a naive install destroys real project documentation — a data-loss event disguised as installation.
EXAMPLE: The project's hand-written docs/guardrails/VERIFY.md containing its release sign-off checklist is overwritten by the kit's generic VERIFY.md; the release checklist is gone.
RULE:
Before each kit file copy: `Test-Path` the destination. If it exists, hash-compare it with the kit source. Hashes equal -> log 'already installed', skip the copy. Hashes differ -> do NOT overwrite; quote the first 10 lines of the existing file, and ask the user to choose: (a) rename the existing file and install, (b) skip this kit doc, (c) back up the existing file then replace. Never resolve a collision without the user.

### non-idempotent-rerun [high | on-demand | migration-risks]
TRIGGER: The very first step of any migration invocation.
MECHANISM: An instruction-following model told 'migrate this project' executes the full recipe regardless of current state. On an already-migrated project this duplicates the Project section, re-runs supersession against the kit's own rules, and — worst — overwrites `CLAUDE.md.pre-migration` with the already-migrated file, destroying the only copy of the true original.
EXAMPLE: User re-runs migration after a kit update. Opus snapshots the migrated CLAUDE.md over the original backup, then 'migrates' the kit core into the Project section, doubling the file and losing the pre-kit original forever.
RULE:
FIRST action of the procedure: grep CLAUDE.md for `guardrails-kit:`. If found, STOP the migration and switch to UPGRADE mode: hash-compare each installed kit doc against the kit source, report drift, and touch nothing else without user direction. If you complete a fresh migration, writing `<!-- guardrails-kit: v<X> migrated <YYYY-MM-DD> -->` as line 1 of CLAUDE.md is mandatory — it is what makes this check work. Backups are always timestamped (`CLAUDE.md.pre-migration-<YYYYMMDD-HHMM>`) so no re-run can ever clobber an earlier backup.

### uncategorizable-lines-dropped-as-noise [high | on-demand | migration-risks]
TRIGGER: When an original line fits none of the disposition categories.
MECHANISM: Classification schemes leak. Old CLAUDE.md files contain TODOs, half-rules, war-story comments, and commented-out blocks that fit no category, so the model treats them as noise and drops them. But 'noise' in an old CLAUDE.md is often a hard-won landmine map.
EXAMPLE: The stray line '(don't upgrade eslint past 8 — plugin-vue breaks, see Mar incident)' fits no rule category and is dropped. Two months later a dependency-update session upgrades eslint and the build breaks exactly as documented.
RULE:
No line may be dropped because it 'does not fit'. Lines that are not clearly rules, facts, or commands go VERBATIM into docs/guardrails/PROJECT-NOTES.md under `## Unsorted (pre-migration CLAUDE.md, <date>)` with disposition UNSORTED. DROPPED is legal only for: exact duplicates within the original file, pure decoration (dividers, empty headings), and lines the user explicitly approved dropping — each with its reason in the log.

### one-shot-write-no-checkpoint [high | on-demand | migration-risks]
TRIGGER: After inventory + conflict pass, before the first Write of any new file.
MECHANISM: The model produces the final CLAUDE.md in one confident Write. Errors are now embedded in a plausible-looking artifact that a human will not diff line-by-line. A pre-write checkpoint inverts the review economics: a human can scan a 10-line drop-list in seconds but will never audit a whole rewritten file.
EXAMPLE: Opus delivers a polished new CLAUDE.md; the user skims it and approves. Three dropped rules and one unresolved conflict ship inside it, discovered only when they fire weeks later.
RULE:
CHECKPOINT — after inventory and conflict pass, BEFORE writing any new file, post in-chat: (1) disposition counts (KEPT/MOVED/MERGED/SUPERSEDED/UNSORTED/DROPPED); (2) every DROPPED line quoted verbatim with its reason; (3) the full CONFLICTS section; (4) the proposed heading skeleton of the new CLAUDE.md. Then WAIT for user approval. If the user does not explicitly approve the DROPPED list, reroute those lines to UNSORTED instead of dropping them.

### budget-blowout-or-trim-to-fit [medium | on-demand | migration-risks]
TRIGGER: When composing the Project section, and again if it exceeds 40 lines.
MECHANISM: Given 'lose nothing', the safe-feeling move is stuffing everything into the always-loaded CLAUDE.md, recreating the bloat the kit exists to remove. The failure has an evil twin: a model that notices the budget then TRIMS RULE WORDING to squeeze under it — paraphrase death by another route. The only legal compression is moving whole lines out.
EXAMPLE: Opus keeps all 55 old lines in CLAUDE.md 'to be safe'; every future session pays ~800 wasted tokens. Corrected naively, it instead shortens ten rules to fit — stripping the exact commands out of them.
RULE:
The `## Project` section of CLAUDE.md is capped at 40 lines. Allowed content: build/test/run commands, iron project constraints (data-loss, security, absolute never-do-X), and one-line trigger->doc pointers. Everything conditional (debug lore, style detail, architecture, environment quirks) moves VERBATIM to docs/guardrails/PROJECT.md, with a routing-table row `<trigger situation> -> read docs/guardrails/PROJECT.md#<anchor>`. If over cap: move whole lines out until under cap. NEVER shorten a rule's wording to fit the cap. Print the final line count of the Project section.

### completion-claim-without-evidence [critical | on-demand | migration-risks]
TRIGGER: Before declaring the migration complete, and before any commit of the migrated files.
MECHANISM: Mid-tier models declare success from intention rather than observation: having executed the steps, they assert the invariants hold without checking. A terminal checklist that demands PRINTED command output for every item converts 'I believe I kept everything' into transcript-verifiable evidence — and is the backstop that catches every earlier failure that slipped through.
EXAMPLE: Opus announces 'migration complete, all original rules preserved' — the disposition table has 58 rows for a 61-line original, two kit docs differ from source by a retyped paragraph, and the sentinel marker was never written. Nothing in the transcript would reveal any of it.
RULE:
FINAL VERIFICATION — run each item and paste its actual output; an item without printed evidence counts as FAILED: (1) row-count equality: print numbered-original-line count and disposition-row count, assert equal; (2) verbatim spot-check: for 10 random KEPT/MOVED rows (all rows if <=10), grep the destination for an exact substring of the original and print the hits; (3) hash-compare every installed kit doc against kit source, print pairs; (4) extract the KIT CORE block from CLAUDE.md and diff against the kit template, print the empty diff; (5) print the new CLAUDE.md Project-section line count (must be <=40); (6) grep line 1 of CLAUDE.md for the `guardrails-kit:` marker, print it; (7) print size + hash of the untouched pre-migration snapshot; (8) confirm docs/guardrails/MIGRATION-LOG.md is saved and print its section headings. Only after all 8 pass may you report the migration complete, and the report must repeat the DROPPED and UNVERIFIED lists.

## FORMAT NOTES

### from reasoning-errors
Cross-cutting observations for doc construction: (1) Exploit concrete instantiation everywhere — weaker models simulate small concrete examples far more reliably than they reason abstractly, so nearly every rule here demands a written trace/comment/REPL output, which also makes compliance transcript-checkable. (2) Put the trap tables (datetime, mutation, familiar-API, division/modulo) as literal markdown tables near the top of CODE.md so they function as lookup rows, not prose; models comply better with 'find your row' than 'remember the principle'. (3) The one-line REPL probe (node -e / python -c) is the cheapest available oracle — several rules route uncertainty to it with the explicit instruction 'paste the output', converting guessing into measurement. (4) Comments-as-trace ('write the invariant/interval/unit as a comment before the code') doubles as both a reasoning scaffold and an audit artifact; wherever possible rules require the artifact, not the mental act. (5) The three core-placement rules compress to one line each for CLAUDE.md: 'Computed loop/slice bounds: trace n=0,1,3 concretely first'; 'Time/size/money numbers carry unit suffixes (Ms/Sec/Bytes/Cents); verify API units, never guess'; 'Never truthiness-check values that can be 0/\"\"/false — compare to null/undefined/None; JS defaults use ?? not ||'. Each should link to its expanded CODE.md section by anchor. (6) Word all triggers as syntactic events the model can detect while typing ('writing a condition containing ! plus &&/||') rather than semantic states ('when logic is complex') — mid-tier models fire on surface features reliably and on judgment calls unreliably.

### from bug-injection
1) Trigger-first wording: every rule should open with its activation clause ('Before the first Edit of any file:', 'After changing any signature:') so a weaker model can pattern-match the situation without judgment. 2) Compliance artifact = paste: the checkable unit is always 'run X and paste the output / list the hits in the transcript'. Rules phrased with paste/list/state verbs are auditable; rules phrased with check/ensure/consider are not — ban the latter vocabulary in the docs. 3) Structure CODE.md around the tool loop the model actually executes: a BEFORE-FIRST-EDIT gate (read-before-edit, generated-file check, twin-target check), a WHILE-EDITING section (replace_all discipline, copy-paste checklist, import verification, API-signature rule), and an AFTER-EACH-EDIT section (py_compile, git diff of the hunk, callsite sweep). Matching doc structure to the edit loop makes routing self-enforcing. 4) Core CLAUDE.md should carry only the four iron rules that fire on essentially every coding turn (read-before-edit, no-unseen-API, callsite-sweep-after-signature-change, no-Write-on-existing-files) as single compressed lines, each ending with a pointer like '→ guardrails/CODE.md'; everything else lives behind the routing table. 5) Several rules share one primitive — 'grep the exact symbol repo-wide and paste the hit list' — so define that once in CODE.md as a named procedure (e.g. REFERENCE SWEEP) with the exact command template, and have rename/signature/schema/dead-code rules invoke it by name; this cuts token cost and increases execution fidelity. 6) Escalation interlocks matter for weaker models: the most dangerous moves (Write fallback, snapshot-update, replace_all) are exactly their frustration responses to repeated failure, so those rules should be worded as explicit prohibitions on the fallback path ('If Edit fails twice, re-Read and retry Edit — do not use Write'), not just as positive procedures.

### from false-completion
Structure the docs as GATES with predicates, not advice. Three cross-cutting observations: (1) Rules that require PASTING output (summary lines, grep hits, evidence tables) are self-enforcing — compliance is visible in the transcript and the act of pasting forces the model to actually read the output; prefer 'paste X' over 'check X' everywhere. (2) Prohibitions need mandated replacements: weaker models comply far better with 'never say A; say B or C instead' than with bare 'never say A', because they need something to emit. Define a controlled vocabulary of completion states — VERIFIED / UNVERIFIED / edited-unverified / NOT DONE / cannot-reproduce — and require every status statement to use one. (3) CLAUDE.md core budget for this lens should be exactly four lines (master evidence gate, forbidden-phrase list with replacements, test-integrity absolute, repro-first loop) plus routing-table rows: 'before claiming done/committing → VERIFY.md', 'anything fails or user reports a bug → DEBUG.md', 'rename/migration/removal → MIGRATE.md'. VERIFY.md should open with the evidence-table template as a copy-paste block so the model fills it rather than composes it. Word every rule so a grader could mark pass/fail from the transcript alone.

### from token-efficiency
Structure and wording guidance for the kit. (1) Core CLAUDE.md lines must be single imperative sentences with the trigger embedded up front ('After changing any signature: grep the old name repo-wide and disposition every hit'), because weaker models pattern-match on the trigger phrase, not on section headers. Nine of these findings are marked core; each compresses to one line, keeping the always-loaded cost under ~150 tokens for this lens. (2) Use hard numbers everywhere (250 lines, 5 files, 50 hits, 30-line subagent contract, 10-line final answer, 100-line command output): weaker models comply with numeric thresholds far more reliably than with judgment words like 'large', 'many', or 'when appropriate'; the exact numbers matter less than their existence. (3) EFFICIENCY.md should be organized as symmetric pairs — every 'read less' rule adjacent to its 'read more' counterpart (grep-before-ranged-read next to read-enclosing-scope-before-first-edit; speculative-exploration-gate next to assumption-word-tripwire) — with one shared framing sentence: 'the unit of cost is the full round trip; a skipped 200-token read that causes one failed edit cycle costs ~10x the read.' Without the pairing, weaker models over-apply the frugality rules and start editing blind. (4) Each on-demand rule should end with a one-line PASS check phrased as a transcript property ('PASS: transcript shows the grep result and a disposition line per hit'), so the model can self-audit and so VERIFY.md can reference the same checks. (5) The CLAUDE.md routing table should route by observable events, not topics: 'a test failed -> DEBUG.md', 'about to claim done -> VERIFY.md', 'grep returned >50 hits -> EFFICIENCY.md#triage', 'task will exceed one sitting -> SESSION.md'. Event-keyed routing fires reliably; topic-keyed routing ('when working on performance...') does not.

### from context-degradation
Cross-cutting design observations for the kit. (1) Route ALL long-session state through ONE artifact — docs/STATE.md with fixed section names — rather than multiple files; weaker models reliably execute 'append to section X' but not 'decide where this belongs'. This also composes with the user's existing /handoff skill and SessionStart auto-injection hook, so the kit reuses machinery already in place. (2) Use fixed UPPERCASE ledger keywords (ANCHOR:, DETOUR:, RETURNING:, DECISION:, ATTEMPT n:, PLAN CHANGE:, CONSTRAINT CHECK:) — they give weaker models a fill-in-the-blank pattern instead of a judgment call, they make compliance greppable from the transcript by an auditor, and labeled uppercase lines survive compaction summarization far better than prose intentions. (3) Replace every judgment threshold with a number: '10 messages' not 'recently', '2 failures' not 'repeatedly', '200 lines' not 'long output', 'depth 2' not 'too deep'. Weaker models comply with countable rules and rationalize their way around graded ones. (4) Phrase core CLAUDE.md lines as categorical prohibitions/obligations ('never X', 'before Y always Z'), not advice; compliance drops sharply for hedged wording. (5) Core-vs-on-demand split principle used here: a rule goes in core only if missing its capture window destroys the whole system (same-turn constraint capture, post-compaction recovery, no-edits-from-memory, anchor line) — everything consultable at leisure goes on-demand. (6) The SESSION doc should open with the STATE.md template verbatim so the model can copy it, followed by a one-page 'trigger -> which section to update' table; procedures compressed to trigger->action pairs are followed far more reliably than explanatory prose. (7) Several rules deliberately interlock (constraints are captured by one rule and consulted by another; open items are captured in SESSION and swept in VERIFY) — keep the pairs cross-referenced by name in the docs so a model reading one half discovers the other.

### from instruction-format
Cross-cutting prescriptions for the kit's structure. (1) Two audiences: several findings are 'Format contracts' addressed to whoever authors/edits the kit (including a future Claude asked to update it), not runtime behavior rules. Do NOT spend always-on CLAUDE.md budget on them — put them in a short docs/guardrails/_FORMAT.md (or a comment header in each doc) and add one routing row: 'are about to edit CLAUDE.md or any guardrail doc -> Read docs/guardrails/_FORMAT.md'. In the findings, placement=core means 'governs the form of the core file', not 'this text ships inside CLAUDE.md'. (2) doc tagging: findings whose scope is kit-wide were assigned to the nearest doc — routing/compaction-survival to SESSION, length/budget/vocabulary to EFFICIENCY — the orchestrator should treat these as governing all docs. (3) Recommended CLAUDE.md skeleton implied by the findings, top to bottom: routing table (first block) -> <=8 plain one-line iron rules with 8-word why-clauses -> last block: <=5 NEVER->instead lines + the post-compaction re-arm line as the literal final line. Total <=50 lines. (4) Recommended guardrail-doc skeleton: line 1 trigger restatement -> ID'd numbered checklist (lines 2-15, echo protocol stated inline) -> `--- reference ---` -> situation-phrased sections, red-flag table (DEBUG/VERIFY), one GOOD/BAD pair per core rule; cap 120 lines. (5) The single highest-leverage pair is finding 1 + finding 2 (event-phrased routing + route-then-announce): every other doc is worth zero if these fail, so they deserve the top-of-file and end-of-file positions and two of the five caps-budget slots if emphasis is needed anywhere. (6) Compliance is testable: because every finding is transcript-checkable (TRIGGER: lines, V<n> echoes, Q1-Q4 slots, M<n>: OK blocks), the kit can ship a simple audit — grep a session transcript for these markers to measure which rules fired and which were skipped, enabling iteration on wording rather than guessing.

### from process-failures
1) Use named, ALL-CAPS one-line artifacts as the compliance backbone: TASK (GOAL/FILES/DONE-WHEN/CONSTRAINTS), BASELINE, CAUSE->SYMPTOM, ASSUMPTION, WORKAROUND, NOTED (not done), HANDLED FAILURES. They cost 1-3 lines each, are greppable in the transcript (checkability for free), and several rules can anchor to the same artifact — the TASK block alone powers the premature-coding rule, the scope-creep rule (FILES delta), the drift check (CONSTRAINTS), and the stop rule (estimate delta). 2) Every rule should open with its trigger in 'When X / Before X / After X' form so a weaker model can match situation->rule without judgment. 3) Phrase prohibitions with a permitted alternative in the same sentence ('do NOT touch it — append NOTED instead'); weak models comply far better when the allowed move is named than when only the forbidden move is. 4) Core one-liners must be compressions of the on-demand rule, pointing at the doc, never paraphrases with different semantics — e.g. 'Changed a signature/name? Grep repo, account for every hit -> CODE.md'. 5) PLAN.md will fire most often; structure its top as a 60-second checklist (premise? prior art? ambiguity? baseline? size threshold?) with the detailed rules below, so cost stays proportional to task size. 6) The labeled artifacts double as proof that an on-demand doc was actually opened and followed — the phase-2 routing simulation can test for their presence.

### from migration-risks
Structure MIGRATE.md as a strictly numbered phase pipeline, because mid-tier compliance collapses when steps are prose: Phase 0 idempotency-sentinel check -> Phase 1 instruction-surface discovery -> Phase 2 backup snapshots -> Phase 3 line inventory -> Phase 4 conflict + dedup pass -> Phase 5 user checkpoint (STOP gate) -> Phase 6 install (copy) + compose (paste) -> Phase 7 path/fact revalidation -> Phase 8 final verification -> Phase 9 write sentinel + report. Three cross-cutting design principles: (1) every phase must END BY PRODUCING A NAMED ARTIFACT (a file or a printed table) — artifacts are what make compliance transcript-checkable and give the model a concrete completion criterion instead of a vibe; (2) the disposition-table format must be specified with a filled 5-row EXAMPLE in the doc (few-shot beats specification for weaker models — they will clone the example's shape exactly); (3) phrase every check as 'run X and PRINT the output', never 'ensure X' — 'ensure' invites assertion, 'print' forces observation. Give each command in both POSIX and PowerShell since Claude Code runs on both. Use explicit STOP/WAIT keywords at the two gates (sentinel found; pre-write checkpoint) — mid-tier models respect capitalized imperative gates far better than conditional prose. Finally, the single most important theme to state at the top of MIGRATE.md as its governing principle: MIGRATION IS TRANSPORT, NOT AUTHORSHIP — every byte in the output is either copied from the kit or copied from the original; the only text the model composes fresh is the log, the report, and one-line pointers.
