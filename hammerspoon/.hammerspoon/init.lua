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

-- Load the IPC module so the `hs` command-line tool can talk to this instance
-- (e.g. `echo 'hs.reload()' | hs`). Harmless if the CLI is never used.
require("hs.ipc")

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

-- ⌘⌥C  →  zero-decision capture into inbox.org (small floating frame)
hs.hotkey.bind({ "cmd", "alt" }, "C", function() emacs("(my/capture-frame)") end)

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

-- --- Window + buffer switcher (Contexts-style) ------------------------------
-- ⌥Space opens a HUD listing on-screen windows AND open Emacs file-buffers,
-- each with a single key assigned (F → Firefox, g → ghostty, c → config.el …);
-- tap the key to jump straight there. Within the HUD: `/` drops into a fuzzy
-- search (hs.chooser) over the same list — useful when you don't recall the
-- letter — and Escape cancels. The two modes never collide: single-key is the
-- default, and typing only begins after you explicitly hit `/`. cmd+tab is left
-- untouched. Keys come from the entry name (first free letter), digits 1-9 as a
-- fallback, so a second Firefox window gets the next free letter of "firefox".
--
-- Each entry is { name, detail, action }. Windows and Emacs buffers are unified
-- behind that shape so the HUD and the fuzzy chooser share one list.
local switchAssigned = {}   -- key -> entry
local switchEntries = {}    -- all entries (incl. those that got no key)
local switchModal = nil

-- Monospace HUD so the [key] / name / detail columns line up cleanly.
local SWITCH_STYLE = {
  textFont = "Menlo", textSize = 16, radius = 12, strokeWidth = 0,
  fillColor = { white = 0, alpha = 0.92 }, textColor = { white = 1 },
  padding = 18,
}

