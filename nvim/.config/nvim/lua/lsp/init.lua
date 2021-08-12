return function()
  local lspconfig = require 'lspconfig'
  local on_attach = require 'lsp.on_attach'

  USER = vim.fn.expand('$USER')
  local HOME = os.getenv 'HOME'
  local SYSTEM_NAME

  -- vim.cmd [[packadd nvim-lspconfig]]

  -- LUA
  if vim.fn.has 'mac' == 1 then
    SYSTEM_NAME = 'macOS'
  elseif vim.fn.has 'unix' == 1 then
    SYSTEM_NAME = 'Linux'
  end

  local sumneko_root_path = HOME .. '/dev/lua-language-server'
  local sumneko_binary = sumneko_root_path
    .. '/bin/'
    .. SYSTEM_NAME
    .. '/lua-language-server'

  require'lspconfig'.sumneko_lua.setup {
    cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';')
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' }
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
          }
        },
        telemetry = { enable = false },
      }
    }
  }

  local servers = {}

  servers.bashls = {
    on_attach = function(client)
      on_attach(client)
    end
  }

  servers.vimls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- TYPESCRIPT
  -- https://github.com/theia-ide/typescript-language-server
  servers.tsserver = {
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_attach(client)
    end,
  }
  --[[
  require("null-ls").config {}
  require("lspconfig")["null-ls"].setup {}
  lspconfig.tsserver.setup {

    on_attach = function(client, bufnr)
      local ts_utils = require("nvim-lsp-ts-utils")
      client.resolved_capabilities.document_formatting = false

      -- defaults
      ts_utils.setup {
        debug = false,
        disable_commands = false,
        enable_import_on_completion = true,
        import_on_completion_timeout = 5000,

        -- eslint
        eslint_enable_code_actions = true,
        eslint_bin = "eslint_d",
        eslint_args = {"-f", "unix", "--stdin", "--stdin-filename", "$FILENAME"},
        eslint_enable_disable_comments = true,

        -- experimental settings!
        -- eslint diagnostics
        eslint_enable_diagnostics = true,
        eslint_diagnostics_debounce = 250,

        -- formatting
        enable_formatting = true,
        formatter = "prettier",
        formatter_args = {"--stdin-filepath", "$FILENAME"},
        format_on_save = true,
        no_save_after_format = false,

        -- parentheses completion
        complete_parens = false,
        signature_help_in_parens = true,

        -- update imports on file move
        update_imports_on_move = false,
        require_confirmation_on_move = false,
        watch_dir = "/src",
      }

      -- required to enable ESLint code actions and formatting
      ts_utils.setup_client(client)

      -- no default maps, so you may want to define some here
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", {silent = true})
      vim.api.nvim_buf_set_keymap(bufnr, "n", "qq", ":TSLspFixCurrent<CR>", {silent = true})
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", {silent = true})
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", {silent = true})
    end
  }
    ]]

  -- CSS
  servers.cssls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- HTML
  servers.html = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- PYTHON
  servers.pyright = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  -- HASKELL
  servers.hls = {
    on_attach = function(client)
      on_attach(client)
    end,
  }

  local efm = require 'lsp.efm'
  servers.efm = efm

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  for server, config in pairs(servers) do
    lspconfig[server].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, config))
  end
end
