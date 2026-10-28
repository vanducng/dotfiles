ZSH_THEME_TERM_TAB_TITLE_IDLE='%1~'
ZSH_THEME_TERM_TITLE_IDLE='%1~'
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%m'
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_TEMPLATE='%m'
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_TEMPLATE='%m'

if [[ -o interactive && -n ${REX_BLOCK:-} && -z ${TMUX:-} ]] && (( $+commands[rex-pane-titles] )); then
  command rex-pane-titles --start >/dev/null 2>&1
fi
