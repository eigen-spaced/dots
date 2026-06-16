local keymap = vim.keymap
local M = {}

function M.config()
  local icons = require("core.icons")

  vim.diagnostic.config {
    severity_sort = true,
    update_in_insert = true,
    underline = true,
    virtual_text = {
      prefix = "▎", -- Could be '●', '▎', 'x'
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
      },
    },
    float = {
      border = "rounded",
      format = function(d)
        local code = d.code
          or (d.user_data and d.user_data.lsp and d.user_data.lsp.code)
          or "?"
        return ("%s (%s) [%s]"):format(d.message, d.source or "unknown", code)
      end,
    },
  }

  local au = vim.api.nvim_create_augroup("LspAttach", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP keymaps",
    callback = function(args)
      local keymap_opts = { buffer = args.buf, silent = true, noremap = true }
      local with_desc = function(opts, desc)
        return vim.tbl_extend("force", opts, { desc = desc })
      end

      keymap.set(
        "n",
        "gD",
        vim.lsp.buf.declaration,
        with_desc(keymap_opts, "LSP declaration")
      )
      keymap.set(
        "n",
        "<leader>gd",
        vim.lsp.buf.definition,
        with_desc(keymap_opts, "LSP definition")
      )
      keymap.set(
        "n",
        "K",
        vim.lsp.buf.hover,
        with_desc(keymap_opts, "LSP hover")
      )
      keymap.set(
        "n",
        "gi",
        vim.lsp.buf.implementation,
        with_desc(keymap_opts, "LSP implementation")
      )
      keymap.set(
        { "n", "v" },
        "<leader>ca",
        vim.lsp.buf.code_action,
        with_desc(keymap_opts, "LSP code action")
      )
      keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, keymap_opts)
      keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, keymap_opts)

      keymap.set("n", "<leader>D", vim.lsp.buf.type_definition)
      keymap.set(
        "n",
        "<leader>rn",
        vim.lsp.buf.rename,
        with_desc(keymap_opts, "LSP rename")
      )

      -- keymap.set("n", "<leader>lt", vim.lsp.buf.document_symbol)
      keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

      local troubleHelper = function(mode)
        require("trouble").toggle { mode = mode, focus = true }
      end

      keymap.set("n", "<leader>xx", "<cmd>Trouble<CR>")
      keymap.set("n", "<leader>gr", function()
        troubleHelper("lsp_references")
      end, with_desc(keymap_opts, "Trouble LSP references"))

      keymap.set("n", "<leader>dd", function()
        require("trouble").toggle { mode = "diagnostics", focus = true }
      end, with_desc(keymap_opts, "Trouble LSP references"))

      keymap.set("n", "<leader>li", function()
        troubleHelper("lsp_incoming_calls")
      end, with_desc(keymap_opts, "Trouble LSP incoming calls"))
      keymap.set("n", "<leader>lo", function()
        troubleHelper("lsp_outgoing_calls")
      end, with_desc(keymap_opts, "Trouble LSP outgoing calls"))
      vim.opt.shortmess:append("c")
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
      vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover {
          border = "rounded",
          max_width = 90,
          max_height = 25,
        }
      end, { buffer = event.buf, desc = "LSP hover" })
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP highlight",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client and client.server_capabilities.documentHighlightProvider then
        local augroup_lsp_highlight = "lsp_highlight"

        vim.api.nvim_create_augroup(augroup_lsp_highlight, { clear = false })
        vim.api.nvim_create_autocmd("CursorHold", {
          group = augroup_lsp_highlight,
          buffer = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = augroup_lsp_highlight,
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })

  local format_au = vim.api.nvim_create_augroup("format_on_save", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_au,
    pattern = "*",

    callback = function(args)
      require("conform").format {
        bufnr = args.buf,
        timeout_ms = 1000,

        -- Use Conform formatters first.
        -- Only fall back to LSP formatting if no Conform formatter exists.
        lsp_format = "fallback",

        filter = function(client)
          local disabled_servers = {
            "lua_ls",
            "eslint",
            "tsserver",
            "pyright",
            "basedpyright",
            "ty",
            "pyrefly",
          }

          return not vim.tbl_contains(disabled_servers, client.name)
        end,
      }
    end,
  })

  -- mason.nvim is kept only as a manual sandbox (`:MasonInstall`) for trying
  -- out new languages. It no longer auto-installs (`ensure_installed`) or
  -- auto-enables (mason-lspconfig) anything: the servers below are enabled
  -- explicitly and their binaries come from each language's own ecosystem
  -- (brew / pnpm -g / cargo / uv / mise). To adopt a new server: install its
  -- binary (e.g. `:MasonInstall foo-ls`) and add it to `servers`.
  -- PATH = "append" so mason's bin never shadows native tools: anything you
  -- :MasonInstall to experiment with is found, but brew/pnpm/cargo/mise wins
  -- whenever both exist.
  pcall(function()
    require("mason").setup { PATH = "append" }
  end)

  -- `ty` has no bundled lspconfig (or after/lsp) config, so define it inline.
  vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git" },
    on_attach = function(client, _)
      client.server_capabilities.hoverProvider = false
    end,
  })

  -- Config for each comes from nvim-lspconfig's bundled `lsp/<name>.lua` merged
  -- with our overrides in `after/lsp/<name>.lua`. rust-analyzer (rustaceanvim)
  -- and the TS server (typescript-tools) are owned by their own plugins and are
  -- intentionally not listed here.
  local servers = {
    "clangd", -- system /usr/bin/clangd
    "gopls", -- mise (go: backend)
    -- "clojure_lsp", -- brew install clojure-lsp/brew/clojure-lsp-native
    "lua_ls", -- brew lua-language-server
    "cssls", -- pnpm -g vscode-langservers-extracted
    "html", -- pnpm -g vscode-langservers-extracted
    "svelte", -- pnpm -g svelte-language-server
    "tailwindcss", -- pnpm -g @tailwindcss/language-server
    "vimls", -- pnpm -g vim-language-server
    "bashls", -- pnpm -g bash-language-server
    "vue_ls", -- pnpm -g @vue/language-server
    "astro", -- pnpm -g @astrojs/language-server
    "harper_ls", -- brew harper
    "pyrefly", -- uv
    "ty", -- uv
  }
  vim.lsp.enable(servers)
end

return M
