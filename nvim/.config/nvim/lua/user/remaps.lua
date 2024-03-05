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

-- Gitsigns
remap("n", "]g", ":Gitsigns next_hunk<cr>", opts)
remap("n", "[g", ":Gitsigns prev_hunk<cr>", opts)

-- Clipboard
remap("v", "<leader>y", "\"*y", opts)
remap("v", "<leader>Y", "\"+y", opts)

-- Telescope
remap("n", "<C-p>", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({}))<cr>", opts)
remap("n", "<leader>ff", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ hidden = true }))<cr>", opts)
remap("n", "<leader>fd", ":lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ cwd = '~/.dotfiles', hidden = true }))<cr>", opts)
remap("n", "<leader>fg", ":lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({}))<cr>", opts)
remap("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<cr>", opts)
remap("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<cr>", opts)
remap("n", "<leader>fs", ":lua require('telescope.builtin').lsp_dynamic_workspace_symbols(require('telescope.themes').get_dropdown({}))<cr>", opts)

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

-- LSP
remap('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
remap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
remap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
remap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  end,
})

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
