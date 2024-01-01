STOW_FOLDERS=yabai skhd kitty
TARGET=$(HOME)/.config/

stow:
	stow --target $(TARGET) .
