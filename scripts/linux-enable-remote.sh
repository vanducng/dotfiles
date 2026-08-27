#!/usr/bin/env bash
# Enable inbound SSH/Mosh so this Linux box is a Moshi/Herdr remote-coding host.
# Requires sudo (openssh-server, mosh, ufw, linger).
# Usage: sudo -E ./scripts/linux-enable-remote.sh
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "run with sudo: sudo -E $0" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-ubuntu}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y openssh-server mosh

systemctl enable --now ssh

if command -v ufw >/dev/null 2>&1; then
  ufw allow OpenSSH
  ufw allow 60000:61000/udp comment 'mosh'
  if ufw status | grep -qi inactive; then
    echo "ufw is inactive; not enabling automatically (avoids locking the desktop)."
    echo "To enable: sudo ufw enable"
  fi
fi

loginctl enable-linger "$TARGET_USER"

# Moshi probes `ssh host 'command -v herdr'` with a default PATH that
# includes /usr/local/bin but not ~/.local/bin.
install -d /usr/local/bin
for name in herdr tmux moshi moshi-hook nvim zsh; do
  if [[ -e "$TARGET_HOME/.local/bin/$name" ]]; then
    ln -sfn "$TARGET_HOME/.local/bin/$name" "/usr/local/bin/$name"
  fi
done

install -d -m 700 -o "$TARGET_USER" -g "$TARGET_USER" "$TARGET_HOME/.ssh"
if [[ ! -f "$TARGET_HOME/.ssh/authorized_keys" ]]; then
  install -m 600 -o "$TARGET_USER" -g "$TARGET_USER" /dev/null "$TARGET_HOME/.ssh/authorized_keys"
fi

echo
echo "sshd is $(systemctl is-active ssh). linger=$(loginctl show-user "$TARGET_USER" -p Linger --value)"
echo "LAN: ssh ${TARGET_USER}@$(hostname -I | awk '{print $1}')"
echo "Then as ${TARGET_USER}: moshi-hook host setup --name dpl --host $(hostname -I | awk '{print $1}')"
echo "Pair Moshi: scan the QR, then moshi-hook pair --token <token> && moshi-hook install"
