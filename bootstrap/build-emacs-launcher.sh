#!/usr/bin/env bash
# Build /Applications/Emacs.app — a small launcher applet for the Dock that opens
# a GUI frame on the always-running Emacs daemon (com.sunny.emacs-daemon).
#
# Why: the daemon is headless, so clicking the real Emacs bundle just brings a
# frameless app forward (an empty/invisible window). This applet runs
# `emacsclient -c' instead, which creates a proper, focused, themed client frame
# (via server-after-make-frame-hook).
#
# Icon: built from bootstrap/emacs-icon.png if present (the bundled Emacs.icns is
# legacy-format and renders blank on current macOS), else falls back to it.
# Idempotent; safe to re-run.
set -euo pipefail

[[ "$OSTYPE" == darwin* ]] || { echo "macOS-only — skipping Emacs launcher."; exit 0; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="/Applications/Emacs.app"
EMACSCLIENT="/opt/homebrew/bin/emacsclient"

# Icon source: prefer the repo PNG, else the installed emacs-plus icon.
ICON_SRC="$SCRIPT_DIR/emacs-icon.png"
[[ -f "$ICON_SRC" ]] || ICON_SRC="$(find /opt/homebrew/Cellar -path '*emacs-plus*/Emacs.app/Contents/Resources/Emacs.icns' 2>/dev/null | sort | tail -1)"

echo "Building Emacs Dock launcher at $APP ..."

# 1. Compile the applet: open a daemon frame with `emacsclient -c'.
scpt="$(mktemp -t emacs-launcher).applescript"
printf '%s\n' "do shell script \"$EMACSCLIENT -c -n -a '' >/dev/null 2>&1\"" > "$scpt"
rm -rf "$APP"
osacompile -o "$APP" "$scpt"
rm -f "$scpt"

# 2. Build + install a modern, multi-resolution icns. (iconutil requires the
#    staging directory to be named *.iconset.)
if [[ -n "$ICON_SRC" && -f "$ICON_SRC" ]]; then
    stage="$(mktemp -d)"; iset="$stage/Emacs.iconset"; mkdir -p "$iset"
    # name:pixels — @2x entries are double their base.
    for spec in 16:icon_16x16 32:icon_16x16@2x 32:icon_32x32 64:icon_32x32@2x \
                128:icon_128x128 256:icon_128x128@2x 256:icon_256x256 \
                512:icon_256x256@2x 512:icon_512x512; do
        px="${spec%%:*}"; name="${spec##*:}"
        sips -s format png -z "$px" "$px" "$ICON_SRC" --out "$iset/$name.png" >/dev/null 2>&1
    done
    iconutil -c icns "$iset" -o "$APP/Contents/Resources/applet.icns"
    rm -rf "$stage"
    # macOS 26's osacompile compiles the (generic) applet icon into an asset
    # catalog that overrides CFBundleIconFile. Drop it so our applet.icns wins.
    /usr/libexec/PlistBuddy -c 'Delete :CFBundleIconName' "$APP/Contents/Info.plist" 2>/dev/null || true
    rm -f "$APP/Contents/Resources/Assets.car"
else
    echo "WARN: no icon source found — applet keeps the generic icon."
fi

# 3. Re-sign ad-hoc (bundle contents changed).
codesign --force --sign - "$APP" >/dev/null 2>&1 || true

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
