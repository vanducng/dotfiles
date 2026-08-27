# dpl remote access (SSH, screen, CDP, internet)

Host **dpl** (DataPlaneLabs). User `ubuntu`. Never-sleep + GDM autologin + linger.
Treat this PC as a lab server: shell, the live GNOME desktop, and a headed Chrome
that Mac agents can attach to over CDP.

Live IPs / listeners: `dpl-remote status`  
Mac SSH snippet (current IPv6): `dpl-remote mac-config`  
This note: `~/.config/homelab/REMOTE.md`

**Do not** port-forward CDP (`9222`) or RDP (`3389`) on the router. Reach both
through an SSH tunnel or Tailscale. CDP is bound to loopback only.

| What | Address | Auth |
|---|---|---|
| SSH | LAN `192.168.1.193:2222` (also IPv6 `:2222`) | pubkey, user `ubuntu` |
| Screen | GNOME RDP `:3389` | user `ubuntu`; password in `~/.config/homelab/rdp.credentials` on dpl (mode 600) |
| Chrome CDP | `127.0.0.1:9222` only | SSH `LocalForward` or Tailscale serve |
| Off-LAN | Tailscale userspace (preferred), or IPv6 SSH | same Tailscale account on Mac/phone |

WAN IPv4 is NAT (`222.253.112.200`). WAN IPv6 on this NIC (may rotate):

```
2001:ee0:4fc4:60f0:facd:87bb:37f5:1d7f
```

---

## 1. Mac `~/.ssh/config`

Paste this (or re-print with `dpl-remote mac-config` if IPv6 changed):

```
Host dpl
  HostName 192.168.1.193
  User ubuntu
  Port 2222
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 30
  LocalForward 127.0.0.1:9222 127.0.0.1:9222
  LocalForward 127.0.0.1:13389 127.0.0.1:3389

Host dpl-v6
  HostName 2001:ee0:4fc4:60f0:facd:87bb:37f5:1d7f
  User ubuntu
  Port 2222
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 30
  LocalForward 127.0.0.1:9222 127.0.0.1:9222
  LocalForward 127.0.0.1:13389 127.0.0.1:3389

Host dpl-ts
  HostName dpl
  User ubuntu
  Port 2222
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 30
  LocalForward 127.0.0.1:9222 127.0.0.1:9222
  LocalForward 127.0.0.1:13389 127.0.0.1:3389
```

Pubkey must already be in `~/.ssh/authorized_keys` on dpl (it is, from the Mac).

```bash
ssh dpl                 # shell on the LAN
ssh -N dpl              # keep CDP + RDP tunnels only
ssh dpl-v6              # off-LAN if the ISP leaves inbound IPv6 open
ssh dpl-ts              # off-LAN after Tailscale is logged in on both sides
```

Cursor / VS Code Remote SSH: host `192.168.1.193`, port `2222`, user `ubuntu`.

---

## 2. See the screen (RDP)

Same GNOME session that is on the monitor (Wayland).

- **On the LAN:** Microsoft Remote Desktop / Windows App → `192.168.1.193:3389`, user `ubuntu`.
- **Anywhere, after `ssh dpl` / `dpl-v6` / `dpl-ts`:** connect to `127.0.0.1:13389`.

Password lives only in `~/.config/homelab/rdp.credentials` on dpl. Do not commit it.

---

## 3. Chrome CDP from the Mac

Headed Google Chrome on the dpl desktop, user-data-dir `~/work/store/chrome-cdp`,
systemd user unit `homelab-cdp.service`. DevTools:

```
http://127.0.0.1:9222/json/version
```

That port is **not** on the LAN NIC. After `ssh dpl` (forwards 9222):

```bash
env -u AGENT_BROWSER_PROFILE agent-browser connect 9222
# or Chrome on the Mac: chrome://inspect → 127.0.0.1:9222
```

You are attached to the **same window** you see over RDP. Named `vd:browser-profile`
profiles stay on 9300–9399; set `BROWSER_PROFILE_CHROME` to
`~/.local/opt/google-chrome/google-chrome` (already in `linux.sh`).

Restart Chrome: `dpl-remote cdp-restart`.

---

## 4. Internet (not just LAN)

### Preferred: Tailscale (no router change)

