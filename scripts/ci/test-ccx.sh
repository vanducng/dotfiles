#!/usr/bin/env bash
# ccx points one Claude Code process at CLI Proxy and leaves plain claude alone.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$PROJECT_ROOT/dotfiles/bin/.local/bin/ccx"
HOME_PATH_RE='/Users/[a-zA-Z0-9_-]|/home/[a-zA-Z]'
ERRORS=0

pass() { echo "[OK] $1"; }
fail() { echo "[FAIL] $1" >&2; ERRORS=$((ERRORS + 1)); }

if [[ ! -x "$SCRIPT" ]]; then
  fail "missing or not executable: $SCRIPT"
else
  pass "script executable"
fi

if bash -n "$SCRIPT"; then
  pass "script bash -n"
else
  fail "script bash -n failed"
fi

if grep -Eq "$HOME_PATH_RE" "$SCRIPT"; then
  fail "script hardcodes a home path"
else
  pass "script uses portable home paths"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/claude" <<'EOF'
#!/bin/bash
printf 'BASE=%s\n' "$ANTHROPIC_BASE_URL"
printf 'TOKEN=%s\n' "$ANTHROPIC_AUTH_TOKEN"
printf 'OPUS=%s\n' "$ANTHROPIC_DEFAULT_OPUS_MODEL"
printf 'SONNET=%s\n' "$ANTHROPIC_DEFAULT_SONNET_MODEL"
printf 'HAIKU=%s\n' "$ANTHROPIC_DEFAULT_HAIKU_MODEL"
printf 'FABLE=%s\n' "$ANTHROPIC_DEFAULT_FABLE_MODEL"
printf 'SUB=%s\n' "$CLAUDE_CODE_SUBAGENT_MODEL"
printf 'API=%s\n' "${ANTHROPIC_API_KEY-unset}"
printf 'BEDROCK=%s\n' "${CLAUDE_CODE_USE_BEDROCK-unset}"
printf 'ARGS=%s\n' "$*"
EOF
chmod +x "$tmp/claude"

if CLI_PROXY_API_KEY= PATH="$tmp:$PATH" "$SCRIPT" grok-4.7 >/dev/null 2>&1; then
  fail "ccx ran without CLI_PROXY_API_KEY"
else
  pass "ccx refuses a missing key"
fi

if PATH="$tmp:$PATH" "$SCRIPT" >/dev/null 2>&1; then
  fail "ccx ran without a model id"
else
  pass "ccx requires a model id"
fi

base_with_newline=$'https://cli-proxy.example\n'
if CLI_PROXY_API_KEY=test-key CLI_PROXY_BASE_URL="$base_with_newline" PATH="$tmp:$PATH" "$SCRIPT" grok-4.7 >/dev/null 2>&1; then
  fail "ccx accepted a base URL with a newline"
else
  pass "ccx rejects a base URL with a control character"
fi

out="$(
  CLI_PROXY_API_KEY=test-key \
  CLI_PROXY_BASE_URL=https://cli-proxy.example/v1 \
  ANTHROPIC_API_KEY=drop-me \
  CLAUDE_CODE_USE_BEDROCK=1 \
  PATH="$tmp:$PATH" \
  "$SCRIPT" grok-4.7 --effort high --autocompact 500k
)"

expect() {
  local line="$1"
  if printf '%s\n' "$out" | grep -qx "$line"; then
    pass "$line"
  else
    fail "missing $line"
  fi
}

expect "BASE=https://cli-proxy.example"
expect "TOKEN=test-key"
expect "OPUS=grok-4.7"
expect "SONNET=grok-4.7"
expect "HAIKU=grok-4.7"
expect "FABLE=grok-4.7"
expect "SUB=grok-4.7"
expect "API=unset"
expect "BEDROCK=unset"
expect 'ARGS=--model grok-4.7 --dangerously-skip-permissions --settings {"env":{"ANTHROPIC_BASE_URL":"https://cli-proxy.example"}} --effort high --autocompact 500k'

args_line="$(printf '%s\n' "$out" | grep '^ARGS=')"
if printf '%s\n' "$args_line" | grep -q 'test-key'; then
  fail "claude args include the proxy key"
else
  pass "claude args omit the proxy key"
fi

if [[ "$ERRORS" -gt 0 ]]; then
  echo "$ERRORS check(s) failed" >&2
  exit 1
fi
echo "ccx checks passed"
