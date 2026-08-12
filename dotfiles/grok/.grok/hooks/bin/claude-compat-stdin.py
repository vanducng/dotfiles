#!/usr/bin/env python3
"""Normalize Grok hook stdin to Claude Code shape, then exec the real hook.

Grok emits camelCase tool envelopes (toolName/toolInput) and native tool names
(run_terminal_command, read_file, …). Shared Claude hooks still expect
tool_name/tool_input and Bash/Read/Edit/…. This adapter bridges both so one
script set works for Claude Code and Grok.

Usage:
  claude-compat-stdin.py <command> [args...]
"""
from __future__ import annotations

import json
import os
import subprocess
import sys

TOOL_ALIASES = {
    "run_terminal_command": "Bash",
    "bash": "Bash",
    "read_file": "Read",
    "read": "Read",
    "search_replace": "Edit",
    "write": "Write",
    "edit": "Edit",
    "multiedit": "Edit",
    "grep": "Grep",
    "list_dir": "Glob",
    "listdir": "Glob",
    "glob": "Glob",
    "web_search": "WebSearch",
    "web_fetch": "WebFetch",
    "spawn_subagent": "Task",
    "ask_user_question": "AskUserQuestion",
}

SNAKE_PROMOTIONS = (
    ("toolName", "tool_name"),
    ("toolInput", "tool_input"),
    ("toolResult", "tool_response"),
    ("hookEventName", "hook_event_name"),
    ("sessionId", "session_id"),
    ("workspaceRoot", "workspace_root"),
    ("permissionMode", "permission_mode"),
    ("stopHookActive", "stop_hook_active"),
    ("lastAssistantMessage", "last_assistant_message"),
    ("toolUseId", "tool_use_id"),
)


def normalize(data: dict) -> dict:
    out = dict(data)
    for camel, snake in SNAKE_PROMOTIONS:
        if camel in out and snake not in out:
            out[snake] = out[camel]

    name = out.get("tool_name") or out.get("toolName") or ""
    if isinstance(name, str) and name:
        mapped = TOOL_ALIASES.get(name) or TOOL_ALIASES.get(name.lower()) or name
        out["tool_name"] = mapped
        out.setdefault("toolName", name)

    if "tool_input" not in out and isinstance(out.get("toolInput"), dict):
        out["tool_input"] = out["toolInput"]
    if not isinstance(out.get("tool_input"), dict):
        out["tool_input"] = {}

    return out


def main() -> int:
    if len(sys.argv) < 2:
        sys.stderr.write("usage: claude-compat-stdin.py <command> [args...]\n")
        # Fail-open: Grok PreToolUse only blocks on explicit deny / exit 2.
        return 0

    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except Exception as exc:
        sys.stderr.write(f"claude-compat-stdin: failed to parse stdin JSON: {exc}\n")
        data = {}

    if not isinstance(data, dict):
        data = {}

    payload = json.dumps(normalize(data))
    env = os.environ.copy()
    try:
        proc = subprocess.run(
            sys.argv[1:],
            input=payload,
            text=True,
            capture_output=True,
            env=env,
        )
    except FileNotFoundError as exc:
        # Fail-open with diagnostics. Non-zero still does not block Grok tools.
        sys.stderr.write(f"claude-compat-stdin: command not found: {exc}\n")
        return 0
    except Exception as exc:
        sys.stderr.write(f"claude-compat-stdin: {exc}\n")
        return 0

    if proc.stdout:
        sys.stdout.write(proc.stdout)
    if proc.stderr:
        sys.stderr.write(proc.stderr)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
