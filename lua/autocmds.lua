-- (Usually near the top of your init.lua, after Lazy.nvim setup)
-- Ensure termguicolors is true globally by default for your main Neovim experience
-- Autocommand: When a terminal buffer is opened (like Lazygit)
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*', -- Applies to any terminal buffer
  callback = function()
    -- Disable Neovim's true colors for *this specific terminal buffer*
    -- This allows the terminal application (Lazygit) to use its own colors.
    vim.opt_local.termguicolors = false
    -- Optional: If Lazygit's background clashes badly, you could try setting
    -- the background of the terminal buffer to a very specific, dark color here,
    -- but usually, disabling termguicolors is enough.
    -- vim.api.nvim_set_hl(0, 'Normal', { bg = '#000000' }) -- Example for a pure black background
  end,
})

-- Autocommand: When leaving *any* terminal buffer
vim.api.nvim_create_autocmd('BufLeave', {
  pattern = 'term://*', -- Specifically targets buffers whose name starts with 'term://'
  callback = function()
    -- Re-enable Neovim's global true colors for all buffers
    vim.opt.termguicolors = true
    -- Force Neovim to reload your main colorscheme to ensure all colors are reapplied.
    -- IMPORTANT: Replace 'tokyonight-night' with the exact name of your main colorscheme.
    vim.cmd 'colorscheme tokyonight-night'
    vim.cmd 'lua ColorMyPencils()'
  end,
})
