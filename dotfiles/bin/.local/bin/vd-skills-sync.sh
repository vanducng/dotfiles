#!/usr/bin/env bash
# Daily sync of vanducng/skills into Claude, Codex and pi (user level) via vd.
# Skips any vd skill whose name collides with a real dir or a symlink not pointing into a vanducng/skills checkout (*/skills/skills/<name>).
set -u
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/go/bin:/opt/homebrew/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
LOG="$HOME/.local/state/vd-skills-sync.log"
LOCK="$HOME/.local/state/vd-skills-sync.lock"
mkdir -p "$HOME/.local/state"
exec >>"$LOG" 2>&1
echo "===== $(date '+%Y-%m-%d %H:%M:%S %z') start on $(hostname) ====="
if ! mkdir "$LOCK" 2>/dev/null; then echo "another run holds $LOCK; exiting"; exit 1; fi
trap 'rmdir "$LOCK"' EXIT
command -v vd >/dev/null || { echo "ERROR: vd not found in PATH"; exit 1; }
echo "vd: $(command -v vd) ($(vd --version 2>&1))"
rc=0
if [ -d "$HOME/.vd/skills/.git" ]; then
  cd "$HOME/.vd/skills" && vd bootstrap --update || { echo "ERROR: bootstrap --update failed"; exit 1; }
else
  vd bootstrap || { echo "ERROR: bootstrap failed"; exit 1; }
fi
cd "$HOME/.vd/skills" || exit 1
echo "skills tag: $(git describe --tags 2>/dev/null)"

# install_target <agent-args> <dest-dir>
install_target() {
  local dest="${@: -1}"; local n=$(($#-1)); local args=("${@:1:$n}")
  local safe=() coll=() name p tgt
  for p in "$HOME/.vd/skills/skills"/*/; do
    name=$(basename "$p")
    if [ -e "$dest/$name" ] || [ -L "$dest/$name" ]; then
      if [ -L "$dest/$name" ]; then
        tgt=$(readlink "$dest/$name")
        case "$tgt" in *skills/skills/"$name") safe+=("$name");; *) coll+=("$name");; esac
      else coll+=("$name"); fi
    else safe+=("$name"); fi
  done
  if [ ${#coll[@]} -eq 0 ]; then
    echo "--> vd install ${args[*]} --force"
    vd install "${args[@]}" --force || rc=1
  else
    echo "WARN: skipping colliding non-vd entries in $dest: ${coll[*]}"
    echo "--> vd install ${args[*]} <${#safe[@]} skills> --force"
    if [ ${#safe[@]} -gt 0 ]; then vd install "${args[@]}" "${safe[@]}" --force || rc=1; fi
  fi
}
install_target codex "$HOME/.agents/skills"
install_target claude --dev "$HOME/.claude/skills"
install_target pi "$HOME/.pi/agent/skills"

# vd install never removes a skill dropped from the catalog, so its link dangles.
for dest in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.pi/agent/skills" "$HOME/.factory/skills"; do
  for l in "$dest"/*; do
    [ -L "$l" ] && [ ! -e "$l" ] || continue
    case "$(readlink "$l")" in *skills/skills/*) rm "$l" && echo "pruned dangling $l";; esac
  done
done
echo "===== $(date '+%Y-%m-%d %H:%M:%S %z') done rc=$rc ====="
exit $rc
