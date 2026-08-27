COMMON_STOW_FOLDERS=tmux herdr pi starship bin vrapperrc yazi zathura lazygit nvim-vscode task nvim mise miu agents atuin direnv diffnav gh-dash agent-deck wtf delta git plannotator dsh
MACOS_STOW_FOLDERS=zsh kitty skhd yabai borders ghostty claude codex grok cursor hammerspoon karabiner rift vscode launchd gopass
# Portable extras for Linux. Do not auto-stow `grok`: the Grok TUI installer owns ~/.grok.
# Opt in with `make stow-grok` after backing up auth.json / sessions.
LINUX_STOW_EXTRAS=kitty claude codex cursor gopass shell-linux ghostty sway waybar wofi mako kanata homelab
ALL_STOW_FOLDERS=$(sort $(COMMON_STOW_FOLDERS) $(MACOS_STOW_FOLDERS) $(LINUX_STOW_EXTRAS))
PLATFORM ?= $(shell uname -s)
ifneq ($(filter Darwin macos,$(PLATFORM)),)
STOW_FOLDERS=$(COMMON_STOW_FOLDERS) $(MACOS_STOW_FOLDERS)
else
STOW_FOLDERS=$(COMMON_STOW_FOLDERS) $(LINUX_STOW_EXTRAS)
endif
SHELL := /bin/bash

.PHONY: help stow-folders stow-install stow-uninstall stow-status setup-herdr test validate deps platform-test script-test linux-deps linux-desktop linux-homelab bootstrap-linux

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Installation:"
	@echo "  make stow-install    - Install all dotfiles"
	@echo "  make stow-uninstall  - Remove all dotfiles"
	@echo "  make stow-status     - Check installation status"
	@echo "  make stow-<tool>     - Install specific tool"
	@echo "  make unstow-<tool>   - Remove specific tool"
	@echo "  make linux-deps      - User-space Linux CLI bootstrap (no sudo)"
	@echo "  make linux-desktop   - Sway/Ghostty/waybar desktop (sudo optional)"
	@echo "  make linux-homelab   - disks, never-sleep, ssh :2222, clone hot repos"
	@echo "  make bootstrap-linux - linux-deps + stow-install"
	@echo "  make setup-herdr     - Install Herdr's Droid integration"
	@echo ""
	@echo "Testing:"
	@echo "  make test            - Run all tests"
	@echo "  make validate        - Validate syntax"
	@echo "  make deps            - Check dependencies"
	@echo "  make platform-test   - Test platform compatibility"
	@echo ""
	@echo "Maintenance:"
	@echo "  make export-aliases  - Export atuin aliases"
	@echo "  make import-aliases  - Import atuin aliases"
	@echo "  make backup-aliases  - Backup and commit aliases"

stow-folders:
	@printf '%s\n' $(STOW_FOLDERS)

stow-install:
	@for folder in $(STOW_FOLDERS); do \
		if [ "$$folder" = pi ]; then \
			echo "Stowing pi (home layout)"; \
			./scripts/pi-home-layout.sh; \
		else \
			echo "Stowing $$folder"; \
			(cd dotfiles && stow --no-folding -D -t $(HOME) $$folder 2>/dev/null || true; \
			 stow --no-folding -t $(HOME) $$folder); \
		fi; \
	done

stow-uninstall stow-clean:
	@for folder in $(STOW_FOLDERS); do \
		if [ "$$folder" = pi ]; then \
			echo "Unstowing pi (home layout)"; \
			./scripts/pi-home-layout.sh --uninstall; \
		else \
			echo "Unstowing $$folder"; \
			(cd dotfiles && stow -t $(HOME) -D $$folder 2>/dev/null || true); \
		fi; \
	done

stow-status:
	@echo "Checking stow status..."
	@cd dotfiles && for folder in $(STOW_FOLDERS); do \
		if stow -t $(HOME) -n -v $$folder 2>&1 | grep -q "LINK:"; then \
			echo "✓ $$folder is installed"; \
		else \
			echo "✗ $$folder is not installed"; \
		fi; \
	done

# Individual tool targets
define make-stow-target
stow-$(1):
	@echo "Stowing $(1)..."
	@cd dotfiles && stow --no-folding -D -t $(HOME) $(1) 2>/dev/null || true
	@cd dotfiles && stow --no-folding -t $(HOME) $(1)

unstow-$(1):
	@echo "Unstowing $(1)..."
	@cd dotfiles && stow -t $(HOME) -D $(1) 2>/dev/null || true
endef

$(foreach tool,$(filter-out pi,$(ALL_STOW_FOLDERS)),$(eval $(call make-stow-target,$(tool))))

stow-pi:
	@echo "Stowing pi (home layout)..."
	@./scripts/pi-home-layout.sh

unstow-pi:
	@echo "Unstowing pi (home layout)..."
	@./scripts/pi-home-layout.sh --uninstall

linux-deps:
	@./scripts/linux-deps.sh

linux-desktop:
	@./scripts/linux-desktop.sh

linux-homelab:
	@./scripts/linux-homelab.sh

bootstrap-linux: linux-deps stow-install
	@echo "Linux bootstrap complete. source ~/.config/shell/linux.sh"

setup-herdr:
	@command -v herdr >/dev/null || { echo "herdr is required"; exit 1; }
	@command -v droid >/dev/null || { echo "droid is required"; exit 1; }
	@herdr integration install droid
	@herdr config check
	@herdr integration status | grep '^droid:'

# CI/CD Testing
test: validate deps platform-test script-test
	@echo "All tests passed!"

validate:
	@./scripts/ci/validate.sh

deps:
	@./scripts/ci/check-dependencies.sh

platform-test:
	@./scripts/ci/test-platforms.sh

script-test:
	@./scripts/ci/test-herdr-fingers.sh
	@./scripts/ci/test-herdr-agents.sh
	@./scripts/ci/test-herdr-pane-rename.sh
	@./scripts/ci/test-herdr-tab-renumber.sh
	@./scripts/ci/test-droid-moshi-notify.sh
	@./scripts/ci/test-pi-config.sh
	@./scripts/ci/test-pi-home-layout.sh
	@./scripts/ci/test-cursor-config.sh
	@./scripts/ci/test-grok-config.sh
	@./scripts/ci/test-dsh-config.sh
	@./scripts/ci/test-cli-proxy-gui-env.sh
	@./scripts/ci/test-gpg-lazygit.sh
	@./scripts/ci/test-nvim-jsonl.sh
	@./scripts/ci/test-linux-bootstrap.sh

install-test:
	@./scripts/ci/test-install.sh

# Docker testing
docker-test-ubuntu:
	@docker build -t dotfiles-test:ubuntu -f tests/ci/Dockerfile.ubuntu .
	@docker run --rm dotfiles-test:ubuntu

docker-test-arch:
	@docker build -t dotfiles-test:arch -f tests/ci/Dockerfile.arch .
	@docker run --rm dotfiles-test:arch

docker-test: docker-test-ubuntu docker-test-arch

# Atuin alias management
export-aliases:
	@./scripts/export-atuin-aliases.sh

import-aliases:
	@./scripts/import-atuin-aliases.sh

# Backup aliases before any major changes
backup-aliases: export-aliases
	@git add dotfiles/atuin/.config/atuin/aliases.sh
	@git commit -m "backup: export current atuin aliases" || true
