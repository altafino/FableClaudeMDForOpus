#!/usr/bin/env bash
# Test suite for scripts/migrate.sh — every design-doc success criterion.
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"   # kit repo root = kit source
M="$HERE/scripts/migrate.sh"
PASS=0; FAIL=0
check() { # name expected actual
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  ok  $1"
  else FAIL=$((FAIL+1)); echo "FAIL  $1 (expected $2, got $3)"; fi
}
mklegacy() { # fresh legacy project dir
  local d; d=$(mktemp -d)
  printf '%s\n' '# My project' 'Dev server: npm run dev (port 5173)' 'Never commit .env files' > "$d/CLAUDE.md"
  echo "$d"
}

echo "== prep: fresh project (no CLAUDE.md) refuses -> install.sh =="
D=$(mktemp -d); ( cd "$D" && bash "$M" "$HERE" prep >/dev/null 2>&1 ); check "fresh refuses (exit 1)" 1 $?
rm -rf "$D"

echo "== prep: legacy project happy path =="
D=$(mklegacy); cd "$D"
OUT=$(bash "$M" "$HERE" prep 2>&1); EC=$?
check "prep exits 0" 0 $EC
ls CLAUDE.md.pre-migration-* >/dev/null 2>&1; check "snapshot created" 0 $?
[ -f docs/guardrails/MIGRATION-PREP.log ]; check "prep log written" 0 $?
N=$(find docs/guardrails -name '*.md' ! -name 'MIGRATION-PREP.log' | wc -l | tr -d ' ')
check "ZERO kit docs written pre-M5 (write gate)" 0 "$N"
grep -q "SNAPSHOT-UNCOMMITTED (no git repo" docs/guardrails/MIGRATION-PREP.log; check "no-git fallback logged" 0 $?
grep -c "MANIFEST:" docs/guardrails/MIGRATION-PREP.log | { read c; check "manifest has 21 docs" 21 "$c"; }

echo "== apply after simulated M5 approval =="
bash "$M" "$HERE" apply >/dev/null 2>&1; check "apply exits 0" 0 $?
N=$(find docs/guardrails -name '*.md' ! -name 'MIGRATION-PREP.log' ! -name 'PROJECT-TEMPLATE.md' | wc -l | tr -d ' ')
check "21 docs copied" 21 "$N"

echo "== prep idempotency: sentinel refuses -> UPGRADE =="
printf '%s\n' '<!-- guardrails-kit: v1.5 migrated 2026-07-10 -->' > CLAUDE.md
( bash "$M" "$HERE" prep >/dev/null 2>&1 ); check "sentinel refuses (exit 2)" 2 $?
cd /; rm -rf "$D"

echo "== prep: planted collision detected, deferred, never overwritten =="
D=$(mklegacy); cd "$D"
mkdir -p docs/guardrails
echo "hand-written old VERIFY rules" > docs/guardrails/VERIFY.md
BEFORE=$(sha256sum docs/guardrails/VERIFY.md | awk '{print $1}')
bash "$M" "$HERE" prep >/dev/null 2>&1; check "prep with collision exits 0" 0 $?
grep -q "COLLISION: VERIFY.md DIFFERENT" docs/guardrails/MIGRATION-PREP.log; check "collision logged as DIFFERENT" 0 $?
grep -q "rename existing to VERIFY.pre-kit.md" docs/guardrails/MIGRATION-PREP.log; check "M6a(1) options logged verbatim" 0 $?
AFTER=$(sha256sum docs/guardrails/VERIFY.md | awk '{print $1}')
check "existing file untouched" "$BEFORE" "$AFTER"
bash "$M" "$HERE" apply >/dev/null 2>&1
AFTER2=$(sha256sum docs/guardrails/VERIFY.md | awk '{print $1}')
check "apply skips deferred collision" "$BEFORE" "$AFTER2"
cd /; rm -rf "$D"

