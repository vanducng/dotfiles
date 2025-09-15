# Starship theme switcher for Nushell

# Switch to lean theme (P10K inspired)
export def starship-lean [] {
    cp ~/.config/nushell/starship-lean.toml ~/.config/starship.toml
    print "Switched to lean Starship theme (P10K inspired)"
}

# Switch to full theme (current configuration)
export def starship-full [] {
    cp ~/.config/nushell/starship-full.toml ~/.config/starship.toml
    print "Switched to full Starship theme"
}

# Show current theme info
export def starship-info [] {
    let config_path = "~/.config/starship.toml"
    if ($config_path | path exists) {
        let content = (open ~/.config/starship.toml --raw)
        if ($content | str contains "P10K-inspired") {
            print "Current theme: Lean (P10K inspired)"
        } else {
            print "Current theme: Full"
        }
    } else {
        print "No Starship config found"
    }
}

# Aliases for convenience
alias st-lean = starship-lean
alias st-full = starship-full
alias st-info = starship-info