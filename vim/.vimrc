" Fausto Fusse - Vim "

" Styles:
syntax on
set bg=dark
set smartindent
set nu
set relativenumber
set nohlsearch
set noerrorbells
set nowrap
set noshowmode
set signcolumn=no

" Advanced:
set nocompatible
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set exrc
set hidden
set ignorecase
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch

" Plugins:
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
" Plug 'pangloss/vim-javascript'
" Plug 'leafgarland/typescript-vim'
" Plug 'vim-airline/vim-airline'
call plug#end()

" Scheme
colorscheme gruvbox
