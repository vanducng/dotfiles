#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/dotfiles/bin/.local/bin/sysmon"
NOTES="$ROOT/dotfiles/bin/.local/bin/notes-vault"
CATALOG="$ROOT/scripts/tinycast/custom-commands.json"
SETUP="$ROOT/scripts/tinycast-setup.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

[[ -x "$SCRIPT" ]] || chmod +x "$SCRIPT"
[[ -x "$NOTES" ]] || chmod +x "$NOTES"
bash -n "$SCRIPT" || fail "sysmon syntax"
bash -n "$NOTES" || fail "notes-vault syntax"
pass "sysmon parses"
grep -q 'seq 1 25' "$SCRIPT" && fail "sysmon still waits in a yabai poll loop"
grep -q 'single-instance' "$SCRIPT" || fail "sysmon should reuse one kitty process"
grep -q 'instance-group sysmon' "$SCRIPT" || fail "sysmon should isolate its kitty group"
grep -q 'find_window_ids' "$SCRIPT" || fail "sysmon should locate an existing overlay by title"
grep -q 'os.setsid' "$SCRIPT" || fail "sysmon should detach kitty from the launcher process group"
grep -q 'unset NO_COLOR FORCE_COLOR' "$SCRIPT" || fail "sysmon should drop NO_COLOR before launching kitty"
grep -q 'Ghostty.app' "$SCRIPT" || fail "sysmon should drop Ghostty TERMINFO so kitty terminfo resolves"
grep -q 'confirm_os_window_close 0' "$SCRIPT" || fail "sysmon should close overlays without a kitty confirm"
grep -q 'confirm_os_window_close=' "$SCRIPT" && fail "kitty --override uses spaces, not equals"
grep -q -- '--config NONE' "$SCRIPT" && fail "sysmon must load kitty.conf so nvim gets the nerd font"
grep -q 'hide_window_decorations no' "$SCRIPT" || fail "sysmon overlay should keep the kitty title bar"
grep -q 'remember_window_size no' "$SCRIPT" || fail "sysmon overlay should not restore a previous kitty size"
grep -q 'cmd_scratch' "$SCRIPT" && fail "sysmon should not expose a scratch session"
grep -q 'meh - f : "$HOME/.local/bin/sysmon" center' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" \
  || fail "skhd meh-f should raise the sysmon overlay"
grep -q 'set visible of' "$SCRIPT" && fail "hiding the kitty process activates the next app"
grep -q 'cmd + alt - f' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" \
  && fail "cmd+opt dock belongs on Tinycast/Karabiner, not skhd"
KARABINER_DOCK="$ROOT/dotfiles/karabiner/.config/karabiner/assets/complex_modifications/sysmon-dock.json"
[[ -f "$KARABINER_DOCK" ]] || fail "karabiner sysmon-dock rule missing"
grep -q 'sysmon' "$KARABINER_DOCK" && grep -q ' dock' "$KARABINER_DOCK" \
  || fail "karabiner sysmon-dock should run sysmon dock"
grep -q '/Users/' "$KARABINER_DOCK" && fail "karabiner sysmon-dock has a personal home path"
grep -q '1:4:3:0:1:1' "$SCRIPT" || fail "sysmon dock should use a 1/4 right grid"
grep -q '1:4:0:0:1:1' "$SCRIPT" || fail "sysmon dock-left should use a 1/4 left grid"
grep -q 'dock-left' "$KARABINER_DOCK" || fail "karabiner should dock left with cmd+opt+V"
grep -q '"key_code": "v"' "$KARABINER_DOCK" || fail "karabiner left dock should bind v"
grep -q 'app="\^kitty\$" title="\^(sysmon|notes-vault)"    manage=off sticky=on sub-layer=above grid=6:6:1:1:4:4' \
  "$ROOT/dotfiles/yabai/.config/yabai/yabairc" || fail "yabai should float the kitty overlay above other apps"
grep -q 'app="\^kitty\$" title!="\^(sysmon.\*|notes-vault)?\$" space=15' \
  "$ROOT/dotfiles/yabai/.config/yabai/yabairc" || fail "yabai must not send untitled or overlay kitty windows to space 15"
