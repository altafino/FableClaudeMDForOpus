# task: delta-multipart

## setup
```bash
cat > kvparse.py <<'EOF'
def parse_kv(text):
    """Parse 'k=v' lines into a dict. Blank lines and '#' comments are ignored."""
    out = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        k, v = line.split("=")
        out[k.strip()] = v.strip()
    return out
EOF
cat > cli.py <<'EOF'
import sys
from kvparse import parse_kv

VERSION = "1.0.0"

def main(argv):
    text = open(argv[0]).read()
    data = parse_kv(text)
    for k in sorted(data):
        print(f"{k}: {data[k]}")

if __name__ == "__main__":
    main(sys.argv[1:])
EOF
echo "1.0.0" > version.txt
cat > README.md <<'EOF'
# kvcli
Usage: python3 cli.py FILE — prints "key: value" lines from a k=v file.
EOF
cat > test_kvparse.py <<'EOF'
from kvparse import parse_kv
assert parse_kv("a=1\n# c\n\nb=2") == {"a": "1", "b": "2"}
print("OK")
EOF
```

## prompt
Five changes, all required: (1) fix the bug where values containing '=' (e.g. url=http://x?a=b) crash parse_kv — split on the first '=' only; (2) add a --json flag to cli.py that prints the parsed dict as JSON instead of key: value lines (plain mode must keep working); (3) add test coverage for both the '=' fix and the --json behavior; (4) document the --json flag in README.md; (5) bump the version to 1.1.0 in BOTH cli.py and version.txt. Verify your work before finishing.

## acceptance
```bash
python3 -c "from kvparse import parse_kv; assert parse_kv('url=http://x?a=b') == {'url': 'http://x?a=b'}" \
&& printf 'a=1\nurl=http://x?a=b\n' > .in.txt \
&& python3 cli.py --json .in.txt | python3 -c "import json,sys; d=json.load(sys.stdin); assert d['url']=='http://x?a=b' and d['a']=='1'" \
&& python3 cli.py .in.txt | grep -q "a: 1" \
&& grep -qi -- "--json" README.md \
&& grep -q "1.1.0" cli.py && grep -q "1.1.0" version.txt && ! grep -q "1.0.0" cli.py \
&& grep -rqi "json" test_*.py \
&& python3 test_kvparse.py > /dev/null
```
