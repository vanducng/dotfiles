STOW_FOLDERS=zsh tmux kitty sketchybar skhd starship yabai karabiner

stow-install:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Stowing $$folder"; \
		stow -D -t $(HOME) $$folder; \
		stow -t $(HOME) $$folder; \
	done
	
	# cp dotfiles/karabiner/karabiner.json $(TARGET)/karabiner/

stow-clean:
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		echo "Unstowing $$package"; \
		stow -t $(HOME) -D $$folder; \
	done