echo "== prep: orphaned MIGRATION-LOG.md stops for the human =="
D=$(mklegacy); cd "$D"; mkdir -p docs/guardrails; echo "## Surfaces" > docs/guardrails/MIGRATION-LOG.md
( bash "$M" "$HERE" prep >/dev/null 2>&1 ); check "orphaned log stops (exit 3)" 3 $?
cd /; rm -rf "$D"

echo "== prep --dry-run: zero writes =="
D=$(mklegacy); cd "$D"
bash "$M" "$HERE" prep --dry-run >/dev/null 2>&1; check "dry-run exits 0" 0 $?
[ ! -e docs/guardrails/MIGRATION-PREP.log ] && [ -z "$(ls CLAUDE.md.pre-migration-* 2>/dev/null)" ]
check "dry-run wrote nothing" 0 $?
cd /; rm -rf "$D"

echo "== migrate-auto.sh --dry-run stops before Claude =="
D=$(mklegacy); cd "$D"
OUT=$(bash "$HERE/scripts/migrate-auto.sh" --kit "$HERE" --dry-run 2>&1); EC=$?
check "auto dry-run exits 0" 0 $EC
echo "$OUT" | grep -q "stopping before the Claude session"; check "auto dry-run stops pre-launch" 0 $?
cd /; rm -rf "$D"

echo "== rollback: refuses without a prep log =="
D=$(mklegacy); cd "$D"
( bash "$M" "$HERE" rollback --yes >/dev/null 2>&1 ); check "rollback without log refuses (exit 1)" 1 $?
cd /; rm -rf "$D"

echo "== rollback after prep only: cleanup, CLAUDE.md untouched =="
D=$(mklegacy); cd "$D"
ORIG=$(sha256sum CLAUDE.md | awk '{print $1}')
bash "$M" "$HERE" prep >/dev/null 2>&1
bash "$M" "$HERE" rollback --yes --purge >/dev/null 2>&1; check "rollback exits 0" 0 $?
check "CLAUDE.md untouched" "$ORIG" "$(sha256sum CLAUDE.md | awk '{print $1}')"
[ ! -e docs/guardrails/MIGRATION-PREP.log ]; check "prep log removed" 0 $?
[ -z "$(ls CLAUDE.md.pre-migration-* 2>/dev/null)" ]; check "snapshot purged (--purge)" 0 $?
[ ! -d docs/guardrails ]; check "created docs/guardrails dir removed" 0 $?
cd /; rm -rf "$D"

echo "== rollback after apply + simulated M6b: full undo, collisions survive =="
D=$(mklegacy); cd "$D"
mkdir -p docs/guardrails
echo "hand-written old VERIFY rules" > docs/guardrails/VERIFY.md
KEEP=$(sha256sum docs/guardrails/VERIFY.md | awk '{print $1}')
ORIG=$(sha256sum CLAUDE.md | awk '{print $1}')
bash "$M" "$HERE" prep >/dev/null 2>&1
bash "$M" "$HERE" apply >/dev/null 2>&1
printf '%s\n' '<!-- guardrails-kit: v1.5 migrated 2026-07-10 -->' 'new composed CLAUDE.md' > CLAUDE.md  # simulate M6b
OUT=$(bash "$M" "$HERE" rollback --yes 2>&1); check "rollback exits 0" 0 $?
echo "$OUT" | grep -q "COMPLETED migration"; check "sentinel warning shown" 0 $?
check "CLAUDE.md restored from snapshot" "$ORIG" "$(sha256sum CLAUDE.md | awk '{print $1}')"
[ ! -e docs/guardrails/CODE.md ]; check "applied kit docs removed" 0 $?
check "pre-existing collision file KEPT" "$KEEP" "$(sha256sum docs/guardrails/VERIFY.md | awk '{print $1}')"
ls CLAUDE.md.pre-migration-* >/dev/null 2>&1; check "snapshot kept without --purge" 0 $?
cd /; rm -rf "$D"

echo
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
