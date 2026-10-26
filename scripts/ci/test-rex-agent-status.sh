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

# The agent's own words: Stop's final message, StopFailure's error, an AskUserQuestion's options.
stop = {"hook_event_name": "Stop", "last_assistant_message": "a\n\nb\r\n  c  "}
assert r.status(stop) == ("done", None, "a ⏎ b ⏎ c"), r.status(stop)
assert r.status({"hook_event_name": "Stop", "last_assistant_message": None}) == ("done", None, "Done")
fail = {"hook_event_name": "StopFailure", "error": "rate_limit", "last_assistant_message": "API Error: rate limited"}
assert r.status(fail) == ("error", None, "API Error: rate limited"), r.status(fail)
assert r.status({"hook_event_name": "StopFailure", "error": "overloaded", "error_details": "try later"}) == ("error", None, "overloaded try later")
ask = {"hook_event_name": "PreToolUse", "tool_name": "AskUserQuestion", "tool_input": {"questions": [
    {"question": "Which test runner?", "header": "Runner", "options": [
        {"label": "vitest", "description": "fast"}, {"label": "jest", "description": "familiar"}, {"label": "both"}]},
    {"question": "Run them in CI?", "header": "CI", "options": [{"label": "yes"}, {"label": "no"}]},
]}}
assert r.status(ask) == ("blocked", "question",
    "Which test runner? ⏎ 1. vitest - fast ⏎ 2. jest - familiar ⏎ 3. both ⏎ (+1 more questions)"), r.status(ask)
assert r.status({"hook_event_name": "PostToolUse", "tool_name": "AskUserQuestion"}) == ("working", None, "Working")

# Codex: its permission request says what it wants to do; outside Claude the label stays.
codex_ask = {"hook_event_name": "PermissionRequest", "tool_name": "shell", "tool_input": {"description": "Run the test suite"}}
assert r.status(codex_ask, "codex") == ("blocked", "permission", "Run the test suite")
assert r.status(codex_ask) == ("blocked", "permission", "Allow shell?"), "Claude keeps Allow X?"
assert r.status({"hook_event_name": "PermissionRequest", "tool_name": "shell"}, "codex") == ("blocked", "permission", "Allow shell?")
assert r.status({"hook_event_name": "Stop", "last_assistant_message": "Tests pass."}, "codex") == ("done", None, "Tests pass.")

# Rex's limits: at most 2048 decoded bytes, cut at a character, and a sequence of at most 4096.
long = "語" * 5000
pairs = r.fields("claude-code", "done", None, long)
decoded = base64.b64decode(pairs.split("msg=")[1]).decode()
assert len(decoded.encode()) <= 2048 and decoded.endswith("…"), len(decoded.encode())
assert not any(ord(ch) < 32 or 0x7f <= ord(ch) <= 0x9f for ch in decoded)
assert len(r.wrap(pairs).encode()) <= 4096, len(r.wrap(pairs).encode())
assert r.fields("claude-code", "done", None, "tab\there\x1b[0m") == "app=claude-code:state=done:msg=" + base64.b64encode("tab here [0m".encode()).decode()
assert r.capped("ab語", 4) == "a…" and r.capped("ok", 4) == "ok"

seq = r.sequence("claude-code", "working", None, "two\nlines")
assert seq.startswith("\x1bPtmux;\x1b\x1b]7501;") and seq.endswith("\x07\x1b\\"), repr(seq)
msg = seq.split("msg=")[1].split("\x07")[0]
assert base64.b64decode(msg).decode() == "two ⏎ lines", msg
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

# Outside tmux, in a Rex pane: codex reports there itself, so nothing is written; pi does not,
# so its status goes straight to its tty, unwrapped. agent_tty and write are stand-ins here.
import io, json as _json
written = []
r.write = lambda tty, text: written.append((tty, text))
r.agent_tty = lambda: (100, "/dev/ttys999")
r.mark = lambda state: written.append(("mark", state))
for name in ("TMUX", "TMUX_PANE"):
    os.environ.pop(name, None)
