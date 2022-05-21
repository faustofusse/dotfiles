local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
            let b:signcolumn_on=1
        else
            set signcolumn=no
            let b:signcolumn_on=0
        endif
    endfunction
']])
keymap("n", "<leader>s", ":call ToggleSignColumn()<cr>", opts)
