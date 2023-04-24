local my_theme = {
    bg = '#ffffff00',
    fg = '#867B6F', -- #767676 #544E4A
    yellow = '#e0af68',
    cyan = '#56b6c2',
    darkblue = '#081633',
    green = '#98c379',
    orange = '#d19a66',
    violet = '#a9a1e1',
    magenta = '#c678dd',
    blue = '#61afef',
    red = '#e86671'
}

local vi_mode_colors = {
    NORMAL = 'fg',
    INSERT = 'green',
    VISUAL = 'orange',
    LINES = 'orange',
    OP = 'green',
    BLOCK = 'orange',
    REPLACE = 'violet',
    ['V-REPLACE'] = 'violet',
    ENTER = 'cyan',
    MORE = 'cyan',
    SELECT = 'orange',
    COMMAND = 'cyan',
    SHELL = 'green',
    TERM = 'green',
    NONE = 'yellow'
}

local file = {
    info = {
        provider = {
            name = 'file_info',
            colored_icon = false,
            opts = {
                type = 'unique',
                file_readonly_icon = '',
                file_modified_icon = '',
                -- file_modified_icon = '[+]',
            }
        },
        left_sep = {
            str = ':: ',
            hl = { fg = 'fg' }
        }
    },
    type = {
        provider = {
            name = 'file_type',
            opts = {
                filetype_icon = true,
                colored_icon = false,
                case = 'lowercase'
            }
        }
    }
}

local components = {
  active = {},
  inactive = {},
}

return {
    'feline-nvim/feline.nvim',
    config = function ()

        local feline = require('feline')
        local vi_mode_utils = require('feline.providers.vi_mode')

        local mode = {
            provider = function ()
                return string.lower(vi_mode_utils.get_vim_mode())
            end,
            hl = function ()
                return {
                    name = vi_mode_utils.get_mode_highlight_name(),
                    fg = vi_mode_utils.get_mode_color(),
                    style = 'bold'
                }
            end,
            left_sep = ' ',
            right_sep = ' '
        }

        table.insert(components.active, { mode, file.info })
        table.insert(components.active, {})
        table.insert(components.active, { file.type })
        table.insert(components.inactive, {})
        table.insert(components.inactive, {})

        feline.setup {
            theme = my_theme,
            components = components,
            vi_mode_colors = vi_mode_colors,
            force_inactive = {
                filetypes = {
                    'packer',
                    'NvimTree',
                    'fugitive',
                    'fugitiveblame'
                },
                buftypes = {'terminal'},
                bufnames = {}
            }
        }
    end
}
