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
    j = "move current line down by 1",
    k = "move current line up by 1",
    c = {
      -- name = "+insert-comment",
      b = "block comment",
      c = "line comment",
    },
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
    l = {
      name = "+list",
      i = "toggle location list",
      s = "toggle quickfix",
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

wk.register({

  b = "insert block comment",
  c = "insert line comment",
}, { mode = "v" })
