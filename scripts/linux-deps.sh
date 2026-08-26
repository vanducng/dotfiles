#!/usr/bin/env bash
# User-space Linux bootstrap. No sudo. Idempotent.
# Learned on Ubuntu 22.04 (host dpl): apt is blocked without a password,
# aqua:tmux/tmux 404s, git-delta is not a mise tool name.
set -euo pipefail

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "linux-deps: refuse to run as root; install into \$HOME" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"
mkdir -p "${HOME}/.local/bin" "${HOME}/.npm-global" "${HOME}/src"

log() { printf 'linux-deps: %s\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

install_mise() {
  if have mise; then
    log "mise already present ($(mise --version | head -1))"
    return 0
  fi
  log "installing mise"
  curl -fsSL https://mise.run | sh
}

install_stow() {
  if have stow; then
    log "stow already present ($(stow --version | head -1))"
    return 0
  fi
  local ver=2.4.1 src="${HOME}/src/stow-${ver}"
  log "building GNU Stow ${ver} into ~/.local"
  mkdir -p "${HOME}/src"
  if [[ ! -d "$src" ]]; then
    curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-${ver}.tar.gz" -o "/tmp/stow-${ver}.tar.gz"
    tar xf "/tmp/stow-${ver}.tar.gz" -C "${HOME}/src"
  fi
  (
    cd "$src"
    ./configure --prefix="${HOME}/.local"
    make
    make install
  )
}

install_rustup() {
  if [[ -x "${HOME}/.cargo/bin/cargo" ]]; then
    log "cargo already present"
    return 0
  fi
  log "installing rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
}

install_droid() {
  if have droid; then
    log "droid already present ($(droid --version 2>/dev/null | head -1 || echo ok))"
    return 0
  fi
  log "installing Factory Droid CLI"
  curl -fsSL https://app.factory.ai/cli | sh
}

install_moshi() {
  if have moshi-hook || have moshi; then
    log "moshi already present"
    return 0
  fi
  log "installing moshi-hook"
  curl -fsSL https://getmoshi.app/install.sh | sh
}

install_vd() {
  if have vd; then
    log "vd already present ($(vd --version | head -1))"
    return 0
  fi
  local ver=v3.14.0 tmp
  tmp="$(mktemp -d)"
  log "installing vd-cli ${ver}"
  curl -fsSL "https://github.com/vanducng/vd-cli/releases/download/${ver}/vd_linux_x86_64.tar.gz" -o "${tmp}/vd.tgz"
  tar xf "${tmp}/vd.tgz" -C "$tmp"
  install -m 755 "$(find "$tmp" -type f -name vd | head -1)" "${HOME}/.local/bin/vd"
  rm -rf "$tmp"
}

install_pi() {
  if ! have npm || ! have node; then
    log "skip pi (node/npm not on PATH yet; run after mise activate)"
    return 0
  fi
  local prefix
  prefix="$(npm prefix -g 2>/dev/null || true)"
  if [[ -d "${prefix}/lib/node_modules/@earendil-works/pi-coding-agent" ]] \
    || [[ -d "${HOME}/.local/share/mise/installs/node/22/lib/node_modules/@earendil-works/pi-coding-agent" ]]; then
    log "pi already present"
    return 0
  fi
  log "installing pi-coding-agent into mise node prefix"
  local node_prefix=""
  if have mise && mise which node >/dev/null 2>&1; then
    node_prefix="$(dirname "$(dirname "$(mise which node)")")"
  fi
  if [[ -n "$node_prefix" ]]; then
    NPM_CONFIG_PREFIX="" npm install -g --prefix "$node_prefix" @earendil-works/pi-coding-agent
  else
    NPM_CONFIG_PREFIX="${HOME}/.npm-global" npm install -g @earendil-works/pi-coding-agent
  fi
}

install_kitty() {
  if have kitty; then
    log "kitty already present ($(kitty --version | head -1))"
    return 0
  fi
  log "installing kitty (user-space)"
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
  ln -sf "${HOME}/.local/kitty.app/bin/kitty" "${HOME}/.local/bin/kitty"
  ln -sf "${HOME}/.local/kitty.app/bin/kitten" "${HOME}/.local/bin/kitten"
}

stow_mise_then_install() {
  if have stow && [[ -d "${REPO_ROOT}/dotfiles/mise" ]]; then
    log "stowing mise config"
    (cd "${REPO_ROOT}/dotfiles" && stow --no-folding -D -t "${HOME}" mise 2>/dev/null || true)
    (cd "${REPO_ROOT}/dotfiles" && stow --no-folding -t "${HOME}" mise)
  fi
  if have mise; then
    log "mise install"
    mise install -y
  fi
}

main() {
  install_mise
  # Pick up ~/.local/bin/mise for the rest of this process.
  export PATH="${HOME}/.local/bin:${PATH}"
  if [[ -x "${HOME}/.local/bin/mise" ]]; then
    # shellcheck disable=SC1090
    eval "$("${HOME}/.local/bin/mise" activate bash)"
  fi
  install_stow
  stow_mise_then_install
  if have mise; then
    eval "$(mise activate bash)"
  fi
  install_rustup
  install_droid
  install_moshi
  install_vd
  install_pi
  install_kitty
  log "done. Open a new shell or: source ~/.config/shell/linux.sh"
}

main "$@"
