vim.g.nvim_tree_git_hl = 0
vim.g.nvim_tree_special_files = {  }
vim.g.nvim_tree_add_trailing = 0

vim.g.nvim_tree_icons = {
  default = "",
  symlink = "",
  git = {
    unstaged = "",
    staged = "S",
    unmerged = "",
    renamed = "➜",
    deleted = "",
    untracked = "U",
    ignored = "◌",
  },
  folder = {
    -- arrow_open = " ",
    -- arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
  },
}

require'nvim-tree'.setup {
    update_to_buf_dir = {
        enable = false,
        auto_open = false,
    },
    filters = {
        dotfiles = false,
        -- custom = { ".git",  ".cache" },
        custom = {},
        exclude = {}
    },
    renderer = {
        indent_markers = {
            enable = true,
            char = "│",
            char_open = "├",
            char_last = "└",
            char_open_last = "└",
        },   
    },
    git = {
        enable = true,
        ignore = true,
        timeout = 400,
    },
}
