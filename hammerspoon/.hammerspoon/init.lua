-- ~/.hammerspoon/init.lua — global hotkeys that drive the Emacs daemon.
--
-- Ported from joshblais.com "How I'm deeply integrating Emacs" (which uses
-- Hyprland `bind' directives on Linux). The pattern is identical, minus his Go
-- launcher: a global hotkey fires a one-line elisp call at the always-on Emacs
-- daemon via `emacsclient'. The daemon (com.sunny.emacs-daemon LaunchAgent) is
-- already running, so emacsclient just talks to its socket — no launcher or
-- bash+sleep timing hack is needed.
--
-- The elisp helper `cust/popup-frame' (defined in ~/.doom.d/config.el) makes a
-- focused macOS GUI frame and runs a command in it. The same commands are also
-- bound under the Doom leader (SPC o d / SPC o n), so the system-wide hotkeys
-- and the in-Emacs leader keys do exactly the same thing.

local EMACSCLIENT = "/opt/homebrew/bin/emacsclient"

-- Evaluate ELISP in the daemon, then pull Emacs to the foreground.
local function emacs(elisp)
  hs.task.new(EMACSCLIENT, function()
    local app = hs.application.get("Emacs")
    if app then app:activate() end
  end, { "-e", elisp }):start()
end

-- Open COMMAND (an interactive command symbol) in a fresh, focused frame.
local function emacsPopup(command)
  emacs("(cust/popup-frame '" .. command .. ")")
end

-- ⌘⌥O  →  org folder in Dirvish
hs.hotkey.bind({ "cmd", "alt" }, "O", function() emacsPopup("cust/dirvish-org") end)

-- ⌘⌥F  →  Dirvish (home / current default-directory of the new frame)
hs.hotkey.bind({ "cmd", "alt" }, "F", function() emacsPopup("dirvish") end)

-- ⌘⌥E  →  emacs-everywhere: edit the focused text field of ANY app in Emacs,
-- C-c C-c to send it back. emacs-everywhere makes/owns its own frame and must
-- run while the *source* app is still frontmost (it records it, then copies the
-- field), so we DON'T pre-activate Emacs here — just fire the command.
-- First use will trigger a macOS prompt to let *Emacs* control "System Events"
-- (Accessibility/Automation); grant it or copy/paste-back won't work.
hs.hotkey.bind({ "cmd", "alt" }, "E", function()
  hs.task.new(EMACSCLIENT, nil, { "-e", "(emacs-everywhere)" }):start()
end)

-- --- Spotify transport (AppleScript → the desktop app) -----------------------
-- Global media hotkeys that drive the local Spotify app from any context — no
-- API key or Premium needed. smudge in Emacs uses this same AppleScript layer
-- for transport, so the two stay in sync.
local function spotify(cmd)
  hs.osascript.applescript('tell application "Spotify" to ' .. cmd)
end

hs.hotkey.bind({ "cmd", "alt" }, "P", function() spotify("playpause") end)        -- ⌘⌥P play/pause
hs.hotkey.bind({ "cmd", "alt" }, "]", function() spotify("next track") end)       -- ⌘⌥] next
hs.hotkey.bind({ "cmd", "alt" }, "[", function() spotify("previous track") end)   -- ⌘⌥[ previous
-- ⌘⌥N now-playing.  (NOT ⌘⌥I — that's Firefox's web-inspector shortcut.)
-- Uses hs.alert (an on-screen HUD) rather than hs.notify, which silently does
-- nothing unless Hammerspoon has been granted Notification permission.
hs.hotkey.bind({ "cmd", "alt" }, "N", function()                                  -- ⌘⌥N now-playing
  local ok, info = hs.osascript.applescript(
    'tell application "Spotify" to (name of current track) & " — " & (artist of current track)')
  hs.alert.show(ok and ("♪  " .. info) or "Spotify isn't running")
end)

-- --- Room to grow: mirror more of the blog as you want it --------------------
-- Global org-capture:
--   hs.hotkey.bind({ "cmd", "alt" }, "C", function() emacsPopup("org-capture") end)

-- Auto-reload on config change, plus ⌘⌥R to reload by hand.
hs.pathwatcher.new(hs.configdir, function(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then hs.reload() end
  end
end):start()
hs.hotkey.bind({ "cmd", "alt" }, "R", function() hs.reload() end)
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
