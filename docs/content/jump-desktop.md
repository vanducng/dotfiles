---
title: "Jump Desktop"
---

Remote desktop across the home machines with [Jump Desktop](https://jumpdesktop.com). The helper CLI and agent instructions live in the `jump-desktop` skill; this repo holds the per-machine config.

| Name in Jump | Machine (hostname) | How Jump reaches it | Fallback entry |
| --- | --- | --- | --- |
| `mini-01` | Mac mini (`mac01`) | Jump Desktop Connect (Fluid, cloud, from anywhere) | `mini-01.jump`: VNC `192.168.1.21:5900` (LAN) |
| `linux-01` | Ubuntu (`dpl`, ssh `linux01`) | Jump Desktop Connect for Linux (Fluid, cloud, from anywhere) - not working yet, see below | none: Jump cannot RDP to GNOME Remote Desktop 42 |
| `macpro` | MacBook Pro (`Ducs-MacBook-Pro`) | Jump Desktop Connect (Fluid, cloud, from anywhere) | `macpro.jump`: VNC `ducs-macbook-pro:5900` (Tailscale, works off the LAN) |

Connect reports each host by its hostname. The names above are set per viewer from `names` by `jump-connect names`; the hostnames stay unchanged because Tailscale, ssh, and skhd use them.

## Account

All hosts and viewers use the one Jump account bought through the Apple App Store (Sign in with Apple). Do not sign Connect or the viewer into any other Jump account. `jump-connect info` on a host should list only that account's Apple relay address, and `jump-connect access` should show `Type:Local` logins from it.

## Files

- `dotfiles/bin/.config/jump-desktop/servers/*.jump` - fallback viewer entries (Jump's JSON format), stowed to `~/.config/jump-desktop/servers/`. No passwords: Jump prompts once and keeps them in the keychain.
- `dotfiles/bin/.config/jump-desktop/names` - display names for the Connect hosts.
- `dotfiles/bin/.local/bin/jump-connect` - shim to `~/skills/skills/jump-desktop/scripts/jump-connect` (works on the Macs and on linux01).

## Commands

```bash
jump-connect status            # service, device id, TCC grants, viewer Local Network grant, last connections
jump-connect access 50         # who connected, from where, and whether auth passed
jump-connect list              # the entries above
jump-connect open mini-01      # connect now
jump-connect import            # save the fallback entries into Jump Desktop's list
jump-connect names             # apply the display names (quit Jump Desktop first)
```

## Set up a Mac

1. `brew install --cask jump-desktop-connect`, then `make stow-bin`.
2. Sign Connect in with the Apple account, or create a Connect Code while signed in to the Jump dashboard with it and run `jump-connect add-user <code>`.
3. Allow Screen Recording, Accessibility, and Remote Desktop for Jump Desktop Connect (`jump-connect perms-ui`), then check `jump-connect perms`. Full Disk Access (`SystemPolicyAllFiles`) stays off; remote control does not need it.
4. In the Jump Desktop viewer: sign in with the Apple account, allow Local Network when macOS asks, run `jump-connect import`, quit Jump Desktop, then `jump-connect names`.
5. For the VNC fallback, turn on System Settings > General > Sharing > Screen Sharing.
6. On the MacBook, run `cnb-openvpn-mac install-repair` once (sudo) so the CNB full tunnel never captures Jump or Tailscale traffic.
7. For unattended use, log in with the macOS account from the viewer instead of waiting for someone to click Allow (`Type:Interactive ... Timedout` in `jump-connect access`).

## linux01

Jump Desktop Connect runs as `jump-connect.service` (package `jump-connect`, logs in `/var/log/jump-connect/`, agent log `~/.local/state/jump-connect/logs/`); `ssh linux01 jump-connect status` checks it; `sudo jump-connect sessions` lists live sessions. See [Linux homelab](/linux-homelab/).

Known issues on Ubuntu 22.04 (GNOME 42, Wayland):

- Fluid connects and authenticates as `ubuntu`, then stays on "connecting": the service logs `Dropping request to view desktop because client does not have access` and the viewer gets no video. Same since the first session on 2026-10-18.
- RDP from Jump to GNOME Remote Desktop 42 cannot work: it accepts only NLA and rejects Jump's NTLM negotiate flags (`NegotiateFlags invalid flags ... 0x00000205 required`), so the window closes right after the password. Use Microsoft Remote Desktop or FreeRDP for RDP to linux01.

## Troubleshooting

- `Error Code: 2.50 (0x32)` on a LAN entry: macOS denied Jump Desktop **Local Network** access (`viewer LAN: DENIED` in `jump-connect status`). Turn it on in System Settings > Privacy & Security > Local Network.
- A full-tunnel VPN (CNB OpenVPN) breaks Jump's WebRTC relay: the service log shows STUN `No route to host` over `utun`. `cnb-openvpn-mac split` fixes it now; `cnb-openvpn-mac install-repair` keeps it fixed after reconnects.
- `JumpConnect --dumpmacperm` reports false from a terminal even when the service is allowed. Trust `jump-connect perms`.
