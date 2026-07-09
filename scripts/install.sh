#!/usr/bin/env bash
# Guardrails kit — self-verifying fresh installer (roadmap Phase C3).
# Usage: scripts/install.sh <kit-dir> [target-dir] [--skills]
# Fresh installs only: a target with an existing CLAUDE.md must use MIGRATE.md.
set -u
KIT="${1:?usage: install.sh <kit-dir> [target-dir] [--skills]}"
TARGET="${2:-.}"
WITH_SKILLS=0
for a in "$@"; do [ "$a" = "--skills" ] && WITH_SKILLS=1; done
FAIL=0
say() { printf '%s\n' "$*"; }
hash_of() { sha256sum "$1" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$1" | awk '{print $1}'; }

[ -f "$KIT/CLAUDE.md" ] || { say "FAIL: $KIT does not look like the kit (no CLAUDE.md)"; exit 1; }
if [ -e "$TARGET/CLAUDE.md" ]; then
  say "FAIL: $TARGET/CLAUDE.md already exists — this installer is fresh-install only."
  say "      Use MIGRATE.md (or /kit-migrate) for projects with an existing CLAUDE.md."
  exit 1
fi

mkdir -p "$TARGET/docs/guardrails"
cp "$KIT/CLAUDE.md" "$TARGET/CLAUDE.md"
cp "$KIT"/docs/guardrails/*.md "$TARGET/docs/guardrails/"
if [ "$WITH_SKILLS" = "1" ] && [ -d "$KIT/.claude/skills" ]; then
  mkdir -p "$TARGET/.claude/skills"
  cp -r "$KIT"/.claude/skills/kit-* "$TARGET/.claude/skills/"
fi

say "== verification (MIGRATE M8 items 3/4/6 equivalents) =="
head -1 "$TARGET/CLAUDE.md" | grep -q "guardrails-kit:" \
  && say "  ok  CLAUDE.md line 1 carries the kit sentinel" \
  || { say "FAIL  CLAUDE.md sentinel missing"; FAIL=1; }
for f in "$KIT"/docs/guardrails/*.md; do
  b="$(basename "$f")"
  if [ "$(hash_of "$f")" = "$(hash_of "$TARGET/docs/guardrails/$b")" ]; then
    say "  ok  hash match: $b"
  else
    say "FAIL  hash mismatch: $b"; FAIL=1
  fi
done
SRC_N=$(ls "$KIT"/docs/guardrails/*.md | wc -l | tr -d ' ')
DST_N=$(ls "$TARGET"/docs/guardrails/*.md | wc -l | tr -d ' ')
[ "$SRC_N" = "$DST_N" ] && say "  ok  doc count: $DST_N" || { say "FAIL  doc count $DST_N != $SRC_N"; FAIL=1; }
if [ "$WITH_SKILLS" = "1" ]; then
  SK=$(ls -d "$TARGET"/.claude/skills/kit-* 2>/dev/null | wc -l | tr -d ' ')
  say "  ok  skills installed: $SK"
fi
if [ "$FAIL" = "0" ]; then
  say "INSTALL: PASS — now fill CLAUDE.md '## Project' (zone 2) with your run/test commands."
else
  say "INSTALL: FAILED — do not use this install; re-run after fixing the above."
fi
exit "$FAIL"
