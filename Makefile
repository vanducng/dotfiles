STOW_FOLDERS=zsh tmux kitty skhd starship yabai bin vrapperrc yazi zathura lazygit nvim-vscode task ghostty nvim mise claude atuin direnv hammerspoon

stow-install:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Stowing $$folder"; \
		stow --no-folding -D -t $(HOME) $$folder 2>/dev/null || true; \
		stow --no-folding -t $(HOME) $$folder; \
	done
	
stow-clean:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Unstowing $$package"; \
		stow -t $(HOME) -D $$folder; \
	done

# Atuin alias management
export-aliases:
	@./scripts/export-atuin-aliases.sh

import-aliases:
	@./scripts/import-atuin-aliases.sh

# Backup aliases before any major changes
backup-aliases: export-aliases
	@git add dotfiles/atuin/.config/atuin/aliases.sh
	@git commit -m "backup: export current atuin aliases" || true
