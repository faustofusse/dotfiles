let mapleader = " "

" Paste
vnoremap <leader>p "_dP

" Telescope
nnoremap <C-p> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" NvimTree
nnoremap <leader>e <cmd>NvimTreeToggle<cr>
" nnoremap <C-e> <cmd>NvimTreeToggle<cr>

" Hop
nnoremap <leader>j <cmd>HopChar1<cr>
nnoremap <leader>w <cmd>HopWord<cr>

" Terminal
nnoremap <leader>t <cmd>terminal<cr>

" Sign column
nnoremap <leader>s <cmd>call ToggleSignColumn()<cr>
function! ToggleSignColumn()
    if !exists("b:signcolumn_on") || !b:signcolumn_on
        set signcolumn=yes
        let b:signcolumn_on=1
    else
        set signcolumn=no
        let b:signcolumn_on=0
    endif
endfunction
