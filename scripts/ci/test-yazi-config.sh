#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cfg_home="$project_root/dotfiles/yazi/.config/yazi"
yazi_toml="$cfg_home/yazi.toml"
theme_toml="$cfg_home/theme.toml"

for file in "$yazi_toml" "$theme_toml"; do
  if [[ ! -f "$file" ]]; then
    printf 'error: missing %s\n' "$file" >&2
    exit 1
  fi
done

if ! python3 -c 'import tomllib' >/dev/null 2>&1; then
  printf 'error: python3 with tomllib (3.11+) is required\n' >&2
  exit 1
fi

python3 - "$yazi_toml" "$theme_toml" <<'PY'
from pathlib import Path
import sys
import tomllib

def check_rules(path: Path, rules, label: str) -> None:
    for i, rule in enumerate(rules):
        if "url" not in rule and "mime" not in rule:
            raise SystemExit(f"{path}: {label}[{i}] needs url or mime: {rule}")

yazi_path = Path(sys.argv[1])
theme_path = Path(sys.argv[2])
yazi = tomllib.loads(yazi_path.read_text())
theme = tomllib.loads(theme_path.read_text())
check_rules(yazi_path, yazi.get("open", {}).get("rules", []), "open.rules")
plugin = yazi.get("plugin", {})
for section in ("fetchers", "spotters", "preloaders", "previewers"):
    check_rules(yazi_path, plugin.get(section, []), f"plugin.{section}")
check_rules(theme_path, theme.get("filetype", {}).get("rules", []), "filetype.rules")
print("yazi selector rules: ok")
PY

if command -v yazi >/dev/null 2>&1; then
  output="$(YAZI_CONFIG_HOME="$cfg_home" yazi --version </dev/null 2>&1 || true)"
  if grep -q 'Failed to parse config' <<<"$output"; then
    printf 'error: yazi rejected the managed config\n%s\n' "$output" >&2
    exit 1
  fi
  printf 'yazi --version: ok\n'
fi