Userspace daemon (`homelab-tailscale.service`, no sudo, no TUN). Other devices
reach SSH/RDP/CDP via `tailscale serve` TCP forwards — **not** Funnel, so not
on the public internet.

On dpl:

```bash
dpl-remote status          # AuthURL while NeedsLogin
dpl-remote login-url       # print / refresh the login URL
dpl-remote up              # wait for you to approve, then serve
dpl-remote serve           # after login: :2222 :3389 :9222 on the tailnet
```

On Mac and phone: install [Tailscale](https://tailscale.com/download), **same account**.
Then `ssh dpl-ts` (or MagicDNS `ssh ubuntu@dpl` if Tailscale SSH ACLs allow it).

After the one-time sudo root script (kernel Tailscale), stop the user daemon so
the two do not race:

```bash
systemctl --user disable --now homelab-tailscale.service
sudo tailscale up --ssh --hostname=dpl
```

### IPv6 fallback (no Tailscale)

```bash
ssh -p 2222 ubuntu@2001:ee0:4fc4:60f0:facd:87bb:37f5:1d7f
```

Confirmed listening on `[::]:2222`. Whether this works from a cafe depends on
the ISP IPv6 firewall. Prefer the SSH tunnel for RDP/CDP; treat raw `:3389` on
v6 as accidental exposure.

### IPv4 port-forward (last resort)

Router `192.168.1.1`: WAN TCP **2222 → 192.168.1.193:2222** only.
Keep **3389** and **9222** closed.

---

## 5. Phone (Moshi + Herdr + tmux)

Install **Moshi** from the App Store / Play Store. This host already has:

- `moshi-hook` 0.3.5 daemon (`moshi-hook.service`, linger)
- `herdr` 0.8.2 headless server (`herdr-server.service`)
- `tmux` 3.7c + TPM plugins (catppuccin, tmux-fingers)
- `mosh-server` on the SSH PATH (user-space, UDP 60000–61000)

### Easy Pair (SSH/Mosh from the phone)

On dpl (prints a QR; expires in a few minutes; anyone who scans it gets SSH):

```bash
moshi-hook host setup --name dpl --host 192.168.1.193 --port 2222 --user ubuntu --force
```

In Moshi: **Easy Pair** → scan the QR (or open the `moshi://host/setup?...` link on the phone).
After that, Moshi opens a shell / tmux / Herdr session picker.

Off-LAN, re-run setup with `--host <tailscale-magicdns-or-ipv6>` after `dpl-remote up`.
Do **not** port-forward the mosh UDP range to the WAN; use Tailscale or IPv6 instead.

### Agent hooks (inbox / approvals)

Separate from Easy Pair. In Moshi: **Settings → Agent Hooks**, copy the token:

```bash
moshi-hook pair --token <token>
moshi-hook install
moshi-hook status
```

Hooks are already installed for claude, codex, cursor, grok, pi.

### Herdr from the phone

`herdr-server` is always on. After SSH/Mosh connects, Moshi can attach to the
default Herdr session. Integrations current: pi, droid, claude, codex, cursor, grok.

---

## 6. CLI cheat sheet

```bash
dpl-remote status
dpl-remote mac-config
dpl-remote login-url
dpl-remote up
dpl-remote serve
dpl-remote cdp-restart
dpl-remote down              # Tailscale logged out; daemon stays
```

Units (user systemd, linger=yes):

- `sshd-user.service` — OpenSSH `:2222`
- `gnome-remote-desktop.service` — RDP `:3389`
- `homelab-cdp.service` — headed Chrome CDP
- `homelab-tailscale.service` — userspace Tailscale daemon
- `homelab-tailscale-up.service` — auto `tailscale up` + serve :2222/:3389/:9222 on boot
- `homelab-nosleep.service` / `homelab-disks.service`

---

## 7. Still needs one sudo (optional)

Docker engine, system sshd `:22`, kernel Tailscale, mosh package, CNB tun:

```bash
sudo -E ~/.dotfiles/scripts/linux-homelab-root.sh
sudo ip tuntap add mode tun user ubuntu group ubuntu name cnb0 && sudo ip link set cnb0 up
cnb-openvpn start
```

Until then, SSH stays on **2222**, Tailscale stays userspace, VPN data plane
needs `cnb0`.
