-- Local plugin living in this config's `lua/projtree/`. `dir` points lazy at
-- the config dir (already on the runtimepath) so it loads on demand without a
-- remote source -- triggered by the keys or the :ProjTree command below.
return {
  "projtree",
  dir = vim.fn.stdpath("config"),
  lazy = true,
  cmd = "ProjTree",
  keys = {
    {
      "<leader>e",
      function()
        require("projtree").toggle()
      end,
      desc = "Toggle project tree",
    },
    -- Mode toggle (folders <-> full) is buffer-local space-space inside the
    -- tree; see lua/projtree/init.lua.
  },
  config = function()
    require("projtree").setup {
      side = "right",
      width = 34,
      mode = "tree",
    }
  end,
}
