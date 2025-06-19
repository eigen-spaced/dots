local keymap = vim.keymap
-- Remap space as leader key
keymap.set("n", "<Space>", "<NOP>")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable Q/q for ex-mode
keymap.set("", "Q", "", { noremap = true, silent = true })
keymap.set("", "q:", "", { noremap = true, silent = true })
-- U.map('n', 'x', '"_x') --delete char without yank
-- U.map('x', 'x', '"_x') -- delete visual selection without yank

-- Toggle highlighting
keymap.set("n", "<leader>hs", "<cmd>set hlsearch!<CR>")

keymap.set("i", "jk", "<Esc>")
keymap.set("i", "kj", "<Esc>")

-- I added this much later in my VIM journey. How did I not think of this?
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")

-- Fallback split navigation incase smart-splits fails
-- Better split navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")
-- Better resizing
keymap.set("n", "<M-Left>", "5<C-W><")
keymap.set("n", "<M-Right>", "5<C-W>>")
keymap.set("n", "<M-Down>", "5<C-W>-")
keymap.set("n", "<M-Up>", "5<C-W>+")

keymap.set("n", "<Space>=", "<C-W>=")

keymap.set("n", "<Leader>o", "o<Esc>k")
keymap.set("n", "<Leader>O", "O<Esc>j")

-- Better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Buffer management
keymap.set("n", "<Tab>", "<cmd>bnext<CR>")
keymap.set("n", "<S-Tab>", "<cmd>bprev<CR>")

-- replace the entire buffer with contents from clipboard and go to the end of the file
keymap.set("n", "<Leader>ra", "<cmd>%!pbpaste<CR>G")

-- Exit terminal using easier keybindings
keymap.set("t", "jk", "<C-\\><C-n>")

-- Line bubbling
keymap.set("x", "J", ":m '>+1<CR>gv-gv")
keymap.set("x", "K", ":m '<-2<CR>gv-gv")
keymap.set("i", "<C-j>", "<cmd>move .+1<CR><esc>==a")
keymap.set("i", "<C-k>", "<cmd>move .-2<CR><esc>==a")
keymap.set("n", "<leader>j", "<cmd>move .+1<CR>==")
keymap.set("n", "<leader>k", "<cmd>move .-2<CR>==")

-- Close readonly buffers with q
keymap.set(
  "n",
  "gq",
  "&readonly ? ':close!<CR>' : 'q'",
  { expr = true, noremap = true }
)

-- Remap for dealing with word wraps
keymap.set(
  "n",
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, noremap = true, silent = true }
)
keymap.set(
  "n",
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, noremap = true, silent = true }
)

keymap.set("i", ",", ",<C-g>u")
keymap.set("i", ".", ".<C-g>u")
keymap.set("i", "!", "!<C-g>u")
keymap.set("i", "(", "(<C-g>u")

keymap.set("n", "<leader>so", require("core.utils").source_filetype)

--open a new file in the same directory
keymap.set(
  "n",
  "<leader>nf",
  [[:e <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false }
)
--open a new file in a horizontal split
keymap.set(
  "n",
  "<leader>ns",
  [[:sp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false }
)
--open a new file in a vertical split
keymap.set(
  "n",
  "<leader>nv",
  [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false }
)

-- keymap.set("n", "<leader>e", [[ <cmd>Lex! %:p:h | vertical resize 40<CR> ]], { silent = true })
keymap.set("n", "ex", [[ <cmd>Lex!<CR> ]], { silent = true })
