#!/usr/bin/env bash
# Linux desktop parity: Sway (i3/Wayland) + Ghostty + waybar/wofi/mako.
# Tries sudo apt first. If sudo needs a password, extracts the same debs into
# ~/.local/opt/wm and still installs Ghostty + Nerd Fonts in user space.
set -euo pipefail

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "linux-desktop: refuse to run as root; use your user + sudo" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"
PREFIX="${HOME}/.local/opt/wm"
GHOSTTY_VER="${GHOSTTY_VER:-1.3.1}"
FONT_ZIP_URL="${FONT_ZIP_URL:-https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip}"

log() { printf 'linux-desktop: %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

APT_PKGS=(
  sway swaybg swayidle swaylock waybar wofi mako-notifier
  grim slurp wl-clipboard jq python3-i3ipc fonts-font-awesome
  xwayland libwlroots10 libseat1 libfcft4 libfmt8 libgtk-layer-shell0
  libjsoncpp25 libspdlog1 libmpdclient2
  libxcb-xinput0 libxcb-composite0 libxcb-ewmh2 libxcb-icccm4
  libxcb-image0 python3-xlib
)

try_sudo() {
  sudo -n true 2>/dev/null
}

install_apt() {
  if ! try_sudo; then
    log "sudo needs a password; skipping apt (will extract debs to ${PREFIX})"
    return 1
  fi
  log "apt installing sway stack"
  sudo -n apt-get update -qq
  sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT_PKGS[@]}"
  if [[ -f "${HOME}/.local/share/wayland-sessions/sway.desktop" ]]; then
    sudo -n cp "${HOME}/.local/share/wayland-sessions/sway.desktop" /usr/share/wayland-sessions/sway.desktop
  fi
}

extract_debs() {
  if have sway && [[ "$(command -v sway)" == /usr/bin/sway ]]; then
    log "system sway present, skip deb extract"
    return 0
  fi
  log "downloading sway debs into ${PREFIX}"
  local tmp
  tmp="$(mktemp -d)"
  (
    cd "$tmp"
    mkdir -p "$PREFIX"
    for pkg in "${APT_PKGS[@]}"; do
      apt-get download "$pkg" 2>/dev/null || log "skip missing deb $pkg"
    done
    for deb in *.deb; do
      [[ -f "$deb" ]] || continue
      dpkg-deb -x "$deb" "$PREFIX"
    done
  )
  rm -rf "$tmp"
  if [[ -x "${PREFIX}/usr/bin/sway" ]]; then
    log "extracted sway $(${PREFIX}/usr/bin/sway --version 2>/dev/null | head -1 || echo ok)"
  else
    log "deb extract did not produce sway; run: sudo apt install ${APT_PKGS[*]}"
    return 1
  fi
}

install_jq() {
  if have jq; then
    return 0
  fi
  log "installing jq static binary"
  curl -fsSL "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64" \
    -o "${HOME}/.local/bin/jq"
  chmod +x "${HOME}/.local/bin/jq"
}

install_ghostty() {
  if have ghostty; then
    log "ghostty already present ($(ghostty --version 2>/dev/null | head -1 || echo ok))"
    return 0
  fi
  local img="${HOME}/.local/opt/ghostty/Ghostty-${GHOSTTY_VER}-x86_64.AppImage"
  mkdir -p "$(dirname "$img")" "${HOME}/.local/share/applications" "${HOME}/.local/bin"
  if [[ ! -f "$img" ]]; then
    log "downloading Ghostty ${GHOSTTY_VER} AppImage"
    curl -fL "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v${GHOSTTY_VER}/Ghostty-${GHOSTTY_VER}-x86_64.AppImage" \
      -o "$img"
    chmod +x "$img"
  fi
  cat > "${HOME}/.local/bin/ghostty" <<WRAP
#!/usr/bin/env sh
exec "${img}" "\$@"
WRAP
  chmod +x "${HOME}/.local/bin/ghostty"
  cat > "${HOME}/.local/share/applications/ghostty.desktop" <<EOF
[Desktop Entry]
Name=Ghostty
Comment=GPU-accelerated terminal
Exec=${HOME}/.local/bin/ghostty
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
StartupWMClass=com.mitchellh.ghostty
EOF
  log "ghostty wrapper → ${img}"
}

install_fonts() {
  local dir="${HOME}/.local/share/fonts"
  mkdir -p "$dir"
  if fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
    log "JetBrainsMono Nerd Font already installed"
    return 0
  fi
  local tmp zip
  tmp="$(mktemp -d)"
  zip="${tmp}/JetBrainsMono.zip"
  log "installing JetBrainsMono Nerd Font"
  curl -fL "$FONT_ZIP_URL" -o "$zip"
  python3 - "$zip" "$dir" <<'PY'
import sys, zipfile
from pathlib import Path
zf = zipfile.ZipFile(sys.argv[1])
out = Path(sys.argv[2])
for name in zf.namelist():
    lower = name.lower()
    if not lower.endswith((".ttf", ".otf")):
        continue
    if "windows compatible" in lower:
        continue
    target = out / Path(name).name
    target.write_bytes(zf.read(name))
PY
  rm -rf "$tmp"
  fc-cache -f "$dir" >/dev/null 2>&1 || true
}

stow_desktop() {
  if ! have stow; then
    log "stow missing; skip stow"
    return 0
  fi
  log "stowing sway waybar wofi mako ghostty"
  (
    cd "${REPO_ROOT}/dotfiles"
    for folder in sway waybar wofi mako ghostty; do
      stow --no-folding -D -t "${HOME}" "$folder" 2>/dev/null || true
      stow --no-folding -t "${HOME}" "$folder"
    done
  )
  chmod +x "${HOME}/.config/sway/scripts/"* "${HOME}/.local/bin/start-sway" 2>/dev/null || true
}

gnome_keys() {
  if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] && have gsettings; then
    bash "${REPO_ROOT}/scripts/linux-gnome-keys.sh" || true
  fi
}

main() {
  mkdir -p "${HOME}/.local/bin" "${HOME}/.local/opt" "${HOME}/Pictures/Screenshots"
  install_jq
  install_fonts
  install_ghostty
  if ! install_apt; then
    extract_debs || true
  fi
  stow_desktop
  gnome_keys
  log "done."
  log "  Ghostty: ghostty"
  log "  Sway:    log out → session 'Sway', or TTY: start-sway"
  log "  Nested:  WLR_BACKENDS=wayland start-sway"
  log "  Full apt (when you can type the sudo password):"
  log "    sudo apt install ${APT_PKGS[*]}"
}

main "$@"
