-- On-demand "focus follows width": the active window grows to `target` columns
-- (enough that formatter-wrapped 80-col lines never visually wrap, accounting
-- for the gutter) while inactive windows shrink. Off by default — toggle with
-- :FocusWidth. Built on the native 'winwidth', so the resize happens
-- automatically whenever you move into a window.
local target = 120

-- Vim defaults, restored when toggling off.
local saved = { winwidth = 20, winminwidth = 1, equalalways = true }
local on = false

vim.api.nvim_create_user_command("FocusWidth", function()
  on = not on
  if on then
    saved = {
      winwidth = vim.o.winwidth,
      winminwidth = vim.o.winminwidth,
      equalalways = vim.o.equalalways,
    }
    vim.o.winwidth = target
    vim.o.winminwidth = 20
    vim.o.equalalways = false
    -- Apply immediately to the current window (winwidth only kicks in on focus).
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      pcall(vim.api.nvim_win_set_width, 0, target)
    end
    vim.notify("FocusWidth on — active window ≥ " .. target .. " cols")
  else
    vim.o.winwidth = saved.winwidth
    vim.o.winminwidth = saved.winminwidth
    vim.o.equalalways = saved.equalalways
    vim.cmd("wincmd =")
    vim.notify("FocusWidth off")
  end
end, { desc = "Toggle focus-follows window width (active window stays wide)" })

-- Size-based split resize (mirrors the tmux PREFIX-arrow resize): the arrow
-- drags the active window's divider in its direction, snapping to fraction
-- stops of the editor instead of stepping by N columns. A window glued to the
-- far edge (right/bottom) only has its inner border to drag, so grow/shrink
-- inverts for it. Replaces the stepwise smart-splits resize on <M-arrow>.
local STOPS = { 25, 33, 50, 67, 75 }

local function next_stop(pct, grow)
  if grow then
    for _, s in ipairs(STOPS) do
      if s > pct + 2 then
        return s
      end
    end
    return STOPS[#STOPS]
  end
  for i = #STOPS, 1, -1 do
    if STOPS[i] < pct - 2 then
      return STOPS[i]
    end
  end
  return STOPS[1]
end

-- axis: "x" (width) or "y" (height); grow = move divider toward right/down.
local function snap_resize(axis, grow)
  local me = vim.fn.winnr()
  local at_far, at_near, total, get, set
  if axis == "x" then
    at_far, at_near = vim.fn.winnr("l") == me, vim.fn.winnr("h") == me
    total = vim.o.columns
    get = function()
      return vim.api.nvim_win_get_width(0)
    end
    set = function(n)
      pcall(vim.api.nvim_win_set_width, 0, n)
    end
  else
    at_far, at_near = vim.fn.winnr("j") == me, vim.fn.winnr("k") == me
    total = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0)
    get = function()
      return vim.api.nvim_win_get_height(0)
    end
    set = function(n)
      pcall(vim.api.nvim_win_set_height, 0, n)
    end
  end
  if at_far and at_near then
    return -- spans the whole axis: no divider to drag
  end
  if at_far and not at_near then
    grow = not grow -- only the inner border is draggable
  end
  local pct = math.floor(get() * 100 / total)
  set(math.floor(total * next_stop(pct, grow) / 100))
end

vim.keymap.set("n", "<M-Right>", function()
  snap_resize("x", true)
end, { desc = "Resize: grow width to next stop" })
vim.keymap.set("n", "<M-Left>", function()
  snap_resize("x", false)
end, { desc = "Resize: shrink width to next stop" })
vim.keymap.set("n", "<M-Down>", function()
  snap_resize("y", true)
end, { desc = "Resize: grow height to next stop" })
vim.keymap.set("n", "<M-Up>", function()
  snap_resize("y", false)
end, { desc = "Resize: shrink height to next stop" })
