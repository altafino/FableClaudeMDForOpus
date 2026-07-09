# task: hard-rename-dynamic

## setup
```bash
cat > core.py <<'EOF'
def process_order(order):
    return {"ok": True, "id": order["id"]}
EOF
cat > api.py <<'EOF'
from core import process_order

def submit(order):
    return process_order(order)
EOF
cat > plugins.py <<'EOF'
import core

def dispatch(name, order):
    fn = getattr(core, name)
    return fn(order)
EOF
cat > config.json <<'EOF'
{"order_handler": "process_order"}
EOF
cat > main.py <<'EOF'
import json
from plugins import dispatch
from api import submit

cfg = json.load(open("config.json"))
assert submit({"id": 1})["ok"]
assert dispatch(cfg["order_handler"], {"id": 2})["id"] == 2
print("OK")
EOF
```

## prompt
Rename the function process_order to handle_order everywhere in this project. No reference to the old name may remain anywhere — including string literals and configuration. Prove it by running main.py.

## acceptance
```bash
! grep -rn "process_order" --include='*.py' --include='*.json' . && python3 main.py
```
