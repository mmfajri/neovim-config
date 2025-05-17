return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gstat', vim.cmd.Git, { desc = 'Gstatus' })
      vim.keymap.set('n', '<leader>ggraph', ':Git log --graph --oneline --decorate --all<CR>', { desc = 'Git Log', noremap = true, silent = true })
    end,
  },
}
