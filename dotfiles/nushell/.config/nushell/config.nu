# Nushell Main Configuration

# Starship prompt configuration
$env.STARSHIP_SHELL = "nu"
def create_left_prompt [] {
    let duration = ($env.CMD_DURATION_MS? | default 0)
    let status = ($env.LAST_EXIT_CODE? | default 0)
    starship prompt --cmd-duration $duration $'--status=($status)'
}

# Use starship as the prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# Prompt indicators for vi mode (minimal since we use starship)
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = ""

# Core configuration
$env.config = {
    show_banner: false
    buffer_editor: ["nvim", "-c", "startinsert"]
    edit_mode: "vi"

    # Cursor configuration for vi mode
    cursor_shape: {
        vi_insert: "line"  # Vertical line cursor in insert mode
        vi_normal: "block" # Block cursor in normal mode
        emacs: "line"
    }

    history: {
        max_size: 100000
        file_format: "sqlite"
        isolation: false
        sync_on_enter: true
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }

    table: {
        mode: "rounded"
        index_mode: "always"
        show_empty: true
        trim: {
            methodology: "wrapping"
            wrapping_try_keep_words: true
        }
    }

    error_style: "fancy"

    keybindings: [
        {
            name: "clear_screen"
            modifier: "control"
            keycode: "char_l"
            mode: [emacs vi_normal vi_insert]
            event: { send: clearscreen }
        }
        {
            name: "tmux_sessionizer"
            modifier: "control"
            keycode: "char_g"
            mode: [emacs vi_normal vi_insert]
            event: { send: executehostcommand cmd: "~/.local/bin/tmux-sessionizer" }
        }
    ]
}

# Source tool configurations
source ~/.config/nushell/modules/aliases.nu
source ~/.config/nushell/modules/functions.nu
source ~/.config/nushell/modules/tools.nu
source ~/.config/nushell/scripts/nvim-integration.nu
source ~/.config/nushell/scripts/starship-theme.nu

# Initialize tools that need to be in config.nu
if (which atuin | is-not-empty) {
    ^/opt/homebrew/bin/atuin init nu | save --force ~/.config/nushell/modules/atuin_init.nu
    if ("~/.config/nushell/modules/atuin_init.nu" | path exists) {
        source ~/.config/nushell/modules/atuin_init.nu
    }
}

# GitHub Copilot integration (manual since nushell not directly supported)
if (which gh | is-not-empty) {
    # Create manual copilot aliases
    def ghcs [command: string] { ^gh copilot suggest $command }
    def ghce [command: string] { ^gh copilot explain $command }
}

# Virtual environment auto-activation hook
$env.config.hooks = {
    env_change: {
        PWD: [{|before, after|
            # Note: Automatic venv activation disabled due to Nushell overlay limitations
            # Use 'overlay use .venv/bin/activate.nu' manually to activate venvs

            # Direnv integration
            if (which direnv | is-not-empty) {
                let direnv_output = (do { ^direnv export json } | complete)
                if $direnv_output.exit_code == 0 {
                    $direnv_output.stdout | from json | default {} | load-env
                }
            }
        }]
    }
}