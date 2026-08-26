#!/usr/bin/env bash
# Privileged homelab pieces. Run once: sudo -E ./scripts/linux-homelab-root.sh
# Installs sshd :22, docker, tailscale; fstab for extra disks; masks sleep;
# copies /usr/local/bin links for moshi PATH probes.
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "run with sudo: sudo -E $0" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-ubuntu}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y \
  openssh-server mosh ufw \
  docker.io docker-compose-v2 \
  uidmap slirp4netns fuse-overlayfs dbus-user-session \
  xfsprogs

# --- never sleep (system) ---
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target || true
mkdir -p /etc/systemd/logind.conf.d
cat >/etc/systemd/logind.conf.d/homelab-nosleep.conf <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
IdleActionSec=0
HandlePowerKey=poweroff
EOF
systemctl restart systemd-logind || true

# --- ssh ---
systemctl enable --now ssh
if command -v ufw >/dev/null; then
  ufw allow OpenSSH
  ufw allow 2222/tcp comment 'user sshd fallback'
  ufw allow 60000:61000/udp comment 'mosh'
fi

# --- fstab extra disks (already formatted; do not mkfs) ---
grep -q 3aaf62c7-54e7-4e19-a588-c9f9f20deb0a /etc/fstab || cat >>/etc/fstab <<'EOF'
# dpl homelab — extra disks (do not format)
UUID=3aaf62c7-54e7-4e19-a588-c9f9f20deb0a /media/ubuntu/3aaf62c7-54e7-4e19-a588-c9f9f20deb0a xfs defaults,nofail,x-systemd.device-timeout=10 0 2
UUID=529001a1-d4bd-4930-9053-7ab4875e856d /media/ubuntu/Volume\040A ext4 defaults,nofail,x-systemd.device-timeout=10 0 2
UUID=fcf77474-1737-4790-9a14-8ee58cc45870 /media/ubuntu/Volume\040B ext4 defaults,nofail,x-systemd.device-timeout=10 0 2
EOF
mkdir -p /media/ubuntu/3aaf62c7-54e7-4e19-a588-c9f9f20deb0a \
  "/media/ubuntu/Volume A" "/media/ubuntu/Volume B"
mount -a || true

# --- docker ---
systemctl enable --now docker
usermod -aG docker "$TARGET_USER"
# data-root on NVMe if present
if [[ -d /media/ubuntu/3aaf62c7-54e7-4e19-a588-c9f9f20deb0a/dpl/docker ]]; then
  mkdir -p /etc/docker
  cat >/etc/docker/daemon.json <<'EOF'
{
  "data-root": "/media/ubuntu/3aaf62c7-54e7-4e19-a588-c9f9f20deb0a/dpl/docker",
  "live-restore": true
}
EOF
  systemctl restart docker || true
fi

# --- tailscale (inbound mesh SSH; prefer this over exposing :22 to the internet) ---
if ! command -v tailscale >/dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi
systemctl enable --now tailscaled || true
echo "Tailscale installed. As ${TARGET_USER} run: sudo tailscale up --ssh --hostname=dpl"

# --- moshi PATH ---
loginctl enable-linger "$TARGET_USER"
install -d /usr/local/bin
for name in herdr tmux moshi moshi-hook nvim zsh lazygit docker; do
  if [[ -e "$TARGET_HOME/.local/bin/$name" ]]; then
    ln -sfn "$TARGET_HOME/.local/bin/$name" "/usr/local/bin/$name"
  fi
done

echo
echo "sshd=$(systemctl is-active ssh) docker=$(systemctl is-active docker) linger=$(loginctl show-user "$TARGET_USER" -p Linger --value)"
echo "LAN: ssh ${TARGET_USER}@192.168.1.193"
echo "Then: sudo tailscale up --ssh --hostname=dpl"
echo "Reserve 192.168.1.193 on the router, port-forward 22 only if you must skip Tailscale."
