#!/bin/bash
# Import atuin aliases from the aliases.sh file

ALIASES_FILE="$HOME/dotfiles/dotfiles/atuin/.config/atuin/aliases.sh"

if [[ ! -f "$ALIASES_FILE" ]]; then
    echo "Error: $ALIASES_FILE not found"
    exit 1
fi

echo "Importing aliases from $ALIASES_FILE..."

# Skip comment lines and execute atuin commands
grep "^atuin dotfiles alias set" "$ALIASES_FILE" | while read -r line; do
    echo "Executing: $line"
    eval "$line"
done

echo "Import complete!"