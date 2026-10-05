"""Image and video probes. Never prints the API key."""

import json

from client import redact, request


def probe_image(model):
    code, raw = request(
        "/v1/images/generations",
        {"model": model, "prompt": "a solid red circle", "n": 1, "size": "1024x1024"},
        90,
    )
    return _result(model, "image", "ok", code, raw, lambda payload: bool(
        (payload.get("data") or [{}])[0].get("b64_json")
        or (payload.get("data") or [{}])[0].get("url")
    ))


def probe_video(model):
    code, raw = request(
        "/v1/videos/generations",
        {"model": model, "prompt": "a red circle"},
        45,
    )
    row = _result(model, "video", "accepted", code, raw, lambda payload: bool(payload.get("request_id")))
    if row["status"] == "accepted":
        row["detail"] = "Accepted. Request id returned. The file was not downloaded."
    return row


def _result(model, channel, ok_status, code, raw, accept):
    detail = ""
    status = "error"
    try:
        payload = json.loads(raw.decode(errors="replace"))
        if code == 200 and accept(payload):
            status = ok_status
        else:
            detail = redact(str(payload.get("error") or payload)[:180])
    except json.JSONDecodeError:
        detail = redact(raw.decode(errors="replace"))[:180]
    return {"id": model, "channel": channel, "status": status, "detail": detail}
