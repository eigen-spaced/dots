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
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\1\2‰\1\0\0\3\0\6\0\t4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\1>\0\2\1G\0\1\0\20buftype_exclude\1\3\0\0\rterminal\rreadonly\1\0\1\25show_current_context\2\nsetup\21indent_blankline\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim"
  },
  kommentary = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/kommentary"
  },
  ["moonlight.nvim"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/moonlight.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\1\2@\0\0\2\0\3\0\a4\0\0\0%\1\1\0>\0\2\0027\0\2\0002\1\0\0>\0\2\1G\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-autopairs"
  },
  ["nvim-compe"] = {
    after_files = { "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    config = { '\27LJ\1\2F\0\1\6\0\3\0\b4\1\0\0007\1\1\0017\1\2\1\16\2\0\0)\3\2\0)\4\2\0)\5\2\0@\1\5\0\27nvim_replace_termcodes\bapi\bvim£\1\0\0\5\0\b\2\0304\0\0\0007\0\1\0007\0\2\0%\1\3\0>\0\2\2\21\0\0\0\b\0\1\0T\1\16€4\1\0\0007\1\1\0017\1\4\1%\2\3\0>\1\2\2\16\2\1\0007\1\5\1\16\3\0\0\16\4\0\0>\1\4\2\16\2\1\0007\1\6\1%\3\a\0>\1\3\2\15\0\1\0T\2\3€)\1\2\0H\1\2\0T\1\2€)\1\1\0H\1\2\0G\0\1\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0•\1\0\0\2\2\6\1\0234\0\0\0007\0\1\0007\0\2\0>\0\1\2\t\0\0\0T\0\4€+\0\0\0%\1\3\0@\0\2\0T\0\f€+\0\1\0>\0\1\2\15\0\0\0T\1\4€+\0\0\0%\1\4\0@\0\2\0T\0\4€4\0\0\0007\0\1\0007\0\5\0@\0\1\0G\0\1\0\0À\1À\19compe#complete\n<Tab>\n<C-n>\15pumvisible\afn\bvim\2b\0\0\2\1\5\1\0144\0\0\0007\0\1\0007\0\2\0>\0\1\2\t\0\0\0T\0\4€+\0\0\0%\1\3\0@\0\2\0T\0\3€+\0\0\0%\1\4\0@\0\2\0G\0\1\0\0À\f<S-Tab>\n<C-p>\15pumvisible\afn\bvim\2›\1\0\0\3\1\a\0\0184\0\0\0\15\0\0\0T\1\b€4\0\0\0007\0\1\0>\0\1\2\15\0\0\0T\1\3€+\0\0\0%\1\2\0@\0\2\0004\0\3\0007\0\4\0007\0\5\0+\1\0\0%\2\6\0>\1\2\0?\0\0\0\0À\t<CR>\18compe#confirm\afn\bvim\30<Plug>luasnip-next-choice\18choice_active\fluasnipğ\b\1\0\t\0"\0@4\0\0\0007\0\1\0007\0\2\0003\1\4\0:\1\3\0004\0\0\0007\0\5\0%\1\a\0:\1\6\0004\0\b\0%\1\t\0>\0\2\0027\0\n\0003\1\v\0003\2\f\0:\2\r\1>\0\2\0011\0\14\0001\1\15\0004\2\16\0001\3\18\0:\3\17\0024\2\16\0001\3\20\0:\3\19\0024\2\16\0001\3\22\0:\3\21\0024\2\b\0%\3\23\0>\2\2\0023\3\24\0007\4\25\2%\5\26\0%\6\27\0%\a\28\0\16\b\3\0>\4\5\0017\4\25\2%\5\29\0%\6\27\0%\a\28\0\16\b\3\0>\4\5\0017\4\25\2%\5\26\0%\6\30\0%\a\31\0\16\b\3\0>\4\5\0017\4\25\2%\5\29\0%\6\30\0%\a\31\0\16\b\3\0>\4\5\0017\4\25\2%\5\26\0%\6 \0%\a!\0\16\b\3\0>\4\5\0010\0\0€G\0\1\0\27v:lua.enter_complete()\t<CR>\27v:lua.s_tab_complete()\f<S-Tab>\6s\25v:lua.tab_complete()\n<Tab>\6i\bmap\1\0\2\texpr\2\vsilent\2\nutils\0\19enter_complete\0\19s_tab_complete\0\17tab_complete\a_G\0\0\vsource\1\0\n\rnvim_lsp\2\ttags\2\nvsnip\2\15treesitter\2\tpath\2\18snippets_nvim\2\rnvim_lua\2\nspell\2\vbuffer\2\tcalc\2\1\0\f\17autocomplete\2\19source_timeout\3È\1\fenabled\2\ndebug\1\14preselect\venable\19max_abbr_width\3d\21incomplete_delay\3\3\19max_menu_width\3d\19max_kind_width\3d\15min_length\3\1\18throttle_time\3P\18documentation\2\nsetup\ncompe\frequire\21menuone,noselect\16completeopt\6o\1\26\0\0\15ï®œ [text]\17î˜‹ [method]\19ï” [function]\22îˆ [constructor]\16ï°  [field]\19ï€« [variable]\16ï†² [class]\20ïš¦ [interface]\17ï†³ [module]\19î˜¤ [property]\15ï‘µ [unit]\16ï¢Ÿ [value]\15ï‘‘ [enum]\14ï Š [key]\18ï‰‰ [snippet]\16îˆ« [color]\15ï…› [file]\20ï ¸ [reference]\17ï» [folder]\22ï… [enum member]\19îˆ¬ [constant]\17ïƒŠ [struct]\16âŒ˜ [event]\19ï• [operator]\15âŒ‚ [type]\23CompletionItemKind\rprotocol\blsp\bvim\0' },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lsp-ts-utils"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\1\2O\0\1\3\1\2\0\a7\1\0\0)\2\1\0:\2\1\1+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\24document_formatting\26resolved_capabilities\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À£\v\1\0\19\0X\1¤\0014\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0024\2\3\0007\2\4\0027\2\5\2%\3\6\0>\2\2\0025\2\a\0004\2\b\0007\2\t\2%\3\n\0>\2\2\2)\3\0\0004\4\3\0007\4\v\0047\4\f\0047\4\r\4>\4\1\0027\5\14\0047\5\15\0057\5\16\5)\6\2\0:\6\17\0057\5\14\0047\5\15\0057\5\16\0053\6\20\0003\a\19\0:\a\21\6:\6\18\0054\5\3\0007\5\4\0057\5\22\5%\6\23\0>\5\2\2\t\5\0\0T\5\2€%\3\24\0T\5\b€4\5\3\0007\5\4\0057\5\22\5%\6\25\0>\5\2\2\t\5\0\0T\5\1€%\3\26\0\16\5\2\0%\6\27\0$\5\6\5\16\6\5\0%\a\28\0\16\b\3\0%\t\29\0$\6\t\0067\a\30\0007\a\31\a3\b\"\0003\t \0;\6\1\t\16\n\5\0%\v!\0$\n\v\n;\n\3\t:\t#\b:\1$\b3\t7\0003\n*\0003\v%\0004\f\3\0007\f&\f4\r'\0007\r(\r%\14)\0>\f\3\2:\f(\v:\v+\n3\v-\0003\f,\0:\f.\v:\v/\n3\v2\0002\f\0\b4\r\3\0007\r\4\r7\r\5\r%\0140\0>\r\2\2)\14\2\0009\14\r\f4\r\3\0007\r\4\r7\r\5\r%\0141\0>\r\2\2)\14\2\0009\14\r\f:\f3\v:\v4\n3\v5\0:\v6\n:\n8\t:\t9\b>\a\2\0017\a:\0007\a\31\a3\b<\0001\t;\0:\t$\b;\4\1\b3\t=\0:\t>\b>\a\2\0012\a\0\0003\bA\0001\t@\0:\t$\b:\b?\a3\bD\0001\tC\0:\t$\b:\bB\a3\bG\0001\tF\0:\t$\b:\bE\a3\bJ\0001\tI\0:\t$\b:\bH\a3\bM\0001\tL\0:\t$\b:\bK\a3\bP\0001\tO\0:\t$\b:\bN\a4\b\0\0%\tQ\0>\b\2\2:\bR\a4\tS\0\16\n\a\0>\t\2\4D\f\n€6\14\f\0007\14\31\0144\15\3\0007\15T\15%\16U\0003\17V\0:\4W\17\16\18\r\0>\15\4\0=\14\0\1B\f\3\3N\fô0\0\0€G\0\1\0\17capabilities\1\0\0\nforce\20tbl_deep_extend\npairs\befm\flsp.efm\1\0\0\0\bhls\1\0\0\0\fpyright\1\0\0\0\thtml\1\0\0\0\ncssls\1\0\0\0\nvimls\1\0\0\0\vbashls\14filetypes\1\a\0\0\15javascript\20javascriptreact\19javascript.jsx\15typescript\20typescriptreact\19typescript.tsx\1\0\0\0\rtsserver\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\28$VIMRUNTIME/lua/vim/lsp\20$VIMRUNTIME/lua\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\6;\tpath\fpackage\nsplit\1\0\1\fversion\vLuaJIT\14on_attach\bcmd\1\0\0\14/main.lua\1\3\0\0\0\a-E\nsetup\16sumneko_lua\25/lua-language-server\n/bin/\29/dev/lua-language-server\nLinux\tunix\nmacOS\bmac\bhas\15properties\1\0\0\1\4\0\0\18documentation\vdetail\24additionalTextEdits\19resolveSupport\19snippetSupport\19completionItem\15completion\17textDocument\29make_client_capabilities\rprotocol\blsp\tHOME\vgetenv\aos\tUSER\n$USER\vexpand\afn\bvim\22lsp.custom_attach\14lspconfig\frequire\2\0" },
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
    config = { "\27LJ\1\2¸\2\0\0\3\0\14\0\0174\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0:\2\a\0013\2\b\0:\2\t\0013\2\n\0:\2\v\0013\2\f\0:\2\r\1>\0\2\1G\0\1\0\26context_commentstring\1\0\1\venable\2\rrainbows\1\0\1\venable\2\vindent\1\0\1\venable\2\14highlight\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\b\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\bzig\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-ts-autotag"] = {
    config = { "\27LJ\1\2=\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\20nvim-ts-autotag\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag"
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
  ["telescope.nvim"] = {
    config = { '\27LJ\1\2¥\5\0\0\b\0#\0,4\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0027\1\3\0013\2\27\0003\3\4\0003\4\20\0003\5\6\0007\6\5\0:\6\a\0057\6\b\0:\6\t\0057\6\n\0:\6\v\0057\6\f\0:\6\r\0057\6\14\0007\a\b\0\30\6\a\6:\6\15\0057\6\16\0:\6\17\0057\6\18\0:\6\19\5:\5\21\0043\5\22\0007\6\5\0:\6\a\5:\5\23\4:\4\24\0033\4\25\0:\4\26\3:\3\28\0023\3 \0003\4\29\0003\5\30\0:\5\31\4:\4!\3:\3"\2>\1\2\1G\0\1\0\fpickers\15find_files\1\0\0\18layout_config\1\0\1\vheight\4š³æÌ\t™³†ÿ\3\1\0\2\14previewer\1\ntheme\bivy\rdefaults\1\0\0\25file_ignore_patterns\1\16\0\0\n%.jpg\v%.jpeg\n%.png\n%.svg\n%.otf\n%.ttf\v.git/*\19node_modules/*\23bower_components/*\v.svn/*\n.hg/*\nCVS/*\f.next/*\f.docz/*\14.DS_Store\rmappings\6n\1\0\0\6i\1\0\0\n<C-q>\19send_to_qflist\n<M-s>\28send_selected_to_qflist\n<TAB>\21toggle_selection\n<C-s>\22select_horizontal\n<C-k>\28move_selection_previous\n<C-j>\24move_selection_next\n<ESC>\1\0\0\nclose\1\0\1\18prompt_prefix\n â¯ \nsetup\14telescope\22telescope.actions\frequire\0' },
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\1\2Y\0\0\3\0\6\0\t4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\4\0003\2\3\0:\2\5\1>\0\2\1G\0\1\0\15open_split\1\0\0\1\2\0\0\n<c-x>\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-eunuch"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-moonfly-colors"] = {
    loaded = true,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/start/vim-moonfly-colors"
  },
  ["vim-surround"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/magnuscake/.local/share/nvim/site/pack/packer/opt/vim-surround"
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
-- Config for: nvim-ts-autotag
time([[Config for nvim-ts-autotag]], true)
try_loadstring("\27LJ\1\2=\0\0\2\0\3\0\0064\0\0\0%\1\1\0>\0\2\0027\0\2\0>\0\1\1G\0\1\0\nsetup\20nvim-ts-autotag\frequire\0", "config", "nvim-ts-autotag")
time([[Config for nvim-ts-autotag]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\1\2Y\0\0\3\0\6\0\t4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\4\0003\2\3\0:\2\5\1>\0\2\1G\0\1\0\15open_split\1\0\0\1\2\0\0\n<c-x>\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: indent-blankline.nvim
time([[Config for indent-blankline.nvim]], true)
try_loadstring("\27LJ\1\2‰\1\0\0\3\0\6\0\t4\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\1>\0\2\1G\0\1\0\20buftype_exclude\1\3\0\0\rterminal\rreadonly\1\0\1\25show_current_context\2\nsetup\21indent_blankline\frequire\0", "config", "indent-blankline.nvim")
time([[Config for indent-blankline.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\1\2¸\2\0\0\3\0\14\0\0174\0\0\0%\1\1\0>\0\2\0027\0\2\0003\1\3\0003\2\4\0:\2\5\0013\2\6\0:\2\a\0013\2\b\0:\2\t\0013\2\n\0:\2\v\0013\2\f\0:\2\r\1>\0\2\1G\0\1\0\26context_commentstring\1\0\1\venable\2\rrainbows\1\0\1\venable\2\vindent\1\0\1\venable\2\14highlight\1\0\2\21use_languagetree\2\venable\2\19ignore_install\1\b\0\0\tjava\bphp\vkotlin\nscala\velixir\nocaml\bzig\1\0\1\21ensure_installed\15maintained\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\1\2O\0\1\3\1\2\0\a7\1\0\0)\2\1\0:\2\1\1+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\24document_formatting\26resolved_capabilities\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À\25\0\1\3\1\0\0\4+\1\0\0\16\2\0\0>\1\2\1G\0\1\0\1À£\v\1\0\19\0X\1¤\0014\0\0\0%\1\1\0>\0\2\0024\1\0\0%\2\2\0>\1\2\0024\2\3\0007\2\4\0027\2\5\2%\3\6\0>\2\2\0025\2\a\0004\2\b\0007\2\t\2%\3\n\0>\2\2\2)\3\0\0004\4\3\0007\4\v\0047\4\f\0047\4\r\4>\4\1\0027\5\14\0047\5\15\0057\5\16\5)\6\2\0:\6\17\0057\5\14\0047\5\15\0057\5\16\0053\6\20\0003\a\19\0:\a\21\6:\6\18\0054\5\3\0007\5\4\0057\5\22\5%\6\23\0>\5\2\2\t\5\0\0T\5\2€%\3\24\0T\5\b€4\5\3\0007\5\4\0057\5\22\5%\6\25\0>\5\2\2\t\5\0\0T\5\1€%\3\26\0\16\5\2\0%\6\27\0$\5\6\5\16\6\5\0%\a\28\0\16\b\3\0%\t\29\0$\6\t\0067\a\30\0007\a\31\a3\b\"\0003\t \0;\6\1\t\16\n\5\0%\v!\0$\n\v\n;\n\3\t:\t#\b:\1$\b3\t7\0003\n*\0003\v%\0004\f\3\0007\f&\f4\r'\0007\r(\r%\14)\0>\f\3\2:\f(\v:\v+\n3\v-\0003\f,\0:\f.\v:\v/\n3\v2\0002\f\0\b4\r\3\0007\r\4\r7\r\5\r%\0140\0>\r\2\2)\14\2\0009\14\r\f4\r\3\0007\r\4\r7\r\5\r%\0141\0>\r\2\2)\14\2\0009\14\r\f:\f3\v:\v4\n3\v5\0:\v6\n:\n8\t:\t9\b>\a\2\0017\a:\0007\a\31\a3\b<\0001\t;\0:\t$\b;\4\1\b3\t=\0:\t>\b>\a\2\0012\a\0\0003\bA\0001\t@\0:\t$\b:\b?\a3\bD\0001\tC\0:\t$\b:\bB\a3\bG\0001\tF\0:\t$\b:\bE\a3\bJ\0001\tI\0:\t$\b:\bH\a3\bM\0001\tL\0:\t$\b:\bK\a3\bP\0001\tO\0:\t$\b:\bN\a4\b\0\0%\tQ\0>\b\2\2:\bR\a4\tS\0\16\n\a\0>\t\2\4D\f\n€6\14\f\0007\14\31\0144\15\3\0007\15T\15%\16U\0003\17V\0:\4W\17\16\18\r\0>\15\4\0=\14\0\1B\f\3\3N\fô0\0\0€G\0\1\0\17capabilities\1\0\0\nforce\20tbl_deep_extend\npairs\befm\flsp.efm\1\0\0\0\bhls\1\0\0\0\fpyright\1\0\0\0\thtml\1\0\0\0\ncssls\1\0\0\0\nvimls\1\0\0\0\vbashls\14filetypes\1\a\0\0\15javascript\20javascriptreact\19javascript.jsx\15typescript\20typescriptreact\19typescript.tsx\1\0\0\0\rtsserver\rsettings\bLua\1\0\0\14telemetry\1\0\1\venable\1\14workspace\flibrary\1\0\0\28$VIMRUNTIME/lua/vim/lsp\20$VIMRUNTIME/lua\16diagnostics\fglobals\1\0\0\1\2\0\0\bvim\fruntime\1\0\0\6;\tpath\fpackage\nsplit\1\0\1\fversion\vLuaJIT\14on_attach\bcmd\1\0\0\14/main.lua\1\3\0\0\0\a-E\nsetup\16sumneko_lua\25/lua-language-server\n/bin/\29/dev/lua-language-server\nLinux\tunix\nmacOS\bmac\bhas\15properties\1\0\0\1\4\0\0\18documentation\vdetail\24additionalTextEdits\19resolveSupport\19snippetSupport\19completionItem\15completion\17textDocument\29make_client_capabilities\rprotocol\blsp\tHOME\vgetenv\aos\tUSER\n$USER\vexpand\afn\bvim\22lsp.custom_attach\14lspconfig\frequire\2\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file Bwipeout lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bwipeout", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command! -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs', 'nvim-compe', 'vim-surround'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
