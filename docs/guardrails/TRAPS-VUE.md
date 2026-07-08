<!-- guardrails-kit: v1.1 | Rows verified against Vue 3.5 docs, 2026-07-08. Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C7 pack dispatch fired: you are editing a .vue file. First: read the pinned minor from package.json (CODE.md C6) — several rows below are version-bounded.

## Reactivity
- Destructuring `reactive()` or a Pinia store LOSES reactivity -> `toRefs` / `storeToRefs`. Props destructure stays reactive only on 3.5+ (version row).
- `ref`: `.value` in script; auto-unwraps at template top level and inside `reactive()` — NOT inside plain nested objects/arrays.
- `watch` on a getter/ref of an object is shallow -> pass `{ deep: true }` deliberately and say why, or watch specific fields.

## Templates
- `v-if` and `v-for` on ONE node: v-if evaluates FIRST in Vue 3 (REVERSED from Vue 2) -> never combine; use a `<template>` wrapper.
- `key` by index + reorder = state bleed between rows -> stable keys.

## Setup & macros
- Composables are called synchronously at setup top level — no `await` before lifecycle hooks register.
- `defineProps`/`defineEmits`/`defineModel` are compiler macros -> never import them; use the returned binding.
- Template refs are null until mount; 3.5+: `useTemplateRef` (version row).
