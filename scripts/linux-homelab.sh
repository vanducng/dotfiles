#!/usr/bin/env bash
# User-space homelab bootstrap (no sudo). Idempotent.
# Disks via udisks, never-sleep, sshd :2222, layout, clone last-30d repos,
# docker-compose binary. Full docker/sshd:22/tailscale: sudo linux-homelab-root.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH}"
. "${REPO_ROOT}/dotfiles/homelab/.config/homelab/layout.env"

log() { printf 'homelab: %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# NVME_MNT / GIT_ROOT / DOCKER_ROOT come from layout.env

ensure_disks() {
  bash "${HOME}/.config/homelab/mount-disks" 2>/dev/null \
    || bash "${REPO_ROOT}/dotfiles/homelab/.config/homelab/mount-disks"
  [[ -d "$NVME_MNT" && -d "$HDDA_MNT" && -d "$HDDB_MNT" ]] || {
    echo "homelab: disks not mounted" >&2
    return 1
  }
}

mk_lab_dirs() {
  mkdir -p \
    "${GIT_ROOT}/"{personal,dpl,cnb,ab-spectrum,bhcoe,crashchat,nlb} \
    "${NVME_MNT}/docker/"{data,tmp} \
    "${NVME_MNT}/worktrees" \
    "${NVME_MNT}/agents" \
    "${NVME_MNT}/cache" \
    "${NVME_MNT}/tmp" \
    "${HDDA_MNT}/dpl/"{datasets,media,incoming} \
    "${HDDB_MNT}/dpl/"{lab,snapshots} \
    "${HOME}/mnt" "${HOME}/.local/bin"
  cat >"${NVME_MNT}/README.md" <<'EOF'
# /media/ubuntu/work (Samsung 970 EVO Plus 2TB)

Git: `~/work/git/<org>`. Docker: `~/work/docker/data`.

| Path | Role |
|---|---|
| `git/cnb` | CareerNow |
| `git/crashchat` | CrashChat.ai |
| `git/ab-spectrum` | AB-Spectrum |
| `git/bhcoe` | BHCOE / Jade |
| `git/dpl` | DataPlaneLabs |
| `git/nlb` | nextlevelbuilder |
| `git/personal` | vanducng |
| `docker/data` | images, volumes, json-logs |
EOF
}

replace_link() {
  # ln -sfn into an existing directory nests the link; replace the node instead.
  local target="$1" link="$2"
  if [[ -L "$link" || -f "$link" ]]; then
    rm -f "$link"
  elif [[ -d "$link" ]]; then
    rmdir "$link" 2>/dev/null || return 1
  fi
  ln -sfn "$target" "$link"
}

link_home() {
  mkdir -p "${HOME}/mnt"
  replace_link "${WORK_ROOT}" "${HOME}/work"
  ln -sfn "${NVME_MNT}" "${HOME}/lab"
  ln -sfn "${HDDA_MNT}/dpl" "${HOME}/archive"
  ln -sfn "${HDDB_MNT}/dpl" "${HOME}/backup"
  ln -sfn "${NVME_MNT}" "${HOME}/mnt/nvme"
  ln -sfn "${HDDA_MNT}" "${HOME}/mnt/hdd-a"
  ln -sfn "${HDDB_MNT}" "${HOME}/mnt/hdd-b"
}

relocate_existing() {
  local src dest
  # Move previously cloned trees off the OS disk if they are still real dirs.
  for pair in \
    "${HOME}/work/git/ab-spectrum:${GIT_ROOT}/ab-spectrum" \
    "${HOME}/work/git/bhcoe:${GIT_ROOT}/bhcoe" \
    "${HOME}/work/git/crashchat:${GIT_ROOT}/crashchat" \
    "${HOME}/work/git/cnb:${GIT_ROOT}/cnb"; do
    src="${pair%%:*}"
    dest="${pair##*:}"
    if [[ -d "$src" && ! -L "$src" ]]; then
      mkdir -p "$dest"
      shopt -s dotglob nullglob
      for item in "$src"/*; do
        base="$(basename "$item")"
        if [[ ! -e "$dest/$base" ]]; then
          mv "$item" "$dest/"
        fi
      done
      shopt -u dotglob nullglob
      rmdir "$src" 2>/dev/null || rm -rf "$src"
    fi
  done
}

never_sleep() {
  if have gsettings; then
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' || true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' || true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 || true
    gsettings set org.gnome.desktop.session idle-delay 0 || true
    gsettings set org.gnome.desktop.screensaver lock-enabled false || true
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false || true
  fi
}

install_user_sshd() {
  local prefix="${HOME}/.local/opt/openssh"
  if [[ ! -x "${prefix}/usr/sbin/sshd" ]]; then
    log "extracting openssh-server for user sshd :2222"
    local tmp
    tmp="$(mktemp -d)"
    (
      cd "$tmp"
      apt-get download openssh-server openssh-sftp-server
      mkdir -p "$prefix"
      for deb in *.deb; do dpkg-deb -x "$deb" "$prefix"; done
    )
    rm -rf "$tmp"
  fi
  mkdir -p "${HOME}/.config/sshd"
  if [[ ! -f "${HOME}/.config/sshd/ssh_host_ed25519_key" ]]; then
    ssh-keygen -t ed25519 -f "${HOME}/.config/sshd/ssh_host_ed25519_key" -N "" -C "dpl-sshd-host"
  fi
  # config is stowed; copy if not present
  if [[ ! -e "${HOME}/.config/sshd/sshd_config" ]]; then
    cp "${REPO_ROOT}/dotfiles/homelab/.config/sshd/sshd_config" "${HOME}/.config/sshd/sshd_config"
  fi
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"
  touch "${HOME}/.ssh/authorized_keys"
  chmod 600 "${HOME}/.ssh/authorized_keys"
}

install_compose() {
  if have docker-compose || docker compose version >/dev/null 2>&1; then
    log "compose present"
    return 0
  fi
  local ver=v2.29.7
  log "installing docker compose ${ver} binary"
  curl -fsSL "https://github.com/docker/compose/releases/download/${ver}/docker-compose-linux-x86_64" \
    -o "${HOME}/.local/bin/docker-compose"
  chmod +x "${HOME}/.local/bin/docker-compose"
}

install_lazygit_link() {
  if [[ -x "${HOME}/.local/share/mise/shims/lazygit" && ! -e "${HOME}/.local/bin/lazygit" ]]; then
    ln -sfn "${HOME}/.local/share/mise/shims/lazygit" "${HOME}/.local/bin/lazygit"
  fi
}

enable_units() {
  systemctl --user daemon-reload
  systemctl --user enable --now homelab-disks.service
  systemctl --user enable --now homelab-nosleep.service
  if [[ -x "${HOME}/.local/opt/openssh/usr/sbin/sshd" ]]; then
    systemctl --user enable --now sshd-user.service || true
  fi
  # already installed last session
  systemctl --user enable herdr-server.service 2>/dev/null || true
  systemctl --user enable moshi-hook.service 2>/dev/null || true
  mkdir -p "${HOME}/.config/systemd/user/herdr-server.service.d"
  cat >"${HOME}/.config/systemd/user/herdr-server.service.d/restart.conf" <<'EOF'
[Service]
Restart=always
RestartSec=3
EOF
  systemctl --user daemon-reload
  systemctl --user restart herdr-server.service 2>/dev/null || true
  # CNB: jump through Mac VPN until ~/.config/openvpn/cnb.auth exists
  if [[ -f "${HOME}/.config/systemd/user/cnb-bastion-jump.service" ]]; then
    systemctl --user enable --now cnb-bastion-jump.service 2>/dev/null || true
  fi
  # CNB OpenVPN is on-demand (cnb-openvpn start|stop). Never `systemctl disable`
  # the unit — systemd unlinks a stowed ~/.config/systemd/user/*.service.
  rm -f "${HOME}/.config/systemd/user/default.target.wants/cnb-openvpn.service"
  log "cnb-openvpn on-demand — cnb-openvpn start|stop|status (gopass cnb/vpn/pfsense-main)"
}

nm_static_hint() {
  # Persist the current address as manual DHCP-less config (applies next connect).
  local con="Wired connection 1"
  nmcli con show "$con" >/dev/null 2>&1 || return 0
  nmcli con modify "$con" ipv4.method manual \
    ipv4.addresses 192.168.1.193/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "192.168.1.1 1.1.1.1" || true
  log "NetworkManager $con set to 192.168.1.193/24 (takes effect on next connection/reboot)"
}

clone_one() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    log "skip exists $dest"
    return 0
  fi
  log "clone $url -> $dest"
  GIT_LFS_SKIP_SMUDGE=1 git clone "$url" "$dest" || log "FAIL clone $url"
}

clone_recent() {
  # org/path pairs: last 30 days as of 2026-08-26, minus already-home clones (dotfiles, skills).
  local root="${GIT_ROOT}"
  local jobs=0
  clone_jobs() { # url dest
    clone_one "$1" "$2" &
    jobs=$((jobs + 1))
    if (( jobs >= 4 )); then
      wait
      jobs=0
    fi
  }

  # personal (skip dotfiles/skills — live in $HOME)
  clone_jobs git@github.com:vanducng/miu-cr.git            "$root/personal/miu-cr"
  clone_jobs git@github.com:vanducng/pass.git               "$root/personal/pass"
  clone_jobs git@github.com:vanducng/vd-cli.git             "$root/personal/vd-cli"
  clone_jobs git@github.com:vanducng/oh-my-dsh.git          "$root/personal/oh-my-dsh"
  clone_jobs git@github.com:vanducng/vanducng-dev.git       "$root/personal/vanducng-dev"
  clone_jobs git@github.com:vanducng/infra-template.git     "$root/personal/infra-template"
  clone_jobs git@github.com:vanducng/miu-db.git             "$root/personal/miu-db"
  clone_jobs git@github.com:vanducng/udacimak.git           "$root/personal/udacimak"
  clone_jobs git@github.com:vanducng/seo.git                "$root/personal/seo"
  clone_jobs git@github.com:vanducng/braze-cli.git          "$root/personal/braze-cli"
  clone_jobs git@github.com:vanducng/smartsheet-cli.git     "$root/personal/smartsheet-cli"
  clone_jobs git@github.com:vanducng/voice-agent-cli.git    "$root/personal/voice-agent-cli"
  clone_jobs git@github.com:vanducng/jira-cli.git           "$root/personal/jira-cli"

  clone_jobs git@github.com:dataplanelabs/infra.git         "$root/dpl/infra"
  clone_jobs git@github.com:dataplanelabs/annhien.git       "$root/dpl/annhien"
  clone_jobs git@github.com:dataplanelabs/goclaw-config.git "$root/dpl/goclaw-config"
  clone_jobs git@github.com:dataplanelabs/goclaw.git        "$root/dpl/goclaw"
  clone_jobs git@github.com:dataplanelabs/code-review.git   "$root/dpl/code-review"

  clone_jobs git@github.com:careernowbrands/cnb-infra.git              "$root/cnb/cnb-infra"
  clone_jobs git@github.com:careernowbrands/cnb-web-services.git       "$root/cnb/cnb-web-services"
  clone_jobs git@github.com:careernowbrands/cnb-ds-astro.git           "$root/cnb/cnb-ds-astro"
  clone_jobs git@github.com:careernowbrands/cnb-rocket-marketingtool.git "$root/cnb/cnb-rocket-marketingtool"
  clone_jobs git@github.com:careernowbrands/cdljobnow-bp.git           "$root/cnb/cdljobnow-bp"
  clone_jobs git@github.com:careernowbrands/cnb-polaris.git            "$root/cnb/cnb-polaris"
  clone_jobs git@github.com:careernowbrands/cnb-core.git               "$root/cnb/cnb-core"
  clone_jobs git@github.com:careernowbrands/cnb-qa-automation.git      "$root/cnb/cnb-qa-automation"
  clone_jobs git@github.com:careernowbrands/cnb-rover.git              "$root/cnb/cnb-rover"
  clone_jobs git@github.com:careernowbrands/cnb-ds-dbt-order-form.git  "$root/cnb/cnb-ds-dbt-order-form"
  clone_jobs git@github.com:careernowbrands/csn-schoolsnow.git         "$root/cnb/csn-schoolsnow"
  clone_jobs git@github.com:careernowbrands/csn-api.git                "$root/cnb/csn-api"
  clone_jobs git@github.com:careernowbrands/cnb-driverwave.git         "$root/cnb/cnb-driverwave"
  clone_jobs git@github.com:careernowbrands/niche-career-now.git       "$root/cnb/niche-career-now"
  clone_jobs git@github.com:careernowbrands/csn-ops.git                "$root/cnb/csn-ops"
  clone_jobs git@github.com:careernowbrands/truck-warrior.git          "$root/cnb/truck-warrior"
  clone_jobs git@github.com:careernowbrands/cnb-ds-infra.git           "$root/cnb/cnb-ds-infra"
  clone_jobs git@github.com:careernowbrands/cnb-ds-datahub.git         "$root/cnb/cnb-ds-datahub"
  clone_jobs git@github.com:careernowbrands/it-ops-scripts.git         "$root/cnb/it-ops-scripts"
  clone_jobs git@github.com:careernowbrands/cnb-meilisearch.git        "$root/cnb/cnb-meilisearch"

  clone_jobs git@github.com:AB-Spectrum/data-platform.git "$root/ab-spectrum/data-platform"
  clone_jobs git@github.com:AB-Spectrum/infra.git         "$root/ab-spectrum/infra"
  clone_jobs git@github.com:AB-Spectrum/tobycli.git       "$root/ab-spectrum/tobycli"

  clone_jobs git@github.com:BHCOE/harmony.git    "$root/bhcoe/harmony"
  clone_jobs git@github.com:BHCOE/jade-infra.git "$root/bhcoe/jade-infra"

  clone_jobs git@github.com:CrashChat-ai/mio.git           "$root/crashchat/mio"
  clone_jobs git@github.com:CrashChat-ai/channel-pulse.git "$root/crashchat/channel-pulse"
  clone_jobs git@github.com:CrashChat-ai/crashvault.git    "$root/crashchat/crashvault"
  clone_jobs git@github.com:CrashChat-ai/crashchat-infra.git "$root/crashchat/infra"

  clone_jobs git@github.com:nextlevelbuilder/dewee.git              "$root/nlb/dewee"
  clone_jobs git@github.com:nextlevelbuilder/agentwiki.git          "$root/nlb/agentwiki"
  clone_jobs git@github.com:nextlevelbuilder/ui-ux-pro-max-skill.git "$root/nlb/ui-ux-pro-max-skill"
  clone_jobs git@github.com:nextlevelbuilder/goclaw.git             "$root/nlb/goclaw"
  clone_jobs git@github.com:nextlevelbuilder/goclaw-docs.git        "$root/nlb/goclaw-docs"
  clone_jobs git@github.com:nextlevelbuilder/agentbrain-cli.git     "$root/nlb/agentbrain-cli"
  clone_jobs git@github.com:nextlevelbuilder/builder-hub-system.git "$root/nlb/builder-hub-system"

  wait
}

stow_homelab() {
  if have stow; then
    (cd "${REPO_ROOT}/dotfiles" && stow --no-folding -D -t "${HOME}" homelab 2>/dev/null || true
      stow --no-folding -t "${HOME}" homelab)
  fi
  chmod +x "${HOME}/.config/homelab/mount-disks" 2>/dev/null || true
}

main() {
  mkdir -p "${HOME}/.local/bin" "${HOME}/.config/sshd"
  stow_homelab
  ensure_disks
  mk_lab_dirs
  relocate_existing
  link_home
  never_sleep
  install_user_sshd
  install_compose
  install_lazygit_link
  enable_units
  nm_static_hint
  if [[ "${SKIP_CLONE:-0}" != 1 ]]; then
    clone_recent
  else
    log "SKIP_CLONE=1 — not cloning"
  fi
  log "done"
  log "  git:      ${HOME}/work/git -> ${GIT_ROOT}"
  log "  docker:   ${DOCKER_ROOT}"
  log "  archive:  ${HOME}/archive"
  log "  backup:   ${HOME}/backup"
  log "  ssh user: $(hostname -I | awk '{print $1}'):2222  (sshd :22 needs sudo linux-homelab-root.sh)"
  log "  never-sleep user inhibit on; system sleep mask needs that same sudo script"
  log "  docker engine needs: sudo -E ${REPO_ROOT}/scripts/linux-homelab-root.sh"
}

main "$@"
