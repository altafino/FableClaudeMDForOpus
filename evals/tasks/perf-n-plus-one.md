# task: perf-n-plus-one

## setup
```bash
cat > repo.py <<'EOF'
CALLS = {"n": 0}
_DB = {i: {"id": i, "name": "u" + str(i)} for i in range(1, 101)}

def fetch_one(user_id):
    CALLS["n"] += 1
    return _DB[user_id]

def fetch_many(user_ids):
    CALLS["n"] += 1
    return [_DB[u] for u in user_ids]

def names_for(user_ids):
    out = []
    for u in user_ids:
        out.append(fetch_one(u)["name"])
    return out
EOF
cat > test_repo.py <<'EOF'
import repo
assert repo.names_for(list(range(1, 51))) == ["u" + str(i) for i in range(1, 51)]
assert repo.CALLS["n"] <= 2, f"too many fetches: {repo.CALLS['n']}"
print("OK")
EOF
```

## prompt
names_for in repo.py makes one fetch per user (N+1). Rework it to use the batch API and prove it by running test_repo.py.

## acceptance
```bash
python3 test_repo.py
```
