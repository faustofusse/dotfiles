return {
    "neovim/nvim-lspconfig",

    dependencies = {
        { "saghen/blink.cmp" },
        { "j-hui/fidget.nvim", opts = { notification = { override_vim_notify = 1, window = { winblend = 0 } } } },
    },

    config = function ()
        local icons = require("config.icons")
        vim.diagnostic.config {
            -- float = { border = 'rounded', source = 'if_many' },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = icons.diagnostic.Error,
                    [vim.diagnostic.severity.WARN] = icons.diagnostic.Warn,
                    [vim.diagnostic.severity.HINT] = icons.diagnostic.Hint,
                    [vim.diagnostic.severity.INFO] = icons.diagnostic.Info,
                }
            }
        }

        local opts = { noremap = true, silent = true }
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            end,
        })

        local filetypes = vim.lsp.config["ts_ls"].filetypes
        table.insert(filetypes, "vue")
        vim.lsp.config("ts_ls", {
            filetypes = filetypes,
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server",
                        languages = { "vue" },
                        configNamespace = "typescript",
                    }
                },
            },
        })

        vim.lsp.enable({ "ts_ls" })
    end
}
