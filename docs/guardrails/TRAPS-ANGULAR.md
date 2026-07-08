<!-- guardrails-kit: v1.1 | Rows verified against Angular 20 docs, 2026-07-08. Editing this file? Read docs/guardrails/_FORMAT.md first. Never paraphrase kit text. -->
You are here because CODE.md C7 pack dispatch fired: angular.json is present and you are editing component/template/service code. First: read the pinned major from package.json (CODE.md C6) — several rows below are version-bounded.

## Signals & change detection
- Signals compare by REFERENCE: mutating an object inside one notifies nobody -> `set()`/`update()` with a new object.
- OnPush + mutated @Input: no re-render -> immutable updates only.
- `effect()` runs after change detection; writing signals inside one is restricted — check the pinned major's rule before doing it.

## Templates & control flow
- `@for` REQUIRES `track`; `track $index` re-renders every row on reorder -> track a stable id.
- Never mix `*ngIf`/`*ngFor` with `@if`/`@for` in new code -> match the repo's existing baseline.

## DI & lifecycle
- `inject()` works only in an injection context (constructor, field initializer, factory) -> never inside event handlers or subscribe callbacks.
- Standalone is the default (19+): imports go on the component; NgModule-era snippets are stale priors — check the repo before copying any.

## RxJS
- Every `subscribe()` names its teardown -> `takeUntilDestroyed()`, or prefer the async pipe (no manual teardown at all).
- Nested subscribes -> switchMap/mergeMap/concatMap; state which and why (cancel vs parallel vs ordered).
