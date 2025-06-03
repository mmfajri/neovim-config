local lazygit_group = vim.api.nvim_create_augroup('LazyGitColors', { clear = true })

-- When opening LazyGit
vim.api.nvim_create_autocmd('TermOpen', {
  group = lazygit_group,
  pattern = 'term://*lazygit*',
  callback = function()
    -- Save current colorscheme
    vim.g.pre_lazygit_colorscheme = vim.g.colors_name

    -- Apply terminal-friendly colorscheme
    vim.cmd 'colorscheme elflord' -- or darkblue/industry/elflord/desert

    -- Force 256-color mode for consistency
    vim.opt_local.termguicolors = false
  end,
})

-- When closing terminal
vim.api.nvim_create_autocmd('TermClose', {
  group = lazygit_group,
  pattern = 'term://*lazygit*',
  callback = function()
    if vim.g.pre_lazygit_colorscheme then
      -- Restore original colorscheme
      vim.cmd('colorscheme ' .. vim.g.pre_lazygit_colorscheme)
      vim.opt.termguicolors = true

      -- Refresh plugins
      if package.loaded['todo-comments'] then
        require('todo-comments').setup()
      end
    end
  end,
})
