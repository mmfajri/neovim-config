return {
  -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    config = function()
      require('Comment').setup()

      vim.keymap.set(
        'n',
        '<leader>c',
        "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
        { desc = 'Comment the Line', noremap = true, silent = true }
      )
      vim.keymap.set(
        'v',
        '<leader>c',
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        { desc = 'Comment / Uncomment the line', noremap = true, silent = true }
      )
    end,
  },
}
