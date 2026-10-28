#!/usr/bin/env bash
# Rex on a Linux box: a personal server as the login user, in the rex stow
# package, enabled as a systemd user service so it returns at boot and after
# a crash. Re-runnable. The Mac equivalent is rex-setup.sh (app settings);
# this one is only the server: keybindings and hosts come from stowing rex.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v rex >/dev/null || { echo "rex is not installed; see https://www.superlogical.com/rex/docs/linux/installation"; exit 1; }
command -v tailscale >/dev/null || { echo "tailscale is not installed; the tailnet listener needs the host node"; exit 1; }
tailscale status >/dev/null 2>&1 || { echo "Tailscale is not connected; sign in, then rerun"; exit 1; }

# Keybindings (init.lua, hosts.lua, hosts.json) on this box. Plain stow, not
# make stow-rex: its rexboard hooks step belongs to the Mac agent setup.
(cd "$DOTFILES/dotfiles" && stow --no-folding -D -t "$HOME" rex 2>/dev/null || true)
(cd "$DOTFILES/dotfiles" && stow --no-folding -t "$HOME" rex)

# The user manager must start at boot, not at first login, or the server
# only comes back when someone logs in.
if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != "yes" ]; then
  loginctl enable-linger "$USER" 2>/dev/null \
    || { echo "Run: sudo loginctl enable-linger $USER, then rerun this script"; exit 1; }
fi

# A shared rex.service from the package install runs as the rex account and
# would only confuse things beside the personal server; it needs sudo, so it
# is left to the operator.
if systemctl is-active --quiet rex.service 2>/dev/null; then
  echo "Note: the system rex.service (shared server) is running. Personal mode does not need it:"
  echo "  sudo systemctl disable --now rex.service"
fi

systemctl --user daemon-reload
systemctl --user enable --now rex-personal.service

rex config check >/dev/null || { echo "Rex config has problems; run: rex config check"; exit 1; }
rex config reload >/dev/null || true

self_dns="$(tailscale status --json | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))')"
suffix="${self_dns#*.}"
echo "Rex personal server: systemd user unit rex-personal.service (boot + crash restart)"
rex server status | head -15
rex server status 2>/dev/null | grep -q "needs login" \
  && echo "First run only: open the authenticate link above and sign the rex-linux-01 node in." \
  || true
echo "From a Mac: rex hosts add linux-01 http://$self_dns:7297, or Add Remote Host https://rex-linux-01.$suffix in the app."
