# task: feature-multifile

## setup
```bash
cat > calc.py <<'EOF'
def add(a, b):
    return a + b
EOF
cat > cli.py <<'EOF'
import sys
from calc import add

OPS = {"add": add}

def main(op, a, b):
    print(OPS[op](float(a), float(b)))

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
EOF
printf '%s\n' '# minicalc' 'Supported operations: add' > README.md
```

## prompt
Add a subtract operation: implement it in calc.py, wire it into cli.py's OPS the same way add is wired, and update README.md's supported-operations line. Verify by running: python3 cli.py subtract 5 2

## acceptance
```bash
[ "$(python3 cli.py subtract 5 2)" = "3.0" ] && grep -qi "subtract" README.md
```
