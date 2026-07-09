#!/usr/bin/env python3
"""Guardrails kit doctor (roadmap Addendum 2, meta-capability 3).

Validates an installed project's kit health — recurring, not install-time-only.
Checks: CLAUDE.md sentinel + KIT CORE/FOOTER marker pairing; the 20 kit docs
present, each with its version comment; docs/STATE.md shape (nine S2 headers,
<=80 lines) and age; PROJECT.md anchors each having a CLAUDE.md pointer (M8
item 9 as a recurring check); optional --kit <path> hash comparison against a
kit source. Output: ok/WARN/FAIL per check + exact repair step; exit 1 on FAIL.
"""
import argparse
import hashlib
import os
import re
import sys
import time

KIT_DOCS = [
    "_FORMAT", "PLAN", "CODE", "DEBUG", "VERIFY", "EFFICIENCY", "SESSION", "TRAPS",
    "SECURITY", "PERFORMANCE", "FRONTEND", "TRUST", "DATA", "TEST",
    "TRAPS-GO", "TRAPS-ANGULAR", "TRAPS-VUE", "TRAPS-TAILWIND", "TRAPS-SQL", "TRAPS-NOSQL",
]
S2_HEADERS = ["## Goal", "## Now", "## Next", "## Constraints", "## Decisions",
              "## Facts", "## Done", "## Open items", "## Failed attempts"]
ok_n = warn_n = fail_n = 0


def report(level: str, msg: str) -> None:
    global ok_n, warn_n, fail_n
    if level == "ok":
        ok_n += 1
    elif level == "WARN":
        warn_n += 1
    else:
        fail_n += 1
    print(f"  [{level:>4}] {msg}")


def sha(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default=".", help="installed project root")
    ap.add_argument("--kit", help="kit source dir for hash comparison")
    args = ap.parse_args()
    root = args.project

    print("== guardrails kit doctor ==")
    cm = os.path.join(root, "CLAUDE.md")
    if not os.path.exists(cm):
        report("FAIL", "CLAUDE.md missing — repair: scripts/install.sh <kit> (fresh) or MIGRATE.md")
        text = ""
    else:
        text = open(cm, encoding="utf-8", errors="replace").read()
        first = text.splitlines()[0] if text else ""
        report("ok" if "guardrails-kit" in first else "FAIL",
               "CLAUDE.md line-1 sentinel" if "guardrails-kit" in first
               else "CLAUDE.md line 1 lacks 'guardrails-kit:' — repair: restore from kit/MIGRATE snapshot")
        for zone in ("KIT CORE", "KIT FOOTER"):
            b = len(re.findall(rf"<!-- BEGIN {zone}", text))
            e = len(re.findall(rf"<!-- END {zone}", text))
            if b == 1 and e == 1:
                report("ok", f"{zone} markers paired")
            else:
                report("FAIL", f"{zone} markers begin={b} end={e} — repair: MIGRATE.md UPGRADE U2 block swap")

    gdir = os.path.join(root, "docs", "guardrails")
    missing = [d for d in KIT_DOCS if not os.path.exists(os.path.join(gdir, d + ".md"))]
    if missing:
        report("FAIL", f"kit docs missing: {', '.join(missing)} — repair: copy from kit source (never retype)")
    else:
        report("ok", f"all {len(KIT_DOCS)} kit docs present")
    unversioned = []
    for d in KIT_DOCS:
        p = os.path.join(gdir, d + ".md")
        if os.path.exists(p):
            with open(p, encoding="utf-8", errors="replace") as f:
                if "guardrails-kit:" not in f.readline():
                    unversioned.append(d)
    report("FAIL" if unversioned else "ok",
           f"docs missing version comment: {', '.join(unversioned)} — repair: restore from kit source"
           if unversioned else "every kit doc carries its version comment")

    st = os.path.join(root, "docs", "STATE.md")
    if not os.path.exists(st):
        report("WARN", "docs/STATE.md missing — repair: create per SESSION.md S2 (or /kit-state)")
    else:
        s = open(st, encoding="utf-8", errors="replace").read()
        hdr_missing = [h for h in S2_HEADERS if h not in s]
        report("FAIL" if hdr_missing else "ok",
               f"STATE.md missing headers: {', '.join(hdr_missing)}" if hdr_missing
               else "STATE.md has all nine S2 headers")
        n = len(s.splitlines())
        report("ok" if n <= 80 else "WARN",
               f"STATE.md {n} lines" + ("" if n <= 80 else " (>80 — trim old Done entries, keep specifics)"))
        age_h = int((time.time() - os.path.getmtime(st)) // 3600)
        report("ok" if age_h < 24 else "WARN", f"STATE.md age {age_h}h" + ("" if age_h < 24 else " — refresh per S3"))

    pj = os.path.join(gdir, "PROJECT.md")
    if os.path.exists(pj):
        anchors = re.findall(r"^## (.+)$", open(pj, encoding="utf-8", errors="replace").read(), re.M)
        unpointed = [a for a in anchors if "PROJECT.md#" not in text or a.lower().replace(" ", "-") not in text.lower()]
        report("WARN" if unpointed else "ok",
               f"PROJECT.md anchors without a zone-2 pointer: {len(unpointed)}" if unpointed
               else "every PROJECT.md anchor has a zone-2 pointer")

    if args.kit:
        mismatched = []
        for d in KIT_DOCS:
            a = os.path.join(gdir, d + ".md")
            b = os.path.join(args.kit, "docs", "guardrails", d + ".md")
            if os.path.exists(a) and os.path.exists(b) and sha(a) != sha(b):
                mismatched.append(d)
        report("WARN" if mismatched else "ok",
               f"docs differing from kit source (hand-edit or version skew): {', '.join(mismatched)}"
               if mismatched else "all kit docs hash-match the kit source")

    blog = os.path.join(root, ".claude", "guardrails-bypass.log")
    if os.path.exists(blog):
        n = sum(1 for _ in open(blog))
        report("WARN", f"{n} hook bypass(es) logged — review .claude/guardrails-bypass.log")

    print(f"\nDOCTOR: {ok_n} ok, {warn_n} warn, {fail_n} fail")
    sys.exit(1 if fail_n else 0)


if __name__ == "__main__":
    main()
