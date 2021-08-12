local M = {}

function M.config()
  require('trouble').setup {
    open_split = { "<c-x>" },
  }
end

return M

