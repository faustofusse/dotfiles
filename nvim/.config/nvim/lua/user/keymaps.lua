local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 2000

-- go to .h
keymap("n", "<leader><C-^>", ":e %:p:h:h/include/%:t:r.h<cr>", opts)

-- QuickFix
keymap("n", "]q", ":cn<cr>", opts)
keymap("n", "[q", ":cp<cr>", opts)

-- Clipboard
keymap("v", "<leader>y", "\"*y", opts)
keymap("v", "<leader>Y", "\"+y", opts)

-- Telescope
keymap("n", "<C-p>", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
keymap("n", "<leader>ff", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
keymap("n", "<leader>fg", ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({}))<cr>", opts)
keymap("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>", opts)
keymap("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>", opts)

-- Harpoon
keymap("n", "<leader>a", ":lua require('harpoon.mark').add_file()<cr>", opts)
keymap("n", "<leader>h", ":lua require('harpoon.ui').toggle_quick_menu()<cr>", opts)
keymap("n", "<leader>j", ":lua require('harpoon.ui').nav_file(1)<cr>", opts)
keymap("n", "<leader>k", ":lua require('harpoon.ui').nav_file(2)<cr>", opts)
keymap("n", "<leader>l", ":lua require('harpoon.ui').nav_file(3)<cr>", opts)
keymap("n", "<leader>;", ":lua require('harpoon.ui').nav_file(4)<cr>", opts)

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)

-- Hop
-- keymap("n", "<leader>a", ":HopChar1<cr>", opts)
-- keymap("n", "<leader>w", ":HopWord<cr>", opts)

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

