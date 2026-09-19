---
title: "Linux homelab (dpl)"
---

Host `dpl` is a homelab box: never-sleep, auto-login, coding-agent handoff, extra disks.

## Disks

| Disk | Size | Use |
|---|---|---|
| Samsung 860 EVO (`/`) | 1 TB | OS, `$HOME` configs, dotfiles |
| Samsung 970 EVO Plus NVMe | 2 TB | **hot** `/media/ubuntu/work` (`~/work`): `git/<org>`, `docker/data` |
| WD Volume A | 16 TB | `~/archive` datasets/media |
| WD Volume B | 16 TB | `~/backup` snapshots of the lab |

Git is `~/work/git/{cnb,crashchat,ab-spectrum,bhcoe,dpl,nlb,personal}`. Worktrees sit next to the clone (`.worktrees/`). Docker images/volumes/json-logs: `~/work/docker/data` after the sudo root script.

Managed home repos (same layout as Mac): `~/dotfiles`, `~/skills`, `~/firstmate`. Hourly `git-sync-repos` keeps them on `origin/main` without discarding WIP. Vault stays at `~/git/personal/vault`.

Curated work clones get a fetch-only refresh every 2h via `git-fetch-repos` (never checkout/merge) when `~/.config/git-fetch-repos/repos` lists them (see `repos.example`; no built-in defaults). Entering a git repo also runs a debounced `git-fetch-cwd` from the shell hook.

On either host, from this repo:

```bash
make ensure-home-repos   # clone/migrate ~/firstmate
make stow-install        # also runs ensure-home-repos after stow
```

Mac: launchd `dev.vanducng.git-sync-repos` (hourly merge-safe sync) and `dev.vanducng.git-fetch-repos` (2h fetch-only). Linux: `git-sync-repos.timer` and `git-fetch-repos.timer`. Sync units call `ensure-home-managed-repos` first.

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

## Remote (SSH, screen, CDP, internet)

User-space, no sudo:

| What | Where | How |
|---|---|---|
| SSH | `:2222` pubkey | `ssh -p 2222 ubuntu@192.168.1.193` |
| Screen | GNOME RDP `:3389` | Microsoft Remote Desktop on the LAN, or `127.0.0.1:13389` via SSH forward |
| Chrome CDP | `127.0.0.1:9222` only | `ssh dpl` then `agent-browser connect 9222` on the Mac |
| Off-LAN | Tailscale userspace | `dpl-remote up` (login URL), install Tailscale on Mac/phone |

Do **not** port-forward `3389` or `9222`. IPv4 WAN is NAT; IPv6 may already reach `:2222` if the ISP leaves inbound open. Details: `~/.config/homelab/REMOTE.md` and `dpl-remote status`.
