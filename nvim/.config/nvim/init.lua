local cmd, api = vim.cmd, vim.api

require("core.options")
require("core.colors")
require("core.statusline")
require("core.winbar")
require("core.keymap")
require("core.search")

-- Bootstrap lazy
local plugins_ok, _ = pcall(require, "conf.lazy")
if not plugins_ok then
  vim.notify("Failed to load plugin manager. Core config loaded.")
end

-- prevent auto commenting of new lines
local auto_comment_group =
  api.nvim_create_augroup("DisableAutoComment", { clear = true })
api.nvim_create_autocmd("BufEnter", {
  command = "set fo-=c fo-=r fo-=o",
  group = auto_comment_group,
  pattern = "*",
})
-- Don't screw up folds when inserting text that might affect them, until
-- leaving insert mode. Foldmethod is local to the window. Protect against
-- screwing up folding when switching between windows.
cmd([[
    augroup folds
      autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
      autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
    augroup END
  ]])

api.nvim_create_augroup("bufcheck", { clear = true })

-- reload config file on change
api.nvim_create_autocmd("BufWritePost", {
  group = "bufcheck",
  pattern = vim.env.MYVIMRC,
  command = "silent source %",
})

vim.api.nvim_create_autocmd("FileType", {
  group = "bufcheck",
  pattern = { "gitcommit", "gitrebase" },
  command = "startinsert | 1",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "bufcheck",
  pattern = { "*.njk", "*.ejs" },
  command = "set filetype=html",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "bufcheck",
  pattern = "*.styl",
  command = "set filetype=css",
})

-- highlight yanked text briefly
api.nvim_create_autocmd("TextYankPost", {
  group = "bufcheck",
  callback = function()
    vim.highlight.on_yank { higroup = "Search", timeout = 250, on_visual = true }
  end,
  pattern = "*",
})

-- Enable spell checking for certain file types
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "bufcheck",
  pattern = { "*.txt", "*.md", "*.tex" },
  callback = function()
    local buf_path = vim.api.nvim_buf_get_name(1)
    local config_path = vim.fn.stdpath("data")

    if config_path ~= nil then
      local file_dir = vim.fn.fnamemodify(buf_path, ":h")
      if file_dir:find(config_path, 1, true) == 1 then
        return
      end

      cmd([[ setlocal spell ]])
    end
  end,
})

api.nvim_create_autocmd("VimResized", { command = "wincmd =" })

-- prettier_d doesn't seem to reset the prettier config unless we run `prettierd restart`
-- So  use this autocmd to run the cmd when we make changes to prettier config
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("PrettierConfigWatch", { clear = true }),
  pattern = {
    "prettier.config.js",
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yaml",
  },
  callback = function()
    local ok, _ = pcall(vim.fn.system, "prettierd restart")
    if ok then
      vim.notify("Prettierd restarted successfully!", vim.log.levels.INFO)
    else
      vim.notify("Failed to restart Prettierd", vim.log.levels.ERROR)
    end
  end,
})

vim.opt.cmdheight = 1

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = vim.api.nvim_create_augroup(
    "cmdheight_1_on_cmdlineenter",
    { clear = true }
  ),
  desc = "Don't hide the status line when typing a command",
  command = ":set cmdheight=1",
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = vim.api.nvim_create_augroup(
    "cmdheight_0_on_cmdlineleave",
    { clear = true }
  ),
  desc = "Hide cmdline when not typing a command",
  command = ":set cmdheight=0",
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup(
    "hide_message_after_write",
    { clear = true }
  ),
  desc = "Get rid of message after writing a file",
  pattern = { "*" },
  command = "redrawstatus",
})
