#!/usr/bin/env bash
# Build & register a macOS handler app for `org-protocol://' URLs, so a browser
# bookmarklet can capture straight into the running Emacs (org-capture). macOS
# delivers custom-scheme URLs via an Apple Event, so the handler is a tiny
# AppleScript app with an `on open location' handler that shells out to
# emacsclient. Idempotent — safe to re-run. macOS only.
set -uo pipefail
[[ "$OSTYPE" == darwin* ]] || { echo "macOS only."; exit 1; }

APP="$HOME/Applications/OrgProtocol.app"
EMACSCLIENT="${EMACSCLIENT:-/opt/homebrew/bin/emacsclient}"

mkdir -p "$HOME/Applications"
tmp="$(mktemp -d)"
cat > "$tmp/handler.applescript" <<EOF
on open location this_URL
    do shell script "$EMACSCLIENT -n " & quoted form of this_URL
end open location
EOF

rm -rf "$APP"
osacompile -o "$APP" "$tmp/handler.applescript" || { echo "osacompile failed"; exit 1; }
rm -rf "$tmp"

# Declare the org-protocol URL scheme in the app's Info.plist.
PLIST="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string 'org-protocol handler'" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string org-protocol" "$PLIST" 2>/dev/null || true

# Register it with LaunchServices as the org-protocol:// handler.
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
"$LSREGISTER" -f "$APP"

echo "Registered $APP as the org-protocol:// handler."
echo "Test:  open 'org-protocol://capture?template=w&url=https%3A%2F%2Fexample.com&title=Example'"
