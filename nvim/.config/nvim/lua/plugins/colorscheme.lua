return {
  {
    "rebelot/kanagawa.nvim",
    -- enabled = false,
    config = function()
      require("kanagawa").setup {
        dimInactive = true,
      }
      vim.cmd("colorscheme kanagawa")
    end,
  },
}
