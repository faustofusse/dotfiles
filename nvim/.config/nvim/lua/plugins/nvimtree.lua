local icons = require('user.icons')
return {
    'kyazdani42/nvim-tree.lua',
    cmd = { 'NvimTreeOpen', 'NvimTreeToggle' },
    opts = {
        filters = {
            dotfiles = false,
            -- custom = { ".git",  ".cache" },
            custom = {},
            exclude = {}
        },
        view = {
            signcolumn = "no",
        },
        renderer = {
            special_files = {},
            add_trailing = true,
            group_empty = true,
            highlight_git = false,
            indent_markers = {
                enable = true,
                inline_arrows = true,
                icons = {
                    corner = "└",
                    edge = "│",
                    item = "│",
                    none = " ",
                },
            },
            icons = {
                webdev_colors = true,
                git_placement = "before",
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                },
                glyphs = {
                    default = "",
                    symlink = "",
                    git = icons.git,
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
}