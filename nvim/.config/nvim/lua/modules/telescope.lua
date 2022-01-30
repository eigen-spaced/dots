local M = {}

function M.setup()
  local nmap = require("core.utils").nmap

  function _G.__telescope_buffers()
    require('telescope.builtin').buffers(
      require('telescope.themes').get_dropdown {
        previewer = false,
        only_cwd = vim.fn.haslocaldir() == 1,
        show_all_buffers = false,
        sort_mru = true,
        ignore_current_buffer = true,
        sorter = require('telescope.sorters').get_substr_matcher(),
        selection_strategy = 'closest',
        layout_strategy = 'center',
        winblend = 0,
        layout_config = { width = 70 },
        color_devicons = true,
      }
    )
  end

  nmap("<C-p>", '<cmd>lua require "telescope.builtin".find_files()<CR>')
  -- nmap("<Leader>bb", '<cmd>lua require "telescope.builtin".buffers()<CR>')
  nmap("<Leader>bb", '<cmd>lua __telescope_buffers()<CR>')
  nmap("<Leader>h", '<cmd>lua require "telescope.builtin".help_tags()<CR>')
end

function M.config()
  local status_ok, actions = pcall(require, "telescope.actions")

  if not status_ok then
    return
  end

  require("telescope").setup {
    defaults = {
      prompt_prefix = " ❯ ",
      mappings = {
        i = {
          ["<ESC>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-s>"] = actions.select_horizontal,
          ["<TAB>"] = actions.toggle_selection + actions.move_selection_next,
          ["<M-s>"] = actions.send_selected_to_qflist,
          ["<C-q>"] = actions.send_to_qflist,
        },
        n = { ["<ESC>"] = actions.close },
      },
      file_ignore_patterns = {
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.svg",
        "%.otf",
        "%.ttf",
        -- folder contents
        ".git/*",
        "node_modules/*",
        "bower_components/*",
        ".svn/*",
        ".hg/*",
        "CVS/*",
        ".next/*",
        ".docz/*",
        ".DS_Store",
      },
      set_env = { COLORTERM = 'truecolor' },
      color_devicons = true,
      scroll_strategy = 'limit',
    },
    pickers = {
      find_files = {
        previewer = false,
      },
    },
  }
end

return M
