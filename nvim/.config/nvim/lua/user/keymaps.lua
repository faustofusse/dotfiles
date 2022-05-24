local opts = { noremap = true, silent = false }

local term_opts = { silent = false }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clipboard
keymap("v", "<leader>y", "\"*y", opts)
keymap("v", "<leader>Y", "\"+y", opts)

-- Telescope
keymap("n", "<C-p>", ":lua require('telescope.builtin').find_files()<cr>", opts)
keymap("n", "<leader>ff", ":lua require('telescope.builtin').find_files()<cr>", opts)
keymap("n", "<leader>fg", ":lua require('telescope.builtin').live_grep()<cr>", opts)
keymap("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>", opts)
keymap("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>", opts)

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)

-- Hop
keymap("n", "<leader>j", ":HopChar1<cr>", opts)
keymap("n", "<leader>w", ":HopWord<cr>", opts)

-- SignColumn
vim.cmd([['
    function! ToggleSignColumn()
        if !exists("b:signcolumn_on") || !b:signcolumn_on
            set signcolumn=yes
            set laststatus=2
            let b:signcolumn_on=1
        else
            set signcolumn=no
            set laststatus=0
            let b:signcolumn_on=0
        endif
    endfunction
']])
keymap("n", "<leader>s", ":call ToggleSignColumn()<cr>", opts)
