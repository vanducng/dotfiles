# Puts ~/.local/bin and the mise shims back at the front of PATH, in that order, without duplicates.
#
# .zshenv puts them there, but the PATH edits in .zprofile (brew shellenv) and .zshrc put Homebrew back in
# front, and a shell that never shows a prompt (a script, ssh, zsh -lc) gets no `mise activate` hook to fix
# it. .zprofile and .zshrc source this file as their last line. Outside a pinned directory a shim with no
# version set falls through to the next match on PATH, so nothing else changes.
() {
  local shims="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims" bin="$HOME/.local/bin"
  local -a head=()
  [[ -d $bin ]] && head+=("$bin")
  [[ -d $shims ]] && head+=("$shims")
  (( $#head )) || return 0
  path=("${head[@]}" ${${path:#${(b)bin}}:#${(b)shims}})
}
