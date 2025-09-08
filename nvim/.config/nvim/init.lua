vim.o.backup = false
vim.o.conceallevel = 0
vim.o.fileencoding = "utf-8"
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.showmode = false
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.swapfile = false
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.writebackup = false
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.wrap = false
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.hidden = false
vim.o.signcolumn = "yes"
vim.o.laststatus = 0
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.winborder = "rounded"

-- vim.o.foldenable = false
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.o.foldnestmax = 2
vim.o.foldlevel = 100

vim.o.timeoutlen = 2000
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { noremap = true, silent = true }

vim.keymap.set("v", "<leader>y", "\"+y", opts)
vim.keymap.set("v", "<leader>Y", "\"*y", opts)

vim.filetype.add({ extension = { templ = "templ" } })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

--

vim.pack.add({ "https://github.com/catppuccin/nvim" }, { confirm = false })

require("catppuccin").setup {
    flavour = "mocha",
    transparent_background = true,
    float = { transparent = true },
}

vim.cmd.colorscheme("catppuccin")

--

vim.pack.add({ "https://github.com/NMAC427/guess-indent.nvim" }, { confirm = false })

require("guess-indent").setup()

--

vim.pack.add({ "https://github.com/windwp/nvim-autopairs" }, { confirm = false })

require("nvim-autopairs").setup()

--

vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" }, { confirm = false })

--

vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" }, { confirm = false })
vim.pack.add({ "https://github.com/nvim-telescope/telescope.nvim" }, { confirm = false })
vim.pack.add({ "https://github.com/nvim-telescope/telescope-fzy-native.nvim" }, { confirm = false })
vim.pack.add({ "https://github.com/nvim-telescope/telescope-ui-select.nvim" }, { confirm = false })

local telescope = require("telescope")
local actions = require("telescope.actions")
local sorters = require("telescope.sorters")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

telescope.setup({
    defaults = {
        file_sorter = sorters.get_fzy_sorter,
        file_ignore_patterns = {
            "dist",
            "node_modules",
            "%_templ.go",
            "%.g.dart",
        },
        color_devicons = true,
        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.send_to_qflist
            }
        }
    },
    pickers = {
        find_files = { theme = "ivy" },
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
        ["ui-select"] = {
            themes.get_dropdown({})
        }
    },
})

telescope.load_extension("fzy_native")
telescope.load_extension("ui-select")

local dropdown = themes.get_dropdown({})

vim.keymap.set("n", "<C-p>",      function() builtin.find_files(themes.get_ivy({})) end, opts)
vim.keymap.set("n", "<leader>ff", function() builtin.find_files(themes.get_ivy({ hidden = true })) end, opts)
vim.keymap.set("n", "<leader>fd", function() builtin.find_files(themes.get_ivy({ cwd = '~/.dotfiles', hidden = true })) end, opts)
vim.keymap.set("n", "<leader>fg", function() builtin.live_grep(dropdown) end, opts)
vim.keymap.set("n", "<leader>fb", function() builtin.buffers(dropdown) end, opts)
vim.keymap.set("n", "<leader>fh", function() builtin.help_tags(dropdown) end, opts)
vim.keymap.set("n", "<leader>fs", function() builtin.lsp_dynamic_workspace_symbols(dropdown) end, opts)
vim.keymap.set("n", "<leader>fr", function() builtin.lsp_references(dropdown) end, opts)

--

vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { confirm = false })
vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

require("oil").setup {
    keymaps = { ["<C-p>"] = false },
    view_options = { show_hidden = true },
    win_options = { signcolumn = "yes" },
    skip_confirm_for_simple_edits = true,
    watch_for_changes = true,
}

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

--

vim.pack.add({ "https://github.com/j-hui/fidget.nvim" }, { confirm = false })

require("fidget").setup {
    notification = {
        override_vim_notify = 1,
        window = { winblend = 0 },
    }
}

--

vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = "v1.6.0" } }, { confirm = false })

require("blink.cmp").setup {
    sources = { default = { 'lsp', 'path', 'snippets' } },
    signature = { enabled = true },
    completion = {
        menu = {
            -- auto_show = function(ctx) return ctx.mode ~= 'cmdline' and vim.bo.buftype ~= "prompt" end,
            auto_show = false,
            draw = { treesitter = { "lsp" } },
        },
        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
    },
}

--

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })

-- vim.diagnostic.config {
--     signs = {
--         text = {
--             [vim.diagnostic.severity.ERROR] = "", --  
--             [vim.diagnostic.severity.WARN] = "", --  
--             [vim.diagnostic.severity.HINT] = "",
--             [vim.diagnostic.severity.INFO] = "", --  
--         }
--     }
-- }

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count =  1, float = true }) end, opts)
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
})

local filetypes = vim.lsp.config["ts_ls"].filetypes
table.insert(filetypes, "vue")
-- table.insert(filetypes, "vue")
vim.lsp.config("ts_ls", {
    filetypes = filetypes,
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server",
                languages = { "vue" },
                configNamespace = "typescript",
            }
        },
    },
})
vim.lsp.enable({ "ts_ls" })

vim.lsp.enable({ "svelte", "dartls" })

--

vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } }, { confirm = false })
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" } }, { confirm = false })

local filetypes = { "go", "gomod", "html", "json", "javascript", "typescript", "tsx", "dockerfile", "markdown", "sql", "lua", "yaml", "bash", "make", "kotlin", "nu", "yuck", "svelte", "dart" }

require("nvim-treesitter").install(filetypes)

vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
        vim.treesitter.start()
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

--

vim.pack.add({ "https://github.com/tpope/vim-fugitive" }, { confirm = false })
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { confirm = false })

require("gitsigns").setup {
    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
    },
    on_attach = function(buffer)
        local gitsigns = require("gitsigns")
        local opts = { noremap = true, silent = true, buffer = buffer }
        vim.keymap.set("n", "]c", gitsigns.next_hunk, opts)
        vim.keymap.set("n", "[c", gitsigns.prev_hunk, opts)
    end
}

--

vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" }, { confirm = false })
vim.pack.add({ { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" } }, { confirm = false })

local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, opts)
vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, opts)
vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end, opts)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end, opts)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end, opts)
vim.keymap.set("n", "<leader>;", function() harpoon:list():select(4) end, opts)

local extensions = require("harpoon.extensions")

harpoon:extend(extensions.builtins.highlight_current_file())
