<!-- guardrails-kit: v1.1 | Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C18 fired: you are editing or creating a UI file (.tsx/.jsx/.vue/.svelte, templates, .css/.scss, styled components).

- FE1. New or changed component/view: report `STATES COVERED: <loading, empty, error, success, overflow>` / `NOT COVERED (by choice): <list + reason>`; an empty states list on a data-driven component is a defect.
- FE2. Before writing a literal color/px/font/shadow: Grep the repo's tokens (tailwind.config.*, CSS custom properties, theme.*) and use the token -> none exists: state that in one line before hardcoding.
- FE3. New component: docs/guardrails/PLAN.md "creating a new instance of a kind that already exists" applies — copy ONE existing component's structure and name the file matched.
- FE4. Every clickable is a button or a link — Grep the diff for `onClick`/`@click` on non-interactive elements and paste hits; every input has a label; every image has alt; each new interaction has a keyboard path.
- FE5. Forms: state controlled vs uncontrolled per input; the invalid-input display path is implemented (CODE.md C13's `HANDLED FAILURES:` includes it).
- FE6. Layout/styling change: name the viewports checked — 375px and one desktop width minimum.
- FE7. Before claiming done: grep the diff for `lorem|asdf|TODO|xxx` in user-visible strings and paste the (zero-)hit list.

--- reference ---

## Framework mechanics you are about to guess
React/Vue/Angular runtime traps live in the TRAPS packs (CODE.md C7 pack dispatch), not here. Visual taste is out of this kit's scope: tokens, states, and a11y minima above are the checkable fraction.

## UI completion evidence
docs/guardrails/VERIFY.md V14 owns it: a rendered screenshot or DOM/e2e assertion produced AFTER the last edit.
