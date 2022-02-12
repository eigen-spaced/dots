local M = {}

function M.setup()
  local U = require"core.utils"
  U.map(
    "n",
    "<leader><leader>",
    "<cmd>NeoTreeFloatToggle<CR>",
    { silent = true, noremap = true }
  )
  U.map(
    "n",
    "<leader>e",
    "<cmd>NeoTreeRevealToggle<CR>",
    { silent = true, noremap = true }
  )
end

function M.config()
  require("neo-tree").setup({
    follow_current_file = false,
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      use_libuv_file_watcher = false, -- This will use the OS level file watchers
      window = {
        width = 30,
        mappings = {
          ["o"] = "open",
          ["<c-s>"] = "open_split",
          ["<c-v>"] = "open_vsplit",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
        },
      },
    },
  })
end

return M
