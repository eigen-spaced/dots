local M = {}

function M.config()
  require("lualine").setup {
    options = {
      theme = "tokyonight",
      section_separators = { "", "" },
      component_separators = { "", "" },
    },
    sections = {
      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },
      lualine_x = { "encoding", "filetype" },
    },
  }
end

return M
