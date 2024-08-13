export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k" 
plugins=(
git
zsh-autosuggestions
aws
kube-aliases
docker
zsh-syntax-highlighting
web-search
zsh-history-substring-search
zsh-vi-mode
)
source $ZSH/oh-my-zsh.sh

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
plugins+=(kube-aliases)

eval $(thefuck --alias)
alias ls='exa'
alias ll='exa -l'
alias pip='pip3'
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

# pyenv init
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8
# GoLang
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
export GOPATH=/Users/vanducng/go
export PATH=$GOPATH/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH=/usr/local/bin/:$PATH
export XDG_CONFIG_HOME="$HOME/.config"

source <(kubectl completion zsh)
complete -o default -F __start_kubectl k

export PATH="$HOME/.rd/bin:$HOME/.cargo/bin:/opt/homebrew/opt/openjdk/bin:$PATH"

#macro to kill the docker desktop app and the VM (excluding vmnetd -> it's a service)
function kdo() {
  ps ax|grep -i docker|egrep -iv 'grep|com.docker.vmnetd'|awk '{print $1}'|xargs kill
}

eval "$(fzf --zsh)"

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

fv() {
  local file
  file=$(fzf)
  if [ -n "$file" ]; then
    nvim "$file"
  fi
}

fcd() {
    local start_dir="$1"
    local dir
    dir=$(find "$start_dir" -type d 2>/dev/null | fzf --height 40% --reverse --border)
    
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

fof() {
  local selected_file
  local search_path="$1"

  if [[ ! -d "$search_path" ]]; then
    echo "Invalid path: $search_path"
    return 1
  fi

  selected_file=$(find "$search_path" -type f | fzf --preview "bat --color=always --style=numbers --line-range=:500 {}" --preview-window=up:50%:wrap)

  if [[ -n "$selected_file" ]]; then
    echo "Opening $selected_file"
    nvim "$selected_file"
  else
    echo "No file selected."
  fi
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^r' atuin-search

# bind to the up key, which depends on terminal mode
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/vanducng/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/vanducng/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/vanducng/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/vanducng/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Ansible vault
export ANSIBLE_VAULT_ENCRYPT_SALT=ddsa
alias av='ansible-vault'
alias adb='astro dev bash --scheduler'
alias ado='astro dev object import -s airflow_settings.yaml'
alias cdeg='cd /Volumes/exs/git'
alias gcb='git checkout -b'
alias gc='git checkout'
alias gp='git pull'
alias gP='git push'
alias v='nvim'
alias lg='lazygit'
alias g='git'
alias t='terraform'
alias ad='akio run dbt'
alias ab='akio run dbt build -s'
alias af='akio run sqlfluff fix'
alias ps='poetry shell'
alias pr='poetry run'
alias tm='$HOME/.local/bin/tmux-sessionizer'
alias lzd='lazydocker'
alias gr='go run .'
alias c="echo -ne '\033c'"
alias nsql="nvim '+SQLua'"
alias dw='datawarden'

zstyle ':completion:*' menu select
fpath+=~/.zfunc

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

clear-terminal() { tput reset; zle redisplay; }
bindkey '^m' clear

# Bindkey
bindkey -s '^g' "$HOME/.local/bin/tmux-sessionizer\n"

. "$HOME/.cargo/env"

eval "$(gh copilot alias -- zsh)"
