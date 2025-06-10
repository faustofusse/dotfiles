return {
    'saghen/blink.cmp',

    version = '*',

    opts = {
        keymap = { preset = 'default' },

        sources = { default = { 'lsp', 'path', 'snippets' } },

        signature = { enabled = true },

        completion = {
            menu = {
                -- auto_show = function(ctx) return ctx.mode ~= 'cmdline' and vim.bo.buftype ~= "prompt" end,
                auto_show = false,
                draw = { treesitter = { "lsp" } },
            },

            ghost_text = { enabled = true },

            documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },

        appearance = { nerd_font_variant = 'mono' },
    },

    opts_extend = { "sources.default" }
}
