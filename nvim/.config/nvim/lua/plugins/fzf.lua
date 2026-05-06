return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-mini/mini.icons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config
  opts = {
    files = {
      winopts = {
        width = 0.5,
        height = 0.5,
      },
      previewer = false,
      cmd = "rg --files --hidden --glob '!.git/' --glob '!node_modules/'",
    },
  },
  keys = {
    {
      "<c-p>",
      function()
        require("fzf-lua").files()
      end,
      mode = { "n", "x" },
    },
    {
      "<c-g>",
      function()
        require("fzf-lua").grep()
      end,
      mode = { "n", "x" },
    },

    {
      "<c-_>",
      function()
        require("fzf-lua").live_grep()
      end,
      mode = { "n", "x" },
    },

    {
      "<c-/>",
      function()
        require("fzf-lua").live_grep()
      end,
      mode = { "n", "x" },
    },

    {
      "<c-b>",
      function()
        require("fzf-lua").buffers()
      end,
      mode = { "n", "x" },
    },
    {
      "<leader>fd",
      function()
        require("fzf-lua").fzf_exec("fd --type d --hidden --exclude .git", {
          prompt = "Directories> ",
          actions = {
            ["default"] = function(selected)
              if selected and selected[1] then
                require("oil").toggle_float(selected[1])
              end
            end,
          },
        })
      end,
      desc = "Open directory in oil",
      mode = { "n" },
    },
  },
}
