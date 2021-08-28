local M = {}

function M.config ()
  require('lualine').setup {
    options = {
      theme = 'palenight',
      section_separators = '',
      component_separators = '',
    },
    sections = {
      lualine_x = {'encoding', 'filetype'},
    }
  }
end

return M
