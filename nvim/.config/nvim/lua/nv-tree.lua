local M = {}

function M.setup()
  local U = require 'utils'
  U.map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { silent = true, noremap = true })
end

function M.config()
  vim.g.nvim_tree_width = 28
  vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
  vim.g.nvim_tree_auto_close = 1 -- 0 by default, closes the tree when it's the last window
  vim.g.nvim_tree_follow = 1 -- 0 by default, this option allows the cursor to be updated when entering a buffer

  --  Modify some of the key mappings
  local tree_cb = require('nvim-tree.config').nvim_tree_callback
  vim.g.nvim_tree_bindings = {
    { key = '<CR>',     cb = tree_cb 'edit' },
    { key = 'o',        cb = tree_cb('edit') },
    { key = 'l',        cb = tree_cb('edit') },
    { key = '<C-v>',    cb = tree_cb('vsplit') },
    { key = '<C-s>',    cb = tree_cb('split') },
    { key = '<C-t>',    cb = tree_cb('tabnew') },
    { key = 'R',        cb = tree_cb('refresh') },
    { key = 'r',        cb = tree_cb('rename') },
    { key = '-',        cb = tree_cb('dir_up') },
  }

  vim.g.nvim_tree_icons = {
    default = ' ',
    symlink = ' ',
    git = {
      unstaged = '✗',
      staged = '✓',
      unmerged = '',
      renamed = '➜',
      untracked = '★',
    },
    folder = {
      arrow_open = "",
      arrow_closed = "",
      default = "",
      open = "",
      empty = "",
      empty_open = "",
      symlink = "",
      symlink_open = "",
    },
    lsp = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  }

  -- lazy-loading
  require('nvim-tree.events').on_nvim_tree_ready(function()
    vim.cmd 'NvimTreeRefresh'
  end)
end

return M
