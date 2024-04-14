return {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
        { 'tpope/vim-dadbod', lazy = true },
        { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
        'DBUI',
        'DBUIToggle',
        'DBUIAddConnection',
        'DBUIFindBuffer',
    },
    init = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_winwidth = 30
        vim.g.db_ui_show_help = 0
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_execute_on_save = 0
        vim.g.db_ui_bind_param_pattern = 'sqlc.arg(\\w\\+)'
        vim.g.db_ui_show_database_icon = 1
        vim.g.db_ui_use_nvim_notify = 1
        vim.g.db_ui_debug = 1
        vim.g.db_ui_force_echo_notifications = 1
    end,
}
