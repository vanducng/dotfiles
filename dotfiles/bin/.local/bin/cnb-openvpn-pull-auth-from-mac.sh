#!/bin/sh
# Run ON THE MAC (needs GUI keychain). Pushes Tunnelblick VPN user/pass to dpl.
set -eu
U=$(security find-generic-password -s Tunnelblick-Auth-config -a username -w)
P=$(security find-generic-password -s Tunnelblick-Auth-config -a password -w)
printf '%s\n%s\n' "$U" "$P" | ssh -p 2222 ubuntu@192.168.1.193 'cat > ~/.config/openvpn/cnb.auth && chmod 600 ~/.config/openvpn/cnb.auth'
echo "wrote dpl:~/.config/openvpn/cnb.auth — then: ssh -p 2222 ubuntu@192.168.1.193 'systemctl --user start cnb-openvpn'"
