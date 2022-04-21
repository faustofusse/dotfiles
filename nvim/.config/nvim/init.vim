source $HOME/.config/nvim/lua/user/plugins.vim
source $HOME/.config/nvim/lua/user/tree.lua
source $HOME/.config/nvim/lua/user/general.vim
source $HOME/.config/nvim/lua/user/telescope.lua
source $HOME/.config/nvim/lua/user/completion.lua
source $HOME/.config/nvim/lua/user/remaps.vim
source $HOME/.config/nvim/themes/gruvbox.vim
source $HOME/.config/nvim/lua/user/lsp.lua

hi EndOfBuffer guifg=bg ctermfg=NONE guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi StatusLine guifg=bg ctermfg=NONE guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi StatusLineNC guifg=bg ctermfg=NONE guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

hi SignifySignAdd guifg=#B9B946 guibg=NONE
hi SigniftSignChange guifg=#99BE83 guibg=bg
hi link SignifySignChangeDelete SignifySignChange
hi SignifySignDelete guifg=#C5503E guibg=NONE
hi link SignifySignDeleteFirstLine SignifySignDelete

lua << EOF

require'hop'.setup {}
require'nvim-treesitter.configs'.setup {
    ensure_installed = 'all',
    highlight = { enable = true, disable = { 'vim', 'lua' } }
}
-- require'lualine'.setup { always_divide_middle = false, options = { disabled_filetypes = { 'NvimTree' } } }

EOF
