#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/rex-agent-status"

python3 - "$script" <<'PY'
import base64, os, sys
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

assert (r.glyph("working", 0), r.glyph("working", 1.0)) == ("◐ ", "◑ ")
assert (r.glyph("blocked", 0), r.glyph("done", 0), r.glyph("", 0)) == ("◉ ", "", "")
assert r.titled("Fix login", "◐ ") == "◐ Fix login"
assert r.titled("◑ Fix login", "◉ ") == "◉ Fix login"
assert r.titled("◉ Fix login", "") == "Fix login"
assert r.titled("✳ Fix login", "") == "✳ Fix login"

for name in ("TMUX", "TMUX_PANE", "REX_BLOCK"):
    os.environ.pop(name, None)
os.environ.update(TMUX="/tmp/tmux-1/default,1,0", TMUX_PANE="%3", TERM="tmux-256color")
assert r.seat_pane() == "%3"
del os.environ["TMUX"], os.environ["TMUX_PANE"]
r.agent_tty = lambda: (100, "/dev/ttys045")
panes = "/dev/ttys044 %1\n/dev/ttys0450 %5\n/dev/ttys045 %9"
r.tmux = lambda *args: panes if args[:2] == ("list-panes", "-a") else None
assert r.seat_pane() == "%9", "found by the agent's tty"
panes = "/dev/ttys044 %1"
assert r.seat_pane() is None, "no pane on that tty"
panes = "/dev/ttys045 %9\n/dev/ttys045 %10"
assert r.seat_pane() is None, "two panes on one tty: neither"
os.environ["TERM"] = "xterm-256color"
def no_lookup(*args):
    raise AssertionError("no lookup outside a tmux TERM")
r.tmux = no_lookup
assert not r.seat_pane()
PY

# Outside tmux and Rex, and with bad input, it writes nothing and never fails the hook.
printf '{"hook_event_name":"Stop"}' | env -u TMUX -u TMUX_PANE -u REX_BLOCK TERM=xterm-256color "$script" claude-code
printf 'not json' | TMUX=x TMUX_PANE=%0 "$script" claude-code

# A seat whose launcher dropped TMUX and TMUX_PANE: the settings.json hook, run as Claude runs it,
# finds the pane from the agent's tty. Fake ps and tmux come first on PATH; a file stands in for the tty.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/.local/bin"
ln -s "$script" "$tmp/home/.local/bin/rex-agent-status"
printf '#!/bin/sh\necho "1 ttys045"\n' > "$tmp/bin/ps"
cat > "$tmp/bin/tmux" <<SH
#!/bin/sh
echo "\$*" >> "$tmp/tmux.log"
case "\$1" in
  list-panes) echo "/dev/ttys045 %9" ;;
  display-message) echo "$tmp/tty" ;;
esac
SH
chmod +x "$tmp/bin/ps" "$tmp/bin/tmux"
: > "$tmp/tty"
hook="$(python3 -c 'import json, sys; print(next(h["command"] for e in json.load(open(sys.argv[1]))["hooks"]["Stop"] for h in e["hooks"] if "rex-agent-status" in h["command"]))' "$project_root/dotfiles/claude/.claude/settings.json")"
seat() { env -u TMUX -u TMUX_PANE -u REX_BLOCK HOME="$tmp/home" PATH="$tmp/bin:$PATH" "$@" sh -c "$hook"; }

printf '{"hook_event_name":"Stop"}' | seat TERM=tmux-256color
grep -qF "$(printf '\033Ptmux;\033\033]7501;app=claude-code:state=done:msg=RG9uZQ==\007\033\\')" "$tmp/tty"
grep -qx 'set-option -p -t %9 @rex_status app=claude-code:state=done:msg=RG9uZQ==' "$tmp/tmux.log"
[ ! -e "$tmp/log" ] || { echo "debug log written while off" >&2; exit 1; }

printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"description":"private words"}}' |
  seat TERM=tmux-256color REX_AGENT_STATUS_LOG="$tmp/log"
grep -q ' PreToolUse env=- pane=%9 wrote working$' "$tmp/log"
[ "$(wc -l < "$tmp/log")" -eq 1 ] && ! grep -q 'private' "$tmp/log"

# Outside tmux and Rex the gate exits before the script runs, so not even the log is written.
: > "$tmp/tty"
: > "$tmp/tmux.log"
printf '{"hook_event_name":"Stop"}' | seat TERM=xterm-256color REX_AGENT_STATUS_LOG="$tmp/log"
[ ! -s "$tmp/tty" ] && [ ! -s "$tmp/tmux.log" ] && [ "$(wc -l < "$tmp/log")" -eq 1 ]
echo "rex-agent-status: ok"
