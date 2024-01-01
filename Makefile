TARGET=$(HOME)/.config

stow-dotfiles:
	stow -D --target $(TARGET) dotfiles
	stow --target $(TARGET) dotfiles
	
	cp dotfiles/karabiner/karabiner.json $(TARGET)/karabiner/
