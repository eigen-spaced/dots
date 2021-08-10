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
  ["gitsigns.nvim"] = {
    config = { "\27LJ\1\2Â\n\0\0\4\0\28\0\0314\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\14\0003\2\4\0003\3\3\0:\3\5\0023\3\6\0:\3\a\0023\3\b\0:\3\t\0023\3\n\0:\3\v\0023\3\f\0:\3\r\2:\2\15\0013\2\16\0:\2\17\0013\2\18\0003\3\19\0:\3\20\0023\3\21\0:\3\22\2:\2\23\0013\2\24\0:\2\25\0013\2\26\0:\2\27\1>\0\2\1G\0\1\0\tyadm\1\0\1\venable\2\16watch_index\1\0\1\rinterval\3è\a\fkeymaps\tn [c\1\2\1\0@&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\tn ]c\1\2\1\0@&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\b\vbuffer\2\17n <leader>hs0<cmd>lua require\"gitsigns\".stage_hunk()<CR>\17n <leader>hR2<cmd>lua require\"gitsigns\".reset_buffer()<CR>\17n <leader>hb0<cmd>lua require\"gitsigns\".blame_line()<CR>\17n <leader>hr0<cmd>lua require\"gitsigns\".reset_hunk()<CR>\fnoremap\2\17n <leader>hp2<cmd>lua require\"gitsigns\".preview_hunk()<CR>\17n <leader>hu5<cmd>lua require\"gitsigns\".undo_stage_hunk()<CR>\16count_chars\1\n\1\0\5\bâ‚‚\bâ‚ƒ\bâ‚„\bâ‚…\bâ‚†\bâ‚‡\bâ‚ˆ\bâ‚‰\6+\bâ‚Š\nsigns\1\0\a\20update_debounce\3d\vlinehl\1\nnumhl\1\18sign_priority\3\6\23current_line_blame\1\22use_internal_diff\2\23use_decoration_api\2\17changedelete\1\0\5\ttext\6~\nnumhl\21GitSignsChangeNr\15show_count\2\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\14topdelete\1\0\5\ttext\bâ€¾\nnumhl\21GitSignsDeleteNr\15show_count\2\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\vdelete\1\0\5\ttext\6_\nnumhl\21GitSignsDeleteNr\15show_count\2\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\vchange\1\0\4\ttext\6~\nnumhl\21GitSignsChangeNr\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\badd\1\0\0\1\0\4\ttext\6+\nnumhl\18GitSignsAddNr\vlinehl\18GitSignsAddLn\ahl\16GitSignsAdd\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  ["guihua.lua"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/guihua.lua"
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
  ["navigator.lua"] = {
    config = { "\27LJ\1\2Ú\1\0\0\4\0\6\0\v4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0002\2\3\0003\3\4\0;\3\1\2:\2\5\1>\0\2\1G\0\1\0\fkeymaps\1\0\2\tfunc\18declaration()\bkey\agK\1\0\6\19preview_height\4æÌ™³\6æÌÙş\3\vheight\4³æÌ™\3³æÌş\3\ndebug\1\20default_mapping\2\21code_action_icon\tï ´ \nwidth\4\0€€ ÿ\3\nsetup\14navigator\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/navigator.lua"
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
    config = { "\27LJ\1\2Ü\1\0\1\5\1\t\0\30+\1\0\0007\1\0\0017\1\1\1%\2\2\0%\3\3\0>\1\3\2\16\2\0\0>\1\2\2\14\0\1\0T\2\19€+\1\0\0007\1\0\0017\1\1\1%\2\4\0%\3\5\0>\1\3\2\16\2\0\0>\1\2\2\14\0\1\0T\2\t€+\1\0\0007\1\0\0017\1\1\1%\2\6\0%\3\a\0%\4\b\0>\1\4\2\16\2\0\0>\1\2\2H\1\2\0\0À\v.zshrc\n.git/\17package.json\t.git\17.eslintrc.js\19pyproject.toml\18tsconfig.json\17root_pattern\tutil·\1\0\0\4\0\b\1\0163\0\0\0002\1\3\0004\2\1\0007\2\2\0027\2\3\2'\3\0\0>\2\2\0<\2\0\0:\1\4\0004\1\1\0007\1\5\0017\1\6\0017\1\a\1\16\2\0\0>\1\2\1G\0\1\0\20execute_command\bbuf\blsp\14arguments\22nvim_buf_get_name\bapi\bvim\1\0\2\fcommand _typescript.organizeImports\ntitle\5\3€€À™\4°\16\1\0\20\0f\1å\0014\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0024\2\3\0007\2\4\2%\3\5\0>\2\2\2)\3\0\0004\4\6\0007\4\a\4%\5\b\0>\4\2\0014\4\6\0007\4\t\0047\4\n\0047\4\v\4>\4\1\0027\5\f\0047\5\r\0057\5\14\5)\6\2\0:\6\15\5\16\5\2\0%\6\16\0$\5\6\5%\6\17\0004\a\0\0%\b\18\0>\a\2\0024\b\0\0%\t\19\0>\b\2\0024\t\0\0%\n\20\0>\t\2\0027\n\21\0007\n\22\n3\v\24\0003\f\23\0;\5\3\f;\6\5\f:\f\a\v:\1\25\v3\f\26\0:\f\27\v3\f\28\0:\f\29\v1\f\30\0:\f\31\v3\f \0:\f!\v3\f#\0003\r\"\0:\r$\f3\r%\0002\14\3\0;\a\1\14:\14&\r2\14\3\0;\a\1\14:\14'\r2\14\3\0;\a\1\14:\14(\r2\14\3\0;\t\1\14;\a\2\14:\14)\r2\14\3\0;\t\1\14;\a\2\14:\14*\r2\14\3\0;\t\1\14;\a\2\14:\14+\r2\14\3\0;\t\1\14;\a\2\14:\14,\r2\14\3\0;\t\1\14;\a\2\14:\14-\r2\14\3\0;\t\1\14;\a\2\14:\14.\r2\14\3\0;\a\1\14:\14/\r2\14\3\0;\a\1\14:\0140\r2\14\3\0;\a\1\14:\0141\r2\14\3\0;\a\1\14:\0142\r:\r3\f:\f4\v>\n\2\0017\n5\0007\n\22\n3\v6\0:\1\25\v:\0047\v3\f8\0:\f\27\v3\f:\0002\r\3\0001\0149\0;\14\1\r:\r;\f:\f<\v>\n\2\0014\n\0\0%\v\1\0>\n\2\0027\n=\n7\n\22\n3\v>\0:\1\25\v:\0047\v>\n\2\0014\n\0\0%\v\1\0>\n\2\0027\n'\n7\n\22\n3\v?\0:\1\25\v:\0047\v>\n\2\0017\n@\0007\n\22\n3\vA\0:\1\25\v:\0047\v>\n\2\0017\nB\0007\n\22\n3\vC\0:\1\25\v:\0047\v>\n\2\0014\n\6\0007\nD\n7\nE\n%\vF\0>\n\2\2\t\n\0\0T\n\2€%\3G\0T\n\b€4\n\6\0007\nD\n7\nE\n%\vH\0>\n\2\2\t\n\0\0T\n\1€%\3I\0\16\n\2\0%\vJ\0$\n\v\n\16\v\n\0%\fK\0\16\r\3\0%\14L\0$\v\14\v4\f\0\0%\r\1\0>\f\2\0027\fM\f7\f\22\f3\rP\0003\14N\0;\v\1\14\16\15\n\0%\16O\0$\15\16\15;\15\3\14:\14\a\r:\1\25\r3\14d\0003\15V\0003\16Q\0004\17\6\0007\17R\0174\18S\0007\18T\18%\19U\0>\17\3\2:\17T\16:\16W\0153\16Y\0003\17X\0:\17Z\16:\16[\0153\16_\0002\17\0\b4\18\6\0007\18D\0187\18\\\18%\19]\0>\18\2\2)\19\2\0009\19\18\0174\18\6\0007\18D\0187\18\\\18%\19^\0>\18\2\2)\19\2\0009\19\18\17:\17`\16:\16a\0153\16b\0:\16c\15:\15e\14:\0144\r>\f\2\0010\0\0€G\0\1\0\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\28$VIMRUNTIME/lua/vim/lsp\20$VIMRUNTIME/lua\vexpand\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\6;\tpath\fpackage\nsplit\1\0\1\fversion\vLuaJIT\1\0\0\14/main.lua\1\3\0\0\0\a-E\16sumneko_lua\25/lua-language-server\n/bin/\29/dev/lua-language-server\nLinux\tunix\nmacOS\bmac\bhas\afn\1\0\0\bhls\1\0\0\fpyright\1\0\0\1\0\0\ncssls\rcommands\20OrganizeImports\1\0\0\0\1\0\1\26debounce_text_changes\3ô\3\17capabilities\1\0\0\rtsserver\rsettings\14languages\fgraphql\tless\tsass\tscss\19typescript.tsx\19javascript.jsx\20typescriptreact\20javascriptreact\15typescript\15javascript\bcss\thtml\tyaml\1\0\0\16rootMarkers\1\0\0\1\5\0\0\17package.json\vgo.mod\n.git/\v.zshrc\17init_options\1\0\5\15codeAction\1\23documentFormatting\2\nhover\1\19documentSymbol\1\15completion\1\rroot_dir\0\14filetypes\1\v\0\0\tyaml\tjson\thtml\bcss\15javascript\15typescript\20javascriptreact\20typescriptreact\19javascript.jsx\19typescript.tsx\nflags\1\0\1\26debounce_text_changes\3–\1\14on_attach\1\0\0\1\5\0\0\19efm-langserver\a-c\0\r-logfile\nsetup\befm\21lsp/efm/eslint_d\23lsp/efm/prettier_d\22lsp/efm/prettierd\17/tmp/efm.log(/.config/efm-langserver/config.yaml\19snippetSupport\19completionItem\15completion\17textDocument\29make_client_capabilities\rprotocol\blsp\29 packadd nvim-lspconfig \bcmd\bvim\tHOME\vgetenv\aos\18lsp.on_attach\14lspconfig\frequire\2\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
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
    config = { "\27LJ\1\2\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0003\3\a\0:\3\b\2:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\vindent\1\0\1\venable\2\14highlight\fdisable\1\4\0\0\bcpp\trust\ago\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\a\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0" },
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
    config = { "\27LJ\1\2¼\4\0\0\b\0\29\0&4\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0027\1\3\0013\2\27\0003\3\4\0003\4\20\0003\5\6\0007\6\5\0:\6\a\0057\6\b\0:\6\t\0057\6\n\0:\6\v\0057\6\f\0:\6\r\0057\6\14\0007\a\b\0\30\6\a\6:\6\15\0057\6\16\0:\6\17\0057\6\18\0:\6\19\5:\5\21\0043\5\22\0007\6\5\0:\6\a\5:\5\23\4:\4\24\0033\4\25\0:\4\26\3:\3\28\2>\1\2\1G\0\1\0\rdefaults\1\0\0\25file_ignore_patterns\1\16\0\0\n%.jpg\v%.jpeg\n%.png\n%.svg\n%.otf\n%.ttf\v.git/*\19node_modules/*\23bower_components/*\v.svn/*\n.hg/*\nCVS/*\f.next/*\f.docz/*\14.DS_Store\rmappings\6n\1\0\0\6i\1\0\0\n<C-q>\19send_to_qflist\n<M-s>\28send_selected_to_qflist\n<TAB>\21toggle_selection\n<C-s>\22select_horizontal\n<C-k>\28move_selection_previous\n<C-j>\24move_selection_next\n<ESC>\1\0\0\nclose\1\0\1\18prompt_prefix\n â¯ \nsetup\14telescope\22telescope.actions\frequire\0" },
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
-- Setup for: nvim-tree.lua
time([[Setup for nvim-tree.lua]], true)
try_loadstring("\27LJ\1\2y\0\0\6\0\a\0\n4\0\0\0%\1\1\0>\0\2\0027\1\2\0%\2\3\0%\3\4\0%\4\5\0003\5\6\0>\1\5\1G\0\1\0\1\0\2\fnoremap\2\vsilent\2\28<cmd>NvimTreeToggle<CR>\14<leader>e\6n\bmap\nutils\frequire\0", "setup", "nvim-tree.lua")
time([[Setup for nvim-tree.lua]], false)
-- Setup for: telescope.nvim
time([[Setup for telescope.nvim]], true)
try_loadstring('\27LJ\1\2 \2\0\0\6\0\r\0\0224\0\0\0%\1\1\0>\0\2\0027\1\2\0%\2\3\0%\3\4\0%\4\5\0003\5\6\0>\1\5\0017\1\2\0%\2\3\0%\3\a\0%\4\b\0003\5\t\0>\1\5\0017\1\2\0%\2\3\0%\3\n\0%\4\v\0003\5\f\0>\1\5\1G\0\1\0\1\0\2\fnoremap\2\vsilent\2!<cmd>Telescope help_tags<CR>\14<Leader>h\1\0\2\fnoremap\2\vsilent\2\31<cmd>Telescope buffers<CR>\15<Leader>bb\1\0\2\fnoremap\2\vsilent\2"<cmd>Telescope find_files<CR>\n<C-p>\6n\bmap\nutils\frequire\0', "setup", "telescope.nvim")
time([[Setup for telescope.nvim]], false)
-- Config for: moonlight.nvim
time([[Config for moonlight.nvim]], true)
try_loadstring("\27LJ\1\2e\0\0\2\0\6\0\n4\0\0\0007\0\1\0)\1\1\0:\1\2\0004\0\3\0%\1\4\0>\0\2\0027\0\5\0>\0\1\1G\0\1\0\bset\14moonlight\frequire\30moonlight_italic_keywords\6g\bvim\0", "config", "moonlight.nvim")
time([[Config for moonlight.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\1\2\2\0\0\4\0\f\0\0154\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0003\3\a\0:\3\b\2:\2\t\0013\2\n\0:\2\v\1>\0\2\1G\0\1\0\vindent\1\0\1\venable\2\14highlight\fdisable\1\4\0\0\bcpp\trust\ago\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\a\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: neoscroll.nvim
time([[Config for neoscroll.nvim]], true)
try_loadstring("\27LJ\1\0027\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\14neoscroll\frequire\0", "config", "neoscroll.nvim")
time([[Config for neoscroll.nvim]], false)
-- Config for: navigator.lua
time([[Config for navigator.lua]], true)
try_loadstring("\27LJ\1\2Ú\1\0\0\4\0\6\0\v4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0002\2\3\0003\3\4\0;\3\1\2:\2\5\1>\0\2\1G\0\1\0\fkeymaps\1\0\2\tfunc\18declaration()\bkey\agK\1\0\6\19preview_height\4æÌ™³\6æÌÙş\3\vheight\4³æÌ™\3³æÌş\3\ndebug\1\20default_mapping\2\21code_action_icon\tï ´ \nwidth\4\0€€ ÿ\3\nsetup\14navigator\frequire\0", "config", "navigator.lua")
time([[Config for navigator.lua]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bwipeout lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bwipeout", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
