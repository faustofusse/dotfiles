return {
    {
        'nvim-treesitter/playground',
        cmd = { 'TSPlaygroundToggle' }, -- 'TSHighlightCapturesUnderCursor', 'TSNodeUnderCursor'
        dependencies = { 'nvim-treesitter/nvim-treesitter' }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        -- dependencies = { { 'nvim-treesitter/playground', cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor', 'TSNodeUnderCursor' } } },
        build = ':TSUpdate',
        config = function ()
            local configs = require('nvim-treesitter.configs')
            local languages = {
                'go', 'rust', 'python', 'html', 'http', 'json', 'javascript', 'typescript', 'c', 'css', 'dot',
                'dockerfile', 'gomod', 'markdown', 'sql', 'tsx', 'lua', 'vim', 'yaml', 'bash', 'make', 'dart',
            }
            configs.setup {
                ensure_installed = languages, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
                sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
                auto_install = false,
                -- ignore_install = { "d", "haskell" }, -- List of parsers to ignore installing
                autopairs = { enable = true },
                highlight = {
                    enable = true, -- false will disable the whole extension
                    disable = {}, -- list of language that will be disabled
                    additional_vim_regex_highlighting = false, -- estaba en true
                },
                indent = { enable = true, disable = { "yaml", "dart" } },
                context_commentstring = {
                    enable = true,
                    enable_autocmd = false,
                },
            }
        end
    }
}
