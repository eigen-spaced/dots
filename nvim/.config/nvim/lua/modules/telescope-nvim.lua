local M = {}

require("core.utils")

function M.setup()
  function _G.__telescope_buffers()
    require("telescope.builtin").buffers(
      require("telescope.themes").get_dropdown {
        previewer = false,
        prompt_title = "Jump to buffer",
        only_cwd = vim.fn.haslocaldir() == 1,
        show_all_buffers = false,
        sort_mru = true,
        ignore_current_buffer = true,
        sorter = require("telescope.sorters").get_substr_matcher(),
        selection_strategy = "closest",
        layout_strategy = "center",
        winblend = 0,
        layout_config = { width = 70 },
        color_devicons = true,
      }
    )
  end

  function _G.__telescope_find_files()
    require("telescope.builtin").find_files {
      previewer = false,
      layout_config = { width = 0.7 },
      color_devicons = true,
    }
  end

  function _G.__telescope_grep()
    require("telescope.builtin").live_grep {
      -- path_display = {},
      layout_strategy = "horizontal",
      layout_config = { preview_width = 0.6 },
    }
  end

  function _G.__telescope_help()
    require("telescope.builtin").help_tags(
      require("telescope.themes").get_dropdown {
        layout_config = { height = 10, width = 0.7 },
      }
    )
  end

  nmap("<C-p>", "<cmd>lua __telescope_find_files()<CR>")
  nmap("<Leader>bb", "<cmd>lua __telescope_buffers()<CR>")
  nmap("<Leader>fw", "<cmd>lua __telescope_grep()<CR>")
  nmap("<Leader><leader>h", "<cmd>lua __telescope_help()<CR>")
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
      set_env = { COLORTERM = "truecolor" },
      color_devicons = true,
      scroll_strategy = "limit",
    },
  }
end

return M
