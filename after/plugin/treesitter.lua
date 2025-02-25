require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "go", "c_sharp", "rust", "json", "yaml", "html", "css", "javascript" }, -- Add languages here
  sync_install = false, -- Install parsers asynchronously
  highlight = {
    enable = true, -- Enable syntax highlighting
    additional_vim_regex_highlighting = false, -- Set to true if you need Vim regex highlights
  },
  indent = { enable = true }, -- Enable better indentation
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}
