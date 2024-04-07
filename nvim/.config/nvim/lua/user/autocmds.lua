vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DartIndentingEnter", { clear = true }),
    pattern = "*.dart",
    callback = function ()
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("BufLeave", {
    group = vim.api.nvim_create_augroup("DartIndentingLeave", { clear = true }),
    pattern = "*.dart",
    callback = function ()
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 4
        vim.opt.tabstop = 4
        vim.opt.softtabstop = 4
    end,
})
