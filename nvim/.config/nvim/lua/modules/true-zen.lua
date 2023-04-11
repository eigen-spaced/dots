local zen_ok, zen = pcall(require, "true-zen")

if not zen_ok then
  return
end

local M = {}

M.config = function()
  zen.setup {
    modes = {
      ataraxis = {
        open_callback = function()
          vim.opt.laststatus = 0
        end,
        close_callback = function()
          vim.opt.laststatus = 3
        end,
      },
      minimalist = {
        open_callback = function()
          vim.opt.laststatus = 0
        end,
        close_callback = function()
          vim.opt.laststatus = 3
        end,
      },
      },
    integrations = {
      lualine = false, -- hide nvim-lualine (ataraxis)
    },
  }
  local api = vim.api

  api.nvim_set_keymap("n", "<leader>zn", ":TZNarrow<CR>", {})
  api.nvim_set_keymap("v", "<leader>zn", ":'<,'>TZNarrow<CR>", {})
  api.nvim_set_keymap("n", "<leader>zf", ":TZFocus<CR>", {})
  api.nvim_set_keymap("n", "<leader>zm", ":TZMinimalist<CR>", {})
  api.nvim_set_keymap("n", "<leader>za", ":TZAtaraxis<CR>", {})
end

return M
