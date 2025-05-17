return {
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require 'cmp'

      cmp.setup {
        sources = {
          { name = 'nvim_lsp' },
        },
        snippet = {
          expand = function(args)
            -- You need Neovim v0.10 to use vim.snippet
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<Tab>'] = cmp.mapping.select_next_item(), -- Move to next suggestion
          ['<S-Tab>'] = cmp.mapping.select_prev_item(), -- Move to previous suggestion
          ['<CR>'] = cmp.mapping.confirm { select = true }, -- Confirm selection
          ['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
        },
      }
    end,
  },
  {
    'hrsh7th/cmp-nvim-lsp',
  },
}
