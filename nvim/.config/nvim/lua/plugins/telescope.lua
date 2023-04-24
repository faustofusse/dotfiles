return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-fzy-native.nvim'
    },
    config = function ()
        local telescope = require('telescope')
        local actions = require("telescope.actions")
        local sorters = require("telescope.sorters")

        telescope.setup({
            defaults = {
                file_sorter = sorters.get_fzy_sorter,
                file_ignore_patterns = {
                    "node_modules",
                },
                color_devicons = true,
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_to_qflist
                    }
                }
            },
            pickers = {
                find_files = { theme = "ivy" },
            },
            extensions = {
                fzy_native = {
                    override_generic_sorter = false,
                    override_file_sorter = true,
                },
            },
        })
        telescope.load_extension("fzy_native")
    end
}
