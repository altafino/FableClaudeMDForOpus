<!-- guardrails-kit: v1.4 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C22 fired: you are writing recursion, a state machine, a parser, or index/offset arithmetic.

These rules extract capability rather than add it: each converts a known think-first technique into a checkable artifact.

- RE1. BEFORE the code: write a 3-5 line worked trace of ONE concrete input through the intended steps as a comment (input -> intermediate values -> output). Code disagrees with the trace -> fix the code; never silently edit the trace to match.
- RE2. AFTER the code: attempt one breaking input (empty, single element, max size, duplicate, negative/zero) and write `COUNTEREXAMPLE TRIED: <input> -> held | broke: <what>`; broke -> fix before the next task step.
- RE3. Anything stateful (loop accumulators, state machines, cursors): one comment naming the invariant that holds at every iteration/transition.
- RE4. Before the first edit of an algorithmic function: state the approach in 2-3 plain sentences (what, not code) -> cannot state it plainly: you do not understand it yet — hand-trace an example first (RE1).

--- reference ---

## Why a trace beats re-reading the code
A trace is falsifiable: the code either reproduces it or it does not. Re-reading confirms what you meant, not what it does. TRAPS.md's date and loop-bound trace rows are instances of RE1.

## A design decision has more than one plausible shape
Owned by docs/guardrails/PLAN.md P10 (the OPTIONS artifact) — enumeration happens at planning time, not mid-edit.
