local M = {}

require("core.utils")

function M.config()
  vim.keymap.set("n", "'", '<cmd>lua require("neoclip.fzf")()<CR>')

  require("neoclip").setup {
    history = 1000,
    keys = {
      fzf = {
        select = "default",
        paste = "ctrl-l",
        paste_behind = "ctrl-h",
      },
    },
  }
end

return M
