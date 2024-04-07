return {
    'stevearc/conform.nvim',
    config = function ()
        vim.api.nvim_create_user_command('Format', function (args)
            require('conform').format({ bufnr = args.bufnr })
        end, {})
        require('conform').setup {
            formatters_by_ft = {
                dart = { 'dart_format' }
            }
        }
    end
}
