local icons = require("user.icons")
return {
    {
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
    },
    {
        "kyazdani42/nvim-tree.lua",
        cmd = { "NvimTreeOpen", "NvimTreeToggle" },
        config = function ()
            require('nvim-tree').setup {
                hijack_netrw = false,
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
            vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", { desc = "Open file explorer" })
        end
    },
}
