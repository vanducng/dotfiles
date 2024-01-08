STOW_FOLDERS=zsh tmux kitty sketchybar skhd starship yabai karabiner bin

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