grep -q -- '-f "$conf"' "$SCRIPT" || fail "sysmon should load tmux.conf"
grep -q 'SYSMON_TMUX_SOCKET' "$SCRIPT" || fail "sysmon should use a dedicated tmux socket"
grep -q '/opt/homebrew/bin' "$SCRIPT" || fail "sysmon must put Homebrew on PATH"
pass "sysmon returns without polling yabai"
grep -q 'System: Processes' "$SETUP" || fail "setup missing processes command"
grep -q 'System: Disk' "$SETUP" || fail "setup missing disk command"
grep -q 'Notes: Vault' "$SETUP" || fail "setup missing vault command"
grep -q 'System: Dock' "$SETUP" || fail "setup missing dock command"
grep -q 'catalog_id' "$SETUP" || fail "setup hardcodes command ids"
grep -q 'combo 1 2304' "$SETUP" && fail "processes hotkey still on cmd+opt+S"
grep -q 'combo 2 2304' "$SETUP" && fail "disk hotkey still on cmd+opt+D"
grep -q 'DOCK_ID}" -string "$(combo 5 2304)"' "$SETUP" \
  || fail "dock hotkey should be Tinycast cmd+opt+G"
grep -q 'LEFT_ID}" -string "$(combo 9 2304)"' "$SETUP" \
  || fail "left dock hotkey should be Tinycast cmd+opt+V"
grep -q 'combo 3 2304' "$SETUP" && fail "cmd+opt+F is still bound (Cursor replace)"
grep -q 'VAULT_ID}" -string "$(combo 5 2304)"' "$SETUP" \
  && fail "vault hotkey should not use cmd+opt+G"
grep -q 'combo 32 2304' "$SETUP" && fail "disk hotkey still on cmd+opt+U"
grep -q 'combo 45 2304' "$SETUP" && fail "vault hotkey still on cmd+opt+N"
pass "setup derives sysmon ids"

command -v python3 >/dev/null 2>&1 || fail "python3 is required"
python3 - "$CATALOG" <<'PY' || fail "sysmon catalog schema"
import json
import sys
from pathlib import Path

required = {
    "c4d8e2a1-7b19-4f3c-9e60-2a1d8c5b4f77": ("System: Processes", "processes"),
    "d9e1f3b2-8c20-4a4d-af71-3b2e9d6c5a88": ("System: Disk", "disk"),
    "e2a4c6d8-9b31-4f5e-8a72-4c3f0e7d6b99": ("Notes: Vault", "vault"),
    "a1c3e5f7-2d43-4b6a-8c94-6e5f2a9d8b11": ("System: Dock", "dock"),
    "f3b7a9c1-4e52-4d8b-9a16-8c0d5e2b7a44": ("System: Dock Left", "dock-left"),
}
commands = json.loads(Path(sys.argv[1]).read_text())
by_id = {item["id"]: item for item in commands}
for command_id, (name, verb) in required.items():
    command = by_id.get(command_id)
    if not command:
        raise SystemExit(f"missing {command_id}")
    if command["name"] != name:
        raise SystemExit(f"{command_id} name {command['name']!r} != {name!r}")
    if f'sysmon" {verb}' not in command["command"] and f'sysmon\\" {verb}' not in command["command"]:
        raise SystemExit(f"{name} command does not invoke {verb}")
    if "/Users/" in command["command"] or "/home/" in command["command"]:
        raise SystemExit(f"{name} command has a personal home path")
    if command["requiresConfirmation"] or command["loadsShellEnvironment"]:
        raise SystemExit(f"{name} must run without confirmation or rc load")
PY
pass "custom-commands.json sysmon"

workdir="$(mktemp -d "${TMPDIR:-/tmp}/sysmon-test.XXXXXX")"
trap 'rm -rf -- "$workdir"' EXIT

cat >"$workdir/btop" <<'EOF'
#!/usr/bin/env bash
echo btop
EOF
cat >"$workdir/dua" <<'EOF'
#!/usr/bin/env bash
echo dua "$@"
EOF
cat >"$workdir/nvim" <<'EOF'
#!/usr/bin/env bash
echo nvim "$@"
EOF
cat >"$workdir/tmux" <<'EOF'
#!/usr/bin/env bash
echo tmux "$@"
EOF
chmod +x "$workdir/btop" "$workdir/dua" "$workdir/nvim" "$workdir/tmux"

