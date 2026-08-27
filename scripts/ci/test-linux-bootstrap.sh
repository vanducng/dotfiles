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
bash -n "$ROOT/scripts/linux-homelab-root.sh" && pass "linux-homelab-root.sh parses" || fail "linux-homelab-root.sh syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/dpl-remote" && pass "dpl-remote parses" || fail "dpl-remote syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" && pass "cdp-chrome parses" || fail "cdp-chrome syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/install-chrome" && pass "install-chrome parses" || fail "install-chrome syntax"
bash -n "$ROOT/dotfiles/homelab/.config/homelab/install-tailscale" && pass "install-tailscale parses" || fail "install-tailscale syntax"
[[ -f "$ROOT/dotfiles/homelab/.config/systemd/user/homelab-cdp.service" ]] && pass "homelab-cdp.service exists" || fail "missing homelab-cdp.service"
[[ -f "$ROOT/dotfiles/homelab/.config/systemd/user/homelab-tailscale.service" ]] && pass "homelab-tailscale.service exists" || fail "missing homelab-tailscale.service"
[[ -f "$ROOT/dotfiles/homelab/.config/systemd/user/homelab-tailscale-up.service" ]] && pass "homelab-tailscale-up.service exists" || fail "missing homelab-tailscale-up.service"
[[ -f "$ROOT/dotfiles/homelab/.config/homelab/REMOTE.md" ]] && pass "REMOTE.md exists" || fail "missing REMOTE.md"
if grep -q 'remote-debugging-address=' "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" \
  && grep -q 'CDP_ADDR:-127.0.0.1' "$ROOT/dotfiles/homelab/.config/homelab/cdp-chrome" \
  && grep -q 'LocalForward 127.0.0.1:' "$ROOT/dotfiles/bin/.local/bin/dpl-remote"; then
  pass "CDP is loopback-only with SSH LocalForward"
else
  fail "CDP must bind loopback and be forwarded over SSH"
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

if [[ $FAIL -ne 0 ]]; then
  echo "test-linux-bootstrap: FAILED" >&2
  exit 1
fi
echo "test-linux-bootstrap: OK"
