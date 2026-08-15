#!/usr/bin/env bash
# Export CLI_PROXY_API_KEY into the macOS GUI session env via launchctl setenv.
# Codex Desktop (ChatGPT.app) does not inherit shell exports; this bridges that gap
# so model_providers.cli_proxy (env_key = CLI_PROXY_API_KEY) works for Dock/Spotlight launches.
#
# Installed as LaunchAgent local.cli-proxy-gui-env (macOS only, via stow launchd).
# Override secret path with CLI_PROXY_GOPASS_PATH if needed.
#
# Usage:
#   set-cli-proxy-gui-env.sh          # set if missing
#   set-cli-proxy-gui-env.sh refresh  # re-read from gopass after key rotation
#   set-cli-proxy-gui-env.sh unset    # clear GUI session var
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
LOG="$STATE_DIR/cli-proxy-gui-env.log"
SECRET_PATH="${CLI_PROXY_GOPASS_PATH:-personal/saas/cli-proxy/code-01-api-key}"
MODE="${1:-}"

mkdir -p "$STATE_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >>"$LOG"
}

if ! command -v launchctl >/dev/null 2>&1; then
  log "error: launchctl not found"
  exit 1
fi

if [[ "$MODE" == "unset" ]]; then
  launchctl unsetenv CLI_PROXY_API_KEY || true
  log "ok: unset CLI_PROXY_API_KEY"
  exit 0
fi

if [[ "$MODE" == "refresh" ]]; then
  launchctl unsetenv CLI_PROXY_API_KEY || true
elif [[ -n "$(launchctl getenv CLI_PROXY_API_KEY 2>/dev/null || true)" ]]; then
  # Already present: skip gopass (avoids pinentry spam on StartInterval retries).
  exit 0
fi

if ! command -v gopass >/dev/null 2>&1; then
  log "error: gopass not on PATH"
  exit 1
fi

timeout_bin="$(command -v timeout || command -v gtimeout || true)"
if [[ -n "$timeout_bin" ]]; then
  key="$($timeout_bin 30 gopass show -o "$SECRET_PATH" 2>/dev/null)" || key=""
else
  key="$(gopass show -o "$SECRET_PATH" 2>/dev/null)" || key=""
fi

if [[ -z "${key:-}" ]]; then
  log "warn: failed to read $SECRET_PATH (gpg locked, missing, or timed out)"
  exit 0
fi

# Strip trailing newline if gopass includes one.
key="${key//$'\r'/}"
key="${key//$'\n'/}"

if ! launchctl setenv CLI_PROXY_API_KEY "$key"; then
  log "error: launchctl setenv failed"
  exit 1
fi

log "ok: set CLI_PROXY_API_KEY for GUI session from $SECRET_PATH"
