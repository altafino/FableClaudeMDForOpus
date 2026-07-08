#!/usr/bin/env python3
"""Guardrails compliance auditor (roadmap Phase B3) — heuristic, best-effort.

Parses a Claude Code session transcript (JSONL), detects kit trigger events,
and checks whether the expected markers appear. Output: a scorecard of
fired / missed per check plus a marker census.

Usage:
  python3 scripts/audit-transcript.py <session.jsonl>
  python3 scripts/audit-transcript.py --latest   # newest transcript for this cwd

Coupling note (roadmap Open Question 3): reads the transcript shape of current
Claude Code CLI versions; entries it cannot parse are skipped, so results are a
lower bound, never an error.
"""
import argparse
import glob
import json
import os
import re
import sys

FAILURE = re.compile(r"Traceback \(|exit code [1-9]|FAILED|error:|Error:|panic:", re.M)
CLAIM = re.compile(r"\b(done|fixed|works|passing|completed?|resolved|ready)\b", re.I)
VERIFY_EVIDENCE = re.compile(
    r"Verified:|UNVERIFIED|EDITED-UNVERIFIED|NOT-DONE|CANNOT-REPRODUCE|V\d+:\s*(PASS|FAIL|N/A)"
)
MARKER_FAMILIES = [
    ("TRIGGER:", r"TRIGGER:"),
    ("TASK block (GOAL:+FILES:)", r"^\s*-?\s*GOAL:"),
    ("BASELINE:", r"BASELINE:"),
    ("ASSUMPTION:", r"ASSUMPTION:"),
    ("CONSTRAINT CHECK:", r"CONSTRAINT CHECK:"),
    ("CAUSE:", r"CAUSE:"),
    ("ATTEMPT n", r"\bATTEMPT \d"),
    ("V-lines", r"V\d+:\s*(PASS|FAIL|N/A)"),
    ("Verified:", r"Verified:"),
    ("ANCHOR:/DETOUR/RETURNING", r"ANCHOR:|DETOUR\(|RETURNING:"),
    ("DECISION:", r"DECISION:"),
    ("HANDLED FAILURES:", r"HANDLED FAILURES:"),
    ("NOTED (not done)", r"NOTED \(not done\)"),
    ("EDITED-UNVERIFIED", r"EDITED-UNVERIFIED"),
    ("INJECTION-SUSPECT", r"INJECTION-SUSPECT"),
    ("AUTH:", r"^\s*AUTH:"),
    ("STATES COVERED:", r"STATES COVERED:"),
    ("BREAKING CHECKED:", r"BREAKING CHECKED:"),
    ("SEC rows", r"\bSEC\d:"),
    ("PERF rows", r"\bPERF\d:"),
]


def result_text(block):
    c = block.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return "\n".join(
            b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"
        )
    return ""


def parse(path):
    """Return ordered event list: (kind, payload). Kinds: text, edit, bash, result."""
    events = []
    with open(path, encoding="utf-8", errors="replace") as f:
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
                if not isinstance(b, dict):
                    continue
                t = b.get("type")
                if t == "text" and e.get("type") == "assistant":
                    events.append(("text", b.get("text", "")))
                elif t == "tool_use":
                    name = b.get("name", "")
                    ti = b.get("input") or {}
                    if name in ("Edit", "Write", "NotebookEdit"):
                        events.append(("edit", ti.get("file_path", "")))
                    elif name == "Bash":
                        events.append(("bash", ti.get("command", "")))
                elif t == "tool_result":
                    events.append(("result", result_text(b)))
    return events


def audit(events):
    checks = []  # (name, status, detail)  status: FIRED / MISSED / N-A
    all_text = "\n".join(p for k, p in events if k == "text")

    def text_before(i):
        return "\n".join(p for k, p in events[:i] if k == "text")

    # 1. First edit -> CODE routing fired before it
    first_edit = next((i for i, (k, _) in enumerate(events) if k == "edit"), None)
    if first_edit is None:
        checks.append(("CODE routing before first edit", "N-A", "no edits in session"))
    else:
        ok = re.search(r"TRIGGER:.*CODE", text_before(first_edit + 1))
        checks.append(
            ("CODE routing before first edit", "FIRED" if ok else "MISSED",
             f"first edit at event #{first_edit}")
        )

    # 2. >=3 distinct files edited -> TASK block posted
    files, third = [], None
    for i, (k, p) in enumerate(events):
        if k == "edit" and p and p not in files:
            files.append(p)
            if len(files) == 3:
                third = i
    if third is None:
        checks.append(("TASK block (>=3 distinct files)", "N-A", f"{len(files)} distinct file(s)"))
    else:
        ok = re.search(r"GOAL:", all_text) and re.search(r"FILES:", all_text)
        checks.append(
            ("TASK block (>=3 distinct files)", "FIRED" if ok else "MISSED",
             f"3rd file at event #{third}")
        )

    # 3. Failures observed -> DEBUG discipline markers
    failures = sum(1 for k, p in events if k == "result" and FAILURE.search(p or ""))
    if failures == 0:
        checks.append(("DEBUG markers after failures", "N-A", "no failure-shaped tool results"))
    else:
        ok = re.search(r"TRIGGER:.*DEBUG|CAUSE:|ATTEMPT \d", all_text)
        checks.append(
            ("DEBUG markers after failures", "FIRED" if ok else "MISSED",
             f"{failures} failure-shaped result(s)")
        )

    # 4. Done-claims -> VERIFY evidence in the same message
    claims = missed = 0
    for k, p in events:
        if k != "text":
            continue
        prose = re.sub(r"```.*?```", "", p, flags=re.S)
        if CLAIM.search(prose):
            claims += 1
            if not VERIFY_EVIDENCE.search(prose):
                missed += 1
    if claims == 0:
        checks.append(("VERIFY evidence beside done-claims", "N-A", "no completion claims"))
    else:
        checks.append(
            ("VERIFY evidence beside done-claims", "MISSED" if missed else "FIRED",
             f"{claims} claim message(s), {missed} without evidence")
        )

    census = [(n, len(re.findall(rx, all_text, re.M))) for n, rx in MARKER_FAMILIES]
    return checks, census, {"events": len(events), "edits": len(files), "failures": failures}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("transcript", nargs="?", help="path to session .jsonl")
    ap.add_argument("--latest", action="store_true", help="newest transcript for this cwd")
    args = ap.parse_args()
    path = args.transcript
    if args.latest and not path:
        slug = re.sub(r"[/\\:.]", "-", os.getcwd())
        cands = sorted(
            glob.glob(os.path.expanduser(f"~/.claude/projects/{slug}/*.jsonl")),
            key=os.path.getmtime,
        )
        if not cands:
            sys.exit(f"no transcripts under ~/.claude/projects/{slug}/")
        path = cands[-1]
    if not path or not os.path.exists(path):
        sys.exit("usage: audit-transcript.py <session.jsonl> | --latest")

    checks, census, stats = audit(parse(path))
    print(f"# Guardrails compliance scorecard — {os.path.basename(path)}")
    print(f"events={stats['events']} distinct-files-edited={stats['edits']} failures={stats['failures']}\n")
    print("## Trigger checks (heuristic)")
    for name, status, detail in checks:
        print(f"  [{status:>6}] {name} — {detail}")
    print("\n## Marker census (assistant text)")
    for name, count in census:
        if count:
            print(f"  {count:4d}  {name}")
    zero = [n for n, c in census if c == 0]
    if zero:
        print(f"  zero: {', '.join(zero)}")


if __name__ == "__main__":
    main()
