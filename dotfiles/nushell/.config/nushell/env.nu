# Nushell Environment Configuration
# This file is loaded before config.nu

# Core environment variables
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")

# Shell history configuration
$env.NU_HISTORY_FILE = ($env.HOME | path join ".shell-history/nushell_history.sqlite3")

# Homebrew
$env.HOMEBREW_NO_AUTO_UPDATE = "1"

# Locale
$env.LC_CTYPE = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

# Development tools
$env.ANSIBLE_VAULT_ENCRYPT_SALT = "ddsa"

# GoLang
$env.GOROOT = "/usr/local/go"
$env.GOPATH = ($env.HOME | path join "go")

# Node/Bun
$env.BUN_INSTALL = ($env.HOME | path join ".bun")

# PATH management using standard library
use std/util "path add"

# Development paths
path add "/opt/homebrew/bin"
path add ($env.HOME | path join ".local/bin")
path add "/opt/homebrew/opt/mysql-client/bin"
path add ($env.HOME | path join ".rd/bin")
path add ($env.HOME | path join ".cargo/bin")
path add "/opt/homebrew/opt/openjdk/bin"
path add ($env.GOPATH | path join "bin")
path add ($env.GOROOT | path join "bin")
path add ($env.HOME | path join ".npm-global/bin")
path add ($env.BUN_INSTALL | path join "bin")
path add ($env.HOME | path join ".claude/local")
path add ($env.HOME | path join ".codeium/windsurf/bin")
path add "/usr/local/bin"

# Additional development paths
$env.LDFLAGS = "-L/usr/local/opt/zlib/lib"
$env.CPPFLAGS = "-I/usr/local/opt/zlib/include"

# Initialize atuin first (before other tools)
if (which atuin | is-not-empty) {
    $env.ATUIN_NOBIND = "true"
    # Note: Using homebrew version instead of ~/.atuin/bin version
    # path add ($env.HOME | path join ".atuin/bin")
}

# Tool initializations that need to be in env.nu
# Note: zoxide initialization temporarily disabled due to parse-time source issues
# if (which zoxide | is-not-empty) {
#     try {
#         source ~/.config/nushell/modules/zoxide.nu
#     } catch {
#         # Zoxide module not found, skip initialization
#     }
# }

if (which direnv | is-not-empty) {
    $env.config = ($env.config | merge {
        hooks: {
            env_change: {
                PWD: [{|before, after|
                    if (which direnv | is-not-empty) {
                        direnv export json | from json | default {} | load-env
                    }
                }]
            }
        }
    })
}