#!/usr/bin/env python3
"""Guardrails eval runner (roadmap B4). See evals/METRICS.md for definitions.

Runs each task under evals/tasks/ in a fresh temp workspace, per condition
(with-kit / without-kit), N times, via headless `claude -p`. Captures: task
acceptance, cost/turns (CLI JSON), and the compliance scorecard (auditor).

  python3 evals/run.py --dry-run --n 1              # plumbing check, no API calls
  python3 evals/run.py --model claude-opus-4-8 --n 5
  python3 evals/run.py --tasks bugfix-chunks rename-sweep --n 5

Real runs consume API budget: tasks x conditions x N sessions. Rows append to
evals/results/<stamp>.jsonl; a summary table prints at the end.
"""
import argparse
import datetime
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def parse_task(path):
    text = open(path, encoding="utf-8").read()
    tid = re.search(r"^# task:\s*(\S+)", text, re.M).group(1)

    def block(name):
        m = re.search(rf"^## {name}\s*\n(.*?)(?=^## |\Z)", text, re.M | re.S)
        return m.group(1).strip() if m else ""

    def bash(section):
        m = re.search(r"```bash\n(.*?)```", section, re.S)
        return m.group(1) if m else section

    return {"id": tid, "setup": bash(block("setup")),
            "prompt": block("prompt"), "acceptance": bash(block("acceptance"))}


def install_kit(ws):
    r = subprocess.run(["bash", os.path.join(ROOT, "scripts", "install.sh"), ROOT, ws],
                       capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"kit install into workspace failed:\n{r.stdout}{r.stderr}")


def run_claude(ws, prompt, model, dry):
    if dry:
        return {"result": "dryrun", "total_cost_usd": 0, "num_turns": 0}
    cmd = ["claude", "-p", prompt, "--output-format", "json",
           "--dangerously-skip-permissions"]
    if model:
        cmd += ["--model", model]
    r = subprocess.run(cmd, cwd=ws, capture_output=True, text=True, timeout=1800)
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return {"result": "unparseable", "stderr": r.stderr[-500:], "exit": r.returncode}


def audit(ws):
    """Newest transcript for the workspace slug -> auditor metrics."""
    slug = re.sub(r"[/\\:.]", "-", ws)
    cands = sorted(glob.glob(os.path.expanduser(f"~/.claude/projects/{slug}/*.jsonl")),
                   key=os.path.getmtime)
    if not cands:
        return {"audit": "no-transcript"}
    r = subprocess.run(["python3", os.path.join(ROOT, "scripts", "audit-transcript.py"),
                        cands[-1]], capture_output=True, text=True)
    out = r.stdout
    fired = len(re.findall(r"\[ FIRED\]", out))
    missed = len(re.findall(r"\[MISSED\]", out))
    m = re.search(r"(\d+) claim message\(s\), (\d+) without evidence", out)
    markers = len(re.findall(r"^\s+\d+\s+TRIGGER:", out, re.M))
    return {
        "fired": fired, "missed": missed,
        "fire_rate": round(fired / (fired + missed), 2) if fired + missed else None,
        "claims": int(m.group(1)) if m else 0,
        "claims_unverified": int(m.group(2)) if m else 0,
        "kit_engaged": bool(markers),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=5)
    ap.add_argument("--model", default=None, help="model id; default = CLI default")
    ap.add_argument("--tasks", nargs="*", help="task ids (default: all)")
    ap.add_argument("--conditions", nargs="*", default=["with-kit", "without-kit"])
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    tasks = [parse_task(p) for p in sorted(glob.glob(os.path.join(ROOT, "evals", "tasks", "*.md")))]
    if args.tasks:
        tasks = [t for t in tasks if t["id"] in args.tasks]
    if not tasks:
        sys.exit("no tasks matched")

    os.makedirs(os.path.join(ROOT, "evals", "results"), exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    out_path = os.path.join(ROOT, "evals", "results", f"{stamp}.jsonl")
    rows = []
    for task in tasks:
        for cond in args.conditions:
            for i in range(args.n):
                ws = tempfile.mkdtemp(prefix=f"gk-eval-{task['id']}-")
                try:
                    subprocess.run(["bash", "-c", task["setup"]], cwd=ws, check=True,
                                   capture_output=True)
                    if cond == "with-kit":
                        install_kit(ws)
                    res = run_claude(ws, task["prompt"], args.model, args.dry_run)
                    acc = subprocess.run(["bash", "-c", task["acceptance"]], cwd=ws,
                                         capture_output=True, text=True)
                    row = {
                        "task": task["id"], "condition": cond, "run": i + 1,
                        "model": args.model or "cli-default", "dry_run": args.dry_run,
                        "pass": acc.returncode == 0,
                        "cost_usd": res.get("total_cost_usd"),
                        "turns": res.get("num_turns"),
                    }
                    row.update(audit(ws) if not args.dry_run else {"audit": "skipped-dry-run"})
                    rows.append(row)
                    with open(out_path, "a") as f:
                        f.write(json.dumps(row) + "\n")
                    print(f"  {task['id']:>18} {cond:<12} run {i + 1}: "
                          f"{'PASS' if row['pass'] else 'fail'}")
                finally:
                    shutil.rmtree(ws, ignore_errors=True)

    print(f"\nresults -> {out_path}\n## summary (mean over N={args.n})")
    for task in tasks:
        for cond in args.conditions:
            sel = [r for r in rows if r["task"] == task["id"] and r["condition"] == cond]
            if not sel:
                continue
            pr = sum(r["pass"] for r in sel) / len(sel)
            fr = [r["fire_rate"] for r in sel if r.get("fire_rate") is not None]
            print(f"  {task['id']:>18} {cond:<12} pass={pr:.0%}"
                  + (f" fire-rate={sum(fr) / len(fr):.0%}" if fr else ""))


if __name__ == "__main__":
    main()
