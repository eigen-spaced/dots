#!/usr/bin/env bash
set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    source bootstrap/mac.sh
elif [[ -f /etc/arch-release ]]; then
    source bootstrap/arch.sh
else
    echo "Unsupported OS."
    exit 1
fi

# Stow dotfiles
stow --restow zsh nvim wezterm emacs 2>/dev/null || true

