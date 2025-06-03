local lazygit_group = vim.api.nvim_create_augroup('LazyGitFix', { clear = true })

-- 1. Fix LazyGit colors without leaking to Neovim
vim.api.nvim_create_autocmd('TermOpen', {
  group = lazygit_group,
  pattern = 'term://*lazygit*',
  callback = function()
    -- Save current settings
    vim.g.pre_lazygit_settings = {
      termguicolors = vim.o.termguicolors,
      colorscheme = vim.g.colors_name,
    }

    -- Force terminal-friendly colors
    vim.opt_local.termguicolors = false
    vim.cmd 'highlight! TermCursorNC ctermbg=8 ctermfg=15'
    vim.cmd 'highlight! TermCursor ctermbg=8 ctermfg=15'
  end,
})

-- 2. Restore Neovim + fix todo-comments after exit
vim.api.nvim_create_autocmd('TermClose', {
  group = lazygit_group,
  pattern = 'term://*lazygit*',
  callback = function()
    if vim.g.pre_lazygit_settings then
      -- Restore original colors
      vim.opt.termguicolors = vim.g.pre_lazygit_settings.termguicolors
      vim.cmd('colorscheme ' .. vim.g.pre_lazygit_settings.colorscheme)

      -- Force reload todo-comments
      if package.loaded['todo-comments'] then
        package.loaded['todo-comments'] = nil
        require('todo-comments').setup()
      end

      -- Refresh UI (critical for plugin stability)
      vim.cmd 'checktime'
      vim.cmd 'mode' -- Force redraw
    end
  end,
})
