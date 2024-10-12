local status_ok, cmp = pcall(require, "cmp")

if not status_ok then
  return
end

local symbol_kinds = require("core.icons").symbol_kinds

local prequire = require("core.utils").prequire
local luasnip = prequire("luasnip")

-- supertab-like mapping
local mapping = {
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip and luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end, {
    "i",
    "s",
  }),
  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, {
    "i",
    "s",
  }),
  ["<C-n>"] = cmp.mapping.select_next_item {
    behavior = cmp.SelectBehavior.Insert,
  },
  ["<C-p>"] = cmp.mapping.select_prev_item {
    behavior = cmp.SelectBehavior.Insert,
  },
  ["<CR>"] = cmp.mapping.confirm {
    behavior = cmp.ConfirmBehavior.Replace,
    select = true,
  },
  ["<C-d>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<C-e>"] = cmp.mapping.close(),
}

cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = mapping,
  sources = {
    { name = "nvim_lsp", priority = 8 },
    { name = "buffer", keyword_length = 7 },
    { name = "luasnip", priority = 6 },
    { name = "nvim_lua", priority = 5 },
    { name = "path", priorty = 4 },
  },
  ---@diagnostic disable: missing-fields
  sorting = {
    comparators = {
      cmp.config.compare.locality,
      cmp.config.compare.recently_used,
      cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
      cmp.config.compare.offset,
      cmp.config.compare.order,
    },
  },
  formatting = {
    format = function(_, vim_item)
      vim_item.kind =
        string.format("%s [%s]", symbol_kinds[vim_item.kind], vim_item.kind)
      return vim_item
    end,
  },
  experimental = { ghost_text = true },
}
