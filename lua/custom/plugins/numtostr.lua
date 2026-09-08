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

      -- 3. Keep your fixed C# fallback logic active, and resolve every other
      -- filetype's commentstring from Comment.nvim's static table directly.
      -- (Comment.nvim's treesitter-based fallback throws "attempt to index
      -- local 'tree' (a nil value)" for filetypes like go, silently aborting
      -- the whole toggle, so we bypass it entirely.)
      pre_hook = function(ctx)
        local U = require 'Comment.utils'
        if vim.bo.filetype == 'cs' or vim.bo.filetype == 'csharp' then
          return ctx.ctype == U.ctype.linewise and '// %s' or '/* %s */'
        end
        return require('Comment.ft').get(vim.bo.filetype, ctx.ctype)
      end,
    },
    config = function(_, opts)
      local comment = require 'Comment'
      comment.setup(opts)
      local api = require 'Comment.api'

      -- 4. Create your custom <leader>c keymaps (Excluding Netrw)
      vim.api.nvim_create_autocmd('FileType', {
        -- Apply to all files, but explicitly skip 'netrw'
        pattern = '*',
        callback = function(args)
          if vim.bo[args.buf].filetype == 'netrw' then
            return
          end

          -- Normal mode: <leader>c to toggle current line or [count] lines
          vim.keymap.set('n', '<leader>c', function()
            local count = vim.v.count
            if count > 0 then
              api.toggle.linewise.count(count)
            else
              api.toggle.linewise.current()
            end
          end, { buffer = args.buf, desc = 'Toggle comment line' })

          -- Visual mode: <leader>c to toggle selection
          vim.keymap.set('x', '<leader>c', function()
            local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
            vim.api.nvim_feedkeys(esc, 'nx', false)
            api.toggle.linewise(vim.fn.visualmode())
          end, { buffer = args.buf, desc = 'Toggle comment selection' })
        end,
      })
    end,
  },
}
