return {
    { 'lukas-reineke/indent-blankline.nvim', main = "ibl", opts = {}, ft = { 'dart' } },
    { 'numToStr/Comment.nvim', opts = {}, keys = { { 'gc', mode = { 'n', 'v' } } } },
    { 'windwp/nvim-autopairs', opts = {}, keys = { { '{', mode = 'i' }, { '[', mode = 'i' }, { '<', mode = 'i' }, { '(', mode = 'i' }, { '\'', mode = 'i' }, { '"', mode = 'i' } } },
    { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
}
