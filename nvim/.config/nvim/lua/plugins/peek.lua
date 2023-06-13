return {
    'toppair/peek.nvim',
    cmd = { 'PeekOpen' },
    build = 'deno task --quiet build:fast',
    config = function ()
        vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
        vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
        require('peek').setup({
            auto_load = true,           -- whether to automatically load preview when entering another markdown buffer
            theme = 'light',            -- 'dark' or 'light'
            app = 'webview',          -- 'webview', 'browser', string or a table of strings
            update_on_change = true,
        })
    end
}
