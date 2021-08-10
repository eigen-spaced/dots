local M = {}

function M.config()
  require'navigator'.setup({
    debug = false, -- log output
    code_action_icon = " ",
    width = 0.75, -- max width ratio (number of cols for the floating window) / (window width)
    height = 0.3, -- max list window height, 0.3 by default
    preview_height = 0.35, -- max height of preview windows

    default_mapping = true,  -- set to false if you will remap every key
    keymaps = {{key = "gK", func = "declaration()"}},
  })
end

return M
