vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.timeoutlen = 2000

local opts = { noremap = true, silent = true }

vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.keymap.set("n", "]q", ":cn<cr>", opts)
vim.keymap.set("n", "[q", ":cp<cr>", opts)
vim.keymap.set("v", "<leader>y", "\"+y", opts)
vim.keymap.set("v", "<leader>Y", "\"*y", opts)

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]

vim.filetype.add({ extension = { templ = "templ" } })

vim.opt.shortmess:append "c"

vim.o.backup = false                          -- creates a backup file
vim.o.conceallevel = 0                        -- so that `` is visible in markdown files
vim.o.fileencoding = "utf-8"                  -- the encoding written to a file
vim.o.hlsearch = false                        -- highlight all matches on previous search pattern
vim.o.ignorecase = true                       -- ignore case in search patterns
vim.o.showmode = false                        -- we don't need to see things like -- INSERT -- anymore
vim.o.smartcase = true                        -- smart case
vim.o.smartindent = true                      -- make indenting smarter again
vim.o.swapfile = false                        -- creates a swapfile
vim.o.termguicolors = true                    -- set term gui colors (most terminals support this)
vim.o.undofile = true                         -- enable persistent undo
vim.o.updatetime = 300                        -- faster completion (4000ms default)
vim.o.writebackup = false                     -- if a file is being edited by another program (or was written to file while editing with another program) it is not allowed to be edited
vim.o.expandtab = true                        -- convert tabs to spaces
vim.o.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.o.tabstop = 4                             -- insert 4 spaces for a tab
vim.o.softtabstop = 4
vim.o.cursorline = true                       -- highlight the current line
vim.o.number = true                           -- set numbered lines
vim.o.relativenumber = true                   -- set relative numbered lines
vim.o.numberwidth = 4                         -- set number column width to 2 {default 4}
vim.o.wrap = false                            -- display lines as one long line
vim.o.scrolloff = 8                           -- explains itself
vim.o.sidescrolloff = 8                       -- explains itself
vim.o.hidden = false
vim.o.signcolumn = "yes"                      -- always show the sign column otherwise it would shift the text each time
vim.o.laststatus = 0 -- 3                     -- remove status bar
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.winborder = "rounded"                   -- borders in all the windows
