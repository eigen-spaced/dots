return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.comment").setup()
    require("mini.surround").setup()
    require("mini.icons").setup()
    require("mini.misc").setup()

    require("mini.files").setup()
    vim.keymap.set("n", "<leader>.", function()
      MiniFiles.open()
    end, { desc = "Open MiniFiles" })

    require("conf.mini_statusline").setup()
  end,
}
