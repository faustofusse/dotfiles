vim.o.completeopt = 'menuone,noinsert,noselect'
vim.g.completion_matching_strategy = { 'exact', 'substring',  'fuzzy' }

local status_ok, cmp = pcall(require, 'cmp')
if not status_ok then
    return
end

local kind_icons = require'user.icons'.kind

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
            return vim_item
        end,
    }
})

