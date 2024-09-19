local colorscheme = 'catppuccin'

local customs = {}

local function custom_highlights()
    vim.cmd[[highlight Normal ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight NormalNC ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight NormalFloat ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight EndOfBuffer ctermbg=NONE guibg=NONE]]

    local values = customs[vim.g.colors_name]
    if values ~= nil then
        for key, value in pairs(values()) do
            vim.api.nvim_set_hl(0, key, value)
        end
    end
end

function SetColorscheme(color)
    color = color or colorscheme
    vim.cmd.colorscheme(color)
    custom_highlights()
end

SetColorscheme()
