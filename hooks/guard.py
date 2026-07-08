#!/usr/bin/env python3
"""Guardrails companion — PreToolUse enforcement (roadmap Phase B1).

Mechanically enforces: iron rule 1/C1 (no Edit of an un-Read file), iron rule 2
(no Write over an existing file), C2 (no edits under generated/vendored paths),
hard stop 2 (no git push without user authorization), hard stop 3 (no
kill-by-image-name), SEC4 (no staged secrets at git commit).

Deny = exit 2 with the reason on stderr (shown to the model).
Bypass convention: GUARDRAILS_BYPASS=1 allows the call and appends one line to
<cwd>/.claude/guardrails-bypass.log so the auditor can review overrides.
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import time

GENERATED = re.compile(
    r"(^|/)(dist|build|out|gen|\.next|target|node_modules|vendor|coverage)(/|$)"
    r"|\.min\.|\.map$"
    r"|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|poetry\.lock|Cargo\.lock)$"
)
# Assignment-with-value shape, not bare words — kit docs legitimately contain
# the words "password|secret|token" in rule text.
SECRETS = re.compile(
    r"(?i)(password|secret|token|api[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}"
    r"|BEGIN [A-Z ]*PRIVATE KEY"
)
KILL_BY_NAME = re.compile(r"(?i)\b(pkill|killall)\b|\btaskkill\b[^|;&]*/(im)\b")
GIT_PUSH = re.compile(r"\bgit\b[^|;&]*\bpush\b")
GIT_COMMIT = re.compile(r"\bgit\b[^|;&]*\bcommit\b")
ALLOW_PUSH_TTL_S = 1800  # scripts/allow-push grants one push within 30 min


def reads_state_path(session_id: str) -> str:
    return os.path.join(tempfile.gettempdir(), f"guardrails-reads-{session_id}.txt")


def deny(msg: str) -> None:
    print(msg, file=sys.stderr)
    sys.exit(2)


def log_bypass(cwd: str, tool: str, detail: str) -> None:
    try:
        d = os.path.join(cwd, ".claude")
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, "guardrails-bypass.log"), "a") as f:
            f.write(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} BYPASS {tool} {detail}\n")
    except OSError:
        pass


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)  # unparseable input: never block on our own bug
    tool = data.get("tool_name", "")
    ti = data.get("tool_input") or {}
    sid = data.get("session_id", "unknown")
    cwd = data.get("cwd") or os.getcwd()

    if os.environ.get("GUARDRAILS_BYPASS") == "1":
        log_bypass(cwd, tool, json.dumps(ti)[:200])
        sys.exit(0)

    if tool in ("Edit", "Write"):
        path = ti.get("file_path", "")
        norm = path.replace("\\", "/")
        if GENERATED.search(norm):
            deny(
                f"guardrails C2: {path} looks generated/vendored — edit the source or the "
                "generator and re-run it instead (docs/guardrails/CODE.md C2). "
                "(false positive? GUARDRAILS_BYPASS=1)"
            )
        exists = os.path.exists(path)
        known = False
        rf = reads_state_path(sid)
        if os.path.exists(rf):
            with open(rf) as f:
                known = path in {line.strip() for line in f}
        if tool == "Edit" and exists and not known:
            deny(
                f"guardrails iron rule 1 / C1: no Read of {path} recorded this session — "
                "Read the enclosing scope first, then retry the Edit. "
                "(state lost after crash/compaction? GUARDRAILS_BYPASS=1, logged)"
            )
        if tool == "Write" and exists:
            deny(
                f"guardrails iron rule 2: {path} exists — modify with Edit, never Write. "
                "Sole exception: the rewrite procedure in docs/guardrails/CODE.md "
                "('You are rewriting instead of editing'); follow it, then GUARDRAILS_BYPASS=1."
            )
        sys.exit(0)

    if tool == "Bash":
        cmd = ti.get("command", "")
        if KILL_BY_NAME.search(cmd):
            deny(
                "guardrails hard stop 3: never kill by image name -> find the PID via the "
                "port (lsof -ti :PORT | netstat -ano | findstr :PORT) and kill that PID. "
                "(bypass: GUARDRAILS_BYPASS=1)"
            )
        if GIT_PUSH.search(cmd):
            flag = os.path.join(cwd, ".claude", ".allow-push")
            if os.path.exists(flag) and time.time() - os.path.getmtime(flag) < ALLOW_PUSH_TTL_S:
                try:
                    os.remove(flag)  # single-use grant
                except OSError:
                    pass
                sys.exit(0)
            deny(
                "guardrails hard stop 2: git push blocked — needs the user's own action: "
                "run scripts/allow-push (grants ONE push for 30 min), then retry. "
                "(bypass: GUARDRAILS_BYPASS=1, logged)"
            )
        if GIT_COMMIT.search(cmd):
            try:
                diff = subprocess.run(
                    ["git", "-C", cwd, "diff", "--cached"],
                    capture_output=True, text=True, timeout=15,
                ).stdout
            except (OSError, subprocess.SubprocessError):
                diff = ""
            hits = [l[:120] for l in diff.splitlines() if l.startswith("+") and SECRETS.search(l)]
            if hits:
                deny(
                    "guardrails SEC4: staged diff matches secret patterns:\n"
                    + "\n".join(hits[:5])
                    + "\nRedact/unstage, or confirm false positive with the user. "
                    "(bypass: GUARDRAILS_BYPASS=1, logged)"
                )
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
