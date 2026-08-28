#!/usr/bin/env bash
# Guard the Linux bootstrap against the failures seen on host dpl.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "OK: $*"; }

[[ -f "$ROOT/scripts/linux-deps.sh" ]] && pass "linux-deps.sh exists" || fail "missing scripts/linux-deps.sh"
[[ -f "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" ]] && pass "linux.toml exists" || fail "missing linux.toml"
[[ -f "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" ]] && pass "linux.sh exists" || fail "missing linux.sh"
[[ -f "$ROOT/dotfiles/git/.config/git/work.gitconfig" ]] && pass "work.gitconfig exists" || fail "missing work.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-crashchat.gitconfig" ]] && pass "work-crashchat.gitconfig exists" || fail "missing work-crashchat.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-ab-spectrum.gitconfig" ]] && pass "work-ab-spectrum.gitconfig exists" || fail "missing work-ab-spectrum.gitconfig"
[[ -f "$ROOT/dotfiles/git/.config/git/work-bhcoe.gitconfig" ]] && pass "work-bhcoe.gitconfig exists" || fail "missing work-bhcoe.gitconfig"

bash -n "$ROOT/scripts/linux-deps.sh" && pass "linux-deps.sh parses" || fail "linux-deps.sh syntax"
bash -n "$ROOT/scripts/linux-desktop.sh" && pass "linux-desktop.sh parses" || fail "linux-desktop.sh syntax"
bash -n "$ROOT/scripts/linux-homelab.sh" && pass "linux-homelab.sh parses" || fail "linux-homelab.sh syntax"
bash -n "$ROOT/scripts/pi-home-layout.sh" && pass "pi-home-layout.sh parses" || fail "pi-home-layout.sh syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/relocate-stores" && pass "relocate-stores parses" || fail "relocate-stores syntax"
relocate_stores="$ROOT/dotfiles/homelab/.config/homelab/relocate-stores"
if grep -qE 'relocate "\$\{HOME\}/\.pi"' "$relocate_stores"; then
  fail "relocate-stores still relocates whole ~/.pi"
elif grep -q '.pi/agent/npm' "$relocate_stores" \
  && grep -q '.pi/agent/sessions' "$relocate_stores" \
  && grep -q '.pi/agent/git' "$relocate_stores"; then
  pass "relocate-stores nests pi npm/sessions/git"
else
  fail "relocate-stores missing nested pi runtime dirs"
fi
bash -n "$ROOT/scripts/linux-homelab-root.sh" && pass "linux-homelab-root.sh parses" || fail "linux-homelab-root.sh syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/dpl-remote" && pass "dpl-remote parses" || fail "dpl-remote syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" && pass "cdp-chrome parses" || fail "cdp-chrome syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/install-chrome" && pass "install-chrome parses" || fail "install-chrome syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/install-tailscale" && pass "install-tailscale parses" || fail "install-tailscale syntax"
[[ -f "$ROOT/dotfiles/homelab/.config/systemd/user/homelab-cdp.service" ]] && pass "homelab-cdp.service exists" || fail "missing homelab-cdp.service"
[[ -f "$ROOT/dotfiles/homelab/.config/systemd/user/homelab-tailscale.service" ]] && pass "homelab-tailscale.service exists" || fail "missing homelab-tailscale.service"
[[ -f "$ROOT/dotfiles/homelab/.config/homelab/REMOTE.md" ]] && pass "REMOTE.md exists" || fail "missing REMOTE.md"
remote_cli="$ROOT/dotfiles/bin/.local/bin/dpl-remote"
mac_config="$(WAN6_IP=2001:db8::10 LAN_IP=192.0.2.10 bash "$remote_cli" mac-config)"
shell_block="$(printf '%s\n' "$mac_config" | awk '/^Host dpl dpl-v6 dpl-ts$/{capture=1; next} /^Host dpl$/{capture=0} capture')"
if grep -q 'remote-debugging-address=' "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" \
  && grep -q 'CDP_ADDR:-127.0.0.1' "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" \
  && grep -q '^Host dpl-ts-tunnel$' <<<"$mac_config" \
  && grep -q 'LocalForward 127.0.0.1:9222 127.0.0.1:9222' <<<"$mac_config" \
  && ! grep -q 'LocalForward' <<<"$shell_block"; then
  pass "CDP is loopback-only with dedicated SSH tunnel aliases"
