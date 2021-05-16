require('plugins')
local actions = require('telescope.actions')
-- Global remapping

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<ESC>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-o>"] = function()
          return
        end,
        ["<TAB>"] = actions.toggle_selection + actions.move_selection_next,
        ["<C-s>"] = actions.send_selected_to_qflist,
        ["<C-q>"] = actions.send_to_qflist
      }
    },
  }
}

vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>Telescope find_files<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<Leader>bB', '<cmd>Telescope buffers<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<Leader>h', '<cmd>Telescope help_tags<CR>', { silent = true })
