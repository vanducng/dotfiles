#!/usr/bin/env bash
# Guard the Linux bootstrap against the failures seen on the Linux host.
# Checks on the homelab box's own scripts live in the private overlay's test.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "OK: $*"; }

[[ -f "$ROOT/scripts/linux-deps.sh" ]] && pass "linux-deps.sh exists" || fail "missing scripts/linux-deps.sh"
[[ -f "$ROOT/dotfiles/shell-linux/.config/mise/conf.d/linux.toml" ]] && pass "linux.toml exists" || fail "missing linux.toml"
# mise loads every conf.d file, so a Linux toolset in the common mise package would apply on macOS too.
[[ ! -e "$ROOT/dotfiles/mise/.config/mise/conf.d/linux.toml" ]] && pass "linux.toml is not in the common mise package" || fail "linux.toml is back in the common mise package"
[[ -f "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" ]] && pass "linux.sh exists" || fail "missing linux.sh"

bash -n "$ROOT/scripts/linux-deps.sh" && pass "linux-deps.sh parses" || fail "linux-deps.sh syntax"
bash -n "$ROOT/scripts/linux-desktop.sh" && pass "linux-desktop.sh parses" || fail "linux-desktop.sh syntax"
bash -n "$ROOT/scripts/pi-home-layout.sh" && pass "pi-home-layout.sh parses" || fail "pi-home-layout.sh syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/git-sync-repos" && pass "git-sync-repos parses" || fail "git-sync-repos syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/git-fetch-repos" && pass "git-fetch-repos parses" || fail "git-fetch-repos syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/git-fetch-cwd" && pass "git-fetch-cwd parses" || fail "git-fetch-cwd syntax"
bash -n "$ROOT/dotfiles/bin/.local/bin/ensure-home-managed-repos" && pass "ensure-home-managed-repos parses" || fail "ensure-home-managed-repos syntax"
[[ -f "$ROOT/dotfiles/launchd/Library/LaunchAgents/dev.vanducng.git-fetch-repos.plist" ]] && pass "git-fetch-repos launchd plist exists" || fail "missing git-fetch-repos plist"
if grep -q 'sync_main firstmate "${HOME}/firstmate"' "$ROOT/dotfiles/bin/.local/bin/git-sync-repos" \
  && grep -q 'ensure-home-managed-repos' "$ROOT/dotfiles/bin/.local/bin/git-sync-repos" \
  && grep -q 'HOME}/firstmate' "$ROOT/dotfiles/bin/.local/bin/ensure-home-managed-repos" \
  && grep -q 'ensure-home-repos' "$ROOT/Makefile"; then
  pass "firstmate managed under HOME on Mac and Linux"
else
  fail "firstmate must be ensured/synced at \$HOME/firstmate on Mac and Linux"
