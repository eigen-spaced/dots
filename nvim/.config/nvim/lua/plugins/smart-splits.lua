return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    local keymap = vim.keymap
    local smart_splits = require("smart-splits")

    -- Resize is handled in core/focus.lua (fraction-snapping, like the tmux
    -- PREFIX-arrow resize). smart-splits keeps seamless nav + buffer swap.
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
