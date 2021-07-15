-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/magnuscake/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/magnuscake/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/magnuscake/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/magnuscake/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/magnuscake/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["bufdelete.nvim"] = {
    commands = { "Bdelete", "Bwipeout" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/bufdelete.nvim"
  },
  kommentary = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/kommentary"
  },
  ["moonlight.nvim"] = {
    config = { "\27LJ\1\2e\0\0\2\0\6\0\n4\0\0\0007\0\1\0)\1\1\0:\1\2\0004\0\3\0%\1\4\0>\0\2\0027\0\5\0>\0\1\1G\0\1\0\bset\14moonlight\frequire\30moonlight_italic_keywords\6g\bvim\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/moonlight.nvim"
  },
  ["neoscroll.nvim"] = {
    config = { "\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14neoscroll\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/neoscroll.nvim"
  },
  ["nvim-compe"] = {
    after_files = { "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    config = { '\27LJ\1\2F\0\1\6\0\3\0\b4\1\0\0007\1\1\0017\1\2\1\16\2\0\0)\3\2\0)\4\2\0)\5\2\0@\1\5\0\27nvim_replace_termcodes\bapi\bvim£\1\0\0\5\0\b\2\0304\0\0\0007\0\1\0007\0\2\0%\1\3\0>\0\2\2\21\0\0\0\b\0\1\0T\1\16€4\1\0\0007\1\1\0017\1\4\1%\2\3\0>\1\2\2\16\2\1\0007\1\5\1\16\3\0\0\16\4\0\0>\1\4\2\16\2\1\0007\1\6\1%\3\a\0>\1\3\2\15\0\1\0T\2\3€)\1\2\0H\1\2\0T\1\2€)\1\1\0H\1\2\0G\0\1\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0•\1\0\0\2\2\6\1\0234\0\0\0007\0\1\0007\0\2\0>\0\1\2\t\0\0\0T\0\4€+\0\0\0%\1\3\0@\0\2\0T\0\f€+\0\1\0>\0\1\2\15\0\0\0T\1\4€+\0\0\0%\1\4\0@\0\2\0T\0\4€4\0\0\0007\0\1\0007\0\5\0@\0\1\0G\0\1\0\0À\1À\19compe#complete\n<Tab>\n<C-n>\15pumvisible\afn\bvim\2b\0\0\2\1\5\1\0144\0\0\0007\0\1\0007\0\2\0>\0\1\2\t\0\0\0T\0\4€+\0\0\0%\1\3\0@\0\2\0T\0\3€+\0\0\0%\1\4\0@\0\2\0G\0\1\0\0À\f<S-Tab>\n<C-p>\15pumvisible\afn\bvim\2›\1\0\0\3\1\a\0\0184\0\0\0\15\0\0\0T\1\b€4\0\0\0007\0\1\0>\0\1\2\15\0\0\0T\1\3€+\0\0\0%\1\2\0@\0\2\0004\0\3\0007\0\4\0007\0\5\0+\1\0\0%\2\6\0>\1\2\0?\0\0\0\0À\t<CR>\18compe#confirm\afn\bvim\30<Plug>luasnip-next-choice\18choice_active\fluasnipÁ\b\1\0\t\0"\0@4\0\0\0007\0\1\0007\0\2\0003\1\4\0:\1\3\0004\0\0\0007\0\5\0%\1\a\0:\1\6\0004\0\b\0%\1\t\0>\0\2\0027\0\n\0003\1\v\0003\2\f\0:\2\r\1>\0\2\0011\0\14\0001\1\15\0004\2\16\0001\3\18\0:\3\17\0024\2\16\0001\3\20\0:\3\19\0024\2\16\0001\3\22\0:\3\21\0024\2\b\0%\3\23\0>\2\2\0023\3\24\0007\4\25\2%\5\26\0%\6\27\0%\a\28\0\16\b\3\0>\4\5\0017\4\25\2%\5\29\0%\6\27\0%\a\28\0\16\b\3\0>\4\5\0017\4\25\2%\5\26\0%\6\30\0%\a\31\0\16\b\3\0>\4\5\0017\4\25\2%\5\29\0%\6\30\0%\a\31\0\16\b\3\0>\4\5\0017\4\25\2%\5\26\0%\6 \0%\a!\0\16\b\3\0>\4\5\0010\0\0€G\0\1\0\27v:lua.enter_complete()\t<CR>\27v:lua.s_tab_complete()\f<S-Tab>\6s\25v:lua.tab_complete()\n<Tab>\6i\bmap\1\0\2\texpr\2\vsilent\2\nutils\0\19enter_complete\0\19s_tab_complete\0\17tab_complete\a_G\0\0\vsource\1\0\5\rnvim_lua\2\rnvim_lsp\2\vbuffer\2\tcalc\2\tpath\2\1\0\f\17autocomplete\2\19source_timeout\3È\1\fenabled\2\ndebug\1\14preselect\venable\19max_abbr_width\3d\21incomplete_delay\3\3\19max_menu_width\3d\19max_kind_width\3d\15min_length\3\1\18throttle_time\3P\18documentation\2\nsetup\ncompe\frequire\21menuone,noselect\16completeopt\6o\1\26\0\0\15ï®œ [text]\17î˜‹ [method]\19ï” [function]\22îˆ [constructor]\16ï°  [field]\19ï€« [variable]\16ï†² [class]\20ïš¦ [interface]\17ï†³ [module]\19î˜¤ [property]\15ï‘µ [unit]\16ï¢Ÿ [value]\15ï‘‘ [enum]\14ï Š [key]\18ï‰‰ [snippet]\16îˆ« [color]\15ï…› [file]\20ï ¸ [reference]\17ï» [folder]\22ï… [enum member]\19îˆ¬ [constant]\17ïƒŠ [struct]\16âŒ˜ [event]\19ï• [operator]\15âŒ‚ [type]\23CompletionItemKind\rprotocol\blsp\bvim\0' },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    after = { "nvim-web-devicons" },
    commands = { "NvimTreeOpen", "NvimTreeToggle" },
    config = { "\27LJ\1\0023\0\0\2\0\3\0\0054\0\0\0007\0\1\0%\1\2\0>\0\2\1G\0\1\0\20NvimTreeRefresh\bcmd\bvimú\a\1\0\6\0'\0_4\0\0\0007\0\1\0'\1\28\0:\1\2\0004\0\0\0007\0\1\0003\1\4\0:\1\3\0004\0\0\0007\0\1\0'\1\1\0:\1\5\0004\0\0\0007\0\1\0'\1\1\0:\1\6\0004\0\a\0%\1\b\0>\0\2\0027\0\t\0004\1\0\0007\1\1\0012\2\n\0003\3\v\0\16\4\0\0%\5\f\0>\4\2\2:\4\r\3;\3\1\0023\3\14\0\16\4\0\0%\5\f\0>\4\2\2:\4\r\3;\3\2\0023\3\15\0\16\4\0\0%\5\f\0>\4\2\2:\4\r\3;\3\3\0023\3\16\0\16\4\0\0%\5\17\0>\4\2\2:\4\r\3;\3\4\0023\3\18\0\16\4\0\0%\5\19\0>\4\2\2:\4\r\3;\3\5\0023\3\20\0\16\4\0\0%\5\21\0>\4\2\2:\4\r\3;\3\6\0023\3\22\0\16\4\0\0%\5\23\0>\4\2\2:\4\r\3;\3\a\0023\3\24\0\16\4\0\0%\5\25\0>\4\2\2:\4\r\3;\3\b\0023\3\26\0\16\4\0\0%\5\27\0>\4\2\2:\4\r\3;\3\t\2:\2\n\0014\1\0\0007\1\1\0013\2\29\0003\3\30\0:\3\31\0023\3 \0:\3!\0023\3\"\0:\3#\2:\2\28\0014\1\a\0%\2$\0>\1\2\0027\1%\0011\2&\0>\1\2\1G\0\1\0\0\23on_nvim_tree_ready\21nvim-tree.events\blsp\1\0\4\tinfo\bïš\thint\bïª\nerror\bï—\fwarning\bï±\vfolder\1\0\b\topen\bî—¾\15empty_open\bï„•\fdefault\bî—¿\15arrow_open\bï‘¼\nempty\bï„”\fsymlink\bï’‚\17arrow_closed\bï‘ \17symlink_open\bî—¾\bgit\1\0\5\runstaged\bâœ—\14untracked\bâ˜…\runmerged\bîœ§\frenamed\bâœ\vstaged\bâœ“\1\0\2\fdefault\tî˜’ \fsymlink\tï’ \20nvim_tree_icons\vdir_up\1\0\1\bkey\6-\vrename\1\0\1\bkey\6r\frefresh\1\0\1\bkey\6R\vtabnew\1\0\1\bkey\n<C-t>\nsplit\1\0\1\bkey\n<C-s>\vvsplit\1\0\1\bkey\n<C-v>\1\0\1\bkey\6l\1\0\1\bkey\6o\acb\tedit\1\0\1\bkey\t<CR>\23nvim_tree_bindings\23nvim_tree_callback\21nvim-tree.config\frequire\21nvim_tree_follow\25nvim_tree_auto_close\1\4\0\0\t.git\17node_modules\v.cache\21nvim_tree_ignore\20nvim_tree_width\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\1\2‚\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0003\3\a\0:\3\b\2:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\vindent\1\0\1\venable\2\14highlight\fdisable\1\4\0\0\bcpp\trust\ago\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\5\0\0\tjava\bphp\vkotlin\nscala\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    load_after = {
      ["nvim-tree.lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\1\2æ\3\0\0\b\0\29\0&4\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0027\1\3\0013\2\27\0003\3\4\0003\4\20\0003\5\6\0007\6\5\0:\6\a\0057\6\b\0:\6\t\0057\6\n\0:\6\v\0057\6\f\0:\6\r\0057\6\14\0007\a\b\0\30\6\a\6:\6\15\0057\6\16\0:\6\17\0057\6\18\0:\6\19\5:\5\21\0043\5\22\0007\6\5\0:\6\a\5:\5\23\4:\4\24\0033\4\25\0:\4\26\3:\3\28\2>\1\2\1G\0\1\0\rdefaults\1\0\0\25file_ignore_patterns\1\a\0\0\n%.jpg\v%.jpeg\n%.png\n%.svg\n%.otf\n%.ttf\rmappings\6n\1\0\0\6i\1\0\0\n<C-q>\19send_to_qflist\n<M-s>\28send_selected_to_qflist\n<TAB>\21toggle_selection\n<C-s>\22select_horizontal\n<C-k>\28move_selection_previous\n<C-j>\24move_selection_next\n<ESC>\1\0\0\nclose\1\0\1\18prompt_prefix\n â¯ \nsetup\14telescope\22telescope.actions\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-eunuch"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-surround"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: telescope.nvim
time([[Setup for telescope.nvim]], true)
try_loadstring('\27LJ\1\2 \2\0\0\6\0\r\0\0224\0\0\0%\1\1\0>\0\2\0027\1\2\0%\2\3\0%\3\4\0%\4\5\0003\5\6\0>\1\5\0017\1\2\0%\2\3\0%\3\a\0%\4\b\0003\5\t\0>\1\5\0017\1\2\0%\2\3\0%\3\n\0%\4\v\0003\5\f\0>\1\5\1G\0\1\0\1\0\2\fnoremap\2\vsilent\2!<cmd>Telescope help_tags<CR>\14<Leader>h\1\0\2\fnoremap\2\vsilent\2\31<cmd>Telescope buffers<CR>\15<Leader>bb\1\0\2\fnoremap\2\vsilent\2"<cmd>Telescope find_files<CR>\n<C-p>\6n\bmap\nutils\frequire\0', "setup", "telescope.nvim")
time([[Setup for telescope.nvim]], false)
-- Setup for: nvim-tree.lua
time([[Setup for nvim-tree.lua]], true)
try_loadstring("\27LJ\1\2y\0\0\6\0\a\0\n4\0\0\0%\1\1\0>\0\2\0027\1\2\0%\2\3\0%\3\4\0%\4\5\0003\5\6\0>\1\5\1G\0\1\0\1\0\2\fnoremap\2\vsilent\2\28<cmd>NvimTreeToggle<CR>\14<leader>e\6n\bmap\nutils\frequire\0", "setup", "nvim-tree.lua")
time([[Setup for nvim-tree.lua]], false)
-- Config for: moonlight.nvim
time([[Config for moonlight.nvim]], true)
try_loadstring("\27LJ\1\2e\0\0\2\0\6\0\n4\0\0\0007\0\1\0)\1\1\0:\1\2\0004\0\3\0%\1\4\0>\0\2\0027\0\5\0>\0\1\1G\0\1\0\bset\14moonlight\frequire\30moonlight_italic_keywords\6g\bvim\0", "config", "moonlight.nvim")
time([[Config for moonlight.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\1\2‚\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0003\3\a\0:\3\b\2:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\vindent\1\0\1\venable\2\14highlight\fdisable\1\4\0\0\bcpp\trust\ago\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\5\0\0\tjava\bphp\vkotlin\nscala\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: neoscroll.nvim
time([[Config for neoscroll.nvim]], true)
try_loadstring("\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14neoscroll\frequire\0", "config", "neoscroll.nvim")
time([[Config for neoscroll.nvim]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
vim.cmd [[command! -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file Bwipeout lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bwipeout", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
