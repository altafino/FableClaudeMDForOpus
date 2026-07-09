# task: algo-window

## setup
```bash
cat > windows.py <<'EOF'
def chunk_overlap(seq, size, overlap):
    """Windows seq[start:start+size] for start = 0, size-overlap, 2*(size-overlap), ...
    generated while start < len(seq). Trailing windows may be shorter than size but
    are never empty. overlap >= size raises ValueError.
    """
    return [seq[i:i + size] for i in range(0, len(seq), size)]
EOF
cat > test_windows.py <<'EOF'
from windows import chunk_overlap
assert chunk_overlap([1, 2, 3, 4, 5, 6, 7], 3, 1) == [[1, 2, 3], [3, 4, 5], [5, 6, 7], [7]]
assert chunk_overlap([1, 2, 3, 4], 2, 0) == [[1, 2], [3, 4]]
print("OK")
EOF
```

## prompt
chunk_overlap in windows.py ignores its documented overlap behavior and the tests fail. Implement it correctly per the docstring and prove it by running test_windows.py.

## acceptance
```bash
python3 test_windows.py > /dev/null && python3 - <<'PY'
from windows import chunk_overlap
assert chunk_overlap([1, 2, 3, 4, 5, 6, 7], 3, 1) == [[1, 2, 3], [3, 4, 5], [5, 6, 7], [7]]
assert chunk_overlap([1, 2, 3, 4], 2, 0) == [[1, 2], [3, 4]]
assert chunk_overlap([1, 2, 3], 5, 0) == [[1, 2, 3]]
assert chunk_overlap([], 3, 1) == []
assert chunk_overlap([1, 2, 3, 4, 5], 2, 1) == [[1, 2], [2, 3], [3, 4], [4, 5], [5]]
try:
    chunk_overlap([1], 2, 2)
    raise AssertionError("expected ValueError")
except ValueError:
    pass
print("OK")
PY
```
