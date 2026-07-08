<!-- guardrails-kit: v1.1 | This file is executed as a procedure. Do not improvise, reorder, or batch PHASES; batching independent tool calls inside one numbered step is fine. -->
# MIGRATE.md — install the guardrails kit into an existing project

GOVERNING PRINCIPLE — MIGRATION IS TRANSPORT, NOT AUTHORSHIP.
Every byte you output is either copied from the kit or copied from the original project files. The only text you compose fresh is the log, the report, and one-line pointers. If you catch yourself rewording, shortening, or "cleaning up" any rule text, you are making the exact error this procedure exists to prevent: paraphrase is where rules die — exact flags, ports, thresholds, and never/always qualifiers are precisely what regeneration discards.

Definitions used below:
- `<KIT>` = the directory containing this MIGRATE.md (it also contains the template CLAUDE.md and docs/guardrails/). Kit docs: _FORMAT, PLAN, CODE, DEBUG, VERIFY, EFFICIENCY, SESSION, TRAPS, SECURITY, PERFORMANCE, FRONTEND, TRUST, DATA, TEST, TRAPS-GO, TRAPS-ANGULAR, TRAPS-VUE, TRAPS-TAILWIND, TRAPS-SQL, TRAPS-NOSQL (20 files; PROJECT-TEMPLATE.md is a convenience copy, not a kit doc).
- `<PROJECT>` = the repo being migrated. All steps run from `<PROJECT>` root.
- Every `Verify:` line must be RUN and its output PRINTED in the transcript. "Ensure" means nothing; print means everything. An unprinted verify counts as FAILED.
- Commands are given as `POSIX | PowerShell` — use exactly one dialect per command.

## Phase 0 — idempotency check (FIRST action, before anything else)
M0. Run: `grep -n "guardrails-kit:" CLAUDE.md` | `Select-String -Path CLAUDE.md -Pattern "guardrails-kit:"` (a missing CLAUDE.md is a pass — note it). Also probe for an orphaned log: `[ -e docs/guardrails/MIGRATION-LOG.md ] && echo "LOG: EXISTS" || echo "LOG: none"` | `Test-Path docs/guardrails/MIGRATION-LOG.md`.
    Sentinel FOUND -> STOP; switch to UPGRADE mode (bottom of this file). Re-running migration on a migrated project clobbers the original backup.
    Log exists WITHOUT the sentinel -> a prior run aborted: print the log's section headings and ask the user whether to resume from its last completed phase or archive it and start over.
    CLAUDE.md does not exist -> FRESH INSTALL: do only M1 (print the inventory in chat; decisions FLAG-to-user only, no log needed), M6a, M6d, M8 items 3, 4, 6, and M9 in fresh-install form.

## Phase 1 — instruction-surface discovery
M1. Create `docs/guardrails/MIGRATION-LOG.md` (this file and the M2 snapshot are the only writes permitted before the M5 gate) with a `## Surfaces` section. Find every instruction surface and print the results:
    - Glob `**/CLAUDE.md` and `**/CLAUDE.local.md` (nested files override the root in their subtrees).
    - `for f in .claude/settings.json .claude/settings.local.json; do [ -e "$f" ] && echo "$f: EXISTS" || echo "$f: none"; done; ls .claude/commands .claude/agents .claude/skills docs/guardrails 2>/dev/null` | `foreach ($f in '.claude/settings.json','.claude/settings.local.json') { "$($f): $(Test-Path $f)" }; Get-ChildItem .claude/commands, .claude/agents, .claude/skills, docs/guardrails -ErrorAction SilentlyContinue`
    - Read every hook in those settings files; for each, note its event (SessionStart/PostToolUse/...), its command, and what it injects or enforces.
    - Grep `^@` in every CLAUDE.md found — each imported file is an instruction surface (decision usually LEAVE; the import LINE migrates with its containing file, see M6b).
    Record every surface under `## Surfaces` with a decision: MIGRATE / LEAVE (reason) / FLAG-to-user. Any existing docs/guardrails file sharing a kit doc name is FLAG-to-user and MUST appear in the M5 checkpoint with the M6a a/b/c question. Nested CLAUDE.md files stay in place and are never edited — they get the M4 token scan, with overlaps logged as FLAG-to-user. The user-global `~/.claude/CLAUDE.md` is read-only context: never edit it, never copy its rules into the project.
    Verify: print the `## Surfaces` list.

