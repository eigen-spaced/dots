local M = {}

function M.setup()
  local U = require "core.utils"
  U.map(
    "n",
    "<leader>e",
    "<cmd>NeoTreeFloatToggle<CR>",
    { silent = true, noremap = true }
  )
end

function M.config()
  require("neo-tree").setup {
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      use_libuv_file_watcher = false, -- This will use the OS level file watchers
    },
    buffers = {
      show_unloaded = true,
      window = {
        position = "left",
        mappings = {
          ["<cr>"] = "open",
          ["<c-s>"] = "open_split",
          ["<c-v>"] = "open_vsplit",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
        },
      },
    },
  }
end

return M
