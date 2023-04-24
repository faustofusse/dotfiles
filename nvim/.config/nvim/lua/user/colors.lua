local colorscheme = 'gruvbox-material'
-- gruvbox-material, catppuccin, tokyonight, nightfox, ...

local customs = {}

customs['gruvbox-material'] = function()
    vim.cmd[[highlight Normal ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight NormalNC ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight NormalFloat ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight EndOfBuffer ctermbg=NONE guibg=NONE]]
    vim.cmd[[highlight! link TSProperty Blue]]
    return {
        CopilotSuggestion = { fg = "#928374", bg = "#3c3836" },
        TelescopeSelection = { fg = "#928374" },
        TelescopeMatching = { fg = "#d4be98" },
        TelescopePromptPrefix = { fg = "#d4be98" },
        NvimTreeFolderIcon = { fg = "#708085" },
        NvimTreeFolderName = { fg = "#BEAD8F" },
        NvimTreeOpenedFolderName = { fg = "#BEAD8F" },
        NvimTreeIndentMarker = { fg = "#4F4945" }
    }
end

         -- EndOfBuffer = { bg = "none", fg = "#5a524c" },
local function custom_highlights()
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
