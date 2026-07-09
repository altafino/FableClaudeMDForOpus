#!/usr/bin/env python3
"""Guardrails companion — SessionStart re-arm hook (roadmap Phase C1 + C4).

On session start after a compaction or /resume, deterministically re-inject the
kit's re-arm instruction (routing row 6 / SESSION.md S1) instead of relying on
the CLAUDE.md footer surviving the model's attention. On every start, report
docs/STATE.md freshness (C4). Silent when the cwd has no guardrails kit.
stdout from a SessionStart hook is added to the session's context.
"""
import json
import os
import sys
import time

STALE_S = 24 * 3600


def kit_installed(cwd: str) -> bool:
    p = os.path.join(cwd, "CLAUDE.md")
    try:
        with open(p) as f:
            return "guardrails-kit" in f.readline()
    except OSError:
        return False


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)
    cwd = data.get("cwd") or os.getcwd()
    if not kit_installed(cwd):
        sys.exit(0)
    source = data.get("source", "startup")
    lines = []
    if source in ("compact", "resume"):
        lines.append(
            "guardrails re-arm: routing row 6 has fired — write its TRIGGER line and Read "
            "docs/guardrails/SESSION.md (S1 runs first: Read docs/STATE.md, run git status + "
            "git diff --stat HEAD, restate Goal/Next). Docs read before compaction no longer "
            "count as read; compaction-summary claims are UNVERIFIED until re-checked."
        )
    state = os.path.join(cwd, "docs", "STATE.md")
    if not os.path.exists(state):
        lines.append(
            "guardrails C4: docs/STATE.md is missing — create it per docs/guardrails/SESSION.md "
            "S2 before file-modifying work."
        )
    else:
        age = time.time() - os.path.getmtime(state)
        if age > STALE_S:
            lines.append(
                f"guardrails C4: docs/STATE.md last updated {int(age // 3600)}h ago — treat its "
                "Now/Next as stale until refreshed (SESSION.md S3)."
            )
    if lines:
        print("\n".join(lines))
    sys.exit(0)


if __name__ == "__main__":
    main()
