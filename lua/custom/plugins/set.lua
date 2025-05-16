vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true


-- Enable highlight search (hlsearch)
vim.opt.hlsearch = true

-- Clear highlight search with <leader>nh
vim.keymap.set('n', '<leader>nh', ':noh<CR>', { noremap = true, silent = true })

-- Customize search highlight color (optional)
vim.api.nvim_set_hl(0, 'Search', { fg = '#FF0000', bg = '#FFFF00', bold = true })
