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

  local mason_status_ok, mason = pcall(require, "mason")
  local mason_lspconfig_status_ok, mason_lspconfig =
    pcall(require, "mason-lspconfig")

  if not mason_status_ok or not mason_lspconfig_status_ok then
    return
  end

  -- Mason-managed servers
  local mason_servers = {
    "cssls",
    "html",
    "svelte",
    "tailwindcss",
    "vimls",
    "bashls",
    "vue_ls",
    "astro",
    "harper_ls",
    "pyrefly",
  }

  -- Non-mason / external servers
  local external_servers = {
    "lua_ls",
    "ty",
  }
  mason.setup()

  mason_lspconfig.setup {
    ensure_installed = mason_servers,
  }

  -- Register configs (custom or default)
  local function setup(server)
    local ok, custom_config = pcall(require, "lsp." .. server)
    vim.lsp.config(server, ok and custom_config or {})
  end

  local all_servers =
    vim.list_extend(vim.deepcopy(mason_servers), external_servers)

  -- Register + enable
  for _, server in ipairs(all_servers) do
    setup(server)
    vim.lsp.enable(server)
  end

  vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git" },
    on_attach = function(client, bufnr)
      client.server_capabilities.hoverProvider = false
    end,
  })
end

return M
