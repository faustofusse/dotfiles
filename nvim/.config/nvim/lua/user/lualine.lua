local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

local theme_ok, theme = pcall(require, "lualine.themes.gruvbox-material")
if not theme_ok then
    return
end

local text = '#544E4A'

vim.highlight.create('StatusLine', { guifg = 'None', guibg = 'None' }, false)

local modes = {
  n = { name = "normal", color = theme.normal.a.bg },
  i = { name = "insert", color = theme.insert.a.bg },
  v = { name = "visual", color = theme.visual.a.bg },
  [""] = { name = "v-block", color = theme.visual.a.bg },
  V = { name = "v-line", color = theme.visual.a.bg },
  c = { name = "command", color = theme.command.a.bg },
  no = { name = "op-pending", color = theme.normal.a.bg },
  s = { name = "select", color = theme.visual.a.bg },
  S = { name = "select-line", color = theme.visual.a.bg},
  [""] = { name = "select-block", color = theme.visual.a.bg },
  ic = { name = "insert-cmp", color = theme.insert.a.bg },
  R = { name = "replace", color = theme.replace.a.bg },
  Rv = { name = "v-replace", color = theme.replace.a.bg },
  cv = { name = "vim-ex", color = theme.command.a.bg },
  ce = { name = "command", color = theme.command.a.bg },
  r = { name = "prompt", color = theme.replace.a.bg },
  rm = { name = "prompt", color = theme.replace.a.bg },
  ["r?"] = { name = "confirm?", color = theme.insert.a.bg },
  ["!"] = { name = "shell", color = theme.command.a.bg },
  t = { name = "terminal", color = theme.terminal.a.bg },
}

local mode = {
    'mode',
    fmt = string.lower,
    color = function()
        return { fg = modes[vim.fn.mode()].color, bg = '#00000000' }
    end,
    padding = 1,
}

local filename = {
    'filename',
    fmt = function(str)
        return ':: ' .. string.lower(str)
    end,
}

lualine.setup {
    options = {
        theme = theme, -- 'gruvbox-material',
        -- section_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = '' },
        -- component_separators = { left = '', right = ''},
        -- component_separators = '|',
        section_separators = '',
        component_separators = '',
        disabled_filetypes = { 'NvimTree' },
        always_divide_middle = false,
        color = { fg = text, bg = '#00000000' },
        padding = 0,
    },
    sections = {
        lualine_a = { mode },
        lualine_b = { filename },
        lualine_c = {'diagnostics'},
        lualine_x = {},
        lualine_y = {'filetype'},
        lualine_z = {'diff', 'branch'}
    },
    extensions = { 'quickfix' }
}
