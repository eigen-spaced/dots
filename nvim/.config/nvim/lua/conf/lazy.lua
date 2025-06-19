local utils = require("core.utils")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  import = "plugins",
  install = { colorscheme = { "kanagawa" } },
})
