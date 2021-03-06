local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install plugins
return packer.startup(function(use)
    -- Packer
    use "wbthomason/packer.nvim"

    -- Copilot use "github/copilot.vim"

    -- General
    use "jiangmiao/auto-pairs"
    use "alvan/vim-closetag"
    use "tpope/vim-surround"
    use "tpope/vim-commentary"
    use "lewis6991/gitsigns.nvim"
    use "phaazon/hop.nvim"

    -- Themes
    use "morhetz/gruvbox"
    use "sainnhe/gruvbox-material"

    -- Icons
    use "kyazdani42/nvim-web-devicons"

    -- Status Bar
    -- use "nvim-lualine/lualine.nvim"
    use 'feline-nvim/feline.nvim'

    -- Telescope / Harpoon
    use "nvim-lua/plenary.nvim"
    use "nvim-telescope/telescope.nvim"
    use "nvim-telescope/telescope-fzy-native.nvim"
    use "ThePrimeagen/harpoon"

    -- File Explorer
    use "kyazdani42/nvim-tree.lua"

    -- Intellisense
    use "neovim/nvim-lspconfig"

    -- Autocompletion
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-vsnip"
    use "hrsh7th/vim-vsnip"

    -- Treesitter
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use "nvim-treesitter/playground"

    -- Database
    use { "kristijanhusak/vim-dadbod-ui", requires = { "tpope/vim-dadbod" } }

    -- REST
    use { "NTBBloodbath/rest.nvim", requires = { "nvim-lua/plenary.nvim" } }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
