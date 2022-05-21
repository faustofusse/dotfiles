source $HOME/.config/nvim/lua/user/plugins.lua
source $HOME/.config/nvim/lua/user/nvimtree.lua
source $HOME/.config/nvim/lua/user/options.lua
source $HOME/.config/nvim/lua/user/telescope.lua
source $HOME/.config/nvim/lua/user/completion.lua
source $HOME/.config/nvim/lua/user/treesitter.lua
source $HOME/.config/nvim/lua/user/hop.lua
source $HOME/.config/nvim/lua/user/lualine.lua
source $HOME/.config/nvim/lua/user/keymaps.lua
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
