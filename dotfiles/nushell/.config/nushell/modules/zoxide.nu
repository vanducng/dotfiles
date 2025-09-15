# Zoxide integration for Nushell
# Generate and apply zoxide initialization directly

if (which zoxide | is-not-empty) {
    # Generate zoxide commands directly rather than sourcing a file
    let zoxide_init = (^zoxide init nushell)
    nu -c $zoxide_init
}