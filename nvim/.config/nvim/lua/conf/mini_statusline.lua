local M = {}

local function combine_groups(groups)
  local parts = vim.tbl_map(function(s)
    if type(s) == "string" then
      return s
    end
    if type(s) ~= "table" then
      return ""
    end

    local string_arr = vim.tbl_filter(function(x)
      return type(x) == "string" and x ~= ""
    end, s.strings or {})
    local str = table.concat(string_arr, " ")

    -- Use previous highlight group
    if s.hl == nil then
      return " " .. str .. " "
    end

    -- Allow using this highlight group later
    if str:len() == 0 then
      return "%#" .. s.hl .. "#"
    end

    return string.format("%%#%s#%s", s.hl, str)
  end, groups)

  return table.concat(parts, "")
end

local function hex(n)
  return n and string.format("#%06x", n) or "NONE"
end

local function bg_of(name)
  return hex(vim.api.nvim_get_hl(0, { name = name, link = false }).bg)
end

-- For each mini statusline section, create a `*Cap` highlight with the
-- section's bg as fg and StatusLine's bg as bg. Drawing an L/R glyph with
-- that group renders a colored pill edge against the statusline background.
local function define_caps()
  local sl_bg = bg_of("StatusLine")
  local sections = {
    "MiniStatuslineModeNormal",
    "MiniStatuslineModeInsert",
    "MiniStatuslineModeVisual",
    "MiniStatuslineModeReplace",
    "MiniStatuslineModeCommand",
    "MiniStatuslineModeOther",
    "MiniStatuslineDevinfo",
    "MiniStatuslineFilename",
    "MiniStatuslineFileinfo",
  }
  for _, s in ipairs(sections) do
    vim.api.nvim_set_hl(0, s .. "Cap", { fg = bg_of(s), bg = sl_bg })
  end
end

local L = ""
local R = ""

function M.setup()
  require("mini.statusline").setup {
    content = {
      -- Content for active window
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
        local git = MiniStatusline.section_git { trunc_width = 40 }
        local diff = MiniStatusline.section_diff { trunc_width = 75 }
        local diagnostics =
          MiniStatusline.section_diagnostics { trunc_width = 75 }
        local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
        local filename = MiniStatusline.section_filename { trunc_width = 140 }
        local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
        local location = MiniStatusline.section_location { trunc_width = 75 }
        local search = MiniStatusline.section_searchcount { trunc_width = 75 }

        local tab = {
          { hl = mode_hl .. "Cap", strings = { L } },
          { hl = mode_hl, strings = { mode } },
          { hl = mode_hl .. "Cap", strings = { R } },
          "%<",
        }

        if table.concat({ git, diff, diagnostics, lsp }):len() > 0 then
          table.insert(
            tab,
            { hl = "MiniStatuslineDevinfoCap", strings = { L } }
          )
          table.insert(tab, {
            hl = "MiniStatuslineDevinfo",
            strings = { git, diff, diagnostics, lsp },
          })
          table.insert(
            tab,
            { hl = "MiniStatuslineDevinfoCap", strings = { R } }
          )
          table.insert(tab, "%<")
        end

        table.insert(tab, { hl = "MiniStatuslineFilenameCap", strings = { L } })
        table.insert(tab, {
          hl = "MiniStatuslineFilename",
          strings = { " ", filename, " " },
        })
        table.insert(tab, { hl = "MiniStatuslineFilenameCap", strings = { R } })

        table.insert(tab, "%=")

        if fileinfo:len() > 0 then
          table.insert(
            tab,
            { hl = "MiniStatuslineFileinfoCap", strings = { L } }
          )
          table.insert(
            tab,
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } }
          )
          table.insert(
            tab,
            { hl = "MiniStatuslineFileinfoCap", strings = { R } }
          )
        end

        table.insert(tab, { hl = mode_hl .. "Cap", strings = { L } })
        table.insert(tab, {
          hl = mode_hl,
          strings = { search, location },
        })
        table.insert(tab, { hl = mode_hl .. "Cap", strings = { R } })

        return combine_groups(tab)
      end,
      -- Content for inactive window(s)
      inactive = nil,
    },
    use_icons = vim.g.have_nerd_font,
    set_vim_settings = true,
  }

  define_caps()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = define_caps })
end

return M
