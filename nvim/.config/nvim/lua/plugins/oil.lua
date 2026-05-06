return {
  "stevearc/oil.nvim",
  opts = {
    delete_to_trash = false,
    keymaps = {
      ["<C-s>"] = "actions.select_split",
      ["<C-v>"] = "actions.select_vsplit",
      ["<Esc>"] = "actions.close",
    },
    float = {
      -- Padding around the floating window
      max_width = 50,
      max_height = 0.5,
      border = "double",
      win_options = {
        winblend = 10,
      },
    },
  },
  keys = {
    -- vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
    {
      "-",
      function()
        require("oil").toggle_float()
      end,
      mode = { "n", "x" },
      desc = "Open folder under current folder",
    },
  },
}
