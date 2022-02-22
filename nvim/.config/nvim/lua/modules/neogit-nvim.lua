local M = {}

require("core.utils")

function M.setup()
  nmap("<leader>ng", '<cmd>lua require("neogit").open()<CR>')
  nmap("<leader>nc", '<cmd>lua require("neogit").open { "commit" }<CR>')
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
