#!/bin/sh
# Run ON THE MAC (needs GUI keychain). Stores CNB OpenVPN user/pass in dpl gopass
# (cnb/vpn/pfsense-main/{username,password}) and refreshes ~/.config/openvpn/cnb.auth.
set -eu
PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"
DPL="${DPL_SSH:-ubuntu@192.168.1.193}"
DPL_PORT="${DPL_SSH_PORT:-2222}"

U=""
P=""

for id in 1700143330356 1719231711903 1668194320662 1663962279625; do
  P=$(security find-generic-password -s "org.openvpn.client." -a "$id" -w 2>/dev/null || true)
  if [ -n "$P" ]; then
    U="duc@careernowbrands.com"
    case "$id" in
      1668194320662|1663962279625) U="Duc" ;;
    esac
    break
  fi
done

if [ -z "$P" ]; then
  U=$(security find-generic-password -s Tunnelblick-Auth-config -a username -w 2>/dev/null || true)
  P=$(security find-generic-password -s Tunnelblick-Auth-config -a password -w 2>/dev/null || true)
fi

if [ -z "$U" ] || [ -z "$P" ]; then
  echo "could not read VPN auth from Keychain (needs a logged-in GUI session)." >&2
  echo "unlock Keychain, or: printf 'user\\npass\\n' | ssh -p $DPL_PORT $DPL cnb-openvpn set-auth" >&2
  exit 1
fi

# Push into gopass on dpl (source of truth), then materialize cnb.auth.
printf '%s\n%s\n' "$U" "$P" | ssh -p "$DPL_PORT" "$DPL" 'export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"; cnb-openvpn set-auth'
echo "stored in dpl gopass cnb/vpn/pfsense-main — start with: ssh -p $DPL_PORT $DPL cnb-openvpn start"