else
  fail "CDP must bind loopback and use dedicated SSH tunnel aliases"
fi
if grep -q 'XDG_RUNTIME_DIR=' "$remote_cli" \
  && grep -q 'DBUS_SESSION_BUS_ADDRESS=' "$remote_cli"; then
  pass "dpl-remote initializes the user systemd bus over SSH"
else
  fail "dpl-remote must initialize the user systemd bus over SSH"
fi
sshd_config="$ROOT/dotfiles/homelab/.config/sshd/sshd_config"
if grep -q '^PermitUserEnvironment yes$' "$sshd_config" \
  && ! grep -qE '^SetEnv PATH=.*(/Users/|/home/)' "$sshd_config" \
  && grep -q '\.ssh/environment' "$ROOT/scripts/linux-homelab.sh"; then
  pass "user SSH PATH is generated from HOME at install time"
else
  fail "user SSH PATH must be generated from HOME at install time"
fi
if grep -qE 'serve --bg --tcp' "$ROOT/dotfiles/bin/.local/bin/dpl-remote" \
  && grep -qi 'not using Funnel' "$ROOT/dotfiles/bin/.local/bin/dpl-remote"; then
  pass "internet path is Tailscale serve, not Funnel"
else
  fail "dpl-remote must serve on the tailnet without Funnel"
fi
bash -n "$ROOT/scripts/linux-gnome-keys.sh" && pass "linux-gnome-keys.sh parses" || fail "linux-gnome-keys.sh syntax"
bash -n "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" && pass "linux.sh parses" || fail "linux.sh syntax"
bash -n "$ROOT/dotfiles/sway/.config/sway/scripts/focus-or-launch" && pass "focus-or-launch parses" || fail "focus-or-launch syntax"
if python3 -c "import ast, pathlib; ast.parse(pathlib.Path('$ROOT/dotfiles/sway/.config/sway/scripts/autotile').read_text())"; then
  pass "autotile python"
else
  fail "autotile python"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" | grep -q 'aqua:tmux/tmux'; then
  fail "linux.toml still uses aqua:tmux/tmux (not in aqua registry)"
else
  pass "linux.toml does not use aqua:tmux/tmux"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" | grep -qE '^[[:space:]]*git-delta[[:space:]]*='; then
  fail "linux.toml uses git-delta (not a mise registry name)"
else
  pass "linux.toml does not use git-delta"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" | grep -qE '/opt/homebrew|/Users/'; then
  fail "linux.sh contains macOS-only paths"
else
  pass "linux.sh has no macOS-only paths"
fi

if grep -E '^[[:space:]]*email[[:space:]]*=' \
  "$ROOT/dotfiles/git/.config/git/work.gitconfig" \
  "$ROOT/dotfiles/git/.config/git/work-bhcoe.gitconfig" \
  "$ROOT/dotfiles/git/.config/git/work-ab-spectrum.gitconfig"; then
  fail "tracked work gitconfigs must not set user.email (use *.local.gitconfig)"
else
  pass "tracked work gitconfigs do not set user.email"
fi
if grep -q 'work.local.gitconfig' "$ROOT/dotfiles/git/.config/git/work.gitconfig" \
  && grep -q 'work-bhcoe.local.gitconfig' "$ROOT/dotfiles/git/.config/git/work-bhcoe.gitconfig" \
  && grep -q 'work-ab-spectrum.local.gitconfig' "$ROOT/dotfiles/git/.config/git/work-ab-spectrum.gitconfig"; then
  pass "work gitconfigs include machine-local overlays"
else
  fail "work gitconfigs missing machine-local overlay includes"
fi
if grep -q 'me@vanducng.dev' "$ROOT/dotfiles/git/.config/git/work-crashchat.gitconfig"; then
  pass "work-crashchat.gitconfig has personal email"
else
  fail "work-crashchat.gitconfig missing personal email"
fi
example="$ROOT/dotfiles/git/.config/git/gitconfig.linux.example"
if grep -q 'gitdir:~/work/git/crashchat/' "$example" && grep -q 'gitdir:~/work/git/ab-spectrum/' "$example" && grep -q 'gitdir:~/work/git/bhcoe/' "$example"; then
  pass "gitconfig.linux.example has per-company includeIf"
else
  fail "gitconfig.linux.example missing per-company includeIf"
