#!/usr/bin/env bash
# Follow-up after linux-homelab-root.sh on Ubuntu 22.04 + Docker 29.
# Fixes invalid daemon.json tmp-dir, setcap on user OpenVPN, kernel Tailscale login hint.
# Run: sudo -E /home/ubuntu/.dotfiles/scripts/linux-homelab-root-fix.sh
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "run with sudo: sudo -E $0" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-ubuntu}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

mkdir -p /etc/docker /media/ubuntu/work/docker/{data,tmp}
cat >/etc/docker/daemon.json <<'EOF'
{
  "data-root": "/media/ubuntu/work/docker/data",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true
}
EOF
systemctl reset-failed docker.service docker.socket || true
systemctl enable --now docker.service
usermod -aG docker "$TARGET_USER"

# The 970 (/media/ubuntu/work) is nosuid — setcap there is ignored.
# Use the copy on the OS disk (see cnb-openvpn).
OVPN="${TARGET_HOME}/.local/libexec/openvpn"
[[ -x "$OVPN" ]] || OVPN="${TARGET_HOME}/.local/opt/openvpn/usr/sbin/openvpn"
if [[ -x "$OVPN" ]]; then
  real="$(readlink -f "$OVPN")"
  setcap cap_net_admin,cap_net_raw+ep "$real"
  echo "setcap CAP_NET_ADMIN on $real"
fi

echo
echo "docker=$(systemctl is-active docker) data-root=$(docker info -f '{{.DockerRootDir}}' 2>/dev/null || echo starting)"
echo "Then as ${TARGET_USER}:"
echo "  newgrp docker   # or log out/in"
echo "  cnb-openvpn start"
echo "  sudo /usr/bin/tailscale up --hostname=dpl --accept-dns=false"
echo "  (open the login URL; Moshi uses :2222 so leave Tailscale SSH off)"
