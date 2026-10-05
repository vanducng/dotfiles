#!/usr/bin/env bash
# The CLI Proxy status skill stays invocable and does not hardcode a home path.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skill="$root/.grok/skills/cli-proxy-models"
page="$root/docs/content/ai/cli-proxy-models.md"

python3 "$skill/scripts/probe.py" --self-test

if [[ ! -f "$skill/SKILL.md" ]]; then
  echo "missing skill" >&2
  exit 1
fi
grep -q '^name: cli-proxy-models$' "$skill/SKILL.md"
grep -q 'title: "CLI Proxy model status"' "$page"
if grep -Eq '/Users/[a-zA-Z0-9_-]|/home/[a-zA-Z]' "$skill/SKILL.md" "$skill/scripts/probe.py" "$page"; then
  echo "status skill hardcodes a home path" >&2
  exit 1
fi
echo "cli-proxy-models skill checks passed"
