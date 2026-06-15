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
    # --no-folding => individual file symlinks (never a directory symlink), so
    # apps that write their own state into e.g. ~/.hammerspoon don't pollute the
    # dotfiles repo.
    for pkg in nvim ghostty tmux zsh scripts hammerspoon doom; do
        if [[ -d "$pkg" ]]; then
            read -rp "Stow $pkg? [y/N] " ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                stow --no-folding --restow "$pkg"
            fi
        else
            echo "Skipping $pkg (not found in $DOTFILES_DIR)."
        fi
    done
    cd - >/dev/null
fi

# --- launchd: Emacs daemon (macOS only) ---------------------------------------
# emacs-plus ships a brew service, but `brew services` doesn't expose it for this
# tap ("has not implemented #service"), so we run the daemon from our own agent.
if [[ "$OSTYPE" == "darwin"* ]] && command -v emacs &>/dev/null; then
    echo
    echo "The Emacs daemon runs as a launchd agent (com.sunny.emacs-daemon):"
    echo "it starts 'emacs --fg-daemon' at login and keeps it alive, so the"
    echo "Emacs.app launcher (emacsclient) always has a daemon to attach to."
    read -rp "Install the Emacs daemon agent? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        emacs_label="com.sunny.emacs-daemon"
        emacs_plist="$HOME/Library/LaunchAgents/$emacs_label.plist"
        mkdir -p "$HOME/Library/LaunchAgents"
        cat > "$emacs_plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$emacs_label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/emacs</string>
        <string>--fg-daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/emacs-daemon.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/emacs-daemon.stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
        launchctl bootout "gui/$(id -u)/$emacs_label" 2>/dev/null || true
        if launchctl bootstrap "gui/$(id -u)" "$emacs_plist"; then
            echo "Installed $emacs_label (starts the Emacs daemon at login)."
        else
            echo "WARN: failed to load $emacs_label — plist written to $emacs_plist."
        fi
    else
        echo "Skipped Emacs daemon agent."
    fi
fi

# --- Emacs Dock launcher applet (macOS only) ----------------------------------
# /Applications/Emacs.app is a small applet that opens a daemon frame via
# `emacsclient -c' — clicking the real headless daemon just shows an empty
# window. build-emacs-launcher.sh compiles it with a modern icon (emacs-icon.png).
if [[ "$OSTYPE" == "darwin"* ]] && command -v emacsclient &>/dev/null; then
    echo
    read -rp "Build the Emacs Dock launcher applet (/Applications/Emacs.app)? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        "$SCRIPT_DIR/build-emacs-launcher.sh"
    else
        echo "Skipped Emacs Dock launcher."
    fi
fi

# --- launchd: update-all reminder (macOS only) --------------------------------
# Runs after the stow step so ~/.config/scripts/update-all exists.
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo
    echo "The update reminder is a launchd agent (com.sunny.update-reminder)."
    echo "It runs a check daily at 11:00 and shows a notification when"
    echo "'update-all' hasn't been run for 14+ days. It only notifies —"
    echo "it never installs or updates anything by itself."
    read -rp "Install the launchd reminder agent? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        agent_label="com.sunny.update-reminder"
        agent_plist="$HOME/Library/LaunchAgents/$agent_label.plist"
        mkdir -p "$HOME/Library/LaunchAgents"
        cat > "$agent_plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$agent_label</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.config/scripts/update-all</string>
        <string>--remind</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>11</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
EOF
        launchctl bootout "gui/$(id -u)/$agent_label" 2>/dev/null || true
        if launchctl bootstrap "gui/$(id -u)" "$agent_plist"; then
            echo "Installed $agent_label (daily 11:00 check)."
        else
            echo "WARN: failed to load $agent_label — plist written to $agent_plist."
        fi
    else
        echo "Skipped launchd reminder agent."
    fi
fi

# --- Post-install: Emacs integration (macOS only) -----------------------------
# The mu4e/smudge/emacs-everywhere stack needs interactive, credential-bearing
# steps (app password, Spotify creds, Accessibility grant) that can't be baked
# into an unattended bootstrap. Run the guided helper when ready.
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo
    echo "Emacs deep-integration (mu4e/smudge/emacs-everywhere) has interactive"
    echo "setup steps. When ready, run:  bootstrap/setup-emacs-integration.sh"
    echo "Reference: bootstrap/emacs-integration.md"
fi