os.environ.update(REX_BLOCK="block:1", TERM="xterm-256color")
def run(app, event):
    written.clear()
    sys.argv, sys.stdin = ["rex-agent-status", app], io.StringIO(_json.dumps(event))
    r.main()
    return list(written)
assert run("codex", {"hook_event_name": "Stop", "last_assistant_message": "done"}) == []
assert run("pi", {"hook_event_name": "Stop", "last_assistant_message": "All green"}) == [
    ("/dev/ttys999", "\x1b]7501;app=pi:state=done:msg=" + base64.b64encode(b"All green").decode() + "\x07")]
assert run("claude-code", {"hook_event_name": "Stop"}) == [
    ("mark", "done"), ("/dev/ttys999", "\x1b]7501;id=turn:app=claude-code:state=done:msg=RG9uZQ==\x07")
], "Claude keeps its spinner path and adds the turn record"
assert run("claude-code", {"hook_event_name": "PreToolUse", "tool_name": "Bash"}) == [("mark", "working")]
assert r.turn_record("claude-code", "Stop", ("done", None, "a ⏎ b")) == "id=turn:app=claude-code:state=done:msg=" + base64.b64encode("a ⏎ b".encode()).decode()
for name in ("UserPromptSubmit", "SessionEnd"):
    assert r.turn_record("claude-code", name, ("working", None, "Working")) == "id=turn:app=claude-code:state=clear", name
assert r.turn_record("claude-code", "PreToolUse", ("working", None, "x")) is None
del os.environ["REX_BLOCK"]
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
# pi's rex-status extension turns pi events into the hook JSON above, through the same script.
mkdir -p "$tmp/pihome/.local/bin"
printf 'import os, sys\nopen(os.environ["PI_LOG"], "a").write(sys.argv[1] + " " + sys.stdin.read() + "\\n")\n' > "$tmp/pihome/.local/bin/rex-agent-status"
HOME="$tmp/pihome" PI_LOG="$tmp/pi.log" TERM=tmux-256color \
  EXT="$project_root/dotfiles/pi/.pi/agent/extensions/rex-status.js" node --input-type=module <<'JS'
import { pathToFileURL } from "node:url";
const ext = await import(pathToFileURL(process.env.EXT).href);
if (ext.reporting({ TERM: "xterm-256color" }) || !ext.reporting({ REX_BLOCK: "b" }) || !ext.reporting({ TERM: "screen" })) throw new Error("gate");
const handlers = {};
ext.default({ on: (name, fn) => { handlers[name] = fn; } });
await handlers.agent_start({});
await handlers.message_end({ message: { role: "user", content: [{ type: "text", text: "ignored" }] } });
await handlers.message_end({ message: { role: "assistant", content: [{ type: "text", text: "All " }, { type: "tool_use" }, { type: "text", text: "green" }] } });
await handlers.agent_settled({});
await handlers.agent_start({});
await handlers.message_end({ message: { role: "assistant", content: [], stopReason: "error", errorMessage: "429 rate limited" } });
await handlers.agent_settled({});
await new Promise((done) => setTimeout(done, 1500));
JS
want='pi {"hook_event_name": "UserPromptSubmit"}
pi {"hook_event_name": "Stop", "last_assistant_message": "All green"}
pi {"hook_event_name": "UserPromptSubmit"}
pi {"hook_event_name": "StopFailure", "last_assistant_message": "429 rate limited"}'
got="$(python3 -c 'import json, sys
for line in open(sys.argv[1]):
    app, _, body = line.strip().partition(" ")
    print(app, json.dumps(json.loads(body)))' "$tmp/pi.log" | sort)"
[ "$got" = "$(sort <<<"$want")" ] || { printf 'pi extension sent:\n%s\n' "$got" >&2; exit 1; }
echo "rex-agent-status: ok"
