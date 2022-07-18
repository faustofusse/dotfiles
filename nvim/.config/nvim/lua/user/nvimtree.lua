local status_ok, nvim_tree = pcall(require, "nvim-tree")
local icons_ok, icons = pcall(require, "user.icons")
if not (status_ok and icons_ok) then
    return
end

nvim_tree.setup {
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
            enable = true,
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

local ntview_ok, nvim_tree_view = pcall(require, "nvim-tree.view")
if ntview_ok then
    nvim_tree_view.View.winopts.signcolumn = 'no'
end

