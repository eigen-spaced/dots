return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    -- notifier = { enabled = true },
    zen = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = false },
    picker = { enabled = true },
    bigfile = {
      enabled = true,
      notify = false,
      size = 100 * 1024, -- 100 KB
      line_length = 1000,
      setup = function(ctx)
        vim.schedule(function()
          Snacks.util.wo(0, {
            foldenable = false,
            statuscolumn = "",
            conceallevel = 0,
          })
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
    },
  },
  keys = {
    {
      "<leader>bk",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    {
      "<leader>Z",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
    },
  },
}
