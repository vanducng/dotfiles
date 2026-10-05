"""HTTP and ccx calls for the CLI Proxy catalog probe. Never prints the API key."""
import json
import os
import signal
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[4]
PROMPT = "Reply with the single word hi and nothing else."
TIMEOUT = 90


def base_url():
    base = os.environ.get("CLI_PROXY_BASE_URL", "https://cli-proxy.dataplanelabs.com")
    base = base.rstrip("/")
    if base.endswith("/v1"):
        base = base[:-3]
    return base


def redact(text):
    key = os.environ.get("CLI_PROXY_API_KEY", "")
    if key and text:
        text = text.replace(key, "[redacted]").replace(urllib.parse.quote(key, safe=""), "[redacted]")
    lines = []
    for line in (text or "").splitlines():
        low = line.lower()
        if any(word in low for word in ("authorization:", "bearer ", "auth_token", "api_key=")):
            continue
        lines.append(line)
    return "\n".join(lines)[-400:]


def is_auth(blob):
    return "Invalid bearer" in blob or "API Error: 401" in blob


def request(path, payload, timeout):
    req = urllib.request.Request(
        base_url() + path,
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": "Bearer " + os.environ["CLI_PROXY_API_KEY"],
            "content-type": "application/json",
            "anthropic-version": "2023-06-01",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read()
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        return 0, str(exc).encode()


def catalog():
    req = urllib.request.Request(
        base_url() + "/v1/models",
        headers={"Authorization": "Bearer " + os.environ["CLI_PROXY_API_KEY"]},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as exc:
        if exc.code == 401:
            raise SystemExit("Auth failed on /v1/models. Status page was not changed.")
        raise SystemExit("Could not list /v1/models. Status page was not changed.")
    except (urllib.error.URLError, TimeoutError, OSError):
        raise SystemExit("Could not list /v1/models. Status page was not changed.")
    return sorted(item["id"] for item in data.get("data", []))


def ccx_bin():
    path = REPO / "dotfiles/bin/.local/bin/ccx"
    if os.access(path, os.X_OK):
        return str(path)
    return "ccx"


def run_ccx(args):
    proc = subprocess.Popen(
        [ccx_bin(), *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        start_new_session=True,
    )
    try:
        out, err = proc.communicate(timeout=TIMEOUT)
        return proc.returncode, out or "", err or "", False
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGTERM)
        try:
            out, err = proc.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            out, err = proc.communicate()
        return 124, out or "", (err or "") + "\nTIMEOUT", True


def message_kind(code, raw):
    text = raw.decode(errors="replace")
    try:
        payload = json.loads(text)
    except json.JSONDecodeError:
        return "error", redact(text)[:180]
    if code == 200:
        parts = [
            block.get("text", "")
            for block in payload.get("content") or []
            if block.get("type") == "text" and block.get("text")
        ]
        return "chat", " ".join(parts)[:80]
    message = str((payload.get("error") or {}).get("message", payload))
    low = message.lower()
    if code == 401 or "invalid bearer" in low:
        return "auth", redact(message)[:180]
    if "/v1/images/" in message:
        return "image", ""
    if "video model" in low or "/v1/videos/" in message:
        return "video", ""
    if "not_found" in low or code == 503:
        return "missing", redact(message)[:180]
    return "error", redact(message)[:180]


def probe_ccx(model):
    code, out, err, timed_out = run_ccx([model, "-p", PROMPT, "--tools", "", "--bare"])
    blob = out + "\n" + err
    reply = " ".join(out.split())[:120]
    if is_auth(blob):
        status = "auth"
    elif timed_out:
        status, reply = "error", "timeout"
    elif code != 0:
        status = "missing" if "not_found" in blob.lower() else "error"
        reply = redact(out or err)[:180]
    elif not reply:
        status = "blank"
    else:
        status = "ok"
    return status, redact(reply)


def probe_model(model):
    code, raw = request(
        "/v1/messages",
        {"model": model, "max_tokens": 16, "messages": [{"role": "user", "content": "hi"}]},
        45,
    )
    kind, detail = message_kind(code, raw)
    if kind == "auth":
        return {"id": model, "channel": "ccx", "status": "auth", "detail": detail}
    if kind == "image":
        from media import probe_image
        return probe_image(model)
    if kind == "video":
        from media import probe_video
        return probe_video(model)
    status, reply = probe_ccx(model)
    if status == "blank" and kind == "chat" and detail:
        reply = "Gateway returned text. ccx printed a blank line."
    elif status == "missing":
        reply = detail or reply
    return {"id": model, "channel": "ccx", "status": status, "detail": reply}


