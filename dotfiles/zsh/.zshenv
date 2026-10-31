# Always sourced (including non-interactive SSH). Moshi probes
# `command -v herdr|tmux|mosh-server` with this PATH only - not .zshrc.
ulimit -n 65536 2>/dev/null || true

if [ -d /opt/homebrew/bin ]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}"
elif [ -d /usr/local/Homebrew ]; then
  PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
fi
# mise shims go ahead of Homebrew so a tool pinned by the workspace resolves to that pin. Outside a
# pinned directory a shim with no version set falls through to the next match on PATH.
[ -d "${MISE_DATA_DIR:-${HOME}/.local/share/mise}/shims" ] && PATH="${MISE_DATA_DIR:-${HOME}/.local/share/mise}/shims:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"
export PATH

[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"

# CLI Proxy key for Codex and OpenRig seats, including non-interactive SSH. The key file is mode 600.
if [ -z "${CLI_PROXY_API_KEY:-}" ] && [ -r "${HOME}/.config/cli-proxy/api-key" ]; then
  CLI_PROXY_API_KEY="$(<"${HOME}/.config/cli-proxy/api-key")"
  export CLI_PROXY_API_KEY
fi
export CLI_PROXY_BASE_URL="${CLI_PROXY_BASE_URL:-https://cli-proxy.dataplanelabs.com}"

# Machine-only settings, not in git.
[ -r "${HOME}/.zshenv.local" ] && . "${HOME}/.zshenv.local"
