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
                -- Split messages with newlines into separate lines
                for line in msg:gmatch('[^\r\n]+') do
                  table.insert(lines, string.format('[%d] %s', i, line))
                end
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
          -- Visual Studio-style code actions with Ctrl+.
          map('<C-.>', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })
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
            -- Explicitly skip jdtls - handled by nvim-jdtls plugin below
            if server_name == 'jdtls' then
              return
            end
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
          end,
          -- Explicit jdtls handler - do absolutely nothing
          jdtls = function()
            -- CRITICAL: Do not call vim.lsp.config for jdtls
            -- nvim-jdtls plugin handles Java LSP completely
          end,
        },
      }
      
      -- Prevent lspconfig FileType autocmds from starting jdtls
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          -- Clear any lspconfig jdtls autocmds
          pcall(vim.api.nvim_clear_autocmds, {
            group = 'lspconfig',
            buffer = 0,
          })
        end,
      })

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
  
  -- Java Language Server (JDTLS)
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      -- Setup autocmd to start JDTLS when Java file is opened
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          local jdtls = require('jdtls')
          local home = os.getenv('USERPROFILE') or os.getenv('HOME')
          local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
          
          -- Check if jdtls is installed
          if vim.fn.isdirectory(jdtls_path) == 0 then
            vim.notify('JDTLS not installed! Run :MasonInstall jdtls', vim.log.levels.ERROR)
            return
          end
          
          -- Check if Java is available
          if vim.fn.executable('java') == 0 then
            vim.notify('Java not found in PATH! Install JDK 17+', vim.log.levels.ERROR)
            return
          end
          
          -- OS-specific config
          local config_dir = 'config_win'
          if vim.fn.has('mac') == 1 then
            config_dir = 'config_mac'
          elseif vim.fn.has('unix') == 1 then
            config_dir = 'config_linux'
          end
          
          -- Check if launcher jar exists
          local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
          if launcher_jar == '' then
            vim.notify('JDTLS launcher not found! Reinstall with :MasonUninstall jdtls then :MasonInstall jdtls', vim.log.levels.ERROR)
            return
          end
          
          -- Use getcwd() as root since user opens nvim from project root
          -- This avoids detecting submodule settings.gradle files
          local root_dir = vim.fn.getcwd()
          local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
          local workspace_dir = home .. '/.cache/jdtls/' .. project_name
          
          -- Find Lombok jar from Gradle cache (project uses Lombok)
          -- Use direct path since glob with ** doesn't work reliably
          local lombok_jar = home .. '/.gradle/caches/modules-2/files-2.1/org.projectlombok/lombok/1.18.32/17d46b3e205515e1e8efd3ee4d57ce8018914163/lombok-1.18.32.jar'
          
          -- Fallback: try to find any lombok jar if specific version not found
          if vim.fn.filereadable(lombok_jar) ~= 1 then
            local possible_jars = vim.fn.globpath(
              home .. '/.gradle/caches/modules-2/files-2.1/org.projectlombok/lombok',
              '**/lombok-*.jar',
              false,
              true
            )
            if #possible_jars > 0 then
              lombok_jar = possible_jars[1]
            else
              lombok_jar = ''
            end
          end
          
          local cmd_args = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xmx1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          }
          
          -- Add Lombok agent if found
          if lombok_jar ~= '' and vim.fn.filereadable(lombok_jar) == 1 then
            table.insert(cmd_args, '-javaagent:' .. lombok_jar)
          end
          
          -- Add JDTLS jar and config
          table.insert(cmd_args, '-jar')
          table.insert(cmd_args, launcher_jar)
          table.insert(cmd_args, '-configuration')
          table.insert(cmd_args, jdtls_path .. '/' .. config_dir)
          table.insert(cmd_args, '-data')
          table.insert(cmd_args, workspace_dir)
          
          local config = {
            cmd = cmd_args,
            root_dir = root_dir,
            settings = {
              java = {
                eclipse = { downloadSources = true },
                maven = { downloadSources = true },
                implementationsCodeLens = { enabled = true },
                referencesCodeLens = { enabled = true },
                references = { includeDecompiledSources = true },
                configuration = {
                  runtimes = {},
                },
              },
            },
            init_options = { bundles = {} },
            capabilities = require('blink.cmp').get_lsp_capabilities(),
          }
          
          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
