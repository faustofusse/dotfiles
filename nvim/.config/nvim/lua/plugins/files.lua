return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function ()
        require("oil").setup {
            keymaps = {
                ["<C-p>"] = false,
            },
            view_options = {
                show_hidden = true,
            },
            win_options = {
                signcolumn = "yes",
            },
            skip_confirm_for_simple_edits = true,
        }
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end
}
