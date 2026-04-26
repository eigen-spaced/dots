return {
  "vieitesss/miniharp.nvim",
  version = "*", -- latest stable release
  -- branch = 'main', -- latest nightly version
  opts = {
    autoload = true,
    autosave = true,
    show_on_autoload = false,
    ui = {
      position = "center", -- `top-left`, `top-right`, `bottom-left`, `bottom-right`.
      show_hints = true,
      enter = true, -- Whether to enter the floating window or not
    },
  },
  config = function()
    local miniharp = require("miniharp")

    vim.keymap.set(
      "n",
      "<leader>m",
      miniharp.toggle_file,
      { desc = "miniharp: toggle file mark" }
    )
    vim.keymap.set(
      "n",
      "<leader>nm",
      miniharp.next,
      { desc = "miniharp: next file mark" }
    )
    vim.keymap.set(
      "n",
      "<leader>pm",
      miniharp.prev,
      { desc = "miniharp: prev file mark" }
    )
    -- vim.keymap.set(
    --   "n",
    --   "<leader>l",
    --   miniharp.show_list,
    --   { desc = "miniharp: toggle marks list" }
    -- )
    vim.keymap.set(
      "n",
      "<leader>L",
      miniharp.enter_list,
      { desc = "miniharp: enter marks list" }
    )

    vim.keymap.set("n", "<leader>1", function()
      miniharp.go_to(1)
    end, { desc = "miniharp: go to mark 1" })
    vim.keymap.set("n", "<leader>2", function()
      miniharp.go_to(2)
    end, { desc = "miniharp: go to mark 2" })
    vim.keymap.set("n", "<leader>3", function()
      miniharp.go_to(3)
    end, { desc = "miniharp: go to mark 3" })
    vim.keymap.set("n", "<leader>4", function()
      miniharp.go_to(4)
    end, { desc = "miniharp: go to mark 4" })
  end,
}
