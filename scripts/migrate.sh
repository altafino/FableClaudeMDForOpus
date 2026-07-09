#!/usr/bin/env bash
# Guardrails kit — migration mechanical wrapper (design doc 2026-07-10).
#
#   scripts/migrate.sh <kit-dir> prep  [--dry-run] [--launch]   (default: prep)
#   scripts/migrate.sh <kit-dir> apply
#   scripts/migrate.sh <kit-dir> rollback [--yes] [--purge]
#
# prep     = MIGRATE.md phases M0 + M2 + collision pre-scan + kit manifest.
#            Writes ONLY the snapshot and docs/guardrails/MIGRATION-PREP.log —
#            never a kit doc (M1/M5 write gate). Judgment phases stay with the
#            model: run /kit-migrate afterwards (or use --launch).
# apply    = MIGRATE.md phase M6a per-file copies, hash-verified against the
#            prep manifest. Run ONLY after the M5 user checkpoint approved.
# rollback = undo a prepped/applied/aborted migration precisely: restore
#            CLAUDE.md from the logged snapshot, remove ONLY files this
#            migration created (APPLIED:/CREATED: log lines), keep everything
#            pre-existing. Prints the full plan and asks before touching
#            anything (--yes skips the prompt; --purge also removes the
#            snapshot, otherwise it is kept as proof).
set -u
KIT="${1:?usage: migrate.sh <kit-dir> [prep|apply|rollback] [--dry-run] [--launch] [--yes] [--purge]}"
MODE="${2:-prep}"
DRY=0; LAUNCH=0; YES=0; PURGE=0
for a in "$@"; do
  [ "$a" = "--dry-run" ] && DRY=1
  [ "$a" = "--launch" ] && LAUNCH=1
  [ "$a" = "--yes" ] && YES=1
  [ "$a" = "--purge" ] && PURGE=1
