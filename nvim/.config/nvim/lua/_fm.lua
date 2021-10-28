local M = {}

function M.config()
  require('fm-nvim').setup{
    -- Border around floating window
    border   = "none", -- opts: 'rounded'; 'double'; 'single'; 'solid'; 'shawdow'

    -- Percentage (0.8 = 80%)
    height   = 0.9,
    width    = 0.9,

    -- Command used to open files
    edit_cmd = "edit", -- opts: 'tabedit'; 'split'; 'pedit'; etc...

    -- Terminal commands used w/ file manager
    cmds = {
      lf_cmd     = "lf", -- eg: lf_cmd = "lf -command 'set hidden'"
      xplr_cmd   = "xplr",
    },

    -- Mappings used inside the floating window
    mappings = {
      vert_split = "<C-v>",
      horz_split = "<C-s>",
      tabedit    = "<C-h>",
      edit       = "<C-e>"
    }
  }
end

return M
