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
    ['<CR>'] = tree_cb 'edit',
    ['o'] = tree_cb 'edit',
    ['l'] = tree_cb 'edit',
    ['<C-v>'] = tree_cb 'vsplit',
    ['<C-s>'] = tree_cb 'split',
    ['<C-t>'] = tree_cb 'tabnew',
    ['R'] = tree_cb 'refresh',
    ['r'] = tree_cb 'rename',
    ['-'] = tree_cb 'dir_up',
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
    folder = { default = '', open = '' },
  }

  -- lazy-loading
  require('nvim-tree.events').on_nvim_tree_ready(function()
    vim.cmd 'NvimTreeRefresh'
  end)
end

return M
