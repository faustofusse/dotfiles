return {
    "nvim-telescope/telescope.nvim",

    event = 'VimEnter',

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzy-native.nvim",
        "nvim-telescope/telescope-ui-select.nvim"
    },

    config = function ()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local sorters = require("telescope.sorters")
        local builtin = require("telescope.builtin")
        local themes = require("telescope.themes")

        telescope.setup({
            defaults = {
                file_sorter = sorters.get_fzy_sorter,
                file_ignore_patterns = {
                    "node_modules",
                    "%_templ.go",
                    "%.g.dart",
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
                ["ui-select"] = {
                    themes.get_dropdown({})
                }
            },
        })

        telescope.load_extension("fzy_native")
        telescope.load_extension("ui-select")

        local opts = { noremap = true, silent = true }
        local dropdown = themes.get_dropdown({})
        vim.keymap.set("n", "<C-p>",      function() builtin.find_files(themes.get_ivy({})) end, opts)
        vim.keymap.set("n", "<leader>ff", function() builtin.find_files(themes.get_ivy({ hidden = true })) end, opts)
        vim.keymap.set("n", "<leader>fd", function() builtin.find_files(themes.get_ivy({ cwd = '~/.dotfiles', hidden = true })) end, opts)
        vim.keymap.set("n", "<leader>fg", function() builtin.live_grep(dropdown) end, opts)
        vim.keymap.set("n", "<leader>fb", function() builtin.buffers(dropdown) end, opts)
        vim.keymap.set("n", "<leader>fh", function() builtin.help_tags(dropdown) end, opts)
        vim.keymap.set("n", "<leader>fs", function() builtin.lsp_dynamic_workspace_symbols(dropdown) end, opts)
        vim.keymap.set("n", "<leader>fr", function() builtin.lsp_references(dropdown) end, opts)
    end
}
