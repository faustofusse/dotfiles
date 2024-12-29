return {
    'saghen/blink.cmp',

    dependencies = { "echasnovski/mini.icons" }, --  'rafamadriz/friendly-snippets'

    version = '*',

    opts = {
        keymap = { preset = 'default' },

        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = 'mono'
        },

        sources = {
            default = { 'lsp', 'path', 'snippets' },
        },

        completion = {
            menu = {
                auto_show = function(ctx)
                    return ctx.mode ~= 'cmdline' and vim.bo.buftype ~= "prompt"
                end,
            }
        },

        signature = { enabled = true },
    },

    opts_extend = { "sources.default" }
}
