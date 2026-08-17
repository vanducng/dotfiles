#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
settings="$project_root/dotfiles/dsh/.dsh/settings.yaml"

if [[ ! -f "$settings" ]]; then
  printf 'error: missing managed dsh settings: %s\n' "$settings" >&2
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$settings" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()
required = [
    "provider: deepseek-official",
    "model: deepseek-v4-flash",
    "cliproxyapi:",
    "api: openai-responses",
    "baseURL: https://cli-proxy.dataplanelabs.com/v1",
    "apiKeyEnv: CLI_PROXY_API_KEY",
    "id: grok-4.6",
    "id: gpt-5.6-sol",
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
print("settings.yaml: ok")
PY
else
  printf 'error: python3 is required to run the dsh config test\n' >&2
  exit 1
fi

printf 'dsh config test: ok\n'
