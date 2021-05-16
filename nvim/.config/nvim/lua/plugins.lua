local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

return require('packer').startup(
  function(use)
    use 'wbthomason/packer.nvim'

    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'

    use 'hrsh7th/nvim-compe'
    use 'neovim/nvim-lspconfig'

    use 'karb94/neoscroll.nvim'
    require('neoscroll').setup()

    use 'tpope/vim-eunuch'
    use 'tpope/vim-surround'
    use 'tpope/vim-fugitive'

    use 'cocopon/iceberg.vim'
    use 'shaunsingh/moonlight.nvim'

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    use {
	    'nvim-telescope/telescope.nvim',
	    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }

    use 'b3nj5m1n/kommentary'

  end)
