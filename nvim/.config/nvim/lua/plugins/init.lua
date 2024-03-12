return {
    { 'lukas-reineke/indent-blankline.nvim', main = "ibl", opts = {}, ft = { 'dart' } },
    { 'sbdchd/neoformat', cmd = 'Neoformat' },
    { 'kyazdani42/nvim-web-devicons', lazy = true },
    { 'folke/trouble.nvim', cmd = "Trouble", opts = { } },
    { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
    { 'ThePrimeagen/harpoon', lazy = true },
    { 'numToStr/Comment.nvim', opts = {}, keys = { { 'gc', mode = { 'n', 'v' } } } },
    { 'windwp/nvim-autopairs', opts = {}, keys = { { '{', mode = 'i' }, { '[', mode = 'i' }, { '<', mode = 'i' }, { '(', mode = 'i' }, { '\'', mode = 'i' }, { '"', mode = 'i' } } },
    { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
}
