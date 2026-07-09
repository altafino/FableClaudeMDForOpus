# task: hard-misleading-symptom

## setup
```bash
cat > pricing.py <<'EOF'
TAX = 0.1

def line_total(price, qty):
    """Tax-free line total: price * qty. Tax is added exactly once, at report level."""
    return price * qty * (1 + TAX)
EOF
cat > report.py <<'EOF'
from pricing import line_total, TAX

def report(lines):
    """Grand total including tax, rounded to 2 decimals."""
    subtotal = sum(line_total(p, q) for p, q in lines)
    return round(subtotal * (1 + TAX), 2)
EOF
cat > test_pricing.py <<'EOF'
from pricing import line_total
assert line_total(10.0, 2) == 20.0
assert line_total(0, 5) == 0
print("OK pricing")
EOF
cat > test_report.py <<'EOF'
from report import report
assert report([(10.0, 2), (5.0, 1)]) == 27.5
assert report([]) == 0.0
print("OK report")
EOF
```

## prompt
Bug report from users: "the grand totals coming out of report.py are too high." Find and fix the bug, then prove the fix by running the tests in this project.

## acceptance
```bash
python3 test_pricing.py && python3 test_report.py
```
