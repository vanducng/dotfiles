# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Force ARM64 architecture
if [[ "$(uname -m)" == "arm64" ]]; then
  exec arch -arm64 zsh
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
zsh-syntax-highlighting
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

# Disable brew auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Aliases now managed by atuin dotfiles

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
export PATH="$PATH:/usr/local/bin"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"

export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$HOME/.rd/bin:$HOME/.cargo/bin:/opt/homebrew/opt/openjdk/bin:$PATH"

eval "$(fzf --zsh)"
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# fv: Fuzzy finds a file using fzf and opens it in Neovim.
# Usage: fv
# Example: fv (then select a file from the fzf prompt)
fv() {
  local file
  file=$(fzf)
  if [ -n "$file" ]; then
    nvim "$file"
  fi
}

# fcd: Fuzzy finds a directory starting from a given path and changes into it.
# Usage: fcd <start_directory>
# Arguments:
#   <start_directory>: The directory to start searching from (e.g., '.').
# Example: fcd .
fcd() {
    local start_dir="$1"
    local dir
    dir=$(find "$start_dir" -type d 2>/dev/null | fzf --height 40% --reverse --border)
    
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

# fof: Fuzzy finds a file within a specified path, shows a preview with bat, and opens the selected file in Neovim.
# Usage: fof <search_path>
# Arguments:
#   <search_path>: The directory to start searching for files (e.g., '.').
# Example: fof .
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
  # Rebind smart-suggestion key - TEMPORARILY DISABLED
  # bindkey '^o' _do_smart_suggestion
}

# Also bind keys for viins mode explicitly
function zvm_after_lazy_keybindings() {
  bindkey -M viins '^r' atuin-search
  bindkey -M viins '^[[A' atuin-up-search
  bindkey -M viins '^[OA' atuin-up-search
  # Rebind smart-suggestion key in vi insert mode - TEMPORARILY DISABLED
  # bindkey -M viins '^o' _do_smart_suggestion
}


# NVM setup
export NVM_DIR="$HOME/.nvm"

# Add default node version to PATH for immediate npm/node/npx access
if [ -d "$NVM_DIR/versions/node" ]; then
  # Use nvm's default alias if it exists
  if [ -f "$NVM_DIR/alias/default" ]; then
    DEFAULT_NODE_VERSION=$(cat "$NVM_DIR/alias/default" | tr -d '\n')
  else
    DEFAULT_NODE_VERSION=$(ls -t "$NVM_DIR/versions/node" 2>/dev/null | head -1)
  fi
  if [ -n "$DEFAULT_NODE_VERSION" ]; then
    # Prepend nvm's node to PATH to take precedence over system node
    export PATH="$NVM_DIR/versions/node/$DEFAULT_NODE_VERSION/bin:$PATH"
  fi
fi

# Lazy load nvm only when needed
nvm_lazy_load() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Create nvm function that loads on first use
nvm() {
  nvm_lazy_load
  nvm "$@"
}

# Ansible vault
export ANSIBLE_VAULT_ENCRYPT_SALT=ddsa

# Fast completion setup
autoload -Uz compinit
# Check if we need to regenerate dump
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -d ~/.zcompdump
else
  compinit -C -d ~/.zcompdump
fi

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
# Lazy load mise to improve startup time
mise() {
  unset -f mise
  eval "$(command ~/.local/bin/mise activate zsh)"
  mise "$@"
}


# opencode
export PATH=/Users/vanducng/.opencode/bin:$PATH

# Completion system already initialized above

# npm global path
export PATH="/Users/vanducng/.npm-global/bin:$PATH"

# Added by dbt installer
export PATH="$PATH:/Users/vanducng/.local/bin"

# Added by Windsurf
export PATH="/Users/vanducng/.codeium/windsurf/bin:$PATH"


# bun completions
[ -s "/Users/vanducng/.bun/_bun" ] && source "/Users/vanducng/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
alias claude="/Users/vanducng/.claude/local/claude"
export PATH="/Users/vanducng/.claude/local:$PATH"
export PATH="$HOME/.local/bin:$PATH"
