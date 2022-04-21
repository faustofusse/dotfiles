vim.g.nvim_tree_git_hl = 0
-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_special_files = {  }
vim.g.nvim_tree_add_trailing = 0

require'nvim-tree'.setup {
    -- auto_close = true,
    update_to_buf_dir = {
        enable = false,
        auto_open = false,
    },
    filters = {
        dotfiles = true,
        custom = { ".git",  ".cache" }
    },
    renderer = {
        indent_markers = {
            enable = true,
            char = "│",
            char_open = "├",
            char_last = "└",
            char_open_last = "└",
        },   
    },
    -- actions = {
    --     open_file = {
    --         quit_on_open = false,
    --     }
    -- }
}
