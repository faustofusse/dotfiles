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
set guicursor=
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
set scrolloff=8

" Plugins:
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
" Plug 'mbbill/undotree'
Plug 'jiangmiao/auto-pairs'
" Plug 'pangloss/vim-javascript'
" Plug 'leafgarland/typescript-vim'
" Plug 'vim-airline/vim-airline'
call plug#end()

" Scheme
colorscheme gruvbox
