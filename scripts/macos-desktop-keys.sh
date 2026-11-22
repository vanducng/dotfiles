#!/usr/bin/env bash
# alt+1..9 -> native "Switch to Desktop N"; yabai's space --focus needs the
# scripting addition, which does not load on macOS 27.
set -euo pipefail

keycodes=(18 19 20 21 23 22 26 28 25)
for i in "${!keycodes[@]}"; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $((118 + i)) \
    "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>$((49 + i))</integer><integer>${keycodes[$i]}</integer><integer>524288</integer></array><key>type</key><string>standard</string></dict></dict>"
done
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
