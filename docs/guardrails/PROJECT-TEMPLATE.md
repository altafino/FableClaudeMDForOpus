<!-- guardrails-kit: v1.1 | Template — copy to docs/guardrails/PROJECT.md when first needed; delete this file if unused. PROJECT.md is project-authored: _FORMAT.md contracts do NOT apply to your content there. -->
# PROJECT.md — project-specific playbooks (template)

Every `##` section is a situation anchor. For EACH section you keep, add one pointer line to CLAUDE.md `## Project`:
`<observable trigger> -> Read docs/guardrails/PROJECT.md#<anchor>`
A section with no pointer is unreachable (MIGRATE.md M6c).

## You are running the app locally
<dev command, port, env prerequisites>

## You are running the tests
<exact commands: full suite / one file / one test>

## You are touching <fragile subsystem>
<the constraint and the safe procedure>

## You hit <known recurring error>
<symptom -> cause -> fix>

Keep sections situation-phrased ("You are ...", "You hit ..."), never topic nouns; replace every `<...>` with real content.
