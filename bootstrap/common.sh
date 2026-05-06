#!/usr/bin/env bash
set -e

# --- mise -------------------------------------------------------------------
if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
fi

eval "$(mise activate bash)"  # or zsh

mise install node@latest python@latest go@latest uv@latest

# --- npm globals ------------------------------------------------------------
npm install -g \
    @fsouza/prettierd \
    neovim \
    @tailwindcss/language-server \
    @vue/typescript-plugin \
    prettier \
    typescript \
    vscode-langservers-extracted \
    @openai/codex

# --- rustup -----------------------------------------------------------------
if ! command -v rustup &>/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --default-toolchain stable --no-modify-path
fi

# Make cargo/rustup available within this script run
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

rustup default stable
rustup component add rust-analyzer rust-src

# --- cargo globals ----------------------------------------------------------
cargo install stylua tree-sitter-cli

# --- verify -----------------------------------------------------------------
node -v && python -V && go version && rustc --version
