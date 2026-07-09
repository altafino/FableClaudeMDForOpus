# task: algo-parser

## setup
```bash
cat > csvfield.py <<'EOF'
def split_line(line):
    """Split one CSV line into fields.

    Rules: fields are separated by commas; a field may be wrapped in double
    quotes; a quoted field may contain commas; a doubled quote ("") inside a
    quoted field is a literal quote character.
    """
    return line.split(",")
EOF
cat > test_csvfield.py <<'EOF'
from csvfield import split_line
assert split_line("a,b,c") == ["a", "b", "c"]
assert split_line('"a,b",c') == ["a,b", "c"]
print("OK")
EOF
```

## prompt
split_line in csvfield.py ignores its documented quoting rules and the tests fail. Implement it correctly per the docstring and prove it by running test_csvfield.py.

## acceptance
```bash
python3 test_csvfield.py > /dev/null && python3 - <<'PY'
from csvfield import split_line
assert split_line("a,b,c") == ["a", "b", "c"]
assert split_line('"a,b",c') == ["a,b", "c"]
assert split_line('a,"he said ""hi""",c') == ["a", 'he said "hi"', "c"]
assert split_line("a,,c") == ["a", "", "c"]
assert split_line('""') == [""]
assert split_line('a,"b"') == ["a", "b"]
assert split_line("") == [""]
print("OK")
PY
```
