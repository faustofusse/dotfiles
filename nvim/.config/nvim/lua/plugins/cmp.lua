vim.o.completeopt = 'menuone,noinsert,noselect'
vim.g.completion_matching_strategy = { 'exact', 'substring',  'fuzzy' }

local kind_icons = require'user.icons'.kind

return {
    'hrsh7th/nvim-cmp',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-vsnip',
        'hrsh7th/vim-vsnip'
    },
    config = function ()
        local cmp = require('cmp')
        cmp.setup({
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = {
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'vsnip' },
                -- { name = 'buffer' },
            },
            window = {
                documentation = {
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
                },
            },
            formatting = {
                -- fields = { 'kind', 'abbr', 'menu' },
                -- fields = {'abbr', 'kind', 'menu'},
                fields = {'kind', 'abbr'},
                format = function(entry, vim_item)
                    vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                    -- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]", nvim_lua = "[Nvim]", luasnip = "[Snippet]", buffer = "[Buffer]", path = "[Path]", emoji = "[Emoji]",
                    })[entry.source.name]
                    -- vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                    return vim_item
                end,
            },
            confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            }
        })
    end
}
