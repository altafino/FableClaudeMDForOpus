#!/usr/bin/env python3
"""Guardrails companion — Stop-hook done-claim verifier (roadmap Phase B2).

At turn end: if the session edited files AND the final assistant message claims
done/fixed/works/passing/complete/resolved/ready WITHOUT a legal VERIFY.md form
(`Verified:` / `UNVERIFIED` / V-lines / canonical statuses), block the stop and
point at docs/guardrails/VERIFY.md. Match scope: assistant prose only — fenced
code blocks are stripped first. Heuristic v0; bypass: GUARDRAILS_BYPASS=1.
"""
import json
import os
import re
import sys

CLAIM = re.compile(r"\b(done|fixed|works|passing|completed?|resolved|ready)\b", re.I)
EVIDENCE = re.compile(
    r"Verified:|UNVERIFIED|EDITED-UNVERIFIED|NOT-DONE|CANNOT-REPRODUCE|V\d+:\s*(PASS|FAIL|N/A)"
)
EDIT_TOOLS = ("Edit", "Write", "NotebookEdit")


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)
    if data.get("stop_hook_active"):  # loop guard: never block our own re-entry
        sys.exit(0)
    if os.environ.get("GUARDRAILS_BYPASS") == "1":
        sys.exit(0)
    tp = data.get("transcript_path")
    if not tp or not os.path.exists(tp):
        sys.exit(0)

    had_edit = False
    last_text = ""
    with open(tp, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
            except json.JSONDecodeError:
                continue
            content = (e.get("message") or {}).get("content")
            if not isinstance(content, list):
                continue
            for b in content:
                if isinstance(b, dict) and b.get("type") == "tool_use" and b.get("name") in EDIT_TOOLS:
                    had_edit = True
            if e.get("type") == "assistant":
                texts = [
                    b.get("text", "")
                    for b in content
                    if isinstance(b, dict) and b.get("type") == "text"
                ]
                if texts:
                    last_text = "\n".join(texts)

    if not had_edit:
        sys.exit(0)  # nothing was edited; completion claims need no run evidence
    prose = re.sub(r"```.*?```", "", last_text, flags=re.S)
    if CLAIM.search(prose) and not EVIDENCE.search(prose):
        print(
            "guardrails VERIFY: the final message claims completion without a legal status "
            "form. Use `Verified: <command> -> <result line>` or `UNVERIFIED — to confirm, "
            "run: <command>` per docs/guardrails/VERIFY.md, or run the verification now. "
            "(bypass: GUARDRAILS_BYPASS=1)",
            file=sys.stderr,
        )
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
