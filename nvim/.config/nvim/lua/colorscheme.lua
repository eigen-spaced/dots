local M = {}

function M.config()
  vim.g.moonlight_italic_keywords = false
  require('moonlight').set()
end

return M

