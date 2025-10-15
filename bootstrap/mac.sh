#!/usr/bin/env bash
set -e

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install git stow mise direnv fzf ripgrep jq
source bootstrap/common.sh

