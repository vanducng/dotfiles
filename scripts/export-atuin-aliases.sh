#!/bin/bash
# Export atuin aliases to a file for backup/version control

ALIASES_FILE="$HOME/dotfiles/dotfiles/atuin/.config/atuin/aliases.sh"

echo "#!/bin/bash" > "$ALIASES_FILE"
echo "# Atuin Aliases - Generated on $(date)" >> "$ALIASES_FILE"
echo "# Use 'atuin dotfiles alias set <name> <command>' to restore" >> "$ALIASES_FILE"
echo "# You can also execute this file directly: ./aliases.sh" >> "$ALIASES_FILE"
echo "" >> "$ALIASES_FILE"

atuin dotfiles alias list | while IFS='=' read -r name command; do
    echo "atuin dotfiles alias set '$name' '$command'" >> "$ALIASES_FILE"
done

# Make the file executable
chmod +x "$ALIASES_FILE"

echo "Aliases exported to $ALIASES_FILE"