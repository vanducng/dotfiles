#!/bin/sh
# Run ON THE MAC (needs GUI keychain). Pushes CNB OpenVPN user/pass to dpl.
# Prefers the currently-connected OpenVPN Connect MAIN profile
# (id 1700143330356, username duc@careernowbrands.com), then Tunnelblick.
set -eu
PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"
DPL="${DPL_SSH:-ubuntu@192.168.1.193}"
DPL_PORT="${DPL_SSH_PORT:-2222}"

U=""
P=""

# OpenVPN Connect stores the password under service org.openvpn.client. / account=<profile id>
for id in 1700143330356 1719231711903 1668194320662 1663962279625; do
  P=$(security find-generic-password -s "org.openvpn.client." -a "$id" -w 2>/dev/null || true)
  if [ -n "$P" ]; then
    U="duc@careernowbrands.com"
    # older Tunnelblick/Connect profiles used short username Duc
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
  echo "unlock Keychain, or paste user/pass into dpl:~/.config/openvpn/cnb.auth" >&2
  exit 1
fi

printf '%s\n%s\n' "$U" "$P" | ssh -p "$DPL_PORT" "$DPL" 'cat > ~/.config/openvpn/cnb.auth && chmod 600 ~/.config/openvpn/cnb.auth'
echo "wrote dpl:~/.config/openvpn/cnb.auth — then: ssh -p $DPL_PORT $DPL 'systemctl --user enable --now cnb-openvpn'"
