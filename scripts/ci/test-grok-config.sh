#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
grok_dir="$project_root/dotfiles/grok/.grok"
hooks_json="$grok_dir/hooks/lifecycle.json"
adapter="$grok_dir/hooks/bin/claude-compat-stdin.py"

for path in "$grok_dir/config.toml" "$hooks_json" "$adapter"; do
  if [[ ! -f "$path" ]]; then
    printf 'error: missing managed grok config file: %s\n' "$path" >&2
    exit 1
  fi
done

if ! command -v python3 >/dev/null 2>&1; then
  printf 'error: python3 is required to run the grok config test\n' >&2
  exit 1
fi

# TOML must include the core managed sections
python3 - <<PY
from pathlib import Path
text = Path("$grok_dir/config.toml").read_text()
required = [
    "[models]",
    "[ui]",
    "[compat.claude]",
    "[mcp_servers.miudb]",
    'permission_mode = "auto"',
    "hooks = false",
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit("missing config markers: " + ", ".join(missing))
print("config.toml: ok")
PY

# Hooks JSON is valid and covers the critical lifecycle events
HOOKS_JSON="$hooks_json" ADAPTER="$adapter" python3 - <<'PY'
import json
import os
from pathlib import Path

hooks_path = Path(os.environ["HOOKS_JSON"])
data = json.loads(hooks_path.read_text())
hooks = data.get("hooks") or {}
required_events = {
    "SessionStart",
    "UserPromptSubmit",
    "PreToolUse",
    "SubagentStart",
    "Stop",
    "SessionEnd",
    "Notification",
}
missing = sorted(required_events - set(hooks))
if missing:
    raise SystemExit(f"missing hook events: {missing}")

blob = hooks_path.read_text()
for needle in (
    "claude-compat-stdin.py",
    "pr-merge-guard.py",
    "scout-block.py",
    "agent-notify.py",
):
    if needle not in blob:
        raise SystemExit(f"hooks missing reference: {needle}")

# Sound anti-spam: no always-on Stop ding, no Notification catch-all, no double sound path
if "attention-sound.sh" in blob:
    raise SystemExit("attention-sound.sh must not be wired (double-dings with agent-notify)")
if 'matcher": "permission_prompt|idle_prompt|approval_required|.*"' in blob or "|.*" in blob and "Notification" in blob:
    # allow other events to use .*; only forbid Notification catch-all
    notif = data.get("hooks", {}).get("Notification") or []
    for block in notif:
        matcher = block.get("matcher") or ""
        if matcher.endswith("|.*") or matcher == ".*":
            raise SystemExit(f"Notification matcher too broad: {matcher!r}")
print("lifecycle.json: ok")
PY

# Adapter normalizes Grok camelCase + native tool names for Claude hooks
HOOKS_JSON="$hooks_json" ADAPTER="$adapter" python3 - <<'PY'
import json
import os
import subprocess
import tempfile
from pathlib import Path

adapter = Path(os.environ["ADAPTER"])
payload = {
    "hookEventName": "pre_tool_use",
    "toolName": "run_terminal_command",
    "toolInput": {"command": "echo hi"},
    "cwd": "/tmp",
}
script = """
import json, sys
data = json.load(sys.stdin)
assert data.get("tool_name") == "Bash", data
assert data.get("tool_input", {}).get("command") == "echo hi", data
print("normalized")
"""
with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as fh:
    fh.write(script)
    probe = fh.name
try:
    proc = subprocess.run(
        ["python3", str(adapter), "python3", probe],
        input=json.dumps(payload),
        text=True,
        capture_output=True,
        check=False,
    )
finally:
    Path(probe).unlink(missing_ok=True)

if proc.returncode != 0 or "normalized" not in proc.stdout:
    raise SystemExit(f"adapter failed: rc={proc.returncode} out={proc.stdout!r} err={proc.stderr!r}")
print("claude-compat-stdin.py: ok")
PY

printf 'grok config test: ok\n'
