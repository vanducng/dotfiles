#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sync="$project_root/dotfiles/bin/.local/bin/rex-hooks-sync"
source_json="$project_root/dotfiles/claude/.claude/settings.json"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
live="$tmp/settings.json"
fail() { echo "test-rex-hooks-sync: $*" >&2; exit 1; }

# A live file with keys and hooks dotfiles does not own, and an old rex hook.
cat > "$live" <<'JSON'
{
  "model": "some-model",
  "env": {"EXAMPLE": "1"},
  "hooks": {
    "Stop": [
      {"hooks": [{"type": "command", "command": "notify-tool stop"}]},
      {"hooks": [{"type": "command", "command": "/bin/sh -c '[ -n \"$TMUX$REX_BLOCK\" ] || exit 0; exec /usr/bin/python3 \"$HOME/.local/bin/rex-agent-status\" claude-code'", "timeout": 5}]}
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
grep '^-' <<<"$out" | grep -qF '|| exit 0; exec' || fail "the old gate is not in the diff"
grep '^+' <<<"$out" | grep -qF 'tmux*|screen*' || fail "the new gate is not in the diff"
if grep -qF -e some-model -e EXAMPLE -e guard-tool -e keep-me -e notify-tool <<<"$out"; then fail "the diff shows other values"; fi
[ -z "$(ls "$tmp" | grep '\.bak-' || true)" ]

"$sync" --apply --target "$live" >/dev/null
python3 - "$live" "$source_json" "$tmp/before.json" <<'PY'
import json, sys
live, source, before = (json.load(open(p)) for p in sys.argv[1:4])
rex = lambda g: any("rex-agent-status" in h.get("command", "") for h in g["hooks"])
assert live["model"] == "some-model" and live["env"] == {"EXAMPLE": "1"}, "other keys kept"
assert live["hooks"]["CustomEvent"] == before["hooks"]["CustomEvent"], "an event dotfiles lacks is kept"
stop = live["hooks"]["Stop"]
assert stop[0]["hooks"][0]["command"] == "notify-tool stop", "a non-rex hook stays first"
assert [g for g in stop if rex(g)] == [g for g in source["hooks"]["Stop"] if rex(g)], "old gate replaced"
pre = live["hooks"]["PreToolUse"]
assert pre[0]["hooks"][0]["command"] == "guard-tool" and rex(pre[-1]), "rex added beside the guard"
for event, groups in source["hooks"].items():
    want = [g for g in groups if rex(g)]
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
# Codex: the same merge from dotfiles/codex/.codex/hooks.json, and a file without a final
# newline keeps it that way, so only the rex lines change.
printf '{\n  "hooks": {\n    "Stop": [\n      {\n        "hooks": [\n          {\n            "type": "command",\n            "command": "notify-tool"\n          }\n        ]\n      }\n    ]\n  }\n}' > "$tmp/codex.json"
diff_out="$("$sync" codex --target "$tmp/codex.json")"
grep '^-' <<<"$diff_out" | grep -v '^---' | grep -q . && fail "codex: a line was removed"
grep -qF 'rex-agent-status\" codex' <<<"$diff_out" || fail "codex: no rex hook added"
"$sync" codex --apply --target "$tmp/codex.json" >/dev/null
[ "$(tail -c 1 "$tmp/codex.json")" = "}" ] || fail "codex: the file gained a final newline"
python3 - "$tmp/codex.json" <<'PY'
import json, sys
hooks = json.load(open(sys.argv[1]))["hooks"]
assert hooks["Stop"][0]["hooks"][0]["command"] == "notify-tool"
for event in ("SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest", "Stop", "SessionEnd"):
    assert any("rex-agent-status" in h["command"] for g in hooks[event] for h in g["hooks"]), event
PY
"$sync" codex --apply --target "$tmp/codex.json" | grep -q 'up to date'
echo "rex-hooks-sync: ok"
