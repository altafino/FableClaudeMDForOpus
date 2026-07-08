<!-- guardrails-kit: v1.1 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C20 fired: you are creating or modifying a test file.

- TE1. No branching, loops, or try/catch inside a test body -> table-driven cases or split tests (logic in tests is untested code).
- TE2. Assert observable behavior, not internals; a mock-call-count assert needs one line stating why the interaction IS the contract.
- TE3. For each new test, state which line of the change makes it fail if reverted -> cannot name one: the test does not cover the change.
- TE4. One behavior per test; the name states the expected behavior, never just the method under test.
- TE5. Build the minimal fixture the assertion needs; copying a fixture >30 lines for a <5-field need -> extract a builder/factory.

--- reference ---

## Proving a regression test detects its bug
Owned by docs/guardrails/DEBUG.md ("You are adding a regression test for the bug you just fixed"): revert the fix, paste the test failing, restore, paste it passing.

## Weakening a failing test
Never — CLAUDE.md `## Hard stops`, first bullet, owns this.
