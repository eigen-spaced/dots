#!/usr/bin/env bash
set -e

# --- mise -------------------------------------------------------------------
if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
fi

eval "$(mise activate bash)"  # or zsh

mise install node@latest python@latest go@latest uv@latest pnpm@latest

# --- pnpm globals -------------------------------------------------------------
# pnpm (mise-managed) owns global JS tools. minimumReleaseAge refuses packages
# published less than a week ago, as a guard against npm supply-chain attacks.
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"
pnpm config set --global minimumReleaseAge 10080

pnpm add -g \
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
