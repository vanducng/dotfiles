#!/usr/bin/env bash
# Rex app settings live in UserDefaults, not init.lua. This script is their source of truth. Re-runnable.
set -euo pipefail

DOMAIN="com.superlogical.rex"
REX="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

command -v defaults >/dev/null || { echo "macOS only"; exit 1; }
[ -x "$REX" ] || { echo "Rex server missing; open Rex Beta.app once"; exit 1; }

# Every machine is defined once, in hosts.json (see hosts.lua for its fields).
HOSTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dotfiles/rex/.config/rex/hosts.json"
label="$(/usr/bin/python3 - "$HOSTS" "$(scutil --get LocalHostName)" <<'PY'
import json, sys
path, me = sys.argv[1], sys.argv[2]
found = [h["label"] for h in json.load(open(path)) if h.get("hostname") == me]
sys.exit(f"{me} is not in {path}; add an entry for this Mac") if not found else print(found[0])
PY
)"
node="rex-$label"

# Option sends Alt (alt+p is not π), the same as Ghostty's macos-option-as-alt.
defaults write "$DOMAIN" Workspace.terminalOptionKeyBehavior -string actsAsAlt
# The sidebar (C-x b, cmd+b) only exists with vertical tabs.
defaults write "$DOMAIN" Workspace.tabStyle -string vertical
defaults write "$DOMAIN" Workspace.paneDensity -string compact
# Sound when an agent finishes or waits on you, including OpenRig seats (rex-agent-status).
defaults write "$DOMAIN" Workspace.playsProgramActivitySounds -bool true
# Everything below needs the tailnet, so stop before writing any of it.
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
[ -x "$TS" ] || TS=tailscale
suffix="$(TAILSCALE_BE_CLI=1 "$TS" status --json \
  | /usr/bin/python3 -c 'import json,sys; s=json.load(sys.stdin).get("MagicDNSSuffix"); sys.exit("Tailscale is not connected; sign in, then rerun") if not s else print(s)')"

# The app's Remote Hosts list ignores hosts.lua. Add each other Mac once; the app
# fills in its IDs on first connect, so existing records are left alone.
hosts_hex="$(/usr/bin/python3 - "$label" "$suffix" "$HOSTS" <<'PY'
import json, plistlib, subprocess, sys, uuid

me, suffix = sys.argv[1], sys.argv[2]
icons = {h["label"]: h.get("icon", "desktopcomputer") for h in json.load(open(sys.argv[3]))}
prefs = plistlib.loads(subprocess.run(
    ["defaults", "export", "com.superlogical.rex", "-"], check=True, capture_output=True).stdout)
data = json.loads(prefs.get("RexSync.servers") or b'{"formatVersion":1,"records":[]}')
if data.get("formatVersion") != 1:
    sys.exit("RexSync.servers has an unknown formatVersion; add the hosts in the app instead")
records = data.setdefault("records", [])
have = {r.get("name") for r in records}
added = False
for name, icon in icons.items():
    if name == me or name in have:
        continue
    url = f"https://rex-{name}.{suffix}"
    records.append({"id": str(uuid.uuid4()).upper(), "name": name, "icon": icon,
                    "locators": [url], "preferredURL": url})
    added = True
if added:
    print(json.dumps(data, separators=(",", ":")).encode().hex())
PY
)"

# What the app's Tailscale toggle saves, so the node comes back after a restart.
defaults write "$DOMAIN" rex.server.tailnet-enabled -bool true
defaults write "$DOMAIN" rex.server.tailnet-hostname -string "$node"
[ -z "$hosts_hex" ] || defaults write "$DOMAIN" RexSync.servers -data "$hosts_hex"

"$REX" server tailscale on --hostname "$node" >/dev/null
current="$("$REX" server status --json | /usr/bin/python3 -c 'import json,sys; print((json.load(sys.stdin).get("tailscale") or {}).get("dns_name", "").split(".")[0])')"
[ "$current" = "$node" ] || "$REX" server tailscale rename "$node" >/dev/null
"$REX" config check >/dev/null || { echo "Rex config has problems; run: rex config check"; exit 1; }
"$REX" config reload >/dev/null
# layout.lua's sessions at the top of the sidebar; a rerun leaves the running ones alone.
"$REX" do "$HOME/.config/rex/actions.lua" --action session_layout
echo "Rex: $node, Option acts as Alt, vertical tabs, compact panes, config reloaded (quit and reopen Rex Beta to apply app settings)"
[ -z "$hosts_hex" ] || echo "Remote Hosts updated; quit and reopen Rex Beta to see them"
