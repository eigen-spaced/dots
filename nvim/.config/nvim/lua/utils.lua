local api = vim.api
local fn = vim.fn

local U = {}

-- Convienent Key mapping function
function U.map(mode, key, result, opts)
  opts = opts or {}

  api.nvim_set_keymap(mode, key, result, opts)
end

return U
