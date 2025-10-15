-- ##########################################
--
-- Utilities for a more enhanced search functionality
--
-- ##########################################

local api, cmd, keymap = vim.api, vim.cmd, vim.keymap

-- Disable helper
local function disable_hl()
  if vim.v.hlsearch == 1 then
    cmd("set nohlsearch")
    vim.cmd("redrawstatus")
  end
end

-- Enable helper
local function enable_hl()
  if vim.fn.getreg("/") ~= "" then
    cmd("set hlsearch")
    vim.cmd("redrawstatus")
  end
end

-- Turn ON hlsearch only while searching with / or ?
api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { "/", "?" },
  callback = enable_hl,
})

-- Disable hlsearch when leaving / or ? search
api.nvim_create_autocmd("CmdlineLeave", {
  pattern = { "/", "?" },
  callback = disable_hl,
})

-- Disable hlsearch when entering insert, visual, or select mode
api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function(ev)
    local _, to = ev.match:match("([^:]+):([^:]+)")
    if to:match("^[ivs]") then
      disable_hl()
    end
  end,
})

-- <Esc> in command-line search mode cancels and disables highlights
api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { "/", "?" },
  callback = function()
    keymap.set("c", "<Esc>", function()
      disable_hl()
      return "<Esc>"
    end, { expr = true, noremap = true, silent = true })
  end,
})

-- Re-enable hlsearch automatically when using n or N (jumping between matches)
keymap.set("n", "n", function()
  enable_hl()
  vim.cmd("normal! n")
end, { noremap = true, silent = true })

keymap.set("n", "N", function()
  enable_hl()
  vim.cmd("normal! N")
end, { noremap = true, silent = true })

keymap.set(
  "n",
  "<ESC>",
  "<cmd>nohlsearch<cr>",
  { silent = true, noremap = true, desc = "Clear search highlight" }
)
