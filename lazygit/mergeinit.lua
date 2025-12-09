-- mergeinit.lua (for external merge tool in Git/Lazygit)

-- Enable 24-bit colors
vim.o.termguicolors = true
vim.opt.background = 'dark'

-- Use built-in dark colorscheme as base
vim.cmd.colorscheme 'habamax'

-- UI tweaks
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'

-- Avoid loading full plugin framework
vim.g.loaded_lazy = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Better merge conflict display
vim.opt.diffopt:append('vertical')
vim.opt.diffopt:append('iwhite')
vim.opt.diffopt:append('algorithm:patience')
vim.opt.diffopt:append('indent-heuristic')

-- Tokyo Night inspired colors for diff/merge
vim.api.nvim_set_hl(0, 'Normal', { bg = '#1a1b26', fg = '#c0caf5' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#1a1b26', fg = '#c0caf5' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#3b4261' })
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#24283b' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#7aa2f7', bold = true })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = '#1a1b26' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#1f2335', fg = '#7aa2f7' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = '#1f2335', fg = '#565f89' })
vim.api.nvim_set_hl(0, 'VertSplit', { fg = '#414868' })

-- Diff highlights with Tokyo Night colors
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#20303b', fg = '#9ece6a' })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#1f2d3d', fg = '#7aa2f7' })
vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#37222c', fg = '#f7768e' })
vim.api.nvim_set_hl(0, 'DiffText', { bg = '#2e4057', fg = '#ffffff', bold = true })

-- Additional syntax highlighting
vim.api.nvim_set_hl(0, 'Comment', { fg = '#565f89', italic = true })
vim.api.nvim_set_hl(0, 'String', { fg = '#9ece6a' })
vim.api.nvim_set_hl(0, 'Function', { fg = '#7aa2f7' })
vim.api.nvim_set_hl(0, 'Keyword', { fg = '#bb9af7' })
vim.api.nvim_set_hl(0, 'Identifier', { fg = '#e0af68' })
