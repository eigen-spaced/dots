-- taken from Kanagawa
local palette = {
  -- Bg Shades
  sumiInk0 = "#16161D",
  sumiInk1 = "#181820",
  sumiInk2 = "#1a1a22",
  sumiInk3 = "#1F1F28",
  sumiInk4 = "#2A2A37",
  sumiInk5 = "#363646",
  sumiInk6 = "#54546D", --fg

  -- Popup and Floats
  waveBlue1 = "#223249",
  waveBlue2 = "#2D4F67",

  -- Diff and Git
  winterGreen = "#2B3328",
  winterYellow = "#49443C",
  winterRed = "#43242B",
  winterBlue = "#252535",
  autumnGreen = "#76946A",
  autumnRed = "#C34043",
  autumnYellow = "#DCA561",

  -- Diag
  samuraiRed = "#E82424",
  roninYellow = "#FF9E3B",
  waveAqua1 = "#6A9589",
  dragonBlue = "#658594",

  -- Fg and Comments
  oldWhite = "#C8C093",
  fujiWhite = "#DCD7BA",
  fujiGray = "#727169",

  oniViolet = "#957FB8",
  oniViolet2 = "#b8b4d0",
  crystalBlue = "#7E9CD8",
  springViolet1 = "#938AA9",
  springViolet2 = "#9CABCA",
  springBlue = "#7FB4CA",
  lightBlue = "#A3D4D5", -- unused yet
  waveAqua2 = "#7AA89F", -- improve lightness: desaturated greenish Aqua

  -- waveAqua2  = "#68AD99",
  -- waveAqua4  = "#7AA880",
  -- waveAqua5  = "#6CAF95",
  -- waveAqua3  = "#68AD99",

  springGreen = "#98BB6C",
  boatYellow1 = "#938056",
  boatYellow2 = "#C0A36E",
  carpYellow = "#E6C384",

  sakuraPink = "#D27E99",
  waveRed = "#E46876",
  peachRed = "#FF5D62",
  surimiOrange = "#FFA066",
  katanaGray = "#717C7C",
}

-- Groups used for my statusline.
---@type table<string, vim.api.keyset.highlight>
local statusline_groups = {}
for mode, color in pairs {
  Command = palette.sakuraPink,
  Insert = palette.waveAqua1,
  Normal = palette.crystalBlue,
  Other = palette.surimiOrange,
  Pending = palette.carpYellow,
  Visual = palette.oniViolet,
} do
  statusline_groups["StatuslineMode" .. mode] = { fg = palette.sumiInk2, bg = color }
  statusline_groups["StatuslineModeSeparator" .. mode] = { fg = color, bg = palette.sumiInk2 }
end

statusline_groups["Filename"] = { fg = palette.sumiInk2, bg = palette.springViolet1 }
statusline_groups["FilenameSeperator"] = { fg = palette.springViolet1, bg = palette.sumiInk2 }

statusline_groups = vim.tbl_extend("error", statusline_groups, {
  StatuslineItalic = { fg = palette.fujiWhite, bg = palette.sumiInk2, italic = true },
  StatuslineSpinner = { fg = palette.springGreen, bg = palette.sumiInk2, bold = true },
  StatuslineTitle = { fg = palette.fujiWhite, bg = palette.sumiInk2, bold = true },
})

local groups = vim.tbl_extend("error", statusline_groups, {})

for group, opts in pairs(groups) do
  vim.api.nvim_set_hl(0, group, opts)
end
