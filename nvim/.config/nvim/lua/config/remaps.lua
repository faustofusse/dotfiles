local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local remap = vim.api.nvim_set_keymap

-- QuickFix
remap("n", "]q", ":cn<cr>", opts)
remap("n", "[q", ":cp<cr>", opts)

-- Git
remap("n", "]c", ":Gitsigns next_hunk<cr>", opts)
remap("n", "[c", ":Gitsigns prev_hunk<cr>", opts)
vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('UserFugitiveConfig', {}),
    pattern = "*",
    callback = function(ev)
        if vim.bo.ft ~= "fugitive" then
            return
        end
        local o = { buffer = ev.buf, remap = false }
        vim.keymap.set("n", "<leader>p", ":Git pull<cr>", o)
        vim.keymap.set("n", "<leader>P", ":Git push<cr>", o)
    end
})

-- Clipboard
remap("v", "<leader>y", "\"+y", opts)
remap("v", "<leader>Y", "\"*y", opts)
