return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      local ts = require 'nvim-treesitter'

      local languages = {
        { parser = 'git_config' },
        { parser = 'yaml' },
        { parser = 'bash', filetypes = { 'sh' } },
        { parser = 'c' },
        { parser = 'c_sharp', filetypes = { 'cs' } },
        { parser = 'diff' },
        { parser = 'html' },
        { parser = 'lua' },
        { parser = 'luadoc' },
        { parser = 'markdown' },
        { parser = 'markdown_inline' },
        { parser = 'query' },
        { parser = 'vim' },
        { parser = 'vimdoc', filetypes = { 'help' } },
        { parser = 'razor' },
        { parser = 'svelte' },
        { parser = 'typescript' },
        { parser = 'javascript' },
        { parser = 'css' },
        { parser = 'java' },
        { parser = 'go' },
      }

      local parsers = {}

      for _, lang in ipairs(languages) do
        table.insert(parsers, lang.parser)

        if lang.filetypes then
          for _, ft in ipairs(lang.filetypes) do
            vim.treesitter.language.register(lang.parser, ft)
          end
        end
      end

      ts.setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
        ensure_installed = parsers,
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype

          local ignore = {
            fidget = true,
            TelescopePrompt = true,
            TelescopeResults = true,
            ['blink-cmp-menu'] = true,
            lazy = true,
          }

          if ignore[ft] then
            return
          end

          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
