local status_ok, feline = pcall(require, "feline")

if not status_ok then
  return
end

local colors = {
  bg = "#282c34",
  fg = "#abb2bf",
  yellow = "#e0af68",
  cyan = "#56b6c2",
  darkblue = "#081633",
  green = "#98c379",
  orange = "#d19a66",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#61afef",
  red = "#e86671",
}

local vi_mode_colors = {
  NORMAL = colors.green,
  INSERT = colors.red,
  VISUAL = colors.magenta,
  OP = colors.green,
  BLOCK = colors.blue,
  REPLACE = colors.violet,
  ["V-REPLACE"] = colors.violet,
  ENTER = colors.cyan,
  MORE = colors.cyan,
  SELECT = colors.orange,
  COMMAND = colors.green,
  SHELL = colors.green,
  TERM = colors.green,
  NONE = colors.yellow,
}

local function file_osinfo()
  local os = vim.bo.fileformat:upper()
  local icon
  if os == "UNIX" then
    icon = " "
  elseif os == "MAC" then
    icon = " "
  else
    icon = " "
  end
  return icon .. os
end

local lsp = require("feline.providers.lsp")
local vi_mode_utils = require("feline.providers.vi_mode")

local lsp_get_diag = function(str)
  local count = lsp.get_diagnostics_count(str)
  return (count > 0) and " " .. count .. " " or ""
end

-- LuaFormatter off

local comps = {
  vi_mode = {
    left = {
      provider = function()
        return "  " .. vi_mode_utils.get_vim_mode()
      end,
      hl = function()
        local val = {
          name = vi_mode_utils.get_mode_highlight_name(),
          fg = vi_mode_utils.get_mode_color(),
        }
        return val
      end,
      -- right_sep = ' '
    },
    right = {
      provider = "▊",
      hl = function()
        local val = {
          name = vi_mode_utils.get_mode_highlight_name(),
          fg = vi_mode_utils.get_mode_color(),
        }
        return val
      end,
      left_sep = " ",
    },
  },
  file = {
    info = {
      -- provider = 'file_info',
      provider = require("core.file-name").get_current_ufn,
      hl = {
        fg = colors.blue,
        style = "bold",
      },
      left_sep = " ",
      right_sep = " ",
    },
    encoding = {
      provider = "file_encoding",
      left_sep = " ",
      hl = {
        fg = colors.violet,
        style = "bold",
      },
    },
    type = {
      provider = "file_type",
    },
    os = {
      provider = file_osinfo,
      left_sep = " ",
      hl = {
        fg = colors.violet,
        style = "bold",
      },
      enabled = function()
        return vim.api.nvim_win_get_width(0) > 80
      end,
    },
  },
  line_percentage = {
    provider = "line_percentage",
    left_sep = " ",
    hl = {
      style = "bold",
    },
  },
  position = {
    provider = "position",
    left_sep = " ",
    hl = function()
      local val = {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color(),
        style = "bold",
      }
      return val
    end,
  },
  scroll_bar = {
    provider = "scroll_bar",
    left_sep = " ",
    hl = {
      fg = colors.blue,
      style = "bold",
    },
  },
  diagnos = {
    err = {
      -- provider = "diagnostic_errors",
      provider = function()
        return "✖" .. lsp_get_diag("Error")
      end,
      enabled = function()
        return lsp.diagnostics_exist("Error")
      end,
      hl = {
        fg = colors.red,
      },
    },
    warn = {
      -- provider = "diagnostic_warnings",
      provider = function()
        return "▲" .. lsp_get_diag("Warn")
      end,
      enabled = function()
        return lsp.diagnostics_exist("Warn")
      end,
      hl = {
        fg = colors.yellow,
      },
    },
    hint = {
      -- provider = "diagnostic_hints",
      provider = function()
        return "" .. lsp_get_diag("Hint")
      end,
      enabled = function()
        return lsp.diagnostics_exist("Hint")
      end,
      hl = {
        fg = colors.cyan,
      },
    },
    info = {
      -- provider = "diagnostic_info",
      provider = function()
        return "✱" .. lsp_get_diag("Info")
      end,
      enabled = function()
        return lsp.diagnostics_exist("Info")
      end,
      hl = {
        fg = colors.blue,
      },
    },
  },
  lsp = {
    name = {
      provider = "lsp_client_names",
      left_sep = " ",
      icon = " ",
      hl = {
        fg = colors.yellow,
      },
    },
  },
  git = {
    branch = {
      provider = "git_branch",
      icon = " ",
      left_sep = " ",
      hl = {
        fg = colors.violet,
        style = "bold",
      },
    },
    add = {
      provider = "git_diff_added",
      hl = {
        fg = colors.green,
      },
    },
    change = {
      provider = "git_diff_changed",
      hl = {
        fg = colors.orange,
      },
    },
    remove = {
      provider = "git_diff_removed",
      hl = {
        fg = colors.red,
      },
    },
  },
}

local components = {
  active = {},
  inactive = {},
}

table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.inactive, {})
table.insert(components.inactive, {})

table.insert(components.active[1], comps.vi_mode.left)
table.insert(components.active[1], comps.file.info)
-- table.insert(components.active[1], comps.lsp.name)
table.insert(components.active[1], comps.diagnos.err)
table.insert(components.active[1], comps.diagnos.warn)
table.insert(components.active[1], comps.diagnos.hint)
table.insert(components.active[1], comps.diagnos.info)

table.insert(components.active[2], comps.git.add)
table.insert(components.active[2], comps.git.change)
table.insert(components.active[2], comps.git.remove)
table.insert(components.active[2], comps.file.os)
table.insert(components.active[2], comps.git.branch)
table.insert(components.active[2], comps.scroll_bar)
table.insert(components.active[2], comps.line_percentage)
table.insert(components.active[2], comps.position)
table.insert(components.active[2], comps.vi_mode.right)

table.insert(components.inactive[1], comps.file.info)
table.insert(components.inactive[1], comps.file.os)

-- LuaFormatter on

feline.setup {
  colors = { bg = colors.bg, fg = colors.fg },
  components = components,
  vi_mode_colors = vi_mode_colors,
  force_inactive = {
    filetypes = {
      "neo-tree",
      "dbui",
      "packer",
      "fugitive",
      "fugitiveblame",
      "Outline",
    },
    buftypes = { "terminal" },
    bufnames = { "neo-tree" },
  },
}
