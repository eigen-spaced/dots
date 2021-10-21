local M = {}

function M.config ()
  require("bufferline").setup{}

  local U = require'utils'
  local nmap = U.nmap

  nmap('<leader>n', '<cmd>:BufferLineCycleNext<CR>')
  nmap('<leader>p', '<cmd>:BufferLineCyclePrev<CR>')
end

return M
