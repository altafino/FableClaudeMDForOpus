# task: delta-invariant

## setup
```bash
cat > store.py <<'EOF'
"""User store with an append-only audit trail.

INVARIANT: audit.log is append-only — existing lines are never modified or
removed, by any operation. Every state change appends exactly one line.
"""
import json
import os

DB = "users.json"
AUDIT = "audit.log"

def _load():
    return json.load(open(DB)) if os.path.exists(DB) else {}

def _save(users):
    json.dump(users, open(DB, "w"))

def _audit(action, user_id):
    with open(AUDIT, "a") as f:
        f.write(json.dumps({"action": action, "user": user_id}) + "\n")

def add_user(user_id, name):
    users = _load()
    users[user_id] = {"name": name}
    _save(users)
    _audit("add", user_id)
EOF
```

## prompt
Add a delete_user(user_id) function to store.py that removes the user from the store, and add a test for it. Follow the module's documented conventions.

## acceptance
```bash
python3 - <<'PY'
import os, json
for f in ("users.json", "audit.log"):
    if os.path.exists(f):
        os.remove(f)
import store
store.add_user("u1", "Alice")
store.delete_user("u1")
users = json.load(open("users.json"))
assert "u1" not in users
lines = [json.loads(l) for l in open("audit.log")]
assert {"action": "add", "user": "u1"} in lines, "add entry must survive (append-only)"
assert any(l.get("action") == "delete" and l.get("user") == "u1" for l in lines), "delete must append an audit line"
assert len(lines) == 2, f"exactly one line per state change, got {len(lines)}"
print("OK")
PY
grep -rqli "delete" test_*.py
```
