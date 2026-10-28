# Always sourced (including non-interactive SSH). Moshi probes
# `command -v herdr|tmux|mosh-server` with this PATH only - not .zshrc.
ulimit -n 65536 2>/dev/null || true

if [ -d /opt/homebrew/bin ]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}"
elif [ -d /usr/local/Homebrew ]; then
  PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
fi
PATH="${HOME}/.local/bin:${PATH}"
export PATH

[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"
