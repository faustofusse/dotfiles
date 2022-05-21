local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

lualine.setup { 
    always_divide_middle = false,
    options = {
        disabled_filetypes = { 'NvimTree' }
    }
}
