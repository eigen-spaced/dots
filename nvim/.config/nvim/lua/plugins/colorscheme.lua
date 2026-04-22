return {
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup {
        options = {
          dim_inactive = true,
          styles = {
            functions = "bold",
            keywords = "italic",
          },
        },
      }
      vim.cmd("colorscheme terafox")
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    enabled = false,
    config = function()
      require("kanagawa").setup {
        dimInactive = true,
      }
      vim.cmd("colorscheme kanagawa")
    end,
  },
}
