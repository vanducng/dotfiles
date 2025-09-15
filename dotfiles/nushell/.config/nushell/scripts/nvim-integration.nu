# Neovim integration for Nushell
# This script provides enhanced integration between Nushell and Neovim

# Set buffer editor configuration
$env.config.buffer_editor = ["nvim", "-c", "startinsert"]

# Function to edit files with selection (using ls instead of external find)
export def nvim-select [] {
    let file = (
        ls **/*
        | where type == file
        | get name
        | where {|f| not ($f | str contains "/.git/") }
        | where {|f| not ($f | str contains "/node_modules/") }
        | where {|f| not ($f | str contains "/.venv/") }
        | where {|f| not ($f | str contains "__pycache__") }
        | input list "Select file to edit:"
    )
    if ($file | is-not-empty) {
        nvim $file
    }
}

# Function to edit config files quickly
export def nvim-config [config?: string] {
    match $config {
        "nu" | "nushell" => { nvim ~/.config/nushell/config.nu }
        "env" => { nvim ~/.config/nushell/env.nu }
        "aliases" => { nvim ~/.config/nushell/modules/aliases.nu }
        "functions" => { nvim ~/.config/nushell/modules/functions.nu }
        "tools" => { nvim ~/.config/nushell/modules/tools.nu }
        "ghostty" => { nvim ~/.config/ghostty/config }
        "zsh" => { nvim ~/.zshrc }
        _ => {
            print "Available configs: nu, env, aliases, functions, tools, ghostty, zsh"
        }
    }
}

# Function to create new files with templates
export def nvim-new [filename: string, template?: string] {
    let file_path = ($filename | path expand)

    # Create directory if it doesn't exist
    let dir = ($file_path | path dirname)
    if not ($dir | path exists) {
        mkdir $dir
    }

    # Create file with template if specified
    match $template {
        "py" | "python" => {
            "#!/usr/bin/env python3\n\n" | save $file_path
        }
        "sh" | "bash" => {
            "#!/bin/bash\n\nset -euo pipefail\n\n" | save $file_path
            chmod +x $file_path
        }
        "nu" | "nushell" => {
            "#!/usr/bin/env nu\n\n" | save $file_path
            chmod +x $file_path
        }
        _ => {
            touch $file_path
        }
    }

    nvim $file_path
}

# Function to search and edit files containing specific text
export def nvim-grep [pattern: string] {
    let matches = (
        if (which rg | is-not-empty) {
            ^rg -l $pattern .
        } else {
            ^grep -r -l $pattern .
        }
        | lines
        | input list $"Select file containing '($pattern)':"
    )

    if ($matches | is-not-empty) {
        nvim $matches
    }
}

# Function to edit the most recently modified files
export def nvim-recent [count: int = 10] {
    let recent_files = (
        ls **/*
        | where type == file
        | where {|f| not ($f.name | str contains "/.git/") }
        | sort-by modified -r
        | first $count
        | get name
        | input list "Select recent file to edit:"
    )

    if ($recent_files | is-not-empty) {
        nvim $recent_files
    }
}

# Function to open nvim with a specific line number
export def nvim-line [file: string, line: int] {
    nvim $"+($line)" $file
}

# Create aliases for common nvim operations
alias v = nvim
alias vi = nvim
alias vim = nvim
alias nv = nvim-select
alias nc = nvim-config
alias nn = nvim-new
alias ng = nvim-grep
alias nr = nvim-recent