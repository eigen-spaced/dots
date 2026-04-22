return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.comment").setup()
    require("mini.surround").setup()
    require("mini.icons").setup()
    require("mini.misc").setup()

    require("conf.mini_statusline").setup()
  end,
}
