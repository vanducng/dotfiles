#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/rex-title-spinner"

python3 - "$script" "$project_root" <<'PY'
import importlib.machinery, importlib.util, io, json, os, sys, tempfile

loader = importlib.machinery.SourceFileLoader("s", sys.argv[1])
spec = importlib.util.spec_from_file_location("s", sys.argv[1], loader=loader)
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)
root = sys.argv[2]
cases = [
    ({"hook_event_name": "SessionStart"}, "idle"),
    ({"hook_event_name": "UserPromptSubmit"}, "working"),
    ({"hook_event_name": "PreToolUse", "tool_name": "Bash"}, "working"),
    ({"hook_event_name": "PreToolUse", "tool_name": "AskUserQuestion"}, "blocked"),
    ({"hook_event_name": "PostToolUse", "tool_name": "AskUserQuestion"}, "working"),
    ({"hook_event_name": "PostToolUse", "tool_name": "Bash"}, None),
    ({"hook_event_name": "PermissionRequest", "tool_name": "Bash"}, "blocked"),
    ({"hook_event_name": "Notification", "notification_type": "permission_prompt"}, "blocked"),
    ({"hook_event_name": "Notification", "notification_type": "idle_prompt"}, None),
    ({"hook_event_name": "Stop"}, "done"),
    ({"hook_event_name": "StopFailure", "error": "rate_limit"}, "error"),
    ({"hook_event_name": "SessionEnd"}, "clear"),
    ({"hook_event_name": "SubagentStart"}, None),
]
for event, want in cases:
    assert s.event_state(event) == want, (event, s.event_state(event))

assert (s.glyph("working", 0), s.glyph("working", 1.0)) == ("◐ ", "◑ ")
assert (s.glyph("blocked", 0), s.glyph("done", 0), s.glyph("", 0)) == ("◉ ", "", "")
assert s.titled("◑ Fix login", "◉ ") == "◉ Fix login"
assert s.titled("◉ Fix login", "") == "Fix login"
assert s.titled("✳ Fix login", "") == "✳ Fix login"

# A redraw survives a bad title and a closed tty, and draws only a changed title.
with tempfile.TemporaryDirectory() as tmp:
    tty = os.path.join(tmp, "tty")
    for answer in ("not json", "[]", None):
        s.run = lambda *_a, answer=answer: answer
        s.redraw(tty, "working")
        assert not os.path.exists(tty), answer
    s.run = lambda *_a: json.dumps({"title": "◑ Fix login"})
    s.redraw(os.path.join(tmp, "gone", "tty"), "working")
    open(tty, "w").close()
    s.redraw(tty, "")
    assert open(tty).read() == "\x1b]2;Fix login\x07", "the glyph comes off"

# Only straight in a Rex pane: inside tmux, rexboard hook reports and Claude keeps its own title.
rex = {"REX_BLOCK": "block:1", "TERM": "xterm-256color"}
assert s.in_rex_pane(rex)
assert not s.in_rex_pane({"TERM": "xterm-256color"})
assert not s.in_rex_pane(dict(rex, TMUX="/tmp/tmux-1/default,1,0"))
assert not s.in_rex_pane(dict(rex, TMUX_PANE="%3"))
assert not s.in_rex_pane(dict(rex, TERM="tmux-256color"))
assert not s.in_rex_pane(dict(rex, TERM="screen"))

marked = []
s.mark = marked.append
def run(env, body):
    marked.clear()
    for name in ("TMUX", "TMUX_PANE", "REX_BLOCK", "TERM"):
        os.environ.pop(name, None)
    os.environ.update(env)
    sys.argv, sys.stdin = ["rex-title-spinner"], io.StringIO(body)
    s.main()
    return list(marked)
assert run(rex, '{"hook_event_name": "Stop"}') == ["done"]
assert run(rex, '{"hook_event_name": "SubagentStart"}') == []
assert run(rex, "not json") == [] and run(rex, "[1]") == []
assert run(dict(rex, TMUX="x", TMUX_PANE="%0"), '{"hook_event_name": "Stop"}') == []
assert run({"TERM": "xterm-256color"}, '{"hook_event_name": "Stop"}') == []

# Every rex hook runs `/bin/sh -c '/opt/homebrew/bin/rexboard hook HARNESS EVENT || true'` (by full
# path and failing open, as `rexboard hooks install` writes it) for the event it sits under, and
# Claude's spinner follows it.
spinner = "/bin/sh -c '[ -n \"$REX_BLOCK\" ] || exit 0; exec /usr/bin/python3 \"$HOME/.local/bin/rex-title-spinner\"'"
for path, harness, events in (
    ("dotfiles/claude/.claude/settings.json", "claude", {"SessionStart", "UserPromptSubmit", "PreToolUse", "PostToolUse",
        "PermissionRequest", "Notification", "Stop", "StopFailure", "SessionEnd"}),
    ("dotfiles/codex/.codex/hooks.json", "codex", {"SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
        "Stop", "SessionEnd"}),
):
    seen = set()
    for event, groups in json.load(open(os.path.join(root, path)))["hooks"].items():
        for group in groups:
            hooks = [h["command"] for h in group["hooks"]]
            for i, command in enumerate(hooks):
                if "rexboard" in command:
                    want = "/bin/sh -c '/opt/homebrew/bin/rexboard hook %s %s || true'" % (harness, event)
                    assert command == want, (path, event, command)
                    seen.add(event)
                    if harness == "claude":
                        assert hooks[i + 1:i + 2] == [spinner], (path, event)
                        assert event != "PostToolUse" or group.get("matcher") == "AskUserQuestion", event
    assert seen == events, (path, events ^ seen)
PY

# Outside a Rex pane, and with bad input, it writes nothing and never fails the hook.
printf '{"hook_event_name":"Stop"}' | env -u TMUX -u TMUX_PANE -u REX_BLOCK TERM=xterm-256color "$script"
printf 'not json' | REX_BLOCK=block:1 TERM=xterm-256color "$script"

# A wrong --spin call does nothing and exits 0.
for args in "--spin" "--spin base" "--spin base notapid /dev/null" "--spin base 1 /dev/null extra"; do
  # shellcheck disable=SC2086
  timeout 5 /usr/bin/python3 "$script" $args || { echo "rex-title-spinner: $args failed" >&2; exit 1; }
done
echo "rex-title-spinner: ok"