fi
if grep -qE 'includeIf "gitdir:~/work/"' "$example"; then
  fail "gitconfig.linux.example still has catch-all ~/work/ includeIf"
else
  pass "gitconfig.linux.example has no catch-all ~/work/ includeIf"
fi

folders="$(make --no-print-directory -s -C "$ROOT" PLATFORM=Linux stow-folders)"
echo "$folders" | grep -qx nvim && pass "Linux stow includes nvim" || fail "Linux stow missing nvim"
echo "$folders" | grep -qx herdr && pass "Linux stow includes herdr" || fail "Linux stow missing herdr"
echo "$folders" | grep -qx git && pass "Linux stow includes git" || fail "Linux stow missing git"
echo "$folders" | grep -qx claude && pass "Linux stow includes claude" || fail "Linux stow missing claude"
echo "$folders" | grep -qx kitty && pass "Linux stow includes kitty" || fail "Linux stow missing kitty"
echo "$folders" | grep -qx shell-linux && pass "Linux stow includes shell-linux" || fail "Linux stow missing shell-linux"
echo "$folders" | grep -qx sway && pass "Linux stow includes sway" || fail "Linux stow missing sway"
echo "$folders" | grep -qx ghostty && pass "Linux stow includes ghostty" || fail "Linux stow missing ghostty"
echo "$folders" | grep -qx waybar && pass "Linux stow includes waybar" || fail "Linux stow missing waybar"
echo "$folders" | grep -qx homelab && pass "Linux stow includes homelab" || fail "Linux stow missing homelab"
if echo "$folders" | grep -qx yabai; then fail "Linux stow includes yabai"; else pass "Linux stow excludes yabai"; fi
if echo "$folders" | grep -qx skhd; then fail "Linux stow includes skhd"; else pass "Linux stow excludes skhd"; fi
if echo "$folders" | grep -qx karabiner; then fail "Linux stow includes karabiner"; else pass "Linux stow excludes karabiner"; fi
if echo "$folders" | grep -qx grok; then fail "Linux stow auto-includes grok"; else pass "Linux stow skips grok (opt-in)"; fi

darwin="$(make --no-print-directory -s -C "$ROOT" PLATFORM=Darwin stow-folders)"
echo "$darwin" | grep -qx yabai && pass "Darwin stow includes yabai" || fail "Darwin stow missing yabai"

if grep -q 'linux-deps' "$ROOT/Makefile"; then
  pass "Makefile has linux-deps target"
else
  fail "Makefile missing linux-deps"
fi
if grep -q 'linux-desktop' "$ROOT/Makefile"; then
  pass "Makefile has linux-desktop target"
else
  fail "Makefile missing linux-desktop"
fi
swaycfg="$ROOT/dotfiles/sway/.config/sway/config"
if grep -q 'xkb_options caps:hyper' "$swaycfg" && grep -q 'bindsym \$meh+a' "$swaycfg" && grep -q 'bindsym \$alt+1' "$swaycfg"; then
  pass "sway config maps caps hyper, meh launchers, alt workspaces"
else
  fail "sway config missing skhd-equivalent binds"
fi
if grep -q 'keybind = super+s>v=' "$ROOT/dotfiles/ghostty/.config/ghostty/config"; then
  pass "ghostty has Linux super+s split leader"
else
  fail "ghostty missing Linux super+s binds"
fi
ghosttycfg="$ROOT/dotfiles/ghostty/.config/ghostty/config"
if grep -q 'keybind = shift+arrow_right=unbind' "$ghosttycfg" \
  && grep -q 'keybind = alt+1=unbind' "$ghosttycfg" \
  && grep -q 'keybind = alt+digit_1=unbind' "$ghosttycfg"; then
  pass "ghostty unbinds shift+arrows and alt+1..9 for Herdr"
else
  fail "ghostty missing Herdr key pass-through unbinds"
fi
herdrcfg="$ROOT/dotfiles/herdr/.config/herdr/config.toml"
if grep -q 'prefix+1..9' "$herdrcfg" && grep -q 'previous_workspace' "$herdrcfg"; then
  pass "herdr workspace keys include prefix+1..9 and previous_workspace"
else
  fail "herdr missing portable workspace keybinds"
fi

if [[ $FAIL -ne 0 ]]; then
  echo "test-linux-bootstrap: FAILED" >&2
  exit 1
fi
echo "test-linux-bootstrap: OK"
