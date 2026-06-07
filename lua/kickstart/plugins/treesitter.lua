return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      local ts = require 'nvim-treesitter'

      ts.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      -- Auto start highlighting
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Auto install missing parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local ft = vim.bo.filetype

          if not vim.tbl_contains(ts.get_installed(), ft) then
            ts.install { ft }
          end
        end,
      })
    end,
  },
}