done
LOG="docs/guardrails/MIGRATION-PREP.log"
DOCS="_FORMAT PLAN CODE DEBUG VERIFY EFFICIENCY SESSION TRAPS SECURITY PERFORMANCE FRONTEND TRUST DATA TEST REASONING TRAPS-GO TRAPS-ANGULAR TRAPS-VUE TRAPS-TAILWIND TRAPS-SQL TRAPS-NOSQL"
say() { printf '%s\n' "$*"; }
sha() { sha256sum "$1" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$1" | awk '{print $1}'; }
log() { [ "$DRY" = "1" ] || printf '%s\n' "$*" >> "$LOG"; }

[ -f "$KIT/CLAUDE.md" ] && [ -f "$KIT/MIGRATE.md" ] || { say "FAIL: $KIT does not look like the kit"; exit 1; }

if [ "$MODE" = "prep" ]; then
  # --- M0: idempotency / entry checks (a script never decides the resume question) ---
  if [ ! -e CLAUDE.md ]; then
    say "REFUSE: no CLAUDE.md here — this is a FRESH install, use scripts/install.sh instead."; exit 1
  fi
  if grep -q "guardrails-kit:" CLAUDE.md; then
    say "REFUSE: kit sentinel found — already migrated. Use MIGRATE.md UPGRADE mode (U0-U4)."; exit 2
  fi
  if [ -e docs/guardrails/MIGRATION-LOG.md ]; then
    say "STOP: docs/guardrails/MIGRATION-LOG.md exists without the sentinel — a prior migration aborted."
    say "      MIGRATE.md M0: a HUMAN must decide — resume from its last completed phase, or archive it"
    say "      and start over. Decide, then re-run prep."; exit 3
  fi
  # --- M2: snapshot CLAUDE.md (other surfaces are discovered at M1 by the model) ---
  STAMP=$(date +%Y%m%d-%H%M)
  SNAP="CLAUDE.md.pre-migration-$STAMP"
  if [ "$DRY" = "0" ]; then
    GDIR_PRE=$([ -d docs/guardrails ] && echo yes || echo no)
    mkdir -p docs/guardrails
    : > "$LOG"
    log "# MIGRATION-PREP.log — written by scripts/migrate.sh prep, $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    log "# Contract: sha256 throughout. Model session: MIGRATE.md 'script-prepped entry' applies — start at M1."
    log "PRE-EXISTING: docs/guardrails $GDIR_PRE"
    for f in docs/guardrails/PROJECT.md docs/guardrails/PROJECT-NOTES.md docs/guardrails/MIGRATION-LOG.md docs/guardrails/PROJECT-TEMPLATE.md; do
      log "PRE-EXISTING: $f $([ -e "$f" ] && echo yes || echo no)"
    done
    cp CLAUDE.md "$SNAP"
    log "SNAPSHOT: $SNAP sha256=$(sha "$SNAP") lines=$(wc -l < "$SNAP" | tr -d ' ')"
    if git rev-parse --git-dir >/dev/null 2>&1; then
      if [ -z "$(git status --porcelain | grep -v "$SNAP")" ]; then
        git add "$SNAP" && git commit -q -m "[chore] pre-migration snapshot" && log "SNAPSHOT-COMMITTED: yes"
      else
        log "SNAPSHOT-UNCOMMITTED (dirty tree, per MIGRATE.md M2)"
      fi
    else
      log "SNAPSHOT-UNCOMMITTED (no git repo, per MIGRATE.md M2 fallback)"
    fi
    say "  ok  snapshot: $SNAP ($(sha "$SNAP" | head -c 12)...)"
  else
    say "  dry  would snapshot CLAUDE.md -> $SNAP"
  fi
  # --- Collision pre-scan + kit manifest (NO copies — pre-M5 write gate) ---
  COLLISIONS=0
  for d in $DOCS; do
    SRC="$KIT/docs/guardrails/$d.md"; DST="docs/guardrails/$d.md"
    [ -f "$SRC" ] || { say "FAIL: kit source missing $d.md"; exit 1; }
    log "MANIFEST: $d.md sha256=$(sha "$SRC")"
    if [ -e "$DST" ]; then
      if [ "$(sha "$DST")" = "$(sha "$SRC")" ]; then
        log "COLLISION: $d.md IDENTICAL — already installed, apply will skip"
        say "  ok  $d.md exists, identical"
      else
        COLLISIONS=$((COLLISIONS+1))
        log "COLLISION: $d.md DIFFERENT — resolve at M5 per MIGRATE.md M6a(1): (a) rename existing to $d.pre-kit.md, re-point references, install; (b) skip this kit doc; (c) back up as $d.md.pre-migration-<stamp> then replace. Never resolve without the user."
        say "  !!  $d.md exists and DIFFERS — deferred to the M5 checkpoint (logged verbatim M6a(1) options)"
      fi
    fi
  done
  say ""
  say "PREP: DONE — mechanical phases M0/M2 evidenced in $LOG ($COLLISIONS collision(s) deferred)."
  say "NEXT: run /kit-migrate in Claude Code (semantic phases M1, M3-M5, M6b/c, M7 — stops for your"
  say "      approval at M5). After M5 approval the session runs: scripts/migrate.sh $KIT apply"
  if [ "$LAUNCH" = "1" ] && [ "$DRY" = "0" ]; then
    exec claude "Read MIGRATE.md in $KIT and execute it exactly, phase by phase. Script-prepped entry applies: docs/guardrails/MIGRATION-PREP.log evidences M0/M2 — spot-check the snapshot hash, then start at M1."
  fi
  exit 0
fi

if [ "$MODE" = "apply" ]; then
  # --- M6a copies, ONLY after the M5 checkpoint ---
  [ -f "$LOG" ] || { say "FAIL: no $LOG — run prep first (and the model session through M5)."; exit 1; }
  FAIL=0; COPIED=0
  mkdir -p docs/guardrails
  for d in $DOCS; do
    SRC="$KIT/docs/guardrails/$d.md"; DST="docs/guardrails/$d.md"
    if grep -q "COLLISION: $d.md DIFFERENT" "$LOG"; then
      say "  skip $d.md — collision deferred to the M5 decision (model executes M6a(1) choice)"; continue
    fi
    EXISTED=$([ -e "$DST" ] && echo yes || echo no)
    cp "$SRC" "$DST"
    WANT=$(grep "MANIFEST: $d.md " "$LOG" | sed 's/.*sha256=//')
    GOT=$(sha "$DST")
    if [ "$WANT" = "$GOT" ]; then
      COPIED=$((COPIED+1))
      [ "$EXISTED" = "no" ] && printf 'APPLIED: docs/guardrails/%s.md created\n' "$d" >> "$LOG"
    else say "FAIL hash mismatch: $d.md"; FAIL=1; fi
  done
  if [ ! -e docs/guardrails/PROJECT-TEMPLATE.md ]; then
    cp "$KIT/docs/guardrails/PROJECT-TEMPLATE.md" docs/guardrails/ 2>/dev/null \
      && printf 'APPLIED: docs/guardrails/PROJECT-TEMPLATE.md created\n' >> "$LOG"
  fi
  say "APPLY: $COPIED doc(s) copied and hash-verified against the prep manifest."
  [ "$FAIL" = "0" ] && say "APPLY: PASS — continue MIGRATE.md at M6b (compose CLAUDE.md)." || say "APPLY: FAILED"
  exit "$FAIL"
fi

if [ "$MODE" = "rollback" ]; then
  [ -f "$LOG" ] || { say "FAIL: no $LOG — nothing to roll back (or it was already rolled back)."; exit 1; }
  SNAP=$(grep -m1 '^SNAPSHOT: ' "$LOG" | awk '{print $2}')
  SNAP_SHA=$(grep -m1 '^SNAPSHOT: ' "$LOG" | sed 's/.*sha256=//; s/ .*//')
  [ -n "$SNAP" ] && [ -f "$SNAP" ] || { say "FAIL: snapshot named in the log is missing — cannot restore CLAUDE.md safely."; exit 1; }
  # --- build the plan ---
  RESTORE=0
  [ "$(sha CLAUDE.md)" != "$SNAP_SHA" ] && RESTORE=1
  REMOVE=""
  while IFS= read -r line; do
    f=$(printf '%s' "$line" | awk '{print $2}')
    [ -e "$f" ] && REMOVE="$REMOVE $f"
  done < <(grep '^APPLIED: .* created$' "$LOG")
  for f in docs/guardrails/PROJECT.md docs/guardrails/PROJECT-NOTES.md docs/guardrails/MIGRATION-LOG.md; do
    if grep -q "^PRE-EXISTING: $f no$" "$LOG" && [ -e "$f" ]; then REMOVE="$REMOVE $f"; fi
  done
  say "ROLLBACK PLAN (nothing touched yet):"
  grep -q "guardrails-kit:" CLAUDE.md && say "  !!  CLAUDE.md carries the kit sentinel — this undoes a COMPLETED migration."
  [ "$RESTORE" = "1" ] && say "  restore  CLAUDE.md <- $SNAP" || say "  keep     CLAUDE.md (unchanged since snapshot)"
  for f in $REMOVE; do say "  remove   $f"; done
  say "  remove   $LOG"
  [ "$PURGE" = "1" ] && say "  remove   $SNAP (--purge)" || say "  keep     $SNAP (proof; remove later or re-run with --purge)"
  if [ "$YES" != "1" ]; then
    printf 'Type yes to execute the rollback: '
    read -r ANSWER
    [ "$ANSWER" = "yes" ] || { say "ABORTED — nothing changed."; exit 4; }
  fi
  # --- execute ---
  GDIR_CREATED=$(grep -q '^PRE-EXISTING: docs/guardrails no$' "$LOG" && echo yes || echo no)
  [ "$RESTORE" = "1" ] && cp "$SNAP" CLAUDE.md
  for f in $REMOVE; do rm -f "$f"; done
  rm -f "$LOG"
  [ "$PURGE" = "1" ] && rm -f "$SNAP"
  if [ "$GDIR_CREATED" = "yes" ]; then
    rmdir docs/guardrails 2>/dev/null || true
    rmdir docs 2>/dev/null || true
  fi
  say "ROLLBACK: DONE — CLAUDE.md $( [ "$RESTORE" = "1" ] && echo restored || echo unchanged ); $(echo $REMOVE | wc -w | tr -d ' ') migration file(s) removed."
  exit 0
fi

say "FAIL: unknown mode '$MODE' (prep|apply|rollback)"; exit 1
