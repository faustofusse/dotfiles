local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

nvim_tree.setup {
    update_to_buf_dir = {
        enable = false,
        auto_open = false,
    },
    filters = {
        dotfiles = false,
        -- custom = { ".git",  ".cache" },
        custom = {},
        exclude = {}
    },
    renderer = {
        special_files = {},
        add_trailing = true,
        group_empty = true,
        highlight_git = false,
        indent_markers = {
            enable = false,
            icons = {
                corner = "└ ",
                edge = "│ ",
                none = "  ",
            },
        },
        icons = {
            webdev_colors = true,
            git_placement = "before",
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    deleted = "",
                    untracked = "U",
                    ignored = "◌",
                },
                folder = {
                    -- arrow_open = " ",
                    -- arrow_closed = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                },
            }
        },
    },
    git = {
        enable = true,
        ignore = true,
        timeout = 400,
    },
}
