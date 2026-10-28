# shellcheck shell=sh
# Turn dotfiles/atuin aliases.sh into POSIX aliases.
#
# macOS gets these from `atuin init` after `atuin dotfiles alias`. That path
# needs ~/.local/share/atuin/key. Load the same names here so `gp` is
# `git pull` when the key is missing. Skip macOS-only commands.

_vd_aliases="${ATUIN_ALIASES_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/atuin/aliases.sh}"

_vd_apply_fallback() {
  if command -v nvim >/dev/null 2>&1; then
    alias v='nvim'
  fi
  if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -l'
  elif command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -l'
  fi
}

if [ ! -f "${_vd_aliases}" ]; then
  _vd_apply_fallback
  unset _vd_aliases
  unset -f _vd_apply_fallback
  return 0
fi

if command -v python3 >/dev/null 2>&1; then
  _vd_alias_script="$(
    ATUIN_ALIASES_FILE="${_vd_aliases}" python3 - <<'PY'
import os
import re

path = os.environ["ATUIN_ALIASES_FILE"]
pat = re.compile(r"^atuin dotfiles alias set '([^']*)' '(.*)'\s*$")
skip_name = {"ls", "ll"}
skip_sub = ("/Users/", "/Volumes/", "/Applications/")
with open(path, encoding="utf-8") as fh:
    for raw in fh:
        m = pat.match(raw.rstrip("\n"))
        if not m:
            continue
        name, cmd = m.group(1), m.group(2)
        if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name):
            continue
        if name in skip_name or any(s in cmd for s in skip_sub):
            print("unalias {} 2>/dev/null || true".format(name))
            continue
        print("alias {}='{}'".format(name, cmd.replace("'", "'\\''")))
PY
  )"
  # shellcheck disable=SC2086
  eval "${_vd_alias_script}"
  unset _vd_alias_script
fi

_vd_apply_fallback
unset _vd_aliases
unset -f _vd_apply_fallback
