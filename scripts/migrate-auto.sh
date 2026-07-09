#!/usr/bin/env bash
# Guardrails kit — one-command migration orchestrator (design doc 2026-07-10).
#   scripts/migrate-auto.sh --kit <kit-dir> [--dry-run] [--model <id>]
# Runs migrate.sh prep, then launches an INTERACTIVE Claude session for the
# semantic phases (M1, M3-M5, M6b/c, M7). Interactive by design: MIGRATE.md's
# M5 checkpoint requires a human answer — never headless.
set -u
KIT=""; DRY=""; MODEL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --kit) KIT="$2"; shift 2 ;;
    --dry-run) DRY="--dry-run"; shift ;;
    --model) MODEL="$2"; shift 2 ;;
    *) echo "usage: migrate-auto.sh --kit <kit-dir> [--dry-run] [--model <id>]"; exit 1 ;;
  esac
done
[ -n "$KIT" ] || { echo "usage: migrate-auto.sh --kit <kit-dir> [--dry-run] [--model <id>]"; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"
bash "$HERE/migrate.sh" "$KIT" prep $DRY || exit $?
[ -n "$DRY" ] && { echo "DRY RUN: stopping before the Claude session."; exit 0; }
set -- claude
[ -n "$MODEL" ] && set -- "$@" --model "$MODEL"
exec "$@" "Read MIGRATE.md in $KIT and execute it exactly, phase by phase. Script-prepped entry applies: docs/guardrails/MIGRATION-PREP.log evidences M0/M2 — spot-check the snapshot hash, then start at M1. At M6a run: scripts/migrate.sh $KIT apply"