fi
# Positive checks on non-comment lines; negative checks use POSIX word edges (no GNU \\b).
_fetch_repos_code=$(grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/bin/.local/bin/git-fetch-repos" || true)
_fetch_cwd_code=$(grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/bin/.local/bin/git-fetch-cwd" || true)
_forbidden='(^|[^[:alnum:]_])(checkout|merge|stash|pull|rebase)([^[:alnum:]_]|$)'
if awk '
  /uname -s.*" == Darwin/ { in_darwin=1; next }
  in_darwin && /fi$/ { in_darwin=0 }
  in_darwin && /git-fetch-cwd/ { found=1 }
  END { exit found ? 0 : 1 }
' "$ROOT/dotfiles/zsh/.zshrc" \
  && grep -q 'git-fetch-cwd' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" \
  && printf '%s\n' "$_fetch_repos_code" | grep -q 'fetch --prune --quiet origin' \
  && printf '%s\n' "$_fetch_cwd_code" | grep -q 'GIT_FETCH_CWD_TTL_SEC' \
  && printf '%s\n' "$_fetch_repos_code" | grep -q 'ConnectTimeout=10' \
  && ! printf '%s\n' "$_fetch_repos_code" | grep -qE "$_forbidden" \
  && ! printf '%s\n' "$_fetch_cwd_code" | grep -qE "$_forbidden" \
  && ! printf '%s\n' "$_fetch_repos_code" | grep -qE 'github\.com[:/]'; then
  pass "git-fetch-repos is fetch-only with shell debounce hooks"
else
  fail "git-fetch must stay fetch-only and hook both Mac zsh and Linux shells"
fi
unset _fetch_repos_code _fetch_cwd_code _forbidden
if grep -q 'personal/saas/cli-proxy/code-01-api-key' "$ROOT/dotfiles/bin/.local/bin/cli-proxy-key" \
  && grep -q 'cli-proxy/api-key' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh"; then
  pass "Linux shells read the CLIProxyAPI key"
else
  fail "cli-proxy-key and linux.sh must read the CLIProxyAPI key"
fi
bash -n "$ROOT/scripts/linux-gnome-keys.sh" && pass "linux-gnome-keys.sh parses" || fail "linux-gnome-keys.sh syntax"
bash -n "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" && pass "linux.sh parses" || fail "linux.sh syntax"
bash -n "$ROOT/dotfiles/sway/.config/sway/scripts/focus-or-launch" && pass "focus-or-launch parses" || fail "focus-or-launch syntax"
if python3 -c "import ast, pathlib; ast.parse(pathlib.Path('$ROOT/dotfiles/sway/.config/sway/scripts/autotile').read_text())"; then
  pass "autotile python"
else
  fail "autotile python"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/shell-linux/.config/mise/conf.d/linux.toml" | grep -q 'aqua:tmux/tmux'; then
  fail "linux.toml still uses aqua:tmux/tmux (not in aqua registry)"
else
  pass "linux.toml does not use aqua:tmux/tmux"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/shell-linux/.config/mise/conf.d/linux.toml" | grep -qE '^[[:space:]]*git-delta[[:space:]]*='; then
  fail "linux.toml uses git-delta (not a mise registry name)"
else
  pass "linux.toml does not use git-delta"
fi

if grep -vE '^[[:space:]]*#' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" | grep -qE '/opt/homebrew|/Users/'; then
  fail "linux.sh contains macOS-only paths"
else
  pass "linux.sh has no macOS-only paths"
fi
if grep -Fq '\033[<u' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" \
  && grep -q '^ssh()' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh"; then
  pass "linux.sh restores kitty keyboard protocol after ssh"
else
  fail "linux.sh must wrap ssh and pop kitty CSI-u flags"
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
if echo "$folders" | grep -qx yabai; then fail "Linux stow includes yabai"; else pass "Linux stow excludes yabai"; fi
if echo "$folders" | grep -qx skhd; then fail "Linux stow includes skhd"; else pass "Linux stow excludes skhd"; fi
if echo "$folders" | grep -qx karabiner; then fail "Linux stow includes karabiner"; else pass "Linux stow excludes karabiner"; fi
if echo "$folders" | grep -qx grok; then fail "Linux stow auto-includes grok"; else pass "Linux stow skips grok (opt-in)"; fi

darwin="$(make --no-print-directory -s -C "$ROOT" PLATFORM=Darwin stow-folders)"
echo "$darwin" | grep -qx yabai && pass "Darwin stow includes yabai" || fail "Darwin stow missing yabai"

mason_lua="$ROOT/dotfiles/nvim/.config/nvim/lua/plugins/mason.lua"
if grep -qE "['\"]tree-sitter-cli['\"]" "$mason_lua"; then
  fail "mason.lua must not ensure_installed tree-sitter-cli (linux-x64 needs GLIBC 2.39)"
else
  pass "mason.lua does not mason-install tree-sitter-cli"
fi
if grep -q 'tree-sitter-cli' "$ROOT/dotfiles/nvim/.config/nvim/lua/lazy_setup.lua" \
  && grep -q 'GLIBC' "$ROOT/dotfiles/nvim/.config/nvim/lua/lazy_setup.lua"; then
  pass "lazy_setup drops a non-runnable mason tree-sitter-cli"
else
  fail "lazy_setup.lua missing mason tree-sitter-cli self-heal"
fi
if grep -q 'install_tree_sitter_cli' "$ROOT/scripts/linux-deps.sh" \
  && grep -q 'cargo install tree-sitter-cli' "$ROOT/scripts/linux-deps.sh"; then
  pass "linux-deps installs tree-sitter-cli via cargo"
else
  fail "linux-deps must cargo-install tree-sitter-cli for Ubuntu 22.04 glibc"
fi

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
  && grep -q 'keybind = alt+digit_1=unbind' "$ghosttycfg" \
  && grep -q 'keybind = alt+digit_9=unbind' "$ghosttycfg"; then
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
if grep -q 'command = "herdr-sessions"' "$herdrcfg" && grep -q 'key = "prefix+s"' "$herdrcfg"; then
  pass "herdr session picker is bound to prefix+s"
else
  fail "herdr missing herdr-sessions keybind"
fi
kittycfg="$ROOT/dotfiles/kitty/.config/kitty/kitty.conf"
kitty_ok=1
grep -qE '^macos_option_as_alt yes$' "$kittycfg" || kitty_ok=0
for i in 1 2 3 4 5 6 7 8 9; do
  code=$((48 + i))
  grep -qF "map ctrl+alt+${i} send_text all \x1b[${code};7u" "$kittycfg" || kitty_ok=0
done
if [[ $kitty_ok -eq 1 ]]; then
  pass "kitty forwards ctrl+alt+1..9 to Herdr as CSI-u"
else
  fail "kitty missing Herdr workspace CSI-u maps or macos_option_as_alt"
fi

linux_toml="$ROOT/dotfiles/shell-linux/.config/mise/conf.d/linux.toml"
if grep -q 'libc = "musl"' "$linux_toml"; then
  pass "linux.toml prefers musl aqua binaries"
else
  fail "linux.toml must set libc = musl for Ubuntu 22.04"
fi
if grep -q 'load-atuin-aliases.sh' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" \
  && grep -q 'atuin/key' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh" \
  && grep -q 'atuin init' "$ROOT/dotfiles/shell-linux/.config/shell/linux.sh"; then
  pass "linux.sh loads atuin aliases and skips init without a key"
else
  fail "linux.sh must source load-atuin-aliases.sh and guard atuin init on the key file"
fi
alias_loader="$ROOT/dotfiles/shell-linux/.config/shell/load-atuin-aliases.sh"
alias_src="$ROOT/dotfiles/atuin/.config/atuin/aliases.sh"
if [[ -f "$alias_loader" ]] && grep -q "atuin dotfiles alias set 'gp' 'git pull'" "$alias_src"; then
  bash -n "$alias_loader" && pass "load-atuin-aliases.sh parses" || fail "load-atuin-aliases.sh syntax"
  alias_out="$(ATUIN_ALIASES_FILE="$alias_src" bash -c "alias esh='/Users/example/tool'; . \"$alias_loader\"; alias")"
  if grep -q "gp='git pull'" <<<"$alias_out" && grep -q "v='nvim'" <<<"$alias_out" && grep -q "g='git'" <<<"$alias_out"; then
    pass "load-atuin-aliases.sh defines gp=git pull, v=nvim, g=git"
  else
    fail "load-atuin-aliases.sh did not define gp/v/g"
  fi
  if grep -q '/Users/' <<<"$alias_out"; then
    fail "load-atuin-aliases.sh leaked macOS /Users/ aliases"
  else
    pass "load-atuin-aliases.sh skips macOS-only aliases"
  fi
else
  fail "missing alias loader or gp=git pull in aliases.sh"
fi

if [[ $FAIL -ne 0 ]]; then
  echo "test-linux-bootstrap: FAILED" >&2
  exit 1
fi
echo "test-linux-bootstrap: OK"
