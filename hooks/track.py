#!/usr/bin/env python3
"""Guardrails companion — PostToolUse read/edit tracker (roadmap Phase B1).

Records file paths the session has Read (or successfully Edited/Written) into a
per-session state file; hooks/guard.py checks it to enforce iron rule 1 / C1.
"""
import json
import os
import sys
import tempfile


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)
    if data.get("tool_name") not in ("Read", "Edit", "Write"):
        sys.exit(0)
    path = (data.get("tool_input") or {}).get("file_path")
    if not path:
        sys.exit(0)
    state = os.path.join(
        tempfile.gettempdir(), f"guardrails-reads-{data.get('session_id', 'unknown')}.txt"
    )
    try:
        existing = set()
        if os.path.exists(state):
            with open(state) as f:
                existing = {line.strip() for line in f}
        if path not in existing:
            with open(state, "a") as f:
                f.write(path + "\n")
    except OSError:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
