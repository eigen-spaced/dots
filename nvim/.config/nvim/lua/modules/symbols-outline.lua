local M = {}

function M.setup()
  nmap("<C-s>", "<cmd>SymbolsOutline<CR>")
end

function M.config()
  vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    width = 35,
    show_symbol_details = true,
    preview_bg_highlight = "Pmenu",
    keymaps = { -- These keymaps can be a string or a table for multiple keys
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      toggle_preview = "K",
      rename_symbol = "r",
      code_actions = "a",
    },
  }
end

return M
