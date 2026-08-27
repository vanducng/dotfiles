---
title: "Linux homelab (dpl)"
---

Host `dpl` is a homelab box: never-sleep, auto-login, coding-agent handoff, extra disks.

## Disks

| Disk | Size | Use |
|---|---|---|
| Samsung 860 EVO (`/`) | 1 TB | OS, `$HOME` configs, dotfiles |
| Samsung 970 EVO Plus NVMe | 2 TB | **hot** `dpl-work`: `~/work/git/<org>`, `~/lab/docker/data` |
| WD Volume A | 16 TB | `~/archive` datasets/media |
| WD Volume B | 16 TB | `~/backup` snapshots of the lab |

Git is `~/work/git/{cnb,crashchat,ab-spectrum,bhcoe,dpl,nlb,personal}`. Worktrees sit next to the clone (`.worktrees/`). Docker images/volumes/json-logs: `~/lab/docker/data` after the sudo root script.

## User-space (no sudo)

```bash
make linux-homelab
```

Mounts disks via udisks, inhibits sleep, starts **sshd on :2222**, clones last-30-day repos onto the NVMe.

## Needs sudo once

```bash
sudo -E ~/.dotfiles/scripts/linux-homelab-root.sh
sudo tailscale up --ssh --hostname=dpl
```

That installs sshd `:22`, docker (data-root on NVMe), tailscale, fstab, and masks suspend. Prefer **Tailscale SSH** over forwarding `:22` to `222.253.112.200`.

LAN IP: `192.168.1.193` (set as NetworkManager manual). Reserve it on the router.

GDM already auto-logs in `ubuntu`; linger is on so `herdr-server` and `moshi-hook` come back after reboot.
