local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local languages = { 'go', 'rust', 'python', 'html', 'json', 'javascript', 'julia', 'c', 'css', 'dot', 'dockerfile', 'gomod', 'http', 'kotlin', 'java', 'markdown', 'sql', 'tsx', 'typescript', 'lua', 'vim', 'yaml', 'bash', 'make' }

configs.setup {
  ensure_installed = languages, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  -- ignore_install = { "d", "haskell" }, -- List of parsers to ignore installing
  autopairs = {
    enable = true,
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { "yaml" } },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}
