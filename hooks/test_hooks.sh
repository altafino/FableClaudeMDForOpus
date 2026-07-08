#!/usr/bin/env bash
# Guardrails companion test suite — every deny's trigger case + its bypass path.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SID="testsess-$$"
STATE="${TMPDIR:-/tmp}/guardrails-reads-$SID.txt"
rm -f "$STATE"
PASS=0; FAIL=0

run_guard() { # $1=json  -> echoes exit code
  printf '%s' "$1" | python3 "$HERE/guard.py" >/dev/null 2>"$TMP/err"; echo $?
}
check() { # $1=name $2=expected_exit $3=actual_exit
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  ok  $1"
  else FAIL=$((FAIL+1)); echo "FAIL  $1 (expected exit $2, got $3)"; sed 's/^/      /' "$TMP/err"; fi
}
j() { python3 -c 'import json,sys; print(json.dumps({"session_id":sys.argv[1],"cwd":sys.argv[2],"tool_name":sys.argv[3],"tool_input":json.loads(sys.argv[4])}))' "$SID" "$1" "$2" "$3"; }

echo "== guard.py: Edit/Write =="
F="$TMP/app.py"; echo "x = 1" > "$F"
check "Edit un-Read file -> deny"        2 "$(run_guard "$(j "$TMP" Edit "{\"file_path\":\"$F\"}")")"
printf '%s' "$(j "$TMP" Read "{\"file_path\":\"$F\"}")" | python3 "$HERE/track.py"
check "Edit after Read -> allow"         0 "$(run_guard "$(j "$TMP" Edit "{\"file_path\":\"$F\"}")")"
check "Write existing file -> deny"      2 "$(run_guard "$(j "$TMP" Write "{\"file_path\":\"$F\"}")")"
check "Write new file -> allow"          0 "$(run_guard "$(j "$TMP" Write "{\"file_path\":\"$TMP/new.py\"}")")"
check "Edit under node_modules -> deny"  2 "$(run_guard "$(j "$TMP" Edit "{\"file_path\":\"$TMP/node_modules/a.js\"}")")"
check "Write lockfile -> deny"           2 "$(run_guard "$(j "$TMP" Write "{\"file_path\":\"$TMP/package-lock.json\"}")")"

echo "== guard.py: Bash =="
check "pkill by name -> deny"            2 "$(run_guard "$(j "$TMP" Bash '{"command":"pkill node"}')")"
check "taskkill /IM -> deny"             2 "$(run_guard "$(j "$TMP" Bash '{"command":"taskkill /IM node.exe /F"}')")"
check "kill by PID -> allow"             0 "$(run_guard "$(j "$TMP" Bash '{"command":"kill 12345"}')")"
check "git push w/o flag -> deny"        2 "$(run_guard "$(j "$TMP" Bash '{"command":"git push origin dev"}')")"
mkdir -p "$TMP/.claude"; touch "$TMP/.claude/.allow-push"
check "git push with flag -> allow"      0 "$(run_guard "$(j "$TMP" Bash '{"command":"git push origin dev"}')")"
[ ! -e "$TMP/.claude/.allow-push" ] && { PASS=$((PASS+1)); echo "  ok  push flag consumed (single-use)"; } || { FAIL=$((FAIL+1)); echo "FAIL  push flag not consumed"; }

echo "== guard.py: secret scan on commit =="
REPO="$TMP/repo"; mkdir -p "$REPO"; git -C "$REPO" init -q
echo 'api_key = "sk-supersecret-12345"' > "$REPO/cfg.py"; git -C "$REPO" add cfg.py
check "commit with staged secret -> deny" 2 "$(run_guard "$(j "$REPO" Bash '{"command":"git commit -m x"}')")"
git -C "$REPO" reset -q; echo 'name = "hello"' > "$REPO/cfg.py"; git -C "$REPO" add cfg.py
check "commit clean staged -> allow"      0 "$(run_guard "$(j "$REPO" Bash '{"command":"git commit -m x"}')")"

echo "== bypass + log =="
EC=$(printf '%s' "$(j "$TMP" Write "{\"file_path\":\"$F\"}")" | GUARDRAILS_BYPASS=1 python3 "$HERE/guard.py" >/dev/null 2>&1; echo $?)
check "bypass allows denied call"        0 "$EC"
grep -q "BYPASS Write" "$TMP/.claude/guardrails-bypass.log" 2>/dev/null \
  && { PASS=$((PASS+1)); echo "  ok  bypass logged"; } || { FAIL=$((FAIL+1)); echo "FAIL  bypass not logged"; }

echo "== stop_verify.py =="
mk_transcript() { # $1=file $2=claim-text $3=with_edit(0/1)
  : > "$1"
  [ "$3" = "1" ] && printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Edit","input":{"file_path":"a.py"}}]}}' >> "$1"
  python3 -c 'import json,sys; print(json.dumps({"type":"assistant","message":{"content":[{"type":"text","text":sys.argv[1]}]}}))' "$2" >> "$1"
}
run_stop() { printf '{"transcript_path":"%s","stop_hook_active":false}' "$1" | python3 "$HERE/stop_verify.py" >/dev/null 2>&1; echo $?; }
T="$TMP/t1.jsonl"; mk_transcript "$T" "The bug is fixed now." 1
check "edited + bare done-claim -> block" 2 "$(run_stop "$T")"
T="$TMP/t2.jsonl"; mk_transcript "$T" "Fixed. Verified: pytest -> 3 passed" 1
check "edited + Verified: -> allow"       0 "$(run_stop "$T")"
T="$TMP/t3.jsonl"; mk_transcript "$T" "All done for today!" 0
check "no edits + done-claim -> allow"    0 "$(run_stop "$T")"
T="$TMP/t4.jsonl"; mk_transcript "$T" "Edited files. EDITED-UNVERIFIED: a.py" 1
check "edited + EDITED-UNVERIFIED -> allow" 0 "$(run_stop "$T")"

rm -f "$STATE"
echo
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