export SYSMON_BTOP="$workdir/btop"
export SYSMON_DUA="$workdir/dua"
export SYSMON_NVIM="$workdir/nvim"
export SYSMON_TMUX="$workdir/tmux"
export SYSMON_OPEN=1
export HOME="$workdir/home"
mkdir -p "$HOME"
touch "$HOME/.tmux.conf"

out="$("$SCRIPT" processes)"
printf '%s\n' "$out" | grep -q 'session: sysmon' || fail "processes session: $out"
printf '%s\n' "$out" | grep -q " -f $HOME/.tmux.conf" || fail "processes missing tmux.conf: $out"
printf '%s\n' "$out" | grep -q 'window: 1 processes' || fail "processes window: $out"
printf '%s\n' "$out" | grep -q "$workdir/btop" || fail "processes missing btop: $out"
printf '%s\n' "$out" | grep -q 'select: sysmon:1' || fail "processes missing select: $out"
printf '%s\n' "$out" | grep -q -- '-L sysmon attach -t sysmon' || fail "processes missing attach: $out"
printf '%s\n' "$out" | grep -q 'open: sysmon-hub' || fail "processes overlay title: $out"
printf '%s\n' "$out" | grep -q 'sysmon-processes' && fail "processes still uses a per-app session: $out"
pass "processes keeps btop in window 1"

out="$("$SCRIPT")"
printf '%s\n' "$out" | grep -q 'show: sysmon' || fail "bare sysmon show: $out"
printf '%s\n' "$out" | grep -q 'place: 6:6:1:1:4:4' || fail "bare sysmon should center: $out"
printf '%s\n' "$out" | grep -q -- '-L sysmon attach -t sysmon' || fail "bare sysmon missing attach: $out"
printf '%s\n' "$out" | grep -q 'window:' && fail "bare sysmon should not select a window: $out"
printf '%s\n' "$out" | grep -q 'select:' && fail "bare sysmon should keep the last window: $out"
pass "bare sysmon raises the last window"

out="$("$SCRIPT" dock)"
printf '%s\n' "$out" | grep -q 'place: 1:4:3:0:1:1' || fail "dock place: $out"
printf '%s\n' "$out" | grep -q 'window:' && fail "dock should not select a window: $out"
pass "dock raises the last window on the right"

out="$("$SCRIPT" dock-left)"
printf '%s\n' "$out" | grep -q 'place: 1:4:0:0:1:1' || fail "dock-left place: $out"
printf '%s\n' "$out" | grep -q 'window:' && fail "dock-left should not select a window: $out"
pass "dock-left raises the last window on the left"

out="$("$SCRIPT" dia)"
printf '%s\n' "$out" | grep -q 'dia: 0.25' || fail "dia ratio: $out"
printf '%s\n' "$out" | grep -q 'side: left' || fail "dia side: $out"
printf '%s\n' "$out" | grep -q 'app: Dia,ego lite' || fail "split apps: $out"
printf '%s\n' "$out" | grep -q 'open: sysmon-hub' || fail "dia should raise the hub: $out"
out="$("$SCRIPT" dia-right)"
printf '%s\n' "$out" | grep -q 'side: right' || fail "dia-right side: $out"
grep -q 'cmd + shift + alt - v : "$HOME/.local/bin/sysmon" dia-left "Dia"' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" || fail "skhd V should split Dia left"
grep -q 'cmd + shift + alt - g : "$HOME/.local/bin/sysmon" dia-right "Dia"' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" || fail "skhd G should split Dia right"
grep -q 'cmd + shift + alt - r : "$HOME/.local/bin/sysmon" dia-left "ego lite"' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" || fail "skhd R should split Ego left"
grep -q 'cmd + shift + alt - t : "$HOME/.local/bin/sysmon" dia-right "ego lite"' "$ROOT/dotfiles/skhd/.config/skhd/skhdrc" || fail "skhd T should split Ego right"
pass "split works for any configured app, left or right"

out="$("$SCRIPT" disk)"
printf '%s\n' "$out" | grep -q 'session: sysmon' || fail "disk session: $out"
printf '%s\n' "$out" | grep -q 'window: 2 disk' || fail "disk window: $out"
printf '%s\n' "$out" | grep -q "$workdir/dua" || fail "disk missing dua: $out"
printf '%s\n' "$out" | grep -q " i $HOME" || fail "disk missing home path: $out"
printf '%s\n' "$out" | grep -q 'select: sysmon:2' || fail "disk missing select: $out"
printf '%s\n' "$out" | grep -q -- '-L sysmon attach -t sysmon' || fail "disk missing attach: $out"
pass "disk keeps dua in window 2"

