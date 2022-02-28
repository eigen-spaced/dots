local status_ok, wk = pcall(require, "which-key")

if not status_ok then
  return
end

wk.setup {
  plugins = {
    spelling = {
      enabled = true,
    },
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 10, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
}

wk.register {
  ["g>"] = "show message history",
  ["<leader>"] = {
    n = {
      name = "+new",
      f = "create a new file",
      s = "create new file in a split",
    },
    E = "show token under the cursor",
    O = "insert space above",
    o = "insert space below",
    p = {
      name = "+packer",
      c = {
        name = "+clean/compile",
        c = "clean",
        o = "compile",
      },
      s = "sync",
    },
    g = "grep word under the cursor",
    l = {
      name = "+list",
      i = "toggle location list",
      s = "toggle quickfix",
    },
    e = {
      name = "+edit",
      v = "open vimrc in a vertical split",
      p = "open plugins file in a vertical split",
      z = "open zshrc in a vertical split",
      t = "open tmux config in a vertical split",
    },
    t = {
      name = "+tab",
      c = "tab close",
      n = "tab edit current buffer",
    },
    so = "source current buffer",
    ["="] = "make windows equal size",
  },
  --[[ ['<localleader>'] = {
      name = 'local leader',
      w = {
        name = '+window',
        h = 'change two vertically split windows to horizontal splits',
        v = 'change two horizontally split windows to vertical splits',
        x = 'swap current window with the next',
        j = 'resize: downwards',
        k = 'resize: upwards',
      },
      l = 'redraw window',
      z = 'center view port',
      [','] = 'add comma to end of line',
      [';'] = 'add semicolon to end of line',
      ['?'] = 'search for word under cursor in google',
      ['!'] = 'search for word under cursor in google',
      ['['] = 'abolish = subsitute cursor word in file',
      [']'] = 'abolish = substitute cursor word on line',
      ['/'] = 'find matching word in buffer',
      ['<space>'] = 'Toggle current fold',
      ['<tab>'] = 'open commandline bufferlist',
    }, ]]
}
