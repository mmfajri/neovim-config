return {
  'nvim-pack/nvim-spectre',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    vim.keymap.set('n', '<leader>F', function()
      require('spectre').toggle()
    end, {
      desc = 'Toggle Spectre',
    })
    vim.keymap.set('n', '<leader>FR', function()
      require('spectre').open_visual { select_word = true }
    end, {
      desc = 'Search current word (Spectre)',
    })
    vim.keymap.set('v', '<leader>Fw', function()
      require('spectre').open_visual()
    end, {
      desc = 'Search current word (Spectre)',
    })
    vim.keymap.set('n', '<leader>Fp', function()
      require('spectre').open_file_search { select_word = true }
    end, {
      desc = 'Search on current file (Spectre)',
    })
  end,
}
