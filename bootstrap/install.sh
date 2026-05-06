#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    source "$SCRIPT_DIR/mac.sh"
elif [[ -f /etc/arch-release ]]; then
    source "$SCRIPT_DIR/arch.sh"
else
    echo "Unsupported OS."
    exit 1
fi

# --- Dotfiles ---------------------------------------------------------------
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/eigen-spaced/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

dotfiles_ready=false
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo "Updating dotfiles in $DOTFILES_DIR..."
    if git -C "$DOTFILES_DIR" pull --ff-only; then
        dotfiles_ready=true
    else
        echo "WARN: 'git pull' failed in $DOTFILES_DIR — skipping stow/linking."
    fi
else
    echo "Cloning $DOTFILES_REPO into $DOTFILES_DIR..."
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        dotfiles_ready=true
    else
        echo "WARN: failed to clone $DOTFILES_REPO — skipping stow/linking."
    fi
fi

# Prompt to stow packages
if ! command -v stow &>/dev/null; then
    echo "Skipping stow step: stow not installed."
elif ! $dotfiles_ready; then
    echo "Skipping stow step: dotfiles unavailable."
else
    cd "$DOTFILES_DIR"
    for pkg in nvim ghostty tmux zsh; do
        if [[ -d "$pkg" ]]; then
            read -rp "Stow $pkg? [y/N] " ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                stow --restow "$pkg"
            fi
        else
            echo "Skipping $pkg (not found in $DOTFILES_DIR)."
        fi
    done
    cd - >/dev/null
fi