mkdir -p "$workdir/scan"
out="$("$SCRIPT" disk "$workdir/scan")"
printf '%s\n' "$out" | grep -q " i $workdir/scan" || fail "disk path: $out"
pass "disk accepts a path"
out="$("$SCRIPT" disk "")"
printf '%s\n' "$out" | grep -q " i $HOME" || fail "empty disk path should use home: $out"
pass "empty disk path falls back to home"
if "$SCRIPT" disk "$workdir/missing-disk" >/dev/null 2>&1; then
  fail "disk accepted a missing path"
fi
pass "disk rejects a missing path"

export OBSIDIAN_VAULT="$workdir/vault"
mkdir -p "$OBSIDIAN_VAULT"
out="$("$SCRIPT" vault)"
printf '%s\n' "$out" | grep -q 'session: sysmon' || fail "vault session: $out"
printf '%s\n' "$out" | grep -q 'window: 3 vault' || fail "vault window: $out"
printf '%s\n' "$out" | grep -q "$workdir/nvim" || fail "vault missing nvim: $out"
printf '%s\n' "$out" | grep -q -- '-lc' || fail "vault should start nvim via login zsh: $out"
printf '%s\n' "$out" | grep -q '.zshrc' || fail "vault should source zshrc for AstroNvim: $out"
printf '%s\n' "$out" | grep -q 'select: sysmon:3' || fail "vault missing select: $out"
printf '%s\n' "$out" | grep -q -- '-L sysmon attach -t sysmon' || fail "vault missing attach: $out"
pass "vault opens nvim in window 3"

out="$(SYSMON_FOCUSED=1 "$SCRIPT" processes)"
printf '%s\n' "$out" | grep -q 'focus: sysmon-hub' || fail "reuse: $out"
printf '%s\n' "$out" | grep -q 'select: sysmon:1' || fail "reuse missing select: $out"
printf '%s\n' "$out" | grep -q 'open:' && fail "reuse opened another window: $out"
pass "processes reuses the hub overlay"

out="$("$NOTES")"
printf '%s\n' "$out" | grep -q 'window: 3 vault' || fail "notes-vault wrapper: $out"
printf '%s\n' "$out" | grep -q "$workdir/nvim" || fail "notes-vault missing nvim: $out"
pass "notes-vault delegates to sysmon vault"

if grep -R -nE '/Users/|/home/[a-z]' "$SCRIPT" "$NOTES" "$CATALOG" "$SETUP" >/dev/null; then
  fail "personal home path leaked into managed files"
fi
pass "no personal home paths"

if command -v tmux >/dev/null 2>&1; then
  live="$workdir/live"
  mkdir -p "$live"
  cat >"$live/hold" <<'EOF'
#!/bin/sh
sleep 30
EOF
  cat >"$live/kitty" <<'EOF'
#!/usr/bin/env bash
{
  printf 'NO_COLOR=%s\n' "${NO_COLOR-<unset>}"
  printf 'FORCE_COLOR=%s\n' "${FORCE_COLOR-<unset>}"
  printf 'TERMINFO=%s\n' "${TERMINFO-<unset>}"
} >"${SYSMON_ENV_LOG:?}"
echo kitty "$@"
EOF
  chmod +x "$live/hold" "$live/kitty"
  unset SYSMON_OPEN SYSMON_FOCUSED
  export SYSMON_BTOP="$live/hold"
  export SYSMON_DUA="$live/hold"
  export SYSMON_NVIM="$live/hold"
  export SYSMON_HERDR="$live/hold"
  export SYSMON_TMUX="$(command -v tmux)"
  export SYSMON_KITTY="$live/kitty"
  export SYSMON_YABAI="$live/missing-yabai"
  export SYSMON_TMUX_SOCKET="sysmon-ci-test-$$"
  cat >"$live/tmux.conf" <<'EOF'
