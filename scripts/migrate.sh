#!/usr/bin/env bash
# Guardrails kit — migration mechanical wrapper (design doc 2026-07-10).
#
#   scripts/migrate.sh <kit-dir> prep  [--dry-run] [--launch]   (default: prep)
#   scripts/migrate.sh <kit-dir> apply
#
# prep  = MIGRATE.md phases M0 + M2 + collision pre-scan + kit manifest.
#         Writes ONLY the snapshot and docs/guardrails/MIGRATION-PREP.log —
#         never a kit doc (M1/M5 write gate). Judgment phases stay with the
#         model: run /kit-migrate afterwards (or use --launch).
# apply = MIGRATE.md phase M6a per-file copies, hash-verified against the
#         prep manifest. Run ONLY after the M5 user checkpoint approved.
set -u
KIT="${1:?usage: migrate.sh <kit-dir> [prep|apply] [--dry-run] [--launch]}"
MODE="${2:-prep}"
DRY=0; LAUNCH=0
for a in "$@"; do
  [ "$a" = "--dry-run" ] && DRY=1
  [ "$a" = "--launch" ] && LAUNCH=1
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
    mkdir -p docs/guardrails
    : > "$LOG"
    log "# MIGRATION-PREP.log — written by scripts/migrate.sh prep, $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    log "# Contract: sha256 throughout. Model session: MIGRATE.md 'script-prepped entry' applies — start at M1."
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
    cp "$SRC" "$DST"
    WANT=$(grep "MANIFEST: $d.md " "$LOG" | sed 's/.*sha256=//')
    GOT=$(sha "$DST")
    if [ "$WANT" = "$GOT" ]; then COPIED=$((COPIED+1)); else say "FAIL hash mismatch: $d.md"; FAIL=1; fi
  done
  cp "$KIT/docs/guardrails/PROJECT-TEMPLATE.md" docs/guardrails/ 2>/dev/null || true
  say "APPLY: $COPIED doc(s) copied and hash-verified against the prep manifest."
  [ "$FAIL" = "0" ] && say "APPLY: PASS — continue MIGRATE.md at M6b (compose CLAUDE.md)." || say "APPLY: FAILED"
  exit "$FAIL"
fi

say "FAIL: unknown mode '$MODE' (prep|apply)"; exit 1
