<!-- guardrails-kit: v1.1 | Rows verified against Tailwind CSS 4 docs, 2026-07-08. Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C7 pack dispatch fired: tailwindcss is in the manifest (or `@theme`/`@import "tailwindcss"` in CSS) and you are writing utility classes or Tailwind config.

- NEVER construct class names dynamically (`text-${color}-500`, concatenation) — the scanner matches complete literal strings and purges the rest -> instead: map full literals (`{red: 'text-red-500'}`) or safelist them.
- v4 is CSS-first: `@theme` in CSS replaces tailwind.config.js -> check which style this repo uses BEFORE writing either (a v3-style config in a v4 repo silently no-ops).
- `@apply` inside Vue SFC `<style>` / CSS modules needs `@reference` in v4 -> add it, or the utilities resolve to nothing.
- Conflicting utilities: STYLESHEET order wins, not class-attribute order -> never emit conditional conflicting classes; use a merge helper (tailwind-merge) and name it.
- No spaces inside arbitrary-value brackets: `w-[calc(100%-2rem)]` works; a space breaks scanning -> use `_` where a space is required.
- v4 targets modern CSS baselines (no legacy Safari/IE) -> check the project's browser-support target before adopting v4-only idioms.

--- reference ---

## Design tokens
Hardcoding a value that a token covers is owned by docs/guardrails/FRONTEND.md FE2 — grep the tokens first.
