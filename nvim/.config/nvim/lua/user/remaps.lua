local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local remap = vim.api.nvim_set_keymap

-- Remap space as leader key
remap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 2000

-- QuickFix
remap("n", "]q", ":cn<cr>", opts)
remap("n", "[q", ":cp<cr>", opts)

-- Clipboard
remap("v", "<leader>y", "\"*y", opts)
remap("v", "<leader>Y", "\"+y", opts)

-- Telescope
remap("n", "<C-p>", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
remap("n", "<leader>ff", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
remap("n", "<leader>fg", ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({}))<cr>", opts)
remap("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>", opts)
remap("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>", opts)

-- Harpoon
remap("n", "<leader>a", ":lua require('harpoon.mark').add_file()<cr>", opts)
remap("n", "<leader>h", ":lua require('harpoon.ui').toggle_quick_menu()<cr>", opts)
remap("n", "<leader>j", ":lua require('harpoon.ui').nav_file(1)<cr>", opts)
remap("n", "<leader>k", ":lua require('harpoon.ui').nav_file(2)<cr>", opts)
remap("n", "<leader>l", ":lua require('harpoon.ui').nav_file(3)<cr>", opts)
remap("n", "<leader>;", ":lua require('harpoon.ui').nav_file(4)<cr>", opts)

-- NvimTree
remap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
