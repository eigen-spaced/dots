local M = {}

function M.setup()
  local U = require 'utils'

  U.map('n', '<C-p>', '<cmd>Telescope find_files<CR>', { silent = true, noremap = true })
  U.map('n', '<Leader>bb', '<cmd>Telescope buffers<CR>', { silent = true, noremap = true })
  U.map('n', '<Leader>h', '<cmd>Telescope help_tags<CR>', { silent = true, noremap = true })
end

function M.config()
  local actions = require 'telescope.actions'

  require('telescope').setup {
    defaults = {
      prompt_prefix = ' ❯ ',
      mappings = {
        i = {
          ["<ESC>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-s>"] = actions.select_horizontal,
          ["<TAB>"] = actions.toggle_selection + actions.move_selection_next,
          ["<M-s>"] = actions.send_selected_to_qflist,
          ["<C-q>"] = actions.send_to_qflist
        },
        n = { ['<ESC>'] = actions.close },
      },
      file_ignore_patterns = {
        '%.jpg',
        '%.jpeg',
        '%.png',
        '%.svg',
        '%.otf',
        '%.ttf',
        -- folder contents
        '.git/*',
        'node_modules/*',
        'bower_components/*',
        '.svn/*',
        '.hg/*',
        'CVS/*',
        '.next/*',
        '.docz/*',
        '.DS_Store'
      },
    },
    pickers = {
      find_files = {
        previewer = false,
        theme = 'ivy',
        layout_config = { height = 0.55 },
      }
    }
  }
end

return M
