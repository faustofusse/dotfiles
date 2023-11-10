local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local remap = vim.api.nvim_set_keymap

-- Remap space as leader key
remap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 2000

-- tmux flutter
-- remap("n", "<leader>fr", "!tmux list-windows | grep dart | awk -F: '{printf(\"tmux send-keys -t %d \"r\"\n\", $1)}' | xargs -I {} sh -c {}", opts)
-- remap("n", "<leader>fR", "!tmux list-windows | grep dart | awk -F: '{printf(\"tmux send-keys -t %d \"R\"\n\", $1)}' | xargs -I {} sh -c {}", opts)

-- QuickFix
remap("n", "]q", ":cn<cr>", opts)
remap("n", "[q", ":cp<cr>", opts)

-- Clipboard
remap("v", "<leader>y", "\"*y", opts)
remap("v", "<leader>Y", "\"+y", opts)

-- Telescope
remap("n", "<C-p>", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
remap("n", "<leader>ff", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
remap("n", "<leader>fd", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ cwd = '~/.dotfiles', hidden = true }))<cr>", opts)
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

-- File explorers (NvimTree, Netrw)
remap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
remap("n", "<leader>pv", ":Ex<cr>", opts)

-- Rest
remap("n", "<leader>rrn", ":lua require('rest-nvim').run(false)<cr>", opts)
remap("n", "<leader>rrl", ":lua require('rest-nvim').last<cr>", opts)
remap("n", "<leader>rrp", ":lua require('rest-nvim').run(true)<cr>", opts)

-- Toggle Status
vim.cmd([['
    function! ToggleStatusBar()
        if !exists("b:statusbar_on") || !b:statusbar_on
            set laststatus=3
            let b:statusbar_on=1
        else
            set laststatus=0
            let b:statusbar_on=0
        endif
    endfunction
']])
remap("n", "<C-s>", ":call ToggleStatusBar()<cr>", opts)
