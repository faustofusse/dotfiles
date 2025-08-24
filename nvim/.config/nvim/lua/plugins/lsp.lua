return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "folke/neodev.nvim", opts = {} },
        { "folke/trouble.nvim", opts = { }, cmd = "Trouble" },
        { "j-hui/fidget.nvim", opts = { notification = { override_vim_notify = 1, window = { winblend = 0 } } } },
        -- { "folke/noice.nvim", opts = { cmdline = { view = "cmdline" } }, dependencies = { "MunifTanjim/nui.nvim" } },
        { "mason-org/mason.nvim" },
        { "mason-org/mason-lspconfig.nvim" },
        { "saghen/blink.cmp" },
    },
    config = function ()
        local icons = require("user.icons")
        vim.diagnostic.config {
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = icons.diagnostic.Error,
                    [vim.diagnostic.severity.WARN] = icons.diagnostic.Warn,
                    [vim.diagnostic.severity.HINT] = icons.diagnostic.Hint,
                    [vim.diagnostic.severity.INFO] = icons.diagnostic.Info,
                }
            }
        }

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
                -- ["ts_ls"] = function ()
                --     lspconfig["ts_ls"].setup {
                --         cmd = { "typescript-language-server", "--stdio" },
                --         filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
                --         capabilities = capabilities,
                --         init_options = {
                --             -- plugins = {
                --             --     {
                --             --         name = "@vue/typescript-plugin",
                --             --         location = vim.fn.stdpath "data" .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                --             --         languages = { "vue" },
                --             --     },
                --             -- },
                --         },
                --     }
                -- end
            }
        }
    end
}
