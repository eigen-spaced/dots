return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    local keymap = vim.keymap
    local smart_splits = require("smart-splits")

    keymap.set("n", "<M-Left>", smart_splits.resize_left)
    keymap.set("n", "<M-Down>", smart_splits.resize_down)
    keymap.set("n", "<M-Up>", smart_splits.resize_up)
    keymap.set("n", "<M-Right>", smart_splits.resize_right)
    -- moving between splits
    keymap.set("n", "<C-h>", smart_splits.move_cursor_left)
    keymap.set("n", "<C-j>", smart_splits.move_cursor_down)
    keymap.set("n", "<C-k>", smart_splits.move_cursor_up)
    keymap.set("n", "<C-l>", smart_splits.move_cursor_right)
    -- swapping buffers
    keymap.set("n", "<leader><leader>h", smart_splits.swap_buf_left)
    keymap.set("n", "<leader><leader>j", smart_splits.swap_buf_down)
    keymap.set("n", "<leader><leader>k", smart_splits.swap_buf_up)
    keymap.set("n", "<leader><leader>l", smart_splits.swap_buf_right)
  end,
}
