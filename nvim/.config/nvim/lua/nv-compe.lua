local M = {}

function M.config()
  local status_luasnip_ok, luasnip = pcall(require, "luasnip")
  if not status_luasnip_ok then
    return
  end

  vim.lsp.protocol.CompletionItemKind = {
    'ﮜ [text]',
    ' [method]',
    ' [function]',
    ' [constructor]',
    'ﰠ [field]',
    ' [variable]',
    ' [class]',
    ' [interface]',
    ' [module]',
    ' [property]',
    ' [unit]',
    ' [value]',
    ' [enum]',
    ' [key]',
    ' [snippet]',
    ' [color]',
    ' [file]',
    ' [reference]',
    ' [folder]',
    ' [enum member]',
    ' [constant]',
    ' [struct]',
    '⌘ [event]',
    ' [operator]',
    '⌂ [type]',
  }

  vim.o.completeopt = "menuone,noselect"

  require 'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true;
      buffer = true;
      calc = true;
      luasnip = true;
      nvim_lsp = true;
      nvim_lua = true;
      spell = true;
      tags = true;
      snippets_nvim = true;
      treesitter = true;
    };
  }

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_backspace = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      return true
    else
      return false
    end
  end

  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      vim.fn.feedkeys(t "<down>", "n")
    elseif luasnip.expand_or_jumpable() then
      vim.fn.feedkeys(t "<Plug>luasnip-expand-or-jump", "")
    elseif check_backspace() then
      vim.fn.feedkeys(t "<Tab>", "n")
    --[[ else
      return vim.fn['compe#complete']() ]]
    else
      return t '<Tab>'
    end
  end

  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      vim.fn.feedkeys(t "<up>", "n")
    elseif luasnip.jumpable(-1) then
      vim.fn.feedkeys(t "<Plug>luasnip-jump-prev", "")
    else
      return t '<S-Tab>'
    end
  end

  _G.enter_complete = function()
    if luasnip and luasnip.choice_active() then
      return t '<Plug>luasnip-next-choice'
    end
    return vim.fn['compe#confirm'](t '<CR>')
  end

  local U = require 'utils'
  local imap = U.imap

  local opts = { expr = true, silent = true }

  imap("<Tab>", "v:lua.tab_complete()", opts)
  U.map("s", "<Tab>", "v:lua.tab_complete()", opts)
  imap("<S-Tab>", "v:lua.s_tab_complete()", opts)
  U.map("s", "<S-Tab>", "v:lua.s_tab_complete()", opts)
  imap('<CR>', 'v:lua.enter_complete()', opts)
end

return M
