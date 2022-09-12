local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>ng", '<cmd>lua require("neogit").open()<CR>')
  vim.keymap.set("n", "<leader>nc", '<cmd>lua require("neogit").open { "commit" }<CR>')
end

function M.config()
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
