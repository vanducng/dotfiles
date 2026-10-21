---
title: "OpenVPN"
---

OpenVPN Connect on each Mac keeps its own profiles. Those `.ovpn` files hold inline private keys. They stay in the app's profile folder and never go into this repository.

## Where the files live

```text
~/Library/Application Support/OpenVPN Connect/profiles/
```

The folder is mode `700`. Each profile is mode `600`. `config.json` next to that folder is app state. Leave it on the machine. Do not copy logs.

The helper `cnb-openvpn-mac` reads that same folder. It is `dotfiles/bin/.local/bin/cnb-openvpn-mac`.

## Copy profiles from the MacBook

On the Mac that should receive them:

```bash
mkdir -p /tmp/ovpn-from-macbook
chmod 700 /tmp/ovpn-from-macbook
scp \
  'vanducng@Ducs-MacBook-Pro.local:Library/Application Support/OpenVPN Connect/profiles/*.ovpn' \
  /tmp/ovpn-from-macbook/
chmod 600 /tmp/ovpn-from-macbook/*.ovpn
```

This copies the profiles OpenVPN Connect has already imported on the MacBook. A file sitting in Downloads, or a Tunnelblick `.tblk`, is a separate export. Import it only when it is not already one of those profiles.

## Import

```bash
BIN="/Applications/OpenVPN Connect/OpenVPN Connect.app/Contents/MacOS/OpenVPN Connect"
"$BIN" --minimize --skip-startup-dialogs \
  --import-profile=/tmp/ovpn-from-macbook/FILE.ovpn \
  --name="PROFILE NAME"
"$BIN" --list-profiles
rm -rf /tmp/ovpn-from-macbook
```

Add `--username=` when the profile is locked to a user. Do not put `--password=` on the command line. A shell history line would keep it.

Import gives each file a new id. The id is what `cnb-openvpn-mac start` expects. The saved password does not travel with the `.ovpn` file.

## Passwords

OpenVPN Connect stores a saved password in the login keychain. The item service is `org.openvpn.client.` and the account is the profile id. After import the id is new, so the MacBook keychain item no longer matches. Connect then asks for the password.

The CNB main password and username are in gopass on the MacBook:

```text
cnb/vpn/pfsense-main/password
cnb/vpn/pfsense-main/username
```

Read the password with `gopass show -o` and store it with `security add-generic-password` under the new profile id. Do not print it, and do not write it into this repo. The other saved passwords exist only in the MacBook login keychain. SSH cannot read that keychain (`errSecInteractionNotAllowed`). Copying those needs an unlocked GUI session on the MacBook. One Jade profile was never saved there, so it has no password to copy.

## After import

CNB profiles push a full tunnel (`redirect-gateway`). Patch them once so the default route stays on the local network:

```bash
cnb-openvpn-mac patch-profiles
cnb-openvpn-mac start <profile-id>
cnb-openvpn-mac split
```

Run `split` again after every reconnect. `cnb-openvpn-mac doctor` checks the tunnel and whether `api2.cursor.sh` is still reachable. See [AI Tools Troubleshooting](/troubleshooting/ai-tools/).

`*.cdljobnow.com` in the routes file pins the apex plus each name in `labels/cdljobnow.com` (staging, dev, test). Those hosts time out from the house network. A repair job re-resolves them onto the tunnel about every 15 seconds after a reconnect. Add a label there when another `*.cdljobnow.com` name does the same.

## Git

`.gitignore` rejects `*.ovpn` and `*.tblk`. Before a commit:

```bash
git status --short
printf '%s\n' 'profile.ovpn' | git check-ignore --stdin -v
```

`git add -f` would override the ignore. Do not use it on a profile, a `.tblk`, or `config.json`.
