#!/bin/sh
# Run ON THE MAC (needs GUI keychain). Stores CNB OpenVPN user/pass in dpl gopass
# (cnb/vpn/pfsense-main/{username,password}) and refreshes ~/.config/openvpn/cnb.auth.
# Never hardcode account names in this script.
set -eu
PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"
DPL="${DPL_SSH:-ubuntu@192.168.1.193}"
DPL_PORT="${DPL_SSH_PORT:-2222}"

U=""
P=""

for id in 1700143330356 1719231711903 1668194320662 1663962279625; do
  P=$(security find-generic-password -s "org.openvpn.client." -a "$id" -w 2>/dev/null || true)
  if [ -n "$P" ]; then
    break
  fi
done

if [ -z "$P" ]; then
  U=$(security find-generic-password -s Tunnelblick-Auth-config -a username -w 2>/dev/null || true)
  P=$(security find-generic-password -s Tunnelblick-Auth-config -a password -w 2>/dev/null || true)
fi

if [ -z "$P" ]; then
  echo "could not read VPN auth from Keychain (needs a logged-in GUI session)." >&2
  echo "unlock Keychain, or pipe username then password into: ssh -p $DPL_PORT $DPL cnb-openvpn set-auth" >&2
  exit 1
fi

REMOTE='export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"'
if [ -n "$U" ]; then
  printf '%s\n%s\n' "$U" "$P" | ssh -p "$DPL_PORT" "$DPL" "$REMOTE; cnb-openvpn set-auth"
else
  printf '%s\n' "$P" | ssh -p "$DPL_PORT" "$DPL" "$REMOTE; cnb-openvpn set-password"
fi
echo "stored in dpl gopass cnb/vpn/pfsense-main — start with: ssh -p $DPL_PORT $DPL cnb-openvpn start"