## Phase 2 — backup (IRON RULE: no Edit/Write to any existing instruction file before this)
M2. For CLAUDE.md and every other instruction file you will touch:
    `cp CLAUDE.md CLAUDE.md.pre-migration-$(date +%Y%m%d-%H%M)` | `Copy-Item CLAUDE.md "CLAUDE.md.pre-migration-$(Get-Date -Format yyyyMMdd-HHmm)"`
    If `git status --porcelain` (excluding the snapshot) is empty: `git add <snapshot> && git commit -m "[chore] pre-migration snapshot"`; if dirty, write SNAPSHOT-UNCOMMITTED in the log. All later references to "original line N" are resolved by Reading the snapshot — never from memory. Never delete or edit a snapshot; the user removes it after accepting the migration.
    Verify: print the snapshot filename(s), `wc -l <snapshot>` | `(Get-Content <snapshot>).Count`, and `git hash-object --no-filters <snapshot>` | `(Get-FileHash <snapshot>).Hash`.

## Phase 3 — line-accounting inventory (before designing anything)
M3. Read the snapshot and number every non-blank line INCLUDING headings: 001, 002, ... A heading that is only a section label gets disposition DROPPED (decoration) or becomes a PROJECT.md anchor; a heading that states a constraint ("## Never touch generated/") is inventoried like any rule line.
    Append the disposition table to MIGRATION-LOG.md — clone the example's SHAPE exactly; example rows are shape only, never copy a disposition because your line resembles an example:

    | # | original text (verbatim) | disposition | destination | note |
    |---|---|---|---|---|
    | 001 | Dev server: npm run dev (port 5173) | MOVED | CLAUDE.md ## Project | fact |
    | 002 | Never commit .env files | KEPT-VERBATIM | CLAUDE.md ## Project | project constraint |
    | 003 | Never say done without re-running the tests | SUPERSEDED-BY | docs/guardrails/VERIFY.md V1 | covered 100%, no delta |
    | 004 | Use tabs in Makefiles, never spaces | MOVED | docs/guardrails/PROJECT.md | style detail |
    | 005 | TODO: revisit widget-cache sharding someday | UNSORTED | docs/guardrails/PROJECT-NOTES.md | not a rule; keep verbatim |

    Allowed dispositions ONLY: KEPT-VERBATIM, MOVED (name the target file), MERGED (only for two lines that literally restate each other; quote both plus the merged text), SUPERSEDED-BY (name kit doc + rule ID; legal only when the kit rule's text covers 100% of the old line — anything it does not literally require is a delta per M4(b) or stays KEPT-VERBATIM), UNSORTED, DROPPED (reason required), CONFLICT-PENDING (points at its `## CONFLICTS` entry; legal only until M5).
    Rules that must hold: one original line -> exactly one row; NEVER fold N rules into one summary line ("follow existing style" is content-free — the originals carried distinct constraints); no line is dropped for "not fitting" — misfits go VERBATIM to docs/guardrails/PROJECT-NOTES.md under `## Unsorted (pre-migration CLAUDE.md, <date>)` as UNSORTED. DROPPED is legal only for exact in-file duplicates, pure decoration (dividers, label-only headings), and lines the user explicitly approves dropping.
    Verify: print both counts — numbered original lines and table rows — and confirm they are EQUAL. Unequal = stop and redo the inventory.

## Phase 4 — conflict and supersession pass (before composing any new file)
M4. Scan the snapshot AND every nested CLAUDE.md with: `grep -inE "\b(must|never|always|don'?t|do not|only|forbidden|not)\b" <file>` | `Select-String -Path <file> -Pattern "\b(must|never|always|don't|do not|only|forbidden|not)\b"`. ADDITIONALLY inspect every line whose subject a kit doc owns (test/build/debug/verify/commit/edit behavior) regardless of tokens — conditional imperatives ("if X, just do Y") conflict without modal words. For each candidate, grep `<KIT>/docs/guardrails/*.md` and `<KIT>/CLAUDE.md` for 2-3 keywords from that line and inspect hits. Record every overlap in a `## CONFLICTS` section of MIGRATION-LOG.md quoting both texts (minimum content if clean: "none found").
    Resolution policy:
    (a) Project FACTS (commands, paths, ports, versions, domain constraints) always beat kit defaults -> the project fact goes in `## Project`.
    (b) Kit PROCESS rules beat generic old process rules -> old line becomes SUPERSEDED-BY. Old rule adds a project-specific delta (an exact command, stricter threshold, extra step)? Keep ONLY the delta as one `## Project` line phrased `In addition to <doc> <rule-ID>: <verbatim delta>`.
    (c) An old rule explicitly forbids what a kit rule requires, or vice versa ("NEVER run the integration suite locally; CI only" vs VERIFY/DEBUG suite runs): do NOT resolve it yourself. Set the row to CONFLICT-PENDING, list it in `## CONFLICTS`, and ask the user at M5. After the user decides: rewrite the row to the decided disposition with `resolved: <decision> <date>` in the note column; a surviving old rule goes KEPT-VERBATIM to `## Project` (constraining a kit procedure -> phrase it `In addition to <doc> <rule-ID>: <verbatim old rule>`).
    Verify: print the `## CONFLICTS` section.

## Phase 5 — user checkpoint (STOP gate)
M5. Post in chat, then WAIT for explicit approval before Phase 6 — no kit-doc copies, no PROJECT.md/PROJECT-NOTES.md, no new CLAUDE.md. The M2 snapshot and MIGRATION-LOG.md are the only files that may exist before approval. Post:
    (1) disposition counts (KEPT/MOVED/MERGED/SUPERSEDED/UNSORTED/DROPPED/CONFLICT-PENDING); (2) every DROPPED line quoted verbatim with its reason; (3) the full `## CONFLICTS` section; (4) every kit-doc name collision from `## Surfaces`; (5) the proposed `## Project` content.
    User does not explicitly approve the DROPPED list? Reroute those lines to UNSORTED. Do not proceed past this line without a user reply.

## Phase 6 — install and compose
M6a. Install kit docs by FILE COPY, never by Write-ing their content (regeneration silently mutates calibrated wording). For EACH of the 20 kit docs, in order:
     (1) Precheck: `[ -e docs/guardrails/<X>.md ] && echo EXISTS || echo none` | `Test-Path docs/guardrails/<X>.md`. Exists? Hash-compare with the kit source (`git hash-object --no-filters` both paths | `Get-FileHash` both): equal -> log "already installed" under `## Kit-doc collisions`, skip; different -> do NOT overwrite; quote the first 10 lines of the existing file and ask the user: (a) rename existing to `<X>.pre-kit.md`, then grep the repo for `docs/guardrails/<X>.md` and list every reference for the user to re-point, then install; (b) skip this kit doc; (c) back up as `<X>.md.pre-migration-<stamp>` (M2 convention) then replace. Never resolve a collision yourself.
     (2) Copy one file at a time — never a wildcard copy when any destination exists: `mkdir -p docs/guardrails && cp "<KIT>/docs/guardrails/<X>.md" docs/guardrails/` | `New-Item -ItemType Directory -Force docs/guardrails | Out-Null; Copy-Item "<KIT>/docs/guardrails/<X>.md" docs/guardrails/`
     (3) Log the outcome under `## Kit-doc collisions`: `<X>.md: installed | skipped (user, <date>) | replaced (backup: <name>)`.
     Verify: for each installed/replaced file, print the hash pair side by side (`git hash-object --no-filters docs/guardrails/<X>.md "<KIT>/docs/guardrails/<X>.md"` | `(Get-FileHash ...).Hash` both) — pairs must match; print SKIPPED lines for skipped names.
M6b. Write the new CLAUDE.md (Write is correct here and supersedes the kit iron rule "Edit, never Write" for this one step — the M2 snapshot is the backup), with exactly this structure:
     line 1: `<!-- guardrails-kit: v1.0 migrated <YYYY-MM-DD> -->`
     zone 1: the block from `<!-- BEGIN KIT CORE v1.0 -->` through `<!-- END KIT CORE -->` in `<KIT>/CLAUDE.md`, BOTH marker lines included — byte-identical copy.
     zone 2: `## Project` — the KEPT-VERBATIM and MOVED-here lines from the log, copy-pasted character-identical. Cap 40 lines. Allowed content: build/test/run commands, iron project constraints, `@path` import lines carried from the original CLAUDE.md (imports are processed ONLY inside CLAUDE.md files — NEVER move an `@` line into docs/guardrails/*, where it becomes inert text), and one-line pointers `<trigger situation> -> Read docs/guardrails/PROJECT.md#<anchor>`. Over cap? Move whole lines out to docs/guardrails/PROJECT.md — NEVER shorten a rule's wording to fit. _FORMAT.md budgets F3/F4 govern the kit zones only; zone-2 project lines are exempt and keep their original casing and count.
     zone 3: the block from `<!-- BEGIN KIT FOOTER v1.0 -->` through `<!-- END KIT FOOTER -->`, BOTH marker lines included — byte-identical copy; it ends the file.
     Never insert, delete, or reword any line inside the kit markers — project content lives only in zone 2 (this is what makes future kit upgrades a wholesale block swap).
M6c. Everything conditional (debug lore, style detail, architecture notes, environment quirks) goes VERBATIM into docs/guardrails/PROJECT.md under situation-phrased `##` anchors; UNSORTED lines go verbatim into docs/guardrails/PROJECT-NOTES.md. For EVERY `##` anchor created in PROJECT.md, add one zone-2 pointer line `<observable trigger> -> Read docs/guardrails/PROJECT.md#<anchor>` to CLAUDE.md — a PROJECT.md section with no zone-2 pointer is unreachable and counts as DROPPED, which requires user approval. PROJECT.md, PROJECT-NOTES.md, and MIGRATION-LOG.md are project-authored archives exempt from _FORMAT.md doc-shape rules — never reformat their transported content.
M6d. Fresh install only: `cp "<KIT>/CLAUDE.md" CLAUDE.md` | `Copy-Item "<KIT>/CLAUDE.md" CLAUDE.md`, then fill `## Project` (zone 2 only) with the project's run/test commands if known.

## Phase 7 — carried-fact revalidation (stale facts get laundered into authority — check them)
M7. For every carried COMMAND: verify the script/target exists (package.json scripts, Makefile targets, `[ -e <path> ]` | `Test-Path <path>`) — do not execute anything with side effects. For every carried PATH: existence-check the same way. For every version claim: check the manifest/lockfile. `@` imports stay inside CLAUDE.md: the containing file's directory is unchanged, so keep the path byte-identical and existence-check the target. Plain relative paths in prose MOVED to docs/guardrails/*: rewrite repo-root-relative and record in that row's note column `path-rewritten: <old> -> <new>` (M8 item 2 checks such rows against the rewritten text).
    Anything failing verification is carried WITH the inline tag `[UNVERIFIED <YYYY-MM-DD>: <what failed>]` — never silently dropped, never carried untagged.
    Verify: print the token -> exists? -> action list.

## Phase 8 — final verification (run each item; paste its actual output; no paste = FAILED)
M8. (1) Row-count equality: numbered-original-line count == disposition-row count, and zero rows still read CONFLICT-PENDING.
    (2) Verbatim spot-check: select every Nth row by row number (N = rowcount/10, all rows if <=10) among KEPT-VERBATIM/MOVED; grep the destination file for an exact >=15-character substring of the row's final text (rewritten text for `path-rewritten` rows; the whole line if shorter); print the hits. Any MISS = a rule was paraphrased or lost — fix before continuing.
    (3) Hash-compare every kit doc marked installed/replaced in `## Kit-doc collisions` against `<KIT>` source (`git hash-object --no-filters` | `Get-FileHash`); print the pairs; print `SKIPPED (user decision <date>)` for skipped names instead of comparing.
    (4) Extract and diff both kit zones: `sed -n '/BEGIN KIT CORE/,/END KIT CORE/p' CLAUDE.md > /tmp/core.new; sed -n '/BEGIN KIT CORE/,/END KIT CORE/p' "<KIT>/CLAUDE.md" > /tmp/core.kit; diff /tmp/core.new /tmp/core.kit` (repeat for FOOTER) | PowerShell: extract each range with `Get-Content` index slicing between the marker matches from `Select-String`, then `Compare-Object` the two arrays. Print the (empty) diff.
    (5) Print the `## Project` section line count (must be <=40).
    (6) Print line 1 of CLAUDE.md (must contain `guardrails-kit:`).
    (7) Print size + hash of the untouched pre-migration snapshot — the hash must equal the one printed at M2.
    (8) Print MIGRATION-LOG.md's section headings — must include `## Surfaces`, the disposition table, `## CONFLICTS`, `## Kit-doc collisions`.
    (9) Print each PROJECT.md `##` anchor beside its zone-2 pointer line; any anchor without a pointer = FAILED.

## Phase 9 — report
M9. Report the migration complete ONLY after every check run for this mode passes (full migration: all 9; fresh install: M8 items 3, 4, 6 — paste those and state "no original CLAUDE.md — no dispositions, conflicts, or snapshot"). The report must repeat: the DROPPED list, the UNVERIFIED-tagged facts, the CONFLICTS resolutions (and any left FLAG-to-user), and the FLAG-to-user surfaces from Phase 1. Recommend the user review MIGRATION-LOG.md, then delete the snapshot when satisfied.

## UPGRADE mode (Phase 0 found the sentinel)
U0. Snapshot CLAUDE.md exactly as in M2. Verify: print filename + hash.
U1. Hash-compare each docs/guardrails file that ALSO exists in `<KIT>/docs/guardrails/` (skip MIGRATION-LOG.md, PROJECT.md, PROJECT-NOTES.md — project-owned, never kit-sourced; skip names logged as user-skipped in `## Kit-doc collisions`); print pairs. Hashes differing from the NEW kit are EXPECTED on a version upgrade — never assert hand-editing. To detect hand edits, compare against the OLD kit source if available; otherwise show the diff (`diff docs/guardrails/<X>.md "<KIT>/docs/guardrails/<X>.md"` | `Compare-Object (Get-Content docs/guardrails/<X>.md) (Get-Content "<KIT>/docs/guardrails/<X>.md")`) and ask before replacing.
U2. Replace the KIT CORE and KIT FOOTER blocks in CLAUDE.md with the new version's blocks (wholesale block swap, markers included — this is why zone 2 stays outside the markers). Show the block diff and WAIT for explicit user approval before editing. Leave `## Project` untouched.
U3. Update the version in CLAUDE.md line 1 only. Replaced docs already carry the new version — Verify by printing line 1 of each replaced file; never edit them.
U4. Re-run M8 items 3, 4, 5, 6 and paste each output; report complete only after all four pass.
