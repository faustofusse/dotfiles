return {
    'rest-nvim/rest.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'http',
    opts = {
        -- Open request results in a horizontal split
        result_split_horizontal = false,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = true,
        result = {
            show_url = true,
            show_http_info = true,
            show_headers = true,
            formatters = { json = "jq" },
        },
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
    }
}