local M = {}

require("core.utils")

function M.setup()
  nmap(
    "'",
    '<cmd>lua require("neoclip"); require("telescope").extensions.neoclip.default()<CR>'
  )
end

function M.config()
  require("neoclip").setup {
    history = 1000,
    keys = {
      telescope = {
        i = {
          paste = "<c-a>",
          paste_behind = "<c-b>",
        },
      },
    },
  }
end

return M
