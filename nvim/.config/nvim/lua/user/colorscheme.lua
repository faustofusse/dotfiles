local colorscheme = 'gruvbox-material'

local customs = {}

customs['gruvbox-material'] = function()
    vim.cmd[[hi link TSProperty Blue]]
    return {
        Normal = { bg = "none" },
        EndOfBuffer = { bg = "none" },
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

local function polyfill_custom_highlights()
    local values = customs[vim.g.colors_name]
    if values ~= nil then
        for key, value in pairs(values()) do
            vim.highlight.create(key, { guifg = value.fg, guibg = value.bg }, false)
        end
    end
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end

polyfill_custom_highlights()
