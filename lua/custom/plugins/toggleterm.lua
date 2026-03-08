return {
  'akinsho/toggleterm.nvim',
  version = '*',

  config = function()
    require('toggleterm').setup {
      direction = 'float',
      start_in_insert = true,
      persist_size = true,
    }

    local Terminal = require('toggleterm.terminal').Terminal

    -- LazyGit terminal instance
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      hidden = true,
      direction = 'float',
      float_opts = {
        border = 'rounded',
      },
    }

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    vim.keymap.set('n', '<leader>lg', _LAZYGIT_TOGGLE, { desc = 'LazyGit' })
  end,
}
