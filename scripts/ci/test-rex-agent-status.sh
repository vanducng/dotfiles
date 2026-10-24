#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/rex-agent-status"

python3 - "$script" <<'PY'
import base64, sys
from importlib.machinery import SourceFileLoader

r = SourceFileLoader("r", sys.argv[1]).load_module()
cases = {
    "SessionStart": ("idle", None, None),
    "UserPromptSubmit": ("working", None, "Working"),
    "Stop": ("done", None, "Done"),
    "SessionEnd": ("clear", None, None),
}
for name, want in cases.items():
    assert r.status({"hook_event_name": name}) == want, name
assert r.status({"hook_event_name": "PreToolUse", "tool_name": "Bash", "tool_input": {"description": "Run tests"}}) == ("working", None, "Run tests")
assert r.status({"hook_event_name": "PermissionRequest", "tool_name": "Bash"}) == ("blocked", "permission", "Allow Bash?")
assert r.status({"hook_event_name": "Notification", "notification_type": "idle_prompt"}) is None
assert r.status({"hook_event_name": "PostToolUse"}) is None

seq = r.sequence("claude-code", "working", None, "two\nlines")
assert seq.startswith("\x1bPtmux;\x1b\x1b]7501;") and seq.endswith("\x07\x1b\\"), repr(seq)
msg = seq.split("msg=")[1].split("\x07")[0]
assert base64.b64decode(msg).decode() == "two lines", msg
assert ":kind=permission" in r.sequence("claude-code", "blocked", "permission", None)
pairs = r.fields("claude-code", "done", None, "Done")
assert pairs == "app=claude-code:state=done:msg=RG9uZQ==", pairs
assert r.wrap(pairs) == r.sequence("claude-code", "done", None, "Done")
PY

# Outside tmux, and with bad input, it writes nothing and never fails the hook.
printf '{"hook_event_name":"Stop"}' | env -u TMUX -u TMUX_PANE "$script" claude-code
printf 'not json' | TMUX=x TMUX_PANE=%0 "$script" claude-code
echo "rex-agent-status: ok"
