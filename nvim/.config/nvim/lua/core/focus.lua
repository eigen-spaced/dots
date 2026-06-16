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

-- Size-based split resize, matching the tmux PREFIX-arrow behaviour: the arrow
-- drags the shared border in its own direction, snapping to fraction stops
-- (25/33/50/67/75%). So <C-Right> always moves the divider right (left split
-- grows, right shrinks) regardless of focus; <C-Up>/<C-Down> likewise for
-- stacked splits. Bound to Ctrl+<arrow>. Replaces the stepwise resize.
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

-- axis "x"/"y"; toward_far = arrow points right/down. The border follows the
-- arrow, so a split on the far (right/bottom) edge — which only has its inner
-- border to move — flips grow/shrink.
local function snap_resize(axis, toward_far)
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
    return -- only split on this axis: nothing to resize against
  end
  local grow = toward_far
  if at_far then
    grow = not grow -- far-edge split moves its inner border, so flip
  end
  local pct = math.floor(get() * 100 / total)
  set(math.floor(total * next_stop(pct, grow) / 100))
end

vim.keymap.set("n", "<leader>w>", function()
  snap_resize("x", true)
end, { desc = "Resize: move split border right" })
vim.keymap.set("n", "<leader>w<", function()
  snap_resize("x", false)
end, { desc = "Resize: move split border left" })
vim.keymap.set("n", "<leader>w-", function()
  snap_resize("y", true)
end, { desc = "Resize: move split border down" })
vim.keymap.set("n", "<leader>w+", function()
  snap_resize("y", false)
end, { desc = "Resize: move split border up" })
