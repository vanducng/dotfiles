# Tinycast runs custom commands as /bin/zsh -lc; skip the full login shell.
[[ -n ${TINYCAST:-} ]] && return

# LaunchAgent shells can start on an external volume without permission to read it.
if ! pwd -P >/dev/null 2>&1; then
  builtin cd -q "$HOME" 2>/dev/null || true
fi

##
# Your previous $HOME/.zprofile file was backed up as $HOME/.zprofile.macports-saved_2022-08-02_at_01:17:23
##

# MacPorts Installer addition on 2022-08-02_at_01:17:23: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"


# MacPorts Installer addition on 2022-08-02_at_01:17:23: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.


# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

# added by Snowflake SnowCD installer
export PATH=/opt/snowflake/snowcd:$PATH

# Inlined `brew shellenv` output (fixed prefix); the eval costs ~80ms per login shell.
export HOMEBREW_PREFIX="/opt/homebrew" HOMEBREW_CELLAR="/opt/homebrew/Cellar" HOMEBREW_REPOSITORY="/opt/homebrew"
fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
export FPATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
[ -z "${MANPATH-}" ] || { export MANPATH="${MANPATH%"${MANPATH##*[!:]}"}"; export MANPATH=":${MANPATH#"${MANPATH%%[!:]*}"}"; }
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Interactive login shells source .zshrc themselves. Doing it here runs startup twice.
if [[ ! -o interactive ]]; then
  source ~/.zshrc
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"

# added by Snowflake SnowflakeCLI installer v1.0
export PATH=/Applications/SnowflakeCLI.app/Contents/MacOS/:$PATH

# The rex CLI ships inside the Rex Beta app. Rex panes put it on PATH; ssh and other shells don't.
rex_bin="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
[[ -x "$rex_bin/rex" ]] && export PATH="$PATH:$rex_bin"
unset rex_bin
