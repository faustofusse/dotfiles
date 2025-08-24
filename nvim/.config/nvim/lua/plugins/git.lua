return {
    { "tpope/vim-fugitive", cmd = "Git" },
    {
        "lewis6991/gitsigns.nvim",

        opts = {
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
                untracked    = { text = "┆" },
            },
            on_attach = function(buffer)
                local gitsigns = require("gitsigns")
                local opts = { noremap = true, silent = true, buffer = buffer }
                vim.keymap.set("n", "]c", gitsigns.next_hunk, opts)
                vim.keymap.set("n", "[c", gitsigns.prev_hunk, opts)
            end
        }
    },
}
