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
local package_path_str = "/Users/magnuscake/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/magnuscake/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/magnuscake/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/magnuscake/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/magnuscake/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
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
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/bufdelete.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n¬\n\0\0\5\0\28\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\16\0=\3\17\0025\3\18\0005\4\19\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\24\0=\3\25\0025\3\26\0=\3\27\2B\0\2\1K\0\1\0\tyadm\1\0\1\venable\2\16watch_index\1\0\1\rinterval\3Ë\a\fkeymaps\tn [c\1\2\1\0@&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\tn ]c\1\2\1\0@&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\b\17n <leader>hu5<cmd>lua require\"gitsigns\".undo_stage_hunk()<CR>\17n <leader>hs0<cmd>lua require\"gitsigns\".stage_hunk()<CR>\fnoremap\2\17n <leader>hb0<cmd>lua require\"gitsigns\".blame_line()<CR>\17n <leader>hp2<cmd>lua require\"gitsigns\".preview_hunk()<CR>\17n <leader>hR2<cmd>lua require\"gitsigns\".reset_buffer()<CR>\17n <leader>hr0<cmd>lua require\"gitsigns\".reset_hunk()<CR>\vbuffer\2\16count_chars\1\n\1\0\5\b‚ÇÇ\b‚ÇÉ\b‚ÇÑ\b‚ÇÖ\b‚ÇÜ\b‚Çá\b‚Çà\b‚Çâ\6+\b‚Çä\nsigns\1\0\a\nnumhl\1\20update_debounce\3d\18sign_priority\3\6\23current_line_blame\1\23use_decoration_api\2\vlinehl\1\22use_internal_diff\2\17changedelete\1\0\5\nnumhl\21GitSignsChangeNr\vlinehl\21GitSignsChangeLn\ttext\6~\15show_count\2\ahl\19GitSignsChange\14topdelete\1\0\5\nnumhl\21GitSignsDeleteNr\vlinehl\21GitSignsDeleteLn\ttext\b‚Äæ\15show_count\2\ahl\19GitSignsDelete\vdelete\1\0\5\nnumhl\21GitSignsDeleteNr\vlinehl\21GitSignsDeleteLn\ttext\6_\15show_count\2\ahl\19GitSignsDelete\vchange\1\0\4\nnumhl\21GitSignsChangeNr\vlinehl\21GitSignsChangeLn\ttext\6~\ahl\19GitSignsChange\badd\1\0\0\1\0\4\nnumhl\18GitSignsAddNr\vlinehl\18GitSignsAddLn\ttext\6+\ahl\16GitSignsAdd\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  kommentary = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/kommentary"
  },
  ["moonlight.nvim"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/moonlight.nvim"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/null-ls.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-autopairs"
  },
  ["nvim-compe"] = {
    after_files = { "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    config = { "\27LJ\2\nF\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim£\1\0\0\6\0\b\2\0306\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\23\0\0\0\b\0\1\0X\1\16Ä6\1\0\0009\1\1\0019\1\4\1'\3\3\0B\1\2\2\18\3\1\0009\1\5\1\18\4\0\0\18\5\0\0B\1\4\2\18\3\1\0009\1\6\1'\4\a\0B\1\3\2\15\0\1\0X\2\3Ä+\1\2\0L\1\2\0X\1\2Ä+\1\1\0L\1\2\0K\0\1\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0ï\1\0\0\3\2\6\1\0236\0\0\0009\0\1\0009\0\2\0B\0\1\2\t\0\0\0X\0\4Ä-\0\0\0'\2\3\0D\0\2\0X\0\fÄ-\0\1\0B\0\1\2\15\0\0\0X\1\4Ä-\0\0\0'\2\4\0D\0\2\0X\0\4Ä6\0\0\0009\0\1\0009\0\5\0D\0\1\0K\0\1\0\0¿\1¿\19compe#complete\n<Tab>\n<C-n>\15pumvisible\afn\bvim\2b\0\0\3\1\5\1\0146\0\0\0009\0\1\0009\0\2\0B\0\1\2\t\0\0\0X\0\4Ä-\0\0\0'\2\3\0D\0\2\0X\0\3Ä-\0\0\0'\2\4\0D\0\2\0K\0\1\0\0¿\f<S-Tab>\n<C-p>\15pumvisible\afn\bvim\2õ\1\0\0\5\1\a\0\0186\0\0\0\15\0\0\0X\1\bÄ6\0\0\0009\0\1\0B\0\1\2\15\0\0\0X\1\3Ä-\0\0\0'\2\2\0D\0\2\0006\0\3\0009\0\4\0009\0\5\0-\2\0\0'\4\6\0B\2\2\0C\0\0\0\0¿\t<CR>\18compe#confirm\afn\bvim\30<Plug>luasnip-next-choice\18choice_active\fluasnip\b\1\0\n\0\"\0@6\0\0\0009\0\1\0009\0\2\0005\1\4\0=\1\3\0006\0\0\0009\0\5\0'\1\a\0=\1\6\0006\0\b\0'\2\t\0B\0\2\0029\0\n\0005\2\v\0005\3\f\0=\3\r\2B\0\2\0013\0\14\0003\1\15\0006\2\16\0003\3\18\0=\3\17\0026\2\16\0003\3\20\0=\3\19\0026\2\16\0003\3\22\0=\3\21\0026\2\b\0'\4\23\0B\2\2\0025\3\24\0009\4\25\2'\6\26\0'\a\27\0'\b\28\0\18\t\3\0B\4\5\0019\4\25\2'\6\29\0'\a\27\0'\b\28\0\18\t\3\0B\4\5\0019\4\25\2'\6\26\0'\a\30\0'\b\31\0\18\t\3\0B\4\5\0019\4\25\2'\6\29\0'\a\30\0'\b\31\0\18\t\3\0B\4\5\0019\4\25\2'\6\26\0'\a \0'\b!\0\18\t\3\0B\4\5\0012\0\0ÄK\0\1\0\27v:lua.enter_complete()\t<CR>\27v:lua.s_tab_complete()\f<S-Tab>\6s\25v:lua.tab_complete()\n<Tab>\6i\bmap\1\0\2\texpr\2\vsilent\2\nutils\0\19enter_complete\0\19s_tab_complete\0\17tab_complete\a_G\0\0\vsource\1\0\n\tpath\2\nspell\2\nvsnip\2\18snippets_nvim\2\rnvim_lua\2\rnvim_lsp\2\ttags\2\tcalc\2\15treesitter\2\vbuffer\2\1\0\f\14preselect\venable\15min_length\3\1\17autocomplete\2\fenabled\2\18throttle_time\3P\18documentation\2\19max_menu_width\3d\19max_kind_width\3d\19max_abbr_width\3d\21incomplete_delay\3ê\3\19source_timeout\3»\1\ndebug\1\nsetup\ncompe\frequire\21menuone,noselect\16completeopt\6o\1\26\0\0\15ÔÆú [text]\17Óòã [method]\19Ôûî [function]\22Óàè [constructor]\16Ô∞† [field]\19ÔÄ´ [variable]\16ÔÜ≤ [class]\20Ôö¶ [interface]\17ÔÜ≥ [module]\19Óò§ [property]\15Ôëµ [unit]\16Ô¢ü [value]\15Ôëë [enum]\14Ô†ä [key]\18Ôââ [snippet]\16Óà´ [color]\15ÔÖõ [file]\20Ô†∏ [reference]\17ÔÅª [folder]\22ÔÖù [enum member]\19Óà¨ [constant]\17ÔÉä [struct]\16‚åò [event]\19ÔÅï [operator]\15‚åÇ [type]\23CompletionItemKind\rprotocol\blsp\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lsp-ts-utils"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿O\0\1\4\1\2\0\a9\1\0\0+\2\1\0=\2\1\1-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\24document_formatting\26resolved_capabilities\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿µ\n\1\0\21\0V\1¢\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0029\2\5\2'\4\6\0B\2\2\0027\2\a\0006\2\b\0009\2\t\2'\4\n\0B\2\2\2+\3\0\0006\4\3\0009\4\4\0049\4\v\4'\6\f\0B\4\2\2\t\4\0\0X\4\2Ä'\3\r\0X\4\bÄ6\4\3\0009\4\4\0049\4\v\4'\6\14\0B\4\2\2\t\4\0\0X\4\1Ä'\3\15\0\18\4\2\0'\5\16\0&\4\5\4\18\5\4\0'\6\17\0\18\a\3\0'\b\18\0&\5\b\0056\6\0\0'\b\1\0B\6\2\0029\6\19\0069\6\20\0065\b\23\0005\t\21\0>\5\1\t\18\n\4\0'\v\22\0&\n\v\n>\n\3\t=\t\24\b=\1\25\b5\t,\0005\n\31\0005\v\26\0006\f\3\0009\f\27\f6\14\28\0009\14\29\14'\15\30\0B\f\3\2=\f\29\v=\v \n5\v\"\0005\f!\0=\f#\v=\v$\n5\v'\0004\f\0\b6\r\3\0009\r\4\r9\r\5\r'\15%\0B\r\2\2+\14\2\0<\14\r\f6\r\3\0009\r\4\r9\r\5\r'\15&\0B\r\2\2+\14\2\0<\14\r\f=\f(\v=\v)\n5\v*\0=\v+\n=\n-\t=\t.\bB\6\2\0014\6\0\0005\a1\0003\b0\0=\b\25\a=\a/\0065\a4\0003\b3\0=\b\25\a=\a2\0065\a7\0003\b6\0=\b\25\a=\a5\0065\a:\0003\b9\0=\b\25\a=\a8\0065\a=\0003\b<\0=\b\25\a=\a;\0065\a@\0003\b?\0=\b\25\a=\a>\0065\aC\0003\bB\0=\b\25\a=\aA\0066\a\0\0'\tD\0B\a\2\2=\aE\0066\b\3\0009\bF\b9\bG\b9\bH\bB\b\1\0029\tI\b9\tJ\t9\tK\t+\n\2\0=\nL\t9\tI\b9\tJ\t9\tK\t5\nO\0005\vN\0=\vP\n=\nM\t6\tQ\0\18\v\6\0B\t\2\4H\f\nÄ8\14\f\0009\14\20\0146\16\3\0009\16R\16'\18S\0005\19T\0=\bU\19\18\20\r\0B\16\4\0A\14\0\1F\f\3\3R\fÙ2\0\0ÄK\0\1\0\17capabilities\1\0\0\nforce\20tbl_deep_extend\npairs\15properties\1\0\0\1\4\0\0\18documentation\vdetail\24additionalTextEdits\19resolveSupport\19snippetSupport\19completionItem\15completion\17textDocument\29make_client_capabilities\rprotocol\blsp\befm\flsp.efm\1\0\0\0\bhls\1\0\0\0\fpyright\1\0\0\0\thtml\1\0\0\0\ncssls\1\0\0\0\rtsserver\1\0\0\0\nvimls\1\0\0\0\vbashls\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\28$VIMRUNTIME/lua/vim/lsp\20$VIMRUNTIME/lua\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\6;\tpath\fpackage\nsplit\1\0\1\fversion\vLuaJIT\14on_attach\bcmd\1\0\0\14/main.lua\1\3\0\0\0\a-E\nsetup\16sumneko_lua\25/lua-language-server\n/bin/\29/dev/lua-language-server\nLinux\tunix\nmacOS\bmac\bhas\tHOME\vgetenv\aos\tUSER\n$USER\vexpand\afn\bvim\18lsp.on_attach\14lspconfig\frequire\2\0" },
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    after = { "nvim-web-devicons" },
    commands = { "NvimTreeOpen", "NvimTreeToggle" },
    config = { "\27LJ\2\n3\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\20NvimTreeRefresh\bcmd\bvim˙\a\1\0\a\0'\0_6\0\0\0009\0\1\0)\1\28\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\5\0006\0\0\0009\0\1\0)\1\1\0=\1\6\0006\0\a\0'\2\b\0B\0\2\0029\0\t\0006\1\0\0009\1\1\0014\2\n\0005\3\v\0\18\4\0\0'\6\f\0B\4\2\2=\4\r\3>\3\1\0025\3\14\0\18\4\0\0'\6\f\0B\4\2\2=\4\r\3>\3\2\0025\3\15\0\18\4\0\0'\6\f\0B\4\2\2=\4\r\3>\3\3\0025\3\16\0\18\4\0\0'\6\17\0B\4\2\2=\4\r\3>\3\4\0025\3\18\0\18\4\0\0'\6\19\0B\4\2\2=\4\r\3>\3\5\0025\3\20\0\18\4\0\0'\6\21\0B\4\2\2=\4\r\3>\3\6\0025\3\22\0\18\4\0\0'\6\23\0B\4\2\2=\4\r\3>\3\a\0025\3\24\0\18\4\0\0'\6\25\0B\4\2\2=\4\r\3>\3\b\0025\3\26\0\18\4\0\0'\6\27\0B\4\2\2=\4\r\3>\3\t\2=\2\n\0016\1\0\0009\1\1\0015\2\29\0005\3\30\0=\3\31\0025\3 \0=\3!\0025\3\"\0=\3#\2=\2\28\0016\1\a\0'\3$\0B\1\2\0029\1%\0013\3&\0B\1\2\1K\0\1\0\0\23on_nvim_tree_ready\21nvim-tree.events\blsp\1\0\4\tinfo\bÔÅö\fwarning\bÔÅ±\thint\bÔÅ™\nerror\bÔÅó\vfolder\1\0\b\15empty_open\bÔÑï\topen\bÓóæ\nempty\bÔÑî\fsymlink\bÔíÇ\fdefault\bÓóø\17arrow_closed\bÔë†\17symlink_open\bÓóæ\15arrow_open\bÔëº\bgit\1\0\5\runstaged\b‚úó\14untracked\b‚òÖ\frenamed\b‚ûú\runmerged\bÓúß\vstaged\b‚úì\1\0\2\fsymlink\tÔíÅ \fdefault\tÓòí \20nvim_tree_icons\vdir_up\1\0\1\bkey\6-\vrename\1\0\1\bkey\6r\frefresh\1\0\1\bkey\6R\vtabnew\1\0\1\bkey\n<C-t>\nsplit\1\0\1\bkey\n<C-s>\vvsplit\1\0\1\bkey\n<C-v>\1\0\1\bkey\6l\1\0\1\bkey\6o\acb\tedit\1\0\1\bkey\t<CR>\23nvim_tree_bindings\23nvim_tree_callback\21nvim-tree.config\frequire\21nvim_tree_follow\25nvim_tree_auto_close\1\4\0\0\t.git\17node_modules\v.cache\21nvim_tree_ignore\20nvim_tree_width\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n∏\2\0\0\4\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\2B\0\2\1K\0\1\0\26context_commentstring\1\0\1\venable\2\rrainbows\1\0\1\venable\2\vindent\1\0\1\venable\2\14highlight\1\0\2\venable\2\21use_languagetree\2\19ignore_install\1\b\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\bzig\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-ts-autotag"] = {
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20nvim-ts-autotag\frequire\0" },
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag"
  },
  ["nvim-web-devicons"] = {
    load_after = {
      ["nvim-tree.lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\n•\5\0\0\t\0#\0,6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0029\1\3\0015\3\27\0005\4\4\0005\5\20\0005\6\6\0009\a\5\0=\a\a\0069\a\b\0=\a\t\0069\a\n\0=\a\v\0069\a\f\0=\a\r\0069\a\14\0009\b\b\0 \a\b\a=\a\15\0069\a\16\0=\a\17\0069\a\18\0=\a\19\6=\6\21\0055\6\22\0009\a\5\0=\a\a\6=\6\23\5=\5\24\0045\5\25\0=\5\26\4=\4\28\0035\4 \0005\5\29\0005\6\30\0=\6\31\5=\5!\4=\4\"\3B\1\2\1K\0\1\0\fpickers\15find_files\1\0\0\18layout_config\1\0\1\vheight\4ö≥ÊÃ\tô≥Üˇ\3\1\0\2\ntheme\bivy\14previewer\1\rdefaults\1\0\0\25file_ignore_patterns\1\16\0\0\n%.jpg\v%.jpeg\n%.png\n%.svg\n%.otf\n%.ttf\v.git/*\19node_modules/*\23bower_components/*\v.svn/*\n.hg/*\nCVS/*\f.next/*\f.docz/*\14.DS_Store\rmappings\6n\1\0\0\6i\1\0\0\n<C-q>\19send_to_qflist\n<M-s>\28send_selected_to_qflist\n<TAB>\21toggle_selection\n<C-s>\22select_horizontal\n<C-k>\28move_selection_previous\n<C-j>\24move_selection_next\n<ESC>\1\0\0\nclose\1\0\1\18prompt_prefix\n ‚ùØ \nsetup\14telescope\22telescope.actions\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\nY\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\15open_split\1\0\0\1\2\0\0\n<c-x>\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/vim-eunuch"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-moonfly-colors"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/vim-moonfly-colors"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/magnuscake/.local/share/nvim/site/pack/packer/start/vim-surround"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: telescope.nvim
time([[Setup for telescope.nvim]], true)
try_loadstring("\27LJ\2\n†\2\0\0\a\0\r\0\0226\0\0\0'\2\1\0B\0\2\0029\1\2\0'\3\3\0'\4\4\0'\5\5\0005\6\6\0B\1\5\0019\1\2\0'\3\3\0'\4\a\0'\5\b\0005\6\t\0B\1\5\0019\1\2\0'\3\3\0'\4\n\0'\5\v\0005\6\f\0B\1\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\2!<cmd>Telescope help_tags<CR>\14<Leader>h\1\0\2\vsilent\2\fnoremap\2\31<cmd>Telescope buffers<CR>\15<Leader>bb\1\0\2\vsilent\2\fnoremap\2\"<cmd>Telescope find_files<CR>\n<C-p>\6n\bmap\nutils\frequire\0", "setup", "telescope.nvim")
time([[Setup for telescope.nvim]], false)
-- Setup for: nvim-tree.lua
time([[Setup for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\ny\0\0\a\0\a\0\n6\0\0\0'\2\1\0B\0\2\0029\1\2\0'\3\3\0'\4\4\0'\5\5\0005\6\6\0B\1\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\2\28<cmd>NvimTreeToggle<CR>\14<leader>e\6n\bmap\nutils\frequire\0", "setup", "nvim-tree.lua")
time([[Setup for nvim-tree.lua]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n∏\2\0\0\4\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\2B\0\2\1K\0\1\0\26context_commentstring\1\0\1\venable\2\rrainbows\1\0\1\venable\2\vindent\1\0\1\venable\2\14highlight\1\0\2\venable\2\21use_languagetree\2\19ignore_install\1\b\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\bzig\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-ts-autotag
time([[Config for nvim-ts-autotag]], true)
try_loadstring("\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20nvim-ts-autotag\frequire\0", "config", "nvim-ts-autotag")
time([[Config for nvim-ts-autotag]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿O\0\1\4\1\2\0\a9\1\0\0+\2\1\0=\2\1\1-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\24document_formatting\26resolved_capabilities\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿\25\0\1\4\1\0\0\4-\1\0\0\18\3\0\0B\1\2\1K\0\1\0\1¿µ\n\1\0\21\0V\1¢\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0029\2\5\2'\4\6\0B\2\2\0027\2\a\0006\2\b\0009\2\t\2'\4\n\0B\2\2\2+\3\0\0006\4\3\0009\4\4\0049\4\v\4'\6\f\0B\4\2\2\t\4\0\0X\4\2Ä'\3\r\0X\4\bÄ6\4\3\0009\4\4\0049\4\v\4'\6\14\0B\4\2\2\t\4\0\0X\4\1Ä'\3\15\0\18\4\2\0'\5\16\0&\4\5\4\18\5\4\0'\6\17\0\18\a\3\0'\b\18\0&\5\b\0056\6\0\0'\b\1\0B\6\2\0029\6\19\0069\6\20\0065\b\23\0005\t\21\0>\5\1\t\18\n\4\0'\v\22\0&\n\v\n>\n\3\t=\t\24\b=\1\25\b5\t,\0005\n\31\0005\v\26\0006\f\3\0009\f\27\f6\14\28\0009\14\29\14'\15\30\0B\f\3\2=\f\29\v=\v \n5\v\"\0005\f!\0=\f#\v=\v$\n5\v'\0004\f\0\b6\r\3\0009\r\4\r9\r\5\r'\15%\0B\r\2\2+\14\2\0<\14\r\f6\r\3\0009\r\4\r9\r\5\r'\15&\0B\r\2\2+\14\2\0<\14\r\f=\f(\v=\v)\n5\v*\0=\v+\n=\n-\t=\t.\bB\6\2\0014\6\0\0005\a1\0003\b0\0=\b\25\a=\a/\0065\a4\0003\b3\0=\b\25\a=\a2\0065\a7\0003\b6\0=\b\25\a=\a5\0065\a:\0003\b9\0=\b\25\a=\a8\0065\a=\0003\b<\0=\b\25\a=\a;\0065\a@\0003\b?\0=\b\25\a=\a>\0065\aC\0003\bB\0=\b\25\a=\aA\0066\a\0\0'\tD\0B\a\2\2=\aE\0066\b\3\0009\bF\b9\bG\b9\bH\bB\b\1\0029\tI\b9\tJ\t9\tK\t+\n\2\0=\nL\t9\tI\b9\tJ\t9\tK\t5\nO\0005\vN\0=\vP\n=\nM\t6\tQ\0\18\v\6\0B\t\2\4H\f\nÄ8\14\f\0009\14\20\0146\16\3\0009\16R\16'\18S\0005\19T\0=\bU\19\18\20\r\0B\16\4\0A\14\0\1F\f\3\3R\fÙ2\0\0ÄK\0\1\0\17capabilities\1\0\0\nforce\20tbl_deep_extend\npairs\15properties\1\0\0\1\4\0\0\18documentation\vdetail\24additionalTextEdits\19resolveSupport\19snippetSupport\19completionItem\15completion\17textDocument\29make_client_capabilities\rprotocol\blsp\befm\flsp.efm\1\0\0\0\bhls\1\0\0\0\fpyright\1\0\0\0\thtml\1\0\0\0\ncssls\1\0\0\0\rtsserver\1\0\0\0\nvimls\1\0\0\0\vbashls\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\28$VIMRUNTIME/lua/vim/lsp\20$VIMRUNTIME/lua\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\6;\tpath\fpackage\nsplit\1\0\1\fversion\vLuaJIT\14on_attach\bcmd\1\0\0\14/main.lua\1\3\0\0\0\a-E\nsetup\16sumneko_lua\25/lua-language-server\n/bin/\29/dev/lua-language-server\nLinux\tunix\nmacOS\bmac\bhas\tHOME\vgetenv\aos\tUSER\n$USER\vexpand\afn\bvim\18lsp.on_attach\14lspconfig\frequire\2\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\nY\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\15open_split\1\0\0\1\2\0\0\n<c-x>\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file Bwipeout lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bwipeout", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs', 'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
