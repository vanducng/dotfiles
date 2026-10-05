"""Render the CLI Proxy status page. The page is the only model inventory."""

from pathlib import Path

REPO = Path(__file__).resolve().parents[4]
DOC = REPO / "docs/content/ai/cli-proxy-models.md"


def family(model):
    if model.startswith(("gpt-image", "grok-imagine-image")):
        return "Image"
    if model.startswith("grok-imagine-video"):
        return "Video"
    for name, prefix in (
        ("Claude", "claude-"),
        ("GPT", "gpt-"),
        ("GLM", "glm-"),
        ("Grok", "grok-"),
        ("Muse", "muse-"),
    ):
        if model.startswith(prefix):
            return name
    return "Other"


def cell(text):
    return " ".join((text or "").split()).replace("|", "/")


def render(checked, rows, launches):
    chat = [row for row in rows if row["channel"] == "ccx"]
    images = [row for row in rows if row["channel"] == "image"]
    videos = [row for row in rows if row["channel"] == "video"]
    ok_chat = [row["id"] for row in chat if row["status"] == "ok"]
    lines = [
        "---",
        'title: "CLI Proxy model status"',
        "---",
        "",
        f"Last checked: {checked}. Refresh this page by invoking `/cli-proxy-models` from the dotfiles repo.",
        "",
        "Chat ids are probed with `ccx <id> -p` and tools turned off. "
        "Image ids use `POST /v1/images/generations`. "
        "Video ids use `POST /v1/videos/generations`. A returned request id counts as accepted, and the file is not downloaded. "
        "The API key stays in the environment.",
        "",
        f"{len(ok_chat)} chat models returned text through `ccx`. "
        f"{sum(row['status'] == 'missing' for row in chat)} are still listed and fail upstream. "
        f"{sum(row['status'] == 'blank' for row in chat)} returned text from the gateway and printed blank in `ccx`. "
        f"{sum(row['status'] == 'ok' for row in images)} image models returned an image. "
        f"{sum(row['status'] == 'accepted' for row in videos)} video models accepted a job.",
        "",
        "## Chat",
        "",
    ]
    for name in ("Claude", "GPT", "GLM", "Grok", "Muse", "Other"):
        ids = [row["id"] for row in chat if row["status"] == "ok" and family(row["id"]) == name]
        if ids:
            lines.extend([f"### {name}", "", ", ".join(f"`{item}`" for item in ids), ""])
    gaps = [row for row in chat if row["status"] != "ok"]
    if gaps:
        lines.extend(["### Gaps", "", "| ID | Status | Detail |", "| --- | --- | --- |"])
        for row in gaps:
            lines.append(f"| `{row['id']}` | {row['status']} | {cell(row.get('detail'))} |")
        lines.append("")
    lines.extend(["## Images", ""])
    image_ok = [row["id"] for row in images if row["status"] == "ok"]
    if image_ok:
        lines.extend([", ".join(f"`{item}`" for item in image_ok), ""])
    image_bad = [row for row in images if row["status"] != "ok"]
    if image_bad:
        lines.extend(["| ID | Status | Detail |", "| --- | --- | --- |"])
        for row in image_bad:
            lines.append(f"| `{row['id']}` | {row['status']} | {cell(row.get('detail'))} |")
        lines.append("")
    if videos:
        lines.extend(["## Videos", "", "| ID | Status | Detail |", "| --- | --- | --- |"])
        for row in videos:
            lines.append(f"| `{row['id']}` | {row['status']} | {cell(row.get('detail'))} |")
    lines.extend(["", "## Documented launches", "", "| Command | Status | Reply |", "| --- | --- | --- |"])
    for row in launches:
        lines.append(f"| `{row['command']}` | {row['status']} | {cell(row.get('detail'))} |")
    lines.append("")
    return "\n".join(lines)


def write_doc(text):
    DOC.parent.mkdir(parents=True, exist_ok=True)
    tmp = DOC.with_suffix(".md.tmp")
    try:
        tmp.write_text(text)
        tmp.replace(DOC)
    finally:
        if tmp.exists():
            tmp.unlink()
