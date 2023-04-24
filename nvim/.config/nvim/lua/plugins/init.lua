return {
    'jiangmiao/auto-pairs',
    'alvan/vim-closetag',
    'tpope/vim-surround',
    'sbdchd/neoformat',
    'kyazdani42/nvim-web-devicons',
    'feline-nvim/feline.nvim',
    'ThePrimeagen/harpoon',
    'sainnhe/gruvbox-material',
    { 'catppuccin/nvim', name = 'catppuccin' },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
}
