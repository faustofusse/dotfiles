return {
    "neovim/nvim-lspconfig",

    dependencies = {
        { "mason-org/mason.nvim" },
        { "mason-org/mason-lspconfig.nvim" },
        { "saghen/blink.cmp" },
        { "folke/neodev.nvim", opts = {} },
        { "folke/trouble.nvim", opts = { }, cmd = "Trouble" },
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

        local capabilities = require('blink.cmp').get_lsp_capabilities()
        local lspconfig = require("lspconfig")

        lspconfig.dartls.setup { capabilities = capabilities }
        lspconfig["ts_ls"].setup { capabilities = capabilities }

        require("mason").setup()
        require("mason-lspconfig").setup {
            automatic_installation = false,
            ensure_installed = {},
            handlers = {
                function (server_name)
                    lspconfig[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["clangd"] = function ()
                    lspconfig.clangd.setup {
                        cmd = { "clangd", "--header-insertion=never" },
                        capabilities = capabilities
                    }
                end,
                ["html"] = function ()
                    lspconfig.html.setup {
                        filetypes = { "html", "templ", "vue" },
                        capabilities = capabilities
                    }
                end,
                ["htmx"] = function ()
                    lspconfig.html.setup {
                        filetypes = { "html", "templ" },
                        capabilities = capabilities
                    }
                end,
                ["tailwindcss"] = function ()
                    lspconfig.tailwindcss.setup {
                        filetypes = { "html", "templ", "tsx", "react", "svelte", "vue" },
                        init_options = { userLanguages = { templ = "html" } },
                        capabilities = capabilities
                    }
                end,
            }
        }
    end
}
