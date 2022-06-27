local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

lualine.setup { 
    options = {
        theme = 'gruvbox-material',
        -- section_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = '' },
        section_separators = '',
        -- component_separators = { left = '', right = ''},
        component_separators = '|',
        disabled_filetypes = { 'NvimTree' },
        always_divide_middle = false
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'filename'},
        lualine_c = {'diagnostics'},
        lualine_x = {'filetype'},
        lualine_y = {'diff', 'branch'},
        lualine_z = {'progress'}
    },
    extensions = { 'quickfix' }
}
