#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
manifest="$project_root/.release-please-manifest.json"
version_file="$project_root/version.txt"
config="$project_root/release-please-config.json"

for file in "$manifest" "$version_file" "$config"; do
  if [[ ! -f "$file" ]]; then
    printf 'error: missing %s\n' "$file" >&2
    exit 1
  fi
done

python3 - "$manifest" "$version_file" "$config" <<'PY'
import json
from pathlib import Path
import sys

def parse(v: str) -> tuple[int, ...]:
    parts = v.strip().split(".")
    if not parts or any(not p.isdigit() for p in parts):
        raise SystemExit(f"invalid semver: {v!r}")
    return tuple(int(p) for p in parts)

manifest_path, version_path, config_path = (Path(p) for p in sys.argv[1:])
manifest = json.loads(manifest_path.read_text())
version = version_path.read_text().strip()
config = json.loads(config_path.read_text())
if manifest.get(".") != version:
    raise SystemExit(f"manifest {manifest.get('.')!r} != version.txt {version!r}")
if parse(version) < parse("0.16.0"):
    raise SystemExit(f"{version} is below last GitHub release 0.16.0; occupied tags will fail CI")
sha = config.get("last-release-sha", "")
if len(sha) != 40 or any(c not in "0123456789abcdef" for c in sha):
    raise SystemExit("release-please-config.json needs last-release-sha on main")
print(f"release manifest: {version} (floor 0.16.0)")
PY
