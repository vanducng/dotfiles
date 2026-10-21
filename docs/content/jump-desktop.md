---
title: "Jump Desktop"
---

Remote desktop across the home machines with [Jump Desktop](https://jumpdesktop.com). The helper CLI and agent instructions live in the `jump-desktop` skill; this repo holds the per-machine config.

| Machine | How Jump reaches it | Entry |
| --- | --- | --- |
| `mac01` (Mac mini) | Jump Desktop Connect (Fluid, cloud, from anywhere); VNC fallback on the LAN | `mac01.jump` -> `192.168.1.21:5900` |
| `linux01` (Ubuntu, Connect name `dpl`) | Jump Desktop Connect for Linux (Fluid, cloud, from anywhere); GNOME Remote Desktop RDP fallback on the LAN | `linux01.jump` -> `192.168.1.193:3389`, user `ubuntu` |
| `ducs-macbook-pro` (laptop) | Jump Desktop Connect (Fluid, cloud, from anywhere); VNC fallback over Tailscale so it also works off the LAN | `ducs-macbook-pro.jump` -> `ducs-macbook-pro:5900` |

## Files

- `dotfiles/bin/.config/jump-desktop/servers/*.jump` - viewer entries (Jump's JSON format), stowed to `~/.config/jump-desktop/servers/`. No passwords: Jump prompts once and keeps them in the keychain.
- `dotfiles/bin/.local/bin/jump-connect` - shim to `~/skills/skills/jump-desktop/scripts/jump-connect` (works on the Macs and on linux01).

Connect hosts (`mac01`, `dpl`, `Ducs-MacBook-Pro`) appear in Jump Desktop automatically once signed in; the files above are the fallbacks.

## Commands

```bash
jump-connect status            # is this Mac reachable: service, device id, TCC grants, last connections
jump-connect access 50         # who connected, from where, and whether auth passed
jump-connect list              # the entries above
jump-connect open linux01      # connect now
jump-connect import            # save all entries into Jump Desktop's list
```

## Set up a Mac host

1. `brew install --cask jump-desktop-connect`, then `make stow-bin`.
2. Sign in from the Connect app, or create a Connect Code in the Jump dashboard and run `jump-connect add-user <code>`.
3. Allow Screen Recording, Accessibility, and Remote Desktop for Jump Desktop Connect (`jump-connect perms-ui`), then check `jump-connect perms`.
4. For the VNC fallback, turn on System Settings > General > Sharing > Screen Sharing.
5. For unattended use, log in with the macOS account from the viewer instead of waiting for someone to click Allow (`Type:Interactive ... Timedout` in `jump-connect access`).

## linux01

Jump Desktop Connect runs as `jump-connect.service` (package `jump-connect`, logs in `/var/log/jump-connect/`); `ssh linux01 jump-connect status` checks it. The RDP fallback is GNOME Remote Desktop (`grdctl status`), credentials via `grdctl rdp set-credentials`. From outside the LAN use the `dpl` Connect entry or `linux01` (Tailscale); see [Linux homelab](/linux-homelab/).

## Troubleshooting

- `Error Code: 2.50 (0x32)` on a LAN entry: macOS denied Jump Desktop **Local Network** access (`viewer LAN: DENIED` in `jump-connect status`). Turn it on in System Settings > Privacy & Security > Local Network.
- A full-tunnel VPN (CNB OpenVPN) breaks Jump's WebRTC relay: the service log shows STUN `No route to host` over `utun`. Run `cnb-openvpn-mac split`.
- `JumpConnect --dumpmacperm` reports false from a terminal even when the service is allowed. Trust `jump-connect perms`.
