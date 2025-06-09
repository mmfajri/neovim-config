vim.o.termguicolors = true
vim.cmd.colorscheme 'tokyonight'

-- Optional: Set diff-specific UI improvements
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'

-- Avoid loading full Lazy.nvim config
-- Skip plugin loading entirely if you're using Lazy.nvim or Packer
vim.g.loaded_lazy = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
