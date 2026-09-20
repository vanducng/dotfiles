#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
config="$project_root/dotfiles/herdr/.config/herdr/config.toml"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/herdr-tab-renumber-test.XXXXXX")"
trap '[[ -n "${test_dir:-}" ]] && rm -r "$test_dir"' EXIT

cat >"$test_dir/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$1 $2" in
  'tab list')
    [[ "${HERDR_RENUMBER_FAIL:-0}" == 0 ]] || exit 7
    if [[ "${HERDR_RENUMBER_MALFORMED:-0}" == 1 ]]; then
      printf '%s\n' '{}'
      exit 0
    fi
    printf '%s\n' '{"result":{"tabs":[
      {"workspace_id":"wA","tab_id":"wA:t5","number":5,"label":"ws"},
      {"workspace_id":"wA","tab_id":"wA:t2","number":2,"label":"infra"},
      {"workspace_id":"wA","tab_id":"wA:t4","number":4,"label":"2-astro"},
      {"workspace_id":"wB","tab_id":"wB:t1","number":1,"label":"notes"},
      {"workspace_id":"wB","tab_id":"wB:t2","number":2,"label":"api\\worker"}
    ]}}'
    ;;
  'tab rename')
    if [[ "${HERDR_RENUMBER_RENAME_FAIL_ID:-}" == "$3" ]]; then
      exit 8
    fi
    printf '%s %s\n' "$3" "$4" >>"$HERDR_RENUMBER_CAPTURE"
    ;;
  *) exit 2 ;;
esac
EOF

chmod +x "$test_dir/herdr"
grep -Fq "command = \"/bin/bash \\\"\$HOME/.local/bin/herdr-tab-renumber\\\"\"" "$config"
capture="$test_dir/renames"
: >"$capture"

PATH="$test_dir:$PATH" \
HERDR_BIN_PATH="$test_dir/herdr" \
HERDR_RENUMBER_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-tab-renumber" >"$test_dir/out"

# Per-workspace 1-based, ordered by number; already-correct "2-astro" is skipped.
[[ "$(wc -l <"$capture")" -eq 4 ]]
grep -qx 'wA:t2 1-infra' "$capture"
grep -qx 'wA:t5 3-ws' "$capture"
grep -qx 'wB:t1 1-notes' "$capture"
grep -Fqx 'wB:t2 2-api\worker' "$capture"
if grep -q 'wA:t4' "$capture"; then
  exit 1
fi
grep -q 'renamed 4 tab(s)' "$test_dir/out"

if HERDR_RENUMBER_FAIL=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_RENUMBER_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-tab-renumber" 2>"$test_dir/list-error"; then
  exit 1
fi
grep -q 'failed to list tabs' "$test_dir/list-error"

if HERDR_RENUMBER_MALFORMED=1 \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_RENUMBER_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-tab-renumber" 2>"$test_dir/format-error"; then
  exit 1
fi
grep -q 'unexpected herdr response format' "$test_dir/format-error"

: >"$capture"
if HERDR_RENUMBER_RENAME_FAIL_ID='wA:t5' \
  PATH="$test_dir:$PATH" \
  HERDR_BIN_PATH="$test_dir/herdr" \
  HERDR_RENUMBER_CAPTURE="$capture" \
  "$project_root/dotfiles/bin/.local/bin/herdr-tab-renumber" \
  >"$test_dir/rename-fail-out" 2>"$test_dir/rename-fail-error"; then
  exit 1
fi
grep -q 'failed to rename wA:t5' "$test_dir/rename-fail-error"
grep -q 'renamed 3 tab(s)' "$test_dir/rename-fail-out"

printf 'herdr-tab-renumber test: ok\n'