unbind-key C-b
set -g prefix C-x
bind-key C-x send-prefix
set -g base-index 0
set -g renumber-windows on
EOF
  export SYSMON_TMUX_CONF="$live/tmux.conf"
  export SYSMON_ENV_LOG="$live/kitty.env"
  export NO_COLOR=1 FORCE_COLOR=0
  export TERMINFO="/Applications/Ghostty.app/Contents/Resources/terminfo"
  export OBSIDIAN_VAULT="$workdir/vault"
  mkdir -p "$OBSIDIAN_VAULT"
  trap 'tmux -L "$SYSMON_TMUX_SOCKET" kill-server >/dev/null 2>&1 || true; rm -rf -- "$workdir"' EXIT

  "$SCRIPT" processes >/dev/null
  for _ in $(seq 1 20); do
    [[ -f "$SYSMON_ENV_LOG" ]] && break
    sleep 0.1
  done
  [[ -f "$SYSMON_ENV_LOG" ]] || fail "kitty did not record its environment"
  grep -q '^NO_COLOR=<unset>$' "$SYSMON_ENV_LOG" || fail "kitty inherited NO_COLOR: $(cat "$SYSMON_ENV_LOG")"
  grep -q '^FORCE_COLOR=<unset>$' "$SYSMON_ENV_LOG" || fail "kitty inherited FORCE_COLOR: $(cat "$SYSMON_ENV_LOG")"
  grep -q '^TERMINFO=<unset>$' "$SYSMON_ENV_LOG" || fail "kitty inherited Ghostty TERMINFO: $(cat "$SYSMON_ENV_LOG")"
  if tmux -L "$SYSMON_TMUX_SOCKET" show-environment -t sysmon | grep -q '^NO_COLOR='; then
    fail "tmux session kept NO_COLOR"
  fi
  if tmux -L "$SYSMON_TMUX_SOCKET" show-environment -t sysmon | grep -q '^FORCE_COLOR='; then
    fail "tmux session kept FORCE_COLOR"
  fi
  if tmux -L "$SYSMON_TMUX_SOCKET" show-environment -t sysmon | grep -q 'Ghostty.app'; then
    fail "tmux session kept Ghostty TERMINFO"
  fi
  "$SCRIPT" disk >/dev/null
  "$SCRIPT" vault >/dev/null

  wins="$(tmux -L "$SYSMON_TMUX_SOCKET" list-windows -t sysmon -F '#{window_index}:#{window_name}')"
  printf '%s\n' "$wins" | grep -qx '1:processes' || fail "live window 1: $wins"
  printf '%s\n' "$wins" | grep -qx '2:disk' || fail "live window 2: $wins"
  printf '%s\n' "$wins" | grep -qx '3:vault' || fail "live window 3: $wins"
  printf '%s\n' "$wins" | grep -qx '4:herdr' || fail "live window 4: $wins"
  prefix="$(tmux -L "$SYSMON_TMUX_SOCKET" show-options -gv prefix)"
  [[ "$prefix" == "C-x" ]] || fail "tmux prefix is $prefix, expected C-x"
  current="$(tmux -L "$SYSMON_TMUX_SOCKET" display-message -p -t sysmon '#{window_name}')"
  [[ "$current" == vault ]] || fail "vault was not selected: $current"
  sessions="$(tmux -L "$SYSMON_TMUX_SOCKET" list-sessions -F '#{session_name}')"
  [[ "$sessions" == sysmon ]] || fail "expected one session, got: $sessions"
  pass "live tmux session has windows 1-3 and prefix C-x"

  "$SCRIPT" show >/dev/null
  current="$(tmux -L "$SYSMON_TMUX_SOCKET" display-message -p -t sysmon '#{window_name}')"
  [[ "$current" == vault ]] || fail "show changed the last window: $current"
  pass "show keeps the last window"

  "$SCRIPT" stop >/dev/null
  if tmux -L "$SYSMON_TMUX_SOCKET" has-session -t sysmon 2>/dev/null; then
    fail "stop left the sysmon session running"
  fi
  pass "stop kills the shared session"

  "$SCRIPT" show >/dev/null
  current="$(tmux -L "$SYSMON_TMUX_SOCKET" display-message -p -t sysmon '#{window_name}')"
  [[ "$current" == processes ]] || fail "first start should open btop: $current"
  pass "first start creates btop"
  "$SCRIPT" stop >/dev/null
fi
