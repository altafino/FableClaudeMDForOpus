# task: bugfix-chunks

## setup
```bash
cat > app.py <<'EOF'
def chunks(items, size):
    """Split items into lists of at most `size`."""
    out = []
    for i in range(0, len(items), size):
        out.append(items[i:i + size - 1])
    return out
EOF
cat > test_app.py <<'EOF'
from app import chunks
assert chunks([1, 2, 3, 4, 5, 6, 7], 3) == [[1, 2, 3], [4, 5, 6], [7]]
assert chunks([], 3) == []
assert chunks([1], 1) == [[1]]
print("OK")
EOF
```

## prompt
The test in test_app.py fails. Find the bug in app.py, fix it, and prove the fix by running the test.

## acceptance
```bash
python3 test_app.py
```
