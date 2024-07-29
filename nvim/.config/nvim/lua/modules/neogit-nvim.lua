local keymap = vim.keymap
local M = {}

function M.config()
  keymap.set("n", "<leader>ng", '<cmd>lua require("neogit").open()<CR>')
  keymap.set("n", "<leader>nc", '<cmd>lua require("neogit").open { "commit" }<CR>')

  require("neogit").setup {
    signs = {
      section = { "", "" },
      item = { "", "" },
      hunk = { "", "" },
    },
    integrations = {
      diffview = true,
    },
  }
end

return M
