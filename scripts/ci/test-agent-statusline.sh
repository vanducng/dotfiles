#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$project_root/dotfiles/bin/.local/bin/agent-statusline"
# A short path, so the folder is not shortened to …/last/two.
test_dir="$(mktemp -d /tmp/asl.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT

expect() {
  local name="$1" want="$2" payload="$3" got
  got="$(printf '%s' "$payload" | NO_COLOR=1 COLUMNS="${COLUMNS_OVERRIDE:-}" "$script")"
  if [[ "$got" != "$want" ]]; then
    printf 'error: %s\n  want: %s\n  got:  %s\n' "$name" "$want" "$got" >&2
    exit 1
  fi
}

repo="$test_dir/repo"
git init -q -b main "$repo"
git -C "$repo" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init

expect "claude payload" "Opus 5.5 xhigh  ◔ 23%  $repo  main  ↯ fast" \
  "{\"model\":{\"display_name\":\"Opus 5.5\"},\"effort\":{\"level\":\"xhigh\"},\"workspace\":{\"current_dir\":\"$repo\"},\"context_window\":{\"used_percentage\":23},\"fast_mode\":true}"

touch "$repo/f" && git -C "$repo" add f
expect "dirty tree" "Opus 5.5  $repo  main*" \
  "{\"model\":{\"display_name\":\"Opus 5.5\"},\"workspace\":{\"current_dir\":\"$repo\"},\"fast_mode\":false}"

expect "grok tokens and branch" "Grok 4.7 high  ◑ 45%  $test_dir  feat/x" \
  "{\"model\":{\"display_name\":\"Grok 4.7\"},\"effort\":{\"level\":\"high\"},\"workspace\":{\"current_dir\":\"$test_dir\",\"branch\":\"feat/x\"},\"context_window\":{\"context_tokens\":90000,\"context_window_size\":200000}}"

expect "older claude usage" "Opus 5.5  ◕ 81%  $test_dir" \
  "{\"model\":{\"display_name\":\"Opus 5.5\"},\"workspace\":{\"current_dir\":\"$test_dir\"},\"context_window\":{\"used_percentage\":null,\"context_window_size\":1000000,\"current_usage\":{\"input_tokens\":10000,\"cache_read_input_tokens\":800000}}}"

COLUMNS_OVERRIDE=20 expect "narrow row keeps the folder name" "Opus 5.5  $(basename "$test_dir")" \
  "{\"model\":{\"display_name\":\"Opus 5.5\"},\"workspace\":{\"current_dir\":\"$test_dir\"}}"

printf 'not json' | (cd "$test_dir" && NO_COLOR=1 "$script") | grep -q '^?' || { echo "error: bad input printed nothing" >&2; exit 1; }

echo "agent-statusline: ok"
