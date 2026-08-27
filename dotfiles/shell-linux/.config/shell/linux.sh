# shellcheck shell=sh
# Portable Linux shell env. Sourced from bashrc/zshrc. No Homebrew, no Darwin home paths.
# Stow package: shell-linux → ~/.config/shell/linux.sh

export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/.npm-global/bin:${PATH}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null || true)}"
export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-$HOME/.npm-global}"
# Bulky stores live on the 970 (`~/work` → /media/ubuntu/work).
export TMPDIR="${TMPDIR:-$HOME/work/tmp}"
export GOPATH="${GOPATH:-$HOME/go}"
export GOMODCACHE="${GOMODCACHE:-$HOME/go/pkg/mod}"
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$HOME/.npm}"
export MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/starship.toml}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ -n "${ZSH_VERSION:-}" ]; then
  _vd_shell=zsh
else
  _vd_shell=bash
fi

if [ -x "${HOME}/.local/bin/mise" ]; then
  eval "$("${HOME}/.local/bin/mise" activate "${_vd_shell}")"
elif command -v mise >/dev/null 2>&1; then
  eval "$(mise activate "${_vd_shell}")"
fi
unset _vd_shell

# Keep ~/.local/bin ahead of mise shims so the stowed `pi` wrapper (and
# herdr/tmux) win over npm bins that mise node prepends.
export PATH="${HOME}/.local/bin:${PATH}"

export PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/work/git/personal/pass}"
export CLI_PROXY_BASE_URL="${CLI_PROXY_BASE_URL:-https://cli-proxy.dataplanelabs.com}"

# vd:browser-profile on Linux (extracted Chrome, profiles on the 970).
if [ -x "${HOME}/.local/opt/google-chrome/google-chrome" ]; then
  export BROWSER_PROFILE_CHROME="${BROWSER_PROFILE_CHROME:-$HOME/.local/opt/google-chrome/google-chrome}"
fi
export BROWSER_PROFILE_ROOT="${BROWSER_PROFILE_ROOT:-$HOME/work/store/chrome-profiles}"
# API key: export CLI_PROXY_API_KEY, or `gopass show -o personal/saas/cli-proxy/code-01-api-key`

# rustup writes this file; it is a no-op until cargo exists.
# shellcheck disable=SC1091
[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"

if [ -n "${ZSH_VERSION:-}" ]; then
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
  command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
else
  command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
  command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
fi
