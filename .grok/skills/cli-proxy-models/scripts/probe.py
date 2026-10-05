#!/usr/bin/env python3
"""Probe the live CLI Proxy catalog and rewrite the status page.

Never prints CLI_PROXY_API_KEY. A 401 aborts before the page is replaced.
"""

import os
import re
import shlex
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

from client import catalog, probe_model, redact, run_ccx
from render import DOC, render, write_doc

EXAMPLES = Path(__file__).resolve().parents[4] / "docs/content/ai/claude-code.md"
WORKERS = 4


def documented():
    if not EXAMPLES.is_file():
        return []
    launch = re.compile(r"^ccx [A-Za-z0-9][A-Za-z0-9._-]*(?: |$)")
    return [line.strip() for line in EXAMPLES.read_text().splitlines() if launch.match(line.strip())]


def probe_launch(command):
    argv = shlex.split(command)
    args = argv[1:] if argv and argv[0] == "ccx" else argv
    code, out, err, timed_out = run_ccx(args)
    blob = out + "\n" + err
    reply = " ".join(out.split())[:80]
    if "401" in blob or "Invalid bearer" in blob:
        status = "auth"
    elif timed_out or code != 0 or not reply:
        status = "error"
        reply = redact(out or err)[:160] or "no reply"
    else:
        status = "ok"
    return {"command": command, "status": status, "detail": reply}


def self_test():
    rows = [
        {"id": "gpt-6.1-sol", "channel": "ccx", "status": "ok", "detail": "hi"},
        {"id": "claude-3-5-haiku-20241022", "channel": "ccx", "status": "missing", "detail": "not_found"},
        {"id": "grok-4.20-multi-agent-0309", "channel": "ccx", "status": "blank", "detail": "blank"},
        {"id": "gpt-image-1.5", "channel": "image", "status": "ok", "detail": ""},
        {"id": "grok-imagine-video", "channel": "video", "status": "accepted", "detail": "request id"},
    ]
    launches = [{"command": "ccx gpt-6.1-sol --effort high", "status": "ok", "detail": "hi"}]
    page = render("2026-10-05", rows, launches)
    assert "super-secret-token" not in page
    assert 'title: "CLI Proxy model status"' in page
    for row in rows:
        assert f"`{row['id']}`" in page
    commands = documented()
    assert "ccx <model-id> [claude args...]" not in commands
    assert any(command.startswith("ccx gpt-6.1-sol ") for command in commands)
    print("self-test ok")


def main():
    if "--self-test" in sys.argv:
        self_test()
        return
    if "CLI_PROXY_API_KEY" not in os.environ:
        print("CLI_PROXY_API_KEY is not set", file=sys.stderr)
        sys.exit(1)
    models = catalog()
    rows = []
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = [pool.submit(probe_model, model) for model in models]
        for future in as_completed(futures):
            row = future.result()
            rows.append(row)
            print(f"{row['status']:9} {row['channel']:6} {row['id']}", flush=True)
    if any(row["status"] == "auth" for row in rows):
        print("Auth failed. Status page was not changed.", file=sys.stderr)
        sys.exit(2)
    launches = []
    for command in documented():
        row = probe_launch(command)
        launches.append(row)
        print(f"{row['status']:9} launch {row['command']}", flush=True)
        if row["status"] == "auth":
            print("Auth failed. Status page was not changed.", file=sys.stderr)
            sys.exit(2)
    order = {model: index for index, model in enumerate(models)}
    rows.sort(key=lambda row: order.get(row["id"], 0))
    write_doc(render(datetime.now(timezone.utc).strftime("%Y-%m-%d"), rows, launches))
    print(f"wrote {DOC}")


if __name__ == "__main__":
    main()
