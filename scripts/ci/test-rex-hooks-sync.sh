#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sync="$project_root/dotfiles/bin/.local/bin/rex-hooks-sync"
source_json="$project_root/dotfiles/claude/.claude/settings.json"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
live="$tmp/settings.json"
fail() { echo "test-rex-hooks-sync: $*" >&2; exit 1; }

# A live file with keys and hooks dotfiles does not own, rexboard's hook, and an old spinner hook.
cat > "$live" <<'JSON'
{
  "model": "some-model",
  "env": {"EXAMPLE": "1"},
  "hooks": {
    "Stop": [
      {"hooks": [{"type": "command", "command": "notify-tool stop"}]},
      {"hooks": [{"type": "command", "command": "rexboard hook claude Stop", "timeout": 5}]},
      {"hooks": [{"type": "command", "command": "/usr/bin/python3 \"$HOME/.local/bin/rex-title-spinner\"", "timeout": 5}]}
    ],
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "guard-tool"}]}],
    "CustomEvent": [{"hooks": [{"type": "command", "command": "keep-me"}]}]
  }
}
JSON
chmod 600 "$live"
cp "$live" "$tmp/before.json"

out="$("$sync" --target "$live")"
cmp -s "$live" "$tmp/before.json"
grep '^-' <<<"$out" | grep -qF '"/usr/bin/python3' || fail "the old spinner hook is not in the diff"
grep '^+' <<<"$out" | grep -qF 'REX_BLOCK' || fail "the new gate is not in the diff"
if grep -qF -e some-model -e EXAMPLE -e guard-tool -e keep-me -e notify-tool -e 'rexboard hook' <<<"$out"; then fail "the diff shows other values"; fi
[ -z "$(ls "$tmp" | grep '\.bak-' || true)" ]

"$sync" --apply --target "$live" >/dev/null
python3 - "$live" "$source_json" "$tmp/before.json" <<'PY'
import json, sys
live, source, before = (json.load(open(p)) for p in sys.argv[1:4])
rex = lambda g: any("rex-title-spinner" in h.get("command", "") for h in g["hooks"])
mine = lambda g: dict(g, hooks=[h for h in g["hooks"] if "rex-title-spinner" in h["command"]])
assert live["model"] == "some-model" and live["env"] == {"EXAMPLE": "1"}, "other keys kept"
assert live["hooks"]["CustomEvent"] == before["hooks"]["CustomEvent"], "an event dotfiles lacks is kept"
stop = live["hooks"]["Stop"]
assert stop[0]["hooks"][0]["command"] == "notify-tool stop", "a non-rex hook stays first"
assert stop[1]["hooks"] == [{"type": "command", "command": "rexboard hook claude Stop", "timeout": 5}], "rexboard's hook kept"
assert [g for g in stop if rex(g)] == [mine(g) for g in source["hooks"]["Stop"] if rex(g)], "old gate replaced"
pre = live["hooks"]["PreToolUse"]
assert pre[0]["hooks"][0]["command"] == "guard-tool" and rex(pre[-1]), "rex added beside the guard"
for event, groups in source["hooks"].items():
    want = [mine(g) for g in groups if rex(g)]
    if want:
        assert [g for g in live["hooks"][event] if rex(g)] == want, event
PY
[ "$(python3 -c 'import os, sys; print(oct(os.stat(sys.argv[1]).st_mode & 0o777))' "$live")" = 0o600 ] || fail "mode not kept"
[ "$(ls "$tmp" | grep -c '\.bak-')" -eq 1 ] || fail "not exactly one backup"
bak="$(ls "$tmp"/settings.json.bak-*)"
cmp -s "$bak" "$tmp/before.json" || fail "the backup is not the old file"
[ "$(python3 -c 'import os, sys; print(oct(os.stat(sys.argv[1]).st_mode & 0o777))' "$bak")" = 0o600 ] || fail "the backup is wider than the file"

"$sync" --apply --target "$live" | grep -q 'up to date'
[ "$(ls "$tmp" | grep -c '\.bak-')" -eq 1 ]

# A stowed (symlinked) or missing file is left alone, and is not an error.
cp "$live" "$tmp/after.json"
ln -s "$live" "$tmp/linked.json"
"$sync" --apply --target "$tmp/linked.json" | grep -q 'symlink'
cmp -s "$live" "$tmp/after.json" || fail "a symlinked file was changed"
"$sync" --apply --target "$tmp/missing.json" | grep -q 'nothing to merge'
[ ! -e "$tmp/missing.json" ] || fail "a missing file was created"

printf '{"hooks": {"Stop": ["a string, not a group"]}}' > "$tmp/odd.json"
if "$sync" --apply --target "$tmp/odd.json" 2>"$tmp/err"; then fail "an odd hook shape was merged"; fi
grep -q 'shape' "$tmp/err"
[ -z "$(ls -a "$tmp" | grep 'rex-hooks-sync-' || true)" ] || fail "a temp file was left"

printf '{ not json' > "$tmp/bad.json"
if "$sync" --apply --target "$tmp/bad.json" 2>"$tmp/err"; then fail "invalid JSON was merged"; fi
grep -q 'not valid JSON' "$tmp/err"
[ "$(cat "$tmp/bad.json")" = '{ not json' ]
if "$sync" codex --target "$live" 2>/dev/null; then fail "codex is rexboard's now"; fi

# `rexboard hooks install` may have made a backup this same second: never write over it.
mkdir "$tmp/twice"
printf '{"hooks": {}}\n' > "$tmp/twice/settings.json"
for s in 0 1; do
  printf 'rexboard'"'"'s backup' > "$tmp/twice/settings.json.bak-$(date -u -v+${s}S +%Y%m%dT%H%M%SZ 2>/dev/null || date -u -d "+$s sec" +%Y%m%dT%H%M%SZ)"
done
"$sync" --apply --target "$tmp/twice/settings.json" >/dev/null
[ "$(ls "$tmp/twice" | grep -c '\.bak-')" -eq 3 ] || fail "a backup was written over: $(ls "$tmp/twice")"
for f in "$tmp"/twice/settings.json.bak-*; do
  case "$(cat "$f")" in "rexboard's backup"|'{"hooks": {}}') ;; *) fail "$f holds $(cat "$f")";; esac
done
echo "rex-hooks-sync: ok"
