# Tool integrations and initializations

# Zoxide integration
export def --env zi [...args] {
    let result = (^zoxide query ...$args | str trim)
    if ($result | is-not-empty) {
        cd $result
    }
}

# FZF integration functions
export def fzf-file [] {
    let file = (^find . -type f | ^fzf)
    if ($file | is-not-empty) {
        print $file
    }
}

export def fzf-dir [] {
    let dir = (^find . -type d | ^fzf)
    if ($dir | is-not-empty) {
        cd $dir
    }
}

# Enhanced ls with exa if available
export def exa [...args] {
    if (which exa | is-not-empty) {
        ^exa ...$args
    } else {
        ls ...$args
    }
}

# Bat for better cat
export def cat [...args] {
    if (which bat | is-not-empty) {
        ^bat ...$args
    } else {
        ^cat ...$args
    }
}

# Better grep with ripgrep
export def grep [...args] {
    if (which rg | is-not-empty) {
        ^rg ...$args
    } else {
        ^grep ...$args
    }
}

# Find alternative with fd
export def find [...args] {
    if (which fd | is-not-empty) {
        ^fd ...$args
    } else {
        ^find ...$args
    }
}

# Top alternative with htop
export def top [] {
    if (which htop | is-not-empty) {
        ^htop
    } else {
        ^top
    }
}

# Disk usage with dust
export def du [...args] {
    if (which dust | is-not-empty) {
        ^dust ...$args
    } else {
        ^du ...$args
    }
}

# Git status with delta
export def git-log [] {
    if (which delta | is-not-empty) {
        ^git log --color=always | ^delta
    } else {
        ^git log
    }
}

# Python virtual environment helpers
export def venv-create [name: string = "venv"] {
    ^python -m venv $name
    print $"Virtual environment '($name)' created"
}

export def venv-activate [name: string = ".venv"] {
    let activate_script = ($name | path join "bin/activate.nu")
    if ($activate_script | path exists) {
        print $"To activate virtual environment manually:"
        print $"overlay use ($activate_script)"
        print $"(Automatic activation not supported in function due to overlay limitations)"
    } else {
        print $"Virtual environment not found: ($name)"
    }
}

# Node version management (if nvm equivalent is needed)
export def node-versions [] {
    if (which node | is-not-empty) {
        ^node --version
    }
    if (which npm | is-not-empty) {
        ^npm --version
    }
}

# Quick server for current directory
export def serve [port: int = 8000] {
    if (which python3 | is-not-empty) {
        print $"Starting server on port ($port)"
        ^python3 -m http.server $port
    } else {
        print "Python3 not available"
    }
}

# Weather (fun command)
export def weather [city?: string] {
    if ($city | is-not-empty) {
        ^curl $"wttr.in/($city)"
    } else {
        ^curl "wttr.in"
    }
}

# System information
export def sysinfo [] {
    let ver = (version)
    print $"OS: ($nu.os-info.name)"
    print $"Kernel: ($nu.os-info.kernel_version)"
    print $"Architecture: ($nu.os-info.arch)"
    print $"Shell: Nushell ($ver.version)"
    print $"PWD: (pwd)"
    print $"User: ($env.USER?)"
}

# Quick note taking
export def note [title: string, ...content: string] {
    let notes_dir = "~/notes"
    let note_file = $"($notes_dir)/($title).md"

    if not ($notes_dir | path exists) {
        mkdir $notes_dir
    }

    let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S")
    let note_content = $"# ($title)\n\nCreated: ($timestamp)\n\n($content | str join ' ')\n"

    $note_content | save --append $note_file
    print $"Note saved to ($note_file)"
}

# Quick file backup
export def backup [file: string] {
    let backup_name = $"($file).backup.(date now | format date '%Y%m%d_%H%M%S')"
    cp $file $backup_name
    print $"Backup created: ($backup_name)"
}