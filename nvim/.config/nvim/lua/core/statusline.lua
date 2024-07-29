local cmd, api = vim.cmd, vim.api

local c = {
  fg = "#d8dee9",
  bg = "#262e38",
  accent = "#8fbcbb",
  lightbg = "#333a47",
  linebg = "#333a47",
  fgfaded = "#616e88",
  grey = "#3e4656",
  bright = "#eceff4",
  dark = "#121212",
  red = "#bf616a",
  green = "#a3be8c",
  blue = "#8fbcbb",
  yellow = "#ebcb8b",
  orange = "#d08770",
}

cmd("hi LspDiagnosticsSignWarning  guifg=" .. c.orange .. " guibg=" .. c.bg)
cmd("hi LspDiagnosticsSignError guifg=" .. c.red .. " guibg=" .. c.bg)
cmd("hi LspDiagnosticsSignInformation guifg=" .. c.yellow .. " guibg=" .. c.bg)
cmd("hi LspDiagnosticsSignHint guifg=" .. c.green .. " guibg=" .. c.bg)

local function lsp()
  local count = {}
  local levels = {
    errors = "Error",
    warnings = "Warn",
    info = "Info",
    hints = "Hint",
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ""
  local warnings = ""
  local hints = ""
  local info = ""

  if count["errors"] ~= 0 then
    errors = " %#LspDiagnosticsSignError# " .. count["errors"]
  end
  if count["warnings"] ~= 0 then
    warnings = " %#LspDiagnosticsSignWarning#   " .. count["warnings"]
  end
  if count["hints"] ~= 0 then
    hints = " %#LspDiagnosticsSignHint#  " .. count["hints"]
  end
  if count["info"] ~= 0 then
    info = " %#LspDiagnosticsSignInformation#  " .. count["info"]
  end

  return errors .. warnings .. hints .. info .. "%*"
end

local function lineinfo()
  if vim.bo.filetype == "alpha" then
    return ""
  end
  return " %P %l:%c "
end

Statusline = {}

Statusline.active = function()
  return table.concat {
    " ",
    "%<",
    vim.b.branch_name .. " // " or "",
    vim.b.file_name,
    "%m",
    lsp(),
    "%=",
    "%=",
    lineinfo(),
  }
end

function Statusline.inactive()
  return " %F"
end

function Statusline.short()
  return "%=" .. "   Neogit" .. "%="
end

api.nvim_create_augroup("Statusline", { clear = true })

api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = "Statusline",
  callback = function()
    vim.opt.statusline = "%{%v:lua.Statusline.active()%}"
  end,
  pattern = "*",
})

-- TODO: set statuline to local buffer so there are no problems when laststatus=2
api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = "Statusline",
  callback = function()
    vim.opt.statusline = "%{%v:lua.Statusline.inactive()%}"
  end,
  pattern = "*",
})

api.nvim_create_autocmd({ "ColorScheme", "ModeChanged" }, {
  group = "Statusline",
  callback = function()
    local curr_mode = api.nvim_get_mode().mode

    if curr_mode == "R" then
      cmd("hi StatusLine  guifg=" .. c.orange .. " guibg=" .. c.bg)
    else
      cmd("hi StatusLine  guifg=" .. c.bright .. " guibg=" .. c.bg)
    end
  end,
  -- command = "hi StatusLine  guibg=" .. c.bg .. " guifg=" .. c.bright,
})

api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
  group = "Statusline",
  callback = function()
    vim.opt.statusline = "%{%v:lua.Statusline.short()%}"
  end,
  pattern = "neo-tree",
})

api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
  group = "Statusline",
  callback = function()
    vim.opt.statusline = "%{%v:lua.Statusline.short()%}"
  end,
  pattern = "NeogitStatus",
})
