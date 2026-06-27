#!/usr/bin/env bash
# Build /Applications/Emacs.app — a small launcher applet for the Dock that opens
# a GUI frame on the always-running Emacs daemon (com.sunny.emacs-daemon).
#
# Why: the daemon is headless, so clicking the real Emacs bundle just brings a
# frameless app forward (an empty/invisible window). This applet runs
# `emacsclient -c' instead, which creates a proper, focused, themed client frame
# (via server-after-make-frame-hook).
#
# Icon: mirrors the emacs-plus app's own icon (selected via
# ~/.config/emacs-plus/build.yml — currently liquid-glass), copying its Tahoe
# Assets.car so the applet gets the native icon with no white tile.
# Idempotent; safe to re-run.
set -euo pipefail

[[ "$OSTYPE" == darwin* ]] || { echo "macOS-only — skipping Emacs launcher."; exit 0; }

APP="/Applications/Emacs.app"
EMACSCLIENT="/opt/homebrew/bin/emacsclient"

# The emacs-plus app whose icon (chosen via ~/.config/emacs-plus/build.yml) we
# mirror onto the launcher.
SRC_APP="/opt/homebrew/opt/emacs-plus@31/Emacs.app"

echo "Building Emacs Dock launcher at $APP ..."

# 1. Compile the applet. It calls a launcher script (written next) that WAITS
#    for the daemon to accept connections before opening a frame, and always
#    exits 0 — so clicking the Dock icon during startup queues a frame instead
#    of raising AppleScript's "command exited with a non-zero status" dialog.
rm -rf "$APP"
osacompile -o "$APP" -e "do shell script \"$APP/Contents/Resources/launch-emacs.sh\""

# 1a. Write that launcher into the bundle (before the codesign step below, so the
#     ad-hoc signature covers it). Escaped \$ stays literal in the script; only
#     $EMACSCLIENT is expanded now.
LAUNCHER="$APP/Contents/Resources/launch-emacs.sh"
cat > "$LAUNCHER" <<EOF
#!/bin/sh
# Poll the Emacs daemon for up to ~10s, then open a GUI frame. Never fails:
# returns 0 even mid-boot, so the launching app shows no error dialog.
c="$EMACSCLIENT"
i=0
while [ \$i -lt 100 ] && ! "\$c" -e t >/dev/null 2>&1; do
  sleep 0.1
  i=\$((i + 1))
done
"\$c" -c -n -a '' >/dev/null 2>&1 || true
EOF
chmod +x "$LAUNCHER"

# 2. Mirror the emacs-plus app's icon onto the applet. On Tahoe that means its
#    Assets.car + CFBundleIconName (a plain .icns gets a white tile); the .icns is
#    the pre-Tahoe fallback. osacompile leaves a generic Assets.car — replace it.
if [[ -d "$SRC_APP" ]]; then
    cp "$SRC_APP/Contents/Resources/Emacs.icns" "$APP/Contents/Resources/applet.icns" 2>/dev/null || true
    rm -f "$APP/Contents/Resources/Assets.car"
    /usr/libexec/PlistBuddy -c 'Delete :CFBundleIconName' "$APP/Contents/Info.plist" 2>/dev/null || true
    if [[ -f "$SRC_APP/Contents/Resources/Assets.car" ]]; then
        cp "$SRC_APP/Contents/Resources/Assets.car" "$APP/Contents/Resources/Assets.car"
        name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconName' "$SRC_APP/Contents/Info.plist" 2>/dev/null || echo Emacs)"
        /usr/libexec/PlistBuddy -c "Add :CFBundleIconName string $name" "$APP/Contents/Info.plist"
    fi
else
    echo "WARN: $SRC_APP not found — applet keeps the generic icon."
fi

# 3. Re-sign ad-hoc (bundle contents changed).
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

# 4. Refresh icon / LaunchServices caches.
lsreg=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
touch "$APP"
"$lsreg" -f "$APP" 2>/dev/null || true
find "$(getconf DARWIN_USER_CACHE_DIR)" -maxdepth 1 -name 'com.apple.iconservices*' -exec rm -rf {} + 2>/dev/null || true
qlmanage -r cache >/dev/null 2>&1 || true
killall Dock 2>/dev/null || true

echo "Done."
echo "Pin $APP to the Dock (drag it from /Applications in Finder)."
echo "If the Dock shows a stale icon, remove the pin and drag it back — the Dock"
echo "caches a pinned app's icon until it's re-added."
