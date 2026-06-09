return {
  {
    'numToStr/Comment.nvim',
    opts = {
      -- 1. Disable the default 'gcc' and 'gc' keymaps completely
      mappings = {
        basic = false,
        extra = false,
      },

      -- 2. Prevent Comment.nvim from acting inside Netrw explorer buffers
      ignore = function()
        return vim.bo.filetype == 'netrw'
      end,

      -- 3. Keep your fixed C# fallback logic active
      pre_hook = function(ctx)
        if vim.bo.filetype == 'cs' or vim.bo.filetype == 'csharp' then
          local U = require 'Comment.utils'
          return ctx.ctype == U.ctype.linewise and '// %s' or '/* %s */'
        end
      end,
    },
    config = function(_, opts)
      local comment = require 'Comment'
      comment.setup(opts)

      -- 4. Create your custom <leader>c keymaps (Excluding Netrw)
      vim.api.nvim_create_autocmd('FileType', {
        -- Apply to all files, but explicitly skip 'netrw'
        pattern = '*',
        callback = function(args)
          if vim.bo[args.buf].filetype == 'netrw' then
            return
          end

          -- Normal mode: <leader>c to toggle current line
          vim.keymap.set('n', '<leader>c', function()
            return vim.v.count == 0 and '<Plug>(comment_toggle_linewise_current)' or '<Plug>(comment_toggle_linewise_count)'
          end, { expr = true, buffer = args.buf, desc = 'Toggle comment line' })

          -- Visual mode: <leader>c to toggle selection
          vim.keymap.set('x', '<leader>c', '<Plug>(comment_toggle_linewise_visual)', {
            buffer = args.buf,
            desc = 'Toggle comment selection',
          })
        end,
      })
    end,
  },
}