-- Truncate S to N characters (UTF-8 aware), adding an ellipsis if it was cut,
-- so long window titles can't blow out the HUD or wrap onto a second line.
local function clip(s, n)
  s = s or ""
  if (utf8.len(s) or #s) <= n then return s end
  local stop = utf8.offset(s, n + 1)
  return (s:sub(1, (stop or (#s + 1)) - 1):gsub("%s+$", "")) .. "…"
end

-- Ask the daemon for file-visiting buffer names, newline-joined (async, so we
-- never block the UI on the socket; daemon down → just windows).
local LIST_BUFFERS_ELISP =
  "(mapconcat 'buffer-name (seq-filter 'buffer-file-name (buffer-list)) \"\\n\")"

-- emacsclient -e prints the result prin1'd: a quoted string with \n / \" / \\
-- escaped. Strip the quotes and unescape back into a list of names.
local function parseBufferList(out)
  if not out then return {} end
  out = out:match("^%s*(.-)%s*$")
  if out == "" or out == "nil" then return {} end
  out = out:gsub('^"(.*)"$', "%1")
  out = out:gsub("\\n", "\n"):gsub('\\"', '"'):gsub("\\\\", "\\")
  local names = {}
  for line in out:gmatch("[^\n]+") do names[#names + 1] = line end
  return names
end

-- First letter of NAME not already in USED; digits 1-9 as a fallback.
local function switchPickKey(name, used)
  for c in name:lower():gmatch("%a") do
    if not used[c] then return c end
  end
  for i = 1, 9 do
    if not used[tostring(i)] then return tostring(i) end
  end
end

local function switchClose()
  if switchModal then switchModal:exit(); switchModal = nil end
  hs.alert.closeAll()
  switchAssigned = {}
end

-- Focus an existing Emacs buffer: reuse a visible GUI frame (or make one),
-- give it input focus, switch to the buffer; emacs() then activates the app.
local function emacsSwitchBuffer(name)
  local safe = name:gsub("\\", "\\\\"):gsub('"', '\\"')
  emacs("(let ((f (or (seq-find 'frame-visible-p (frame-list)) (make-frame))))" ..
        " (select-frame-set-input-focus f)" ..
        ' (switch-to-buffer "' .. safe .. '"))')
end

-- `/` from the HUD: fuzzy-search the same entries via hs.chooser. The chooser
-- owns all typing (no single-key bindings here), so the modes can't interfere.
local function switchFuzzy()
  if switchModal then switchModal:exit(); switchModal = nil end
  hs.alert.closeAll()
  local choices = {}
  for i, e in ipairs(switchEntries) do
    choices[#choices + 1] = { text = e.name, subText = e.detail, idx = i }
  end
  local chooser = hs.chooser.new(function(choice)
    if choice and switchEntries[choice.idx] then switchEntries[choice.idx].action() end
  end)
  chooser:choices(choices)
  chooser:searchSubText(true)
  chooser:show()
end

-- Build the unified entry list, assign keys, draw the HUD, enter the modal.
-- Called from switchShow's emacs callback so buffers are already fetched.
local function switchBuild(buffers)
  switchModal = hs.hotkey.modal.new()
  switchEntries = {}
  local used, rows, lines = {}, {}, {}
  local haveBuffers = #buffers > 0

  for _, win in ipairs(hs.window.orderedWindows()) do
    local app = win:application():name()
    -- Emacs is buffer-oriented: when we have its buffers, skip its OS windows
    -- so the same file isn't listed twice (its window title ≈ current buffer).
    -- If the daemon gave us nothing, fall back to showing the Emacs window.
    if not (haveBuffers and app == "Emacs") then
      switchEntries[#switchEntries + 1] = {
        name = app, detail = win:title(),
        action = function() win:focus() end,
      }
    end
  end
  for _, buf in ipairs(buffers) do
    switchEntries[#switchEntries + 1] = {
      name = buf, detail = "Emacs",
      action = function() emacsSwitchBuffer(buf) end,
    }
  end

  for _, e in ipairs(switchEntries) do
    local key = switchPickKey(e.name, used)
    if key then
      used[key] = true
      switchAssigned[key] = e
      switchModal:bind("", key, function()
        local x = switchAssigned[key]
        switchClose()
        if x then x.action() end
      end)
      rows[#rows + 1] = { key = key:upper(), name = clip(e.name, 28), detail = e.detail }
    end
  end

  -- Pad the name column to the widest name (monospace → real alignment), then
  -- clip the detail so every row is one tidy line: "[K]  name      detail".
  local namew = 0
  for _, r in ipairs(rows) do namew = math.max(namew, #r.name) end
  for _, r in ipairs(rows) do
    lines[#lines + 1] = string.format("[%s]  %-" .. namew .. "s   %s",
      r.key, r.name, clip(r.detail, 52))
  end

  table.insert(lines, "")
  table.insert(lines, string.format(" %-" .. (namew + 4) .. "s   %s", "/ search", "esc cancel"))
  switchModal:bind("", "/", switchFuzzy)
  switchModal:bind("", "escape", switchClose)
  hs.alert.show(table.concat(lines, "\n"), SWITCH_STYLE, hs.screen.mainScreen(), "infinite")
  switchModal:enter()
end

local function switchShow()
  switchClose()
  local task = hs.task.new(EMACSCLIENT, function(_, out)
    switchBuild(parseBufferList(out))
  end, { "-e", LIST_BUFFERS_ELISP })
  if task then task:start() else switchBuild({}) end
end

hs.hotkey.bind({ "alt" }, "space", switchShow)   -- ⌥Space  window/buffer switcher

-- Auto-reload on config change, plus ⌘⌥R to reload by hand.
local function reloadOnLua(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then hs.reload() end
  end
end
hs.pathwatcher.new(hs.configdir, reloadOnLua):start()

-- init.lua is a symlink into ~/dotfiles; FSEvents reports edits against the
-- REAL path, so the watcher above never sees them. Also watch the real dir.
local realInit = hs.fs.pathToAbsolute(hs.configdir .. "/init.lua")
local realDir = realInit and realInit:match("(.*)/")
if realDir and realDir ~= hs.configdir then
  hs.pathwatcher.new(realDir, reloadOnLua):start()
end
hs.hotkey.bind({ "cmd", "alt" }, "R", function() hs.reload() end)
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
