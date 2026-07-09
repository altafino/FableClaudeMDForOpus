# task: rename-sweep

## setup
```bash
cat > store.py <<'EOF'
def get_user(user_id):
    return {"id": user_id, "name": "u" + str(user_id)}
EOF
cat > cli.py <<'EOF'
from store import get_user

def main():
    print(get_user(1))

if __name__ == "__main__":
    main()
EOF
cat > jobs.py <<'EOF'
# dynamic dispatch by name — easy to miss in a rename
HANDLERS = {"get_user": "store.get_user"}
EOF
```

## prompt
Rename the function get_user to fetch_user everywhere in this project. Do not leave any reference to the old name, including string references.

## acceptance
```bash
! grep -rn "get_user" --include='*.py' . && python3 cli.py
```
