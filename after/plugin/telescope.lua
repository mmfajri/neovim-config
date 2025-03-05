vim = vim
local builtin = require('telescope.builtin')
--old config
--vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })


vim.keymap.set('n', '<leader>ev', function ()
    builtin.find_files({
        cwd = vim.fn.expand("$LOCALAPPDATA/nvim"),
    })
end, {noremap = true, silent = true})

vim.keymap.set('n', '<leader>pf', function()
  local cwd = vim.fn.expand("%:p:h") -- Get the directory of the current buffer
  builtin.find_files({ cwd = cwd })
end, { desc = 'Search files in the current buffer directory' })

vim.keymap.set('n', '<leader>df', function()
  builtin.find_files({ cwd = vim.fn.getcwd() }) -- Use the updated working directory
end, { desc = 'Search files in current directory' })

--OTHER CONFIG
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope find git names'})
vim.keymap.set('n', '<leader>ps', function ()
	builtin.grep_string({ search = vim.fn.input("Grep -> ")});
end)

vim.keymap.set('n', '<leader>toptnv', function()
  builtin.find_files({ cwd = "C:/Users/900363/AppData/Local/nvim" })
end, { desc = 'Telescope find files in Neovim config' })

vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope find git namfs' })

-- vim.keymap.set('n', '<leader>tgoptnv', function() 
--   builtin.grep_string({ search = vim.fn.input("Grep -> "), cwd = "C:/Users/900363/AppData/Local/nvim" })
-- end, { desc = 'Telescope grep in Neovim config' })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>bb', builtin.buffers, { desc = 'Telescope Buffers' })
