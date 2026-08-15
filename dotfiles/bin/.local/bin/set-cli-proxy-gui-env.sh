#!/usr/bin/env bash
# Export CLI_PROXY_API_KEY into the macOS GUI session env via launchctl setenv.
# Codex Desktop (ChatGPT.app) does not inherit shell exports; this bridges that gap
# so model_providers.cli_proxy (env_key = CLI_PROXY_API_KEY) works for Dock/Spotlight launches.
#
# Installed as LaunchAgent local.cli-proxy-gui-env (macOS only, via stow launchd).
# Override secret path with CLI_PROXY_GOPASS_PATH if needed.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
LOG="$STATE_DIR/cli-proxy-gui-env.log"
SECRET_PATH="${CLI_PROXY_GOPASS_PATH:-personal/saas/cli-proxy/code-01-api-key}"

mkdir -p "$STATE_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >>"$LOG"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

if ! command -v launchctl >/dev/null 2>&1; then
  log "error: launchctl not found"
  exit 1
fi

# Already present: skip gopass (avoids pinentry spam on StartInterval retries).
if [[ -n "$(launchctl getenv CLI_PROXY_API_KEY 2>/dev/null || true)" ]]; then
  exit 0
fi

if ! command -v gopass >/dev/null 2>&1; then
  log "error: gopass not on PATH"
  exit 1
fi

if ! key="$(gopass show -o "$SECRET_PATH" 2>/dev/null)"; then
  log "warn: failed to read $SECRET_PATH (gpg locked or missing)"
  exit 0
fi

if [[ -z "$key" ]]; then
  log "warn: empty secret at $SECRET_PATH"
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
