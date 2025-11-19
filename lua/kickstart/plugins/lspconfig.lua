-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        opts = {
          server = {
            tailwindcss = {},
          },
          registries = {
            'github:mason-org/mason-registry',
            'github:Crashdummyy/mason-registry',
          },
        },
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            suppress_on_insert = false, -- still show updates even when typing
            display = {
              render_limit = 20, -- show more messages
              done_icon = '✔',
            },
          },
          notification = {
            override_vim_notify = true, -- replaces vim.notify
            window = {
              winblend = 0, -- make notifications opaque
              max_width = 100, -- even wider to see full error messages
            },
            view = {
              stack_upwards = false, -- newer notifications on top
            },
          },
        },
        keys = {
          {
            '<leader>fn',
            function()
              require('fidget.notification').show_history()
            end,
            desc = 'Fidget: Show notification history',
          },
          {
            '<leader>fN',
            function()
              -- Try to get Fidget notification history directly
              local fidget = require('fidget.notification')
              local history = fidget.get_history and fidget.get_history() or {}
              
              if #history == 0 then
                vim.notify('No Fidget notification history available', vim.log.levels.WARN)
                return
              end
              
              -- Create new buffer
              vim.cmd('new')
              local buf = vim.api.nvim_get_current_buf()
              
              -- Set buffer options
              vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
              vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
              vim.api.nvim_buf_set_option(buf, 'swapfile', false)
              vim.api.nvim_buf_set_name(buf, 'Fidget-History')
              
              -- Format history entries
              local lines = {}
              for i, notif in ipairs(history) do
                local msg = type(notif) == 'table' and notif.message or tostring(notif)
                table.insert(lines, string.format('[%d] %s', i, msg))
              end
              
              -- Add content BEFORE making it read-only
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              
              -- NOW make it read-only
              vim.api.nvim_buf_set_option(buf, 'modifiable', false)
              
              vim.notify('Fidget history opened! Use visual mode to copy.', vim.log.levels.INFO)
            end,
            desc = 'Open Fidget history in copyable buffer',
          },
        },
      },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Function when LSP attaches to buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- LSP-related mappings
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- Highlight references on cursor hold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      -- LSP capabilities (with blink.cmp)
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      -- Ensure LSP servers are installed
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Lua code formatter
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
          end,
        },
      }

      -- CSS LS
      vim.lsp.config('cssls', {
        filetypes = { 'css', 'scss', 'less', 'postcss' },
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = 'ignore',
            },
          },
        },
        capabilities = capabilities,
      })

      -- Tailwind CSS
      vim.lsp.config('tailwindcss', {
        filetypes = {
          'html',
          'css',
          'scss',
          'sass',
          'postcss',
          'javascript',
          'typescript',
          'svelte',
        },
        init_options = {
          userLanguages = {
            svelte = 'html',
            postcss = 'css',
          },
        },
        capabilities = capabilities,
      })

      -- ESLint
      vim.lsp.config('eslint', {
        filetypes = { 'javascript', 'typescript' },
        settings = {
          experimental = {
            useFlatConfig = true,
          },
        },
        capabilities = capabilities,
      })

      -- Svelte
      vim.lsp.config('svelte', {
        settings = {
          svelte = {
            plugin = {
              typescript = {
                enable = true,
                diagnostics = {
                  enable = true,
                },
              },
            },
          },
        },
        capabilities = capabilities,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
