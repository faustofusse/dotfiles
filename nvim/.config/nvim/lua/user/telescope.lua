local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local sorters = require("telescope.sorters")

telescope.setup({
    defaults = {
        file_sorter = sorters.get_fzy_sorter,
        color_devicons = true,
        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous
            }
        }
    },
    pickers = {
        find_files = {
            theme = "ivy",
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
    },
})

telescope.load_extension("fzy_native")
