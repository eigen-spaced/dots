local keymap = vim.keymap
local M = {}

function M.config()
  local icons = require("core.icons")

  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = {
        prefix = "▎", -- Could be '●', '▎', 'x'
      },
      update_in_insert = true,
    })

  vim.diagnostic.config {
    severity_sort = true,
    virtual_text = true,
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
        return ("%s (%s) [%s]"):format(
          d.message,
          d.source,
          d.code or d.user_data.lsp.code
        )
      end,
    },
    underline = true,
    jump = {
      float = true,
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
        require("trouble").open { mode = mode }
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

  -- Prevent race conditions and conflicts between volar and tsserver
  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "prevent tsserver and volar competing",
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end
      local active_clients = vim.lsp.get_clients()
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- prevent tsserver and volar competing
      -- if client.name == "volar" or require("lspconfig").util.root_pattern("nuxt.config.ts")(vim.fn.getcwd()) then
      -- OR
      if client and client.name == "volar" then
        for _, client_ in pairs(active_clients) do
          -- stop tsserver if volar is already active
          if client_.name == "tsserver" then
            client_.stop()
          end
        end
      elseif client and client.name == "tsserver" then
        for _, client_ in pairs(active_clients) do
          -- prevent tsserver from starting if volar is already active
          if client_.name == "volar" then
            client.stop()
          end
        end
      end
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

  vim.api.nvim_create_autocmd("LspAttach", {
    group = au,
    desc = "LSP format",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.server_capabilities.documentFormattingProvider then
        local augroup_lsp_format = "lsp_format"
        vim.api.nvim_create_augroup(augroup_lsp_format, { clear = false })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup_lsp_format,
          buffer = bufnr,
          callback = function()
            require("conform").format {
              -- async = true,
              filter = function(server)
                local disabled_servers = {
                  "lua_ls",
                  "eslint",
                  "tsserver",
                }
                return not vim.tbl_contains(disabled_servers, server.name)
              end,
            }
          end,
        })
      end
    end,
  })

  local mason_status_ok, mason = pcall(require, "mason")
  local mason_lspconfig_status_ok, mason_lspconfig =
    pcall(require, "mason-lspconfig")

  if not mason_status_ok or not mason_lspconfig_status_ok then
    return
  end

  local servers = {
    "lua_ls",
    "rust_analyzer",
    "cssls",
    "html",
    "svelte",
    "pyright",
    "tailwindcss",
    "vimls",
    "bashls",
    "vue_ls",
    "gopls",
    "astro",
    "biome",
    "harper_ls",
  }

  local ensure_installed = servers or {}

  mason.setup()
  mason_lspconfig.setup {
    ensure_installed = ensure_installed,
  }

  vim.api.nvim_create_user_command("LspEnable", function()
    local lsp_configs = {}

    for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
      local server_name = vim.fn.fnamemodify(f, ":t:r")
      local ok, cfg = pcall(require, "lsp." .. server_name)

      if ok then
        -- Register config
        vim.lsp.config[server_name] = cfg
        table.insert(lsp_configs, server_name)
      else
        vim.notify(
          "LSP config not found or invalid for " .. server_name,
          vim.log.levels.WARN
        )
      end
    end

    -- Enable all defined servers
    vim.lsp.enable(lsp_configs)
  end, {})

  -- https://www.npbee.me/posts/deno-and-typescript-in-a-monorepo-neovim-lsp if
  -- I ever have to setup deno with TS
end

return M
