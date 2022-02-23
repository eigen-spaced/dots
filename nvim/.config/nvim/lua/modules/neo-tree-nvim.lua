local M = {}

require("core.utils")

function M.setup()
  nmap("<leader><leader>", "<cmd>NeoTreeFloatToggle<CR>")
  nmap("<leader>e", "<cmd>NeoTreeRevealToggle<CR>")
end

function M.config()
  require("neo-tree").setup {
    close_if_last_window = true,
    follow_current_file = false,
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      use_libuv_file_watcher = false, -- This will use the OS level file watchers
      window = {
        width = 33,
        mappings = {
          ["o"] = "open",
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
