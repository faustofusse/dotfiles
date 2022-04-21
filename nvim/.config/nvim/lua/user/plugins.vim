call plug#begin('~/.config/nvim/autoload/plugged')

" Copilot
Plug 'github/copilot.vim'

" General
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-signify' " otro: lewis6991/gitsigns.nvim
Plug 'phaazon/hop.nvim'

" Themes
Plug 'morhetz/gruvbox'

" Icons
Plug 'kyazdani42/nvim-web-devicons'

" Status Bar
Plug 'nvim-lualine/lualine.nvim'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" File Explorer
Plug 'kyazdani42/nvim-tree.lua'

" Intellisense
Plug 'neovim/nvim-lspconfig'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do':':TSUpdate'}
Plug 'nvim-treesitter/playground'

call plug#end()
