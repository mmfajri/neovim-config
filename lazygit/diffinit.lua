-- diffinit.lua (for external diffs in Lazygit)

-- Enable 24-bit colors
vim.o.termguicolors = true
vim.opt.background = 'dark'

-- Add your custom plugin path to the runtimepath
vim.opt.rtp:append(vim.fn.stdpath 'config' .. '/lua/kickstart/plugins')

-- Set theme and UI tweaks
vim.cmd.colorscheme 'tokyonight'
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'

-- Avoid loading full plugin framework
vim.g.loaded_lazy = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Force vertical diff split after files are loaded
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Wait for diff mode to be initialized
    vim.defer_fn(function()
      if vim.wo.diff then
        -- Move left window to full height vertical split
        vim.cmd('wincmd H')
      end
    end, 50) -- Small delay to ensure diff mode is active
  end,
})
