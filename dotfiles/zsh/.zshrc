# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export EDITOR=nvim
export VISUAL="$EDITOR"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k" 
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
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

function zvm_vi_yank() {
	zvm_yank
	echo ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh


export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

alias ls='exa'
alias ll='exa -l'
alias pip='pip3'
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql
alias a=/Users/vanducng/.virtualenvs/global/bin/aider

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
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"

export XDG_CONFIG_HOME="$HOME/.config"

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

# Fix VSCode virtual environment persistence issue
# Unset VIRTUAL_ENV if it's being set globally by VSCode
if [[ -n "$VSCODE_ENV_REPLACE" && -n "$VIRTUAL_ENV" ]]; then
  unset VIRTUAL_ENV
  unset VIRTUAL_ENV_PROMPT
fi

# Set atuin PATH first
. "$HOME/.atuin/bin/env"

# Initialize atuin before zsh-vi-mode
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# Define a function to set up atuin keybindings after zsh-vi-mode loads
function zvm_after_init() {
  # Rebind the keys after zsh-vi-mode loads
  bindkey '^r' atuin-search
  # bind to the up key, which depends on terminal mode
  bindkey '^[[A' atuin-up-search
  bindkey '^[OA' atuin-up-search
}

# Also bind keys for viins mode explicitly
function zvm_after_lazy_keybindings() {
  bindkey -M viins '^r' atuin-search
  bindkey -M viins '^[[A' atuin-up-search
  bindkey -M viins '^[OA' atuin-up-search
}


# Lazy load NVM to speed up shell startup
export NVM_DIR="$HOME/.nvm"
# Add nvm to PATH but don't load it yet
export PATH="$NVM_DIR/versions/node/$(ls -t $NVM_DIR/versions/node 2>/dev/null | head -1)/bin:$PATH"

# Lazy load nvm
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Create placeholder functions
node() { nvm "$0" "$@" }
npm() { nvm "$0" "$@" }
npx() { nvm "$0" "$@" }

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/vanducng/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/vanducng/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/vanducng/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/vanducng/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Ansible vault
export ANSIBLE_VAULT_ENCRYPT_SALT=ddsa
alias p='python'
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
alias g3='arc-cli s 1 && arc-cli new-tab https://github.com/careernowbrands/cnb-ds-astro'
alias g0='arc-cli s 1 && arc-cli new-tab https://github.com/careernowbrands/cnb-ds-dbt-order-form'
alias d='docker'
alias dc='docker-compose'
alias tt='taskwarrior-tui'
alias ghas='gh auth switch'
alias esm='/Users/vanducng/.virtualenvs/global/bin/ec2-session'
alias esh='/Users/vanducng/.virtualenvs/global/bin/ec2-ssh'
alias etn='/Users/vanducng/.virtualenvs/global/bin/ec2-tunnel'
alias pca="pre-commit run --all-files"

zstyle ':completion:*' menu select
fpath+=~/.zfunc

eval "$(zoxide init zsh)"

eval "$(direnv hook zsh)"

# Local virtual environment activation
# Function to activate local .venv when entering directories
auto_activate_venv() {
  if [[ -d ".venv" && -z "$VIRTUAL_ENV" ]]; then
    source .venv/bin/activate
    echo "Activated local virtual environment: $(basename $PWD)"
  elif [[ -n "$VIRTUAL_ENV" && ! -d ".venv" ]]; then
    # Check if we're no longer in the directory that has the active venv
    local venv_dir=$(dirname "$VIRTUAL_ENV")
    if [[ "$PWD" != "$venv_dir"* ]]; then
      deactivate 2>/dev/null || unset VIRTUAL_ENV VIRTUAL_ENV_PROMPT
      echo "Deactivated virtual environment"
    fi
  fi
}

# Hook to run on directory change
chpwd_functions+=(auto_activate_venv)

clear-terminal() { tput reset; zle redisplay; }
zle -N clear-terminal
bindkey '^l' clear-terminal

# Bindkey
bindkey -s '^g' "$HOME/.local/bin/tmux-sessionizer\n"

. "$HOME/.cargo/env"

eval "$(gh copilot alias -- zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(~/.local/bin/mise activate zsh)"


# opencode
export PATH=/Users/vanducng/.opencode/bin:$PATH

fpath+=~/.zfunc; autoload -Uz compinit; compinit

# npm global path
export PATH="/Users/vanducng/.npm-global/bin:$PATH"

# Added by dbt installer
export PATH="$PATH:/Users/vanducng/.local/bin"

# dbt aliases
alias dbtf=/Users/vanducng/.local/bin/dbt

# Added by Windsurf
export PATH="/Users/vanducng/.codeium/windsurf/bin:$PATH"
