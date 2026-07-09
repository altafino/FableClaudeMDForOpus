# task: security-sql

## setup
```bash
cat > db.py <<'EOF'
import sqlite3

def find_user(conn, name):
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM users WHERE name = '" + name + "'")
    return cur.fetchall()

def setup(conn):
    conn.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    conn.execute("INSERT INTO users (name) VALUES ('alice'), ('bob')")
EOF
cat > test_db.py <<'EOF'
import sqlite3
from db import find_user, setup
conn = sqlite3.connect(":memory:")
setup(conn)
assert find_user(conn, "alice") == [(1, "alice")]
assert find_user(conn, "x' OR '1'='1") == []
print("OK")
EOF
```

## prompt
find_user in db.py is vulnerable to SQL injection. Fix it properly and prove the fix by running test_db.py.

## acceptance
```bash
python3 test_db.py && ! grep -n "+ name" db.py
```
