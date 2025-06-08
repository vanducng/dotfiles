STOW_FOLDERS=zsh tmux kitty skhd starship yabai bin vrapperrc yazi zathura lazygit nvim-vscode task ghostty nvim mise claude

stow-install:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Stowing $$folder"; \
		stow -D -t $(HOME) $$folder; \
		stow -t $(HOME) $$folder; \
	done
	
stow-clean:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Unstowing $$package"; \
		stow -t $(HOME) -D $$folder; \
	done
