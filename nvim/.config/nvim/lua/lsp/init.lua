USER = vim.fn.expand('$USER')

local M = {}

function M.setup()
end

function M.config()
  local lspconfig = require 'lspconfig'

  local on_attach = require 'lsp.on_attach'

  local HOME = os.getenv 'HOME'
  local SYSTEM_NAME

  vim.cmd [[ packadd nvim-lspconfig ]]

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- EFM LANGUAGE SERVER
  -- https://github.com/mattn/efm-langserver
    local efm_config = HOME .. '/.config/efm-langserver/config.yaml'
    local efm_log = '/tmp/efm.log'
    local prettierd = require 'lsp/efm/prettierd'
    local prettier_d = require 'lsp/efm/prettier_d'
    local eslint_d = require 'lsp/efm/eslint_d'

  lspconfig.efm.setup {
    cmd = { 'efm-langserver', '-c', efm_config, '-logfile', efm_log },
    on_attach = on_attach,
    flags = { debounce_text_changes = 150 },
    filetypes = {
      'yaml',
      'json',
      'html',
      'css',
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'javascript.jsx',
      'typescript.tsx',
    },
    -- Fallback to .bashrc as a project root to enable LSP on loose files
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        'tsconfig.json',
        'pyproject.toml'
      )(fname) or lspconfig.util.root_pattern(
          '.eslintrc.js',
          '.git'
        )(fname) or lspconfig.util.root_pattern(
          'package.json',
          '.git/',
          '.zshrc'
        )(fname)
    end,
    init_options = {
      documentFormatting = true,
      documentSymbol = false,
      completion = false,
      codeAction = false,
      hover = false,
    },
    settings = {
      rootMarkers = { 'package.json', 'go.mod', '.git/', '.zshrc' },
      languages = {
        yaml = { prettierd },
        html = { prettierd },
        css = { prettierd },
        javascript = { eslint_d, prettierd },
        typescript = { eslint_d, prettierd },
        javascriptreact = { eslint_d, prettierd },
        typescriptreact = { eslint_d, prettierd },
        ["javascript.jsx"] = { eslint_d, prettierd },
        ["typescript.tsx"] = { eslint_d, prettierd },
        scss               = { prettierd },
        sass               = { prettierd },
        less               = { prettierd },
        graphql            = { prettierd },
      },
    },
  }

  -- EMMET
  if not lspconfig.emmet_ls then
    configs.emmet_ls = {
      default_config = {
        cmd = {'emmet-ls', '--stdio'};
        filetypes = {'html', 'css'};
        root_dir = function(fname)
          return vim.loop.cwd()
        end;
        settings = {};
      };
    }
  end
lspconfig.emmet_ls.setup{ capabilities = capabilities; }

  -- TYPESCRIPT
  -- https://github.com/theia-ide/typescript-language-server
  lspconfig.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- CSS
  require'lspconfig'.cssls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- HTML
  require'lspconfig'.html.setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- PYTHON
  lspconfig.pyright.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- HASKELL
  lspconfig.hls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }

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
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
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
end

return M
