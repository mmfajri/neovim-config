vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- OLD CONFIGURATION TO GO TO NVIM CONFIG
-- vim.keymap.set('n', '<leader>ev', function()
--   vim.cmd("cd $LOCALAPPDATA/nvim") -- Change working directory
--   vim.cmd("edit $LOCALAPPDATA/nvim/") -- Open the folder
-- end, { noremap = true, silent = true })

--CHANGING DIRECTORY WORKING
vim.keymap.set('n', '<leader>cd', function()
    local netrw_dir = vim.b.netrw_curdir
    if netrw_dir then
        vim.cmd('cd ' .. netrw_dir)
        print('Changed working directory to: ' .. netrw_dir)
    else
        print('Not in Netrw!')
    end
end, { noremap = true, silent = true })

-- Map keys to switch buffers
vim.api.nvim_set_keymap('n', '<leader>bn', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bp', ':bprev<CR>', { noremap = true, silent = true })

-- Map keys to escape from any mode
vim.keymap.set("i", "<C-[>", "<Esc>", { noremap = true })
vim.keymap.set("v", "<C-[>", "<Esc>", { noremap = true })
