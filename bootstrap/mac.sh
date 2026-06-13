#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# fzf is also required by the `doomkeys` script (scripts/ stow package).
brew install git stow mise direnv fzf ripgrep jq tmux ffmpeg
brew install --cask ghostty

# Emacs (emacs-plus@30): built from source; native-comp is on by default. Runs
# as a daemon via the com.sunny.emacs-daemon LaunchAgent (set up in install.sh).
# NOTE: Doom itself (~/.emacs.d + `doom install`/`doom sync`) is managed
# separately; run `doom sync` after install so the native-comp cache matches.
brew install d12frosted/emacs-plus/emacs-plus@30

# libvips ships `vipsthumbnail', which Doom's dirvish uses to render image/
# video/pdf thumbnails in the file manager.
brew install vips

# Hammerspoon: scriptable global macOS hotkeys (Lua) that fire
# `emacsclient -e (...)' at the Emacs daemon — the deep-Emacs-integration layer
# (open org folder, dirvish, etc.). Config is the `hammerspoon' stow package
# (~/.hammerspoon/init.lua). Edit-anywhere (emacs-everywhere) would additionally
# need an Accessibility-permission grant for Hammerspoon in System Settings.
brew install --cask hammerspoon

source "$SCRIPT_DIR/common.sh"
