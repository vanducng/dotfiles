#!/usr/bin/env python3
# Reports cursor-agent's state to Rex via the Program Status Protocol (OSC 7501).
import base64
import json
import os
import re
import subprocess
import sys

APP = "cursor-agent"
MSG_MAX = 120


# Hooks run without the agent's terminal on stdio, so write to the nearest ancestor's tty.
def ancestor_tty():
    pid = os.getppid()
    for _ in range(8):
        out = subprocess.run(
            ["/bin/ps", "-o", "ppid=,tty=", "-p", str(pid)],
            capture_output=True, text=True, timeout=1,
        ).stdout.split()
        if len(out) != 2:
            return None
        ppid, tty = out
        if tty not in ("??", "?", "-"):
            return tty if tty.startswith("/dev/") else "/dev/" + tty
        pid = int(ppid)
        if pid <= 1:
            return None
    return None


def b64(text):
    text = re.sub(r"[\x00-\x1f\x7f-\x9f]+", " ", text).strip()
    if len(text) > MSG_MAX:
        text = text[: MSG_MAX - 1] + "…"
    return base64.b64encode(text.encode()).decode()


def status_for(event, payload):
    if event == "sessionStart":
        return "idle", None
    if event == "beforeSubmitPrompt":
        return "working", payload.get("prompt") or None
    if event == "beforeShellExecution":
        return "working", "Running " + (payload.get("command") or "a command")
    if event == "beforeMCPExecution":
        return "working", "Calling " + (payload.get("tool_name") or "an MCP tool")
    if event == "afterFileEdit":
        return "working", "Edited " + (os.path.basename(payload.get("file_path") or "") or "a file")
    if event == "stop":
        status = payload.get("status")
        if status == "aborted":
            return "idle", None
        if status == "error":
            return "error", "Turn failed"
        return "done", "Turn complete"
    if event == "sessionEnd":
        return "clear", None
    return None, None


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    if not os.environ.get("REX_BLOCK") or os.environ.get("TMUX"):
        return
    event = payload.get("hook_event_name") or (sys.argv[1] if len(sys.argv) > 1 else "")
    state, msg = status_for(event, payload)
    if not state:
        return
    pairs = ["state=" + state]
    if state != "clear":
        pairs.append("app=" + APP)
    if msg:
        pairs.append("msg=" + b64(msg))
    tty = ancestor_tty()
    if not tty:
        return
    with open(tty, "w") as f:
        f.write("\x1b]7501;" + ":".join(pairs) + "\x1b\\")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
