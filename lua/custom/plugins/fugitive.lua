return {
  {
    'tpope/vim-fugitive',
    config = function()
      -- Git status and log
      vim.keymap.set('n', '<leader>gstat', vim.cmd.Git, { desc = 'Git Status' })
      vim.keymap.set('n', '<leader>ggraph', ':Git log --graph --oneline --decorate --all<CR>', { desc = 'Git Log', noremap = true, silent = true })
      
      -- Create custom highlight groups for bright, visible labels (do this early!)
      vim.api.nvim_set_hl(0, 'MergeCurrentLabel', { fg = '#1a1b26', bg = '#7aa2f7', bold = true }) -- Blue background, dark text
      vim.api.nvim_set_hl(0, 'MergeWorkingLabel', { fg = '#1a1b26', bg = '#e0af68', bold = true }) -- Yellow/Orange background, dark text
      vim.api.nvim_set_hl(0, 'MergeIncomingLabel', { fg = '#ffffff', bg = '#f7768e', bold = true }) -- Red/Pink background, white text
      
      -- Label windows in 3-way merge
      local function label_merge_windows()
        -- Small delay to ensure windows are properly created
        vim.defer_fn(function()
          local wins = vim.api.nvim_tabpage_list_wins(0)
          
          -- Debug: print number of windows
          print('Number of windows:', #wins)
          
          if #wins >= 3 then
            -- Fugitive 3-way diff creates windows in this order: left (//2), middle (working), right (//3)
            local left_win = wins[1]
            local middle_win = wins[2]
            local right_win = wins[3]
            
            -- Set window-local statusline with bright, custom colored labels
            vim.api.nvim_set_option_value('statusline', '%#MergeCurrentLabel#  ← CURRENT (OURS) %*', { win = left_win, scope = 'local' })
            vim.api.nvim_set_option_value('statusline', '%#MergeWorkingLabel#  ✎ WORKING COPY (EDIT HERE) %*', { win = middle_win, scope = 'local' })
            vim.api.nvim_set_option_value('statusline', '%#MergeIncomingLabel#  → INCOMING (THEIRS) %*', { win = right_win, scope = 'local' })
            
            -- Also show helpful message
            vim.notify('🔀 3-Way Merge: LEFT=Ours(Current) | MIDDLE=Edit | RIGHT=Theirs(Incoming)', vim.log.levels.INFO)
          end
        end, 200)
      end
      
      -- Merge conflict resolution with 3-way diff + label immediately
      vim.keymap.set('n', '<leader>gm', function()
        vim.cmd('Gvdiffsplit!')
        label_merge_windows()
      end, { desc = 'Git: Open 3-Way Merge' })
      
      -- Accept ALL changes from one side (whole conflict block) + auto-jump
      vim.keymap.set('n', '<leader>gh', ':diffget //2<CR>]c', { desc = 'Git: Accept ALL from Left (Ours) + Next' })
      vim.keymap.set('n', '<leader>gl', ':diffget //3<CR>]c', { desc = 'Git: Accept ALL from Right (Theirs) + Next' })
      
      -- Accept BOTH changes (union merge) - puts both together
      vim.keymap.set('n', '<leader>gb', function()
        -- Get from left first (ours)
        vim.cmd('diffget //2')
        -- Then append from right (theirs)
        vim.cmd('diffget //3')
        -- Jump to next conflict
        vim.cmd('normal! ]c')
      end, { desc = 'Git: Accept BOTH (Ours + Theirs) + Next' })
      
      -- Visual Studio-style: Pick SPECIFIC lines/hunks (works in visual mode)
      vim.keymap.set('v', '<leader>gh', ':diffget //2<CR>', { desc = 'Git: Pick Selected from Left (Ours)' })
      vim.keymap.set('v', '<leader>gl', ':diffget //3<CR>', { desc = 'Git: Pick Selected from Right (Theirs)' })
      
      -- Accept current hunk under cursor
      vim.keymap.set('n', '<leader>gH', ':diffget //2<CR>', { desc = 'Git: Accept This Hunk from Left' })
      vim.keymap.set('n', '<leader>gL', ':diffget //3<CR>', { desc = 'Git: Accept This Hunk from Right' })
      vim.keymap.set('n', '<leader>gB', function()
        vim.cmd('diffget //2')
        vim.cmd('diffget //3')
      end, { desc = 'Git: Accept BOTH This Hunk (No Jump)' })
      
      -- Auto-open 3-way diff when opening a file with conflict markers
      vim.api.nvim_create_autocmd('BufReadPost', {
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          
          -- Check if file has conflict markers
          for _, line in ipairs(lines) do
            if line:match('^<<<<<<<') then
              -- File has conflicts, open 3-way diff
              vim.defer_fn(function()
                vim.cmd('Gvdiffsplit!')
                label_merge_windows()
              end, 100)
              break
            end
          end
        end,
      })
      
      -- Trigger labeling on various events
      vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
        callback = function()
          -- Check if we're in a diff mode with 3 windows
          if vim.wo.diff then
            local wins = vim.api.nvim_tabpage_list_wins(0)
            if #wins == 3 then
              label_merge_windows()
            end
          end
        end,
      })
    end,
  },
}
