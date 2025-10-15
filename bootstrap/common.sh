#!/usr/bin/env bash
set -e

# Initialize mise
if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
fi

eval "$(mise activate bash)"  # or zsh

# Install runtimes
mise install node@latest python@latest go@latest uv@latest

# Global npm packages
npm install -g @biomejs/biome @fsouza/prettierd neovim @tailwindcss/language-server @vue/typescript-plugin prettier typescript vscode-langservers-extracted

# Verify
node -v && python -V && go version

