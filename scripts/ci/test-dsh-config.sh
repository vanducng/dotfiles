#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
settings="$project_root/dotfiles/dsh/.dsh/settings.yaml"
agents="$project_root/dotfiles/dsh/.dsh/AGENTS.md"

if [[ ! -f "$settings" ]]; then
  printf 'error: missing managed dsh settings: %s\n' "$settings" >&2
  exit 1
fi

if [[ ! -L "$agents" ]]; then
  printf 'error: managed dsh AGENTS.md must be a symlink: %s\n' "$agents" >&2
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$settings" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()
required = [
    "provider: cliproxyapi",
    "model: grok-4.6",
    "cliproxyapi:",
    "api: openai-responses",
    "baseURL: https://cli-proxy.dataplanelabs.com/v1",
    "apiKeyEnv: CLI_PROXY_API_KEY",
    "id: grok-4.6",
    "id: gpt-5.6-sol",
    "id: claude-fable-5",
    "id: claude-opus-5",
    "id: gpt-5.5",
    "xhigh: xhigh",
    "max: max",
    "zai-coding-cn:",
    "apiKeyEnv: ZAI_CODING_CN_API_KEY",
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit("missing settings markers: " + ", ".join(missing))
if "sk-" in text or "apiKey:" in text:
    raise SystemExit("managed settings must not contain inline secrets")
windows = {
    "grok-4.6": ("500000", "32768"),
    "claude-fable-5": ("1000000", "65536"),
    "gpt-5.6-sol": ("272000", "65536"),
    "claude-sonnet-4-6": ("1000000", "65536"),
    "gpt-5.4-mini": ("400000", "65536"),
}
for model_id, (context, max_tokens) in windows.items():
    block = text.split(f"id: {model_id}", 1)[1].split("- id:", 1)[0]
    if f"contextWindow: {context}" not in block or f"maxTokens: {max_tokens}" not in block:
        raise SystemExit(f"unexpected window for {model_id}")
print("settings.yaml: ok")
PY

python3 - "$agents" <<'PY'
from pathlib import Path
import sys

link = Path(sys.argv[1])
target = link.readlink()
if target.as_posix() != "../../agents/AGENTS.md":
    raise SystemExit(f"unexpected AGENTS.md target: {target}")
if "/Users/" in str(target) or "/home/" in str(target):
    raise SystemExit("AGENTS.md symlink must stay relative")
text = link.read_text()
if not text.startswith("# Global Agent Instructions"):
    raise SystemExit("AGENTS.md does not resolve to the global agent instructions")
print("AGENTS.md: ok")
PY
else
  printf 'error: python3 is required to run the dsh config test\n' >&2
  exit 1
fi

printf 'dsh config test: ok\n'
