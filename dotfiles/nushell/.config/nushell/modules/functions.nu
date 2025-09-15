# Custom Functions - Essential Nushell functions

# yy: Yazi integration with directory change
export def yy [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX" | str trim)
    ^yazi ...$args --cwd-file $tmp

    if ($tmp | path exists) {
        let cwd = (open $tmp | str trim)
        if ($cwd | is-not-empty) and ($cwd != (pwd | str trim)) {
            cd $cwd
        }
        rm $tmp
    }
}

# Clear terminal function
export def c [] {
    clear
}

# Git related functions
export def gcb [branch_name: string] {
    git checkout -b $branch_name
}

export def gc [branch_name: string] {
    git checkout $branch_name
}

export def gP [] {
    git push
}

# Enhanced git diff functions
export def gd [...args] {
    git diff ...$args
}

export def gds [] {
    git diff --staged
}

export def gdh [] {
    git diff HEAD~1
}

# Git status with short format
export def gs [] {
    git status -s
}

# Git log with graph
export def glog [] {
    git log --oneline --graph --decorate --all -10
}

# Tmux sessionizer shortcut
export def tm [] {
    ^($env.HOME | path join ".local/bin/tmux-sessionizer")
}

# Lazy git
export def lg [] {
    ^lazygit
}

# Lazy docker
export def lzd [] {
    ^lazydocker
}

# Go run
export def gr [] {
    go run .
}

# Docker shortcuts
export def d [...args] {
    ^docker ...$args
}

export def dc [...args] {
    ^docker-compose ...$args
}

# Python shortcut
export def p [...args] {
    ^python ...$args
}


# Open current directory in file manager
export def open-here [] {
    if $nu.os-info.name == "macos" {
        ^open .
    } else if $nu.os-info.name == "linux" {
        ^xdg-open .
    }
}

# Quick edit of nushell config
export def edit-config [] {
    nvim ~/.config/nushell/config.nu
}

export def edit-env [] {
    nvim ~/.config/nushell/env.nu
}

# Reload nushell config - note: restart shell instead to avoid circular imports
export def reload-config [] {
    print "To reload config, restart your Nushell session or open a new terminal"
}