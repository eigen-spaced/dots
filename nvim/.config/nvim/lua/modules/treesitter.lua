local M = {}

function M.config()
  ---@diagnostic disable: missing-fields
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "c",
      "vim",
      "lua",
      "vimdoc",
      "html",
      "javascript",
      "typescript",
      "clojure",
      "fennel",
    },
    ignore_install = {
      "http",
      "perl",
      "vala",
      "kotlin",
      "scala",
      "elixir",
      "zig",
    },
    highlight = {
      enable = true, -- false will disable the whole extension
      use_languagetree = true,
    },
    indent = { enable = true, disable = { "python", "yaml", "go" } },
    textobjects = { -- syntax-aware textobjects
      select = {
        enable = true,
        disable = {},
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aC"] = "@class.outer",
          ["iC"] = "@class.inner",
          ["ac"] = "@conditional.outer",
          ["ic"] = "@conditional.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["is"] = "@statement.inner",
          ["as"] = "@statement.outer",
          ["am"] = "@call.outer",
          ["im"] = "@call.inner",
          ["ad"] = "@comment.outer",
          ["id"] = "@comment.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["[["] = "@parameter.inner",
          ["[f"] = "@function.outer",
        },
        swap_previous = {
          ["]]"] = "@parameter.inner",
          ["]f"] = "@function.outer",
        },
      },
    },
  }
end

return M
