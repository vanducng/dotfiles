#!/usr/bin/env bash
# Checks the label the Pi footer shows for a model (dotfiles/pi/.pi/agent/extensions/lib/model-label.js).
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v node >/dev/null 2>&1 || { printf 'error: node is required to run the pi model label test\n' >&2; exit 1; }
node "$project_root/scripts/ci/pi-model-label.check.mjs" "$project_root/dotfiles/pi/.pi/agent/extensions/lib/model-label.js"
grep -q 'modelLabel(' "$project_root/dotfiles/pi/.pi/agent/extensions/statusline.ts" \
	|| { printf 'error: statusline.ts does not build its label with modelLabel\n' >&2; exit 1; }
