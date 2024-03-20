return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "folke/neodev.nvim", opts = {} },
        { "folke/trouble.nvim", opts = { }, cmd = "Trouble" },
        { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
    },
    config = function ()
        local icons = require("user.icons")
        local signs = {
            { name = "DiagnosticSignError", text = icons.diagnostics.Error },
            { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
            { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
            { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
        }
        for _, sign in ipairs(signs) do
            vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
        end

        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- dartls is not in mason
        lspconfig.dartls.setup { capabilities = capabilities }

        require("mason").setup()
        require("mason-lspconfig").setup {
            ensure_installed = { 'html', 'pyright', 'tsserver', 'gopls', 'rust_analyzer', 'lua_ls', 'templ' },
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
                        filetypes = { "html", "templ" },
                        capabilities = capabilities
                    }
                end,
                ["tailwindcss"] = function ()
                    lspconfig.tailwindcss.setup {
                        filetypes = { "html", "templ", "astro", "javascript", "typescript", "react" },
                        init_options = { userLanguages = { templ = "html" } },
                        capabilities = capabilities
                    }
                end,
            }
        }
    end
}
