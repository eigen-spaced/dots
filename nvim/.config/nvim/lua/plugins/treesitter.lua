return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "go",
        "gomod",
        "gowork",
        "gotmpl",
        "python",
        "javascript",
        "typescript",
        "html",
      }

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "TreesitterHighlight",
          { clear = true }
        ),
        callback = function(args)
          local bufnr = args.buf
          local ft = vim.bo[bufnr].filetype

          local ignore_ft = {
            "fzf",
            "TelescopePrompt",
            "qf",
            "netrw",
            "lazy",
            "mason",
            "notify",
          }
          if vim.tbl_contains(ignore_ft, ft) then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft) or ft

          -- We pass the function, then the arguments: pcall(fn, arg1, arg2)
          local ok, err = pcall(vim.treesitter.start, bufnr, lang)
        end,
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = true, -- Don't load automatically
    event = "VeryLazy", -- Load after everything else
    config = function()
      require("nvim-ts-autotag").setup {
        filetypes = {
          "html",
          "javascript",
          "javascriptreact",
          "svelte",
          "typescript",
          "typescriptreact",
          "vue",
        },
        skip_tags = {
          "area",
          "base",
          "br",
          "col",
          "command",
          "embed",
          "hr",
          "img",
          "slot",
          "input",
          "keygen",
          "link",
          "meta",
          "menuitem",
          "param",
          "source",
          "track",
          "wbr",
        },
      }
    end,
  },
}
