-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

    'mxsdev/nvim-dap-vscode-js',
    {
      'microsoft/vscode-js-debug',
      version = '1.x',
      build = 'npm i && npm run compile vsDebugServerBundle && mv dist out',
    },
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>dl',
      function()
        local dap_log = vim.fn.stdpath('cache') .. '/dap.log'
        local js_log = vim.fn.stdpath('cache') .. '/dap_vscode_js.log'
        
        vim.cmd('tabnew')
        vim.cmd('e ' .. dap_log)
        vim.cmd('vsplit ' .. js_log)
        vim.cmd('wincmd h')
        
        vim.notify('Opened DAP logs (left=dap.log, right=js-debug)', vim.log.levels.INFO)
      end,
      desc = 'Debug: Open DAP log files',
    },
    {
      '<leader>dr',
      function()
        -- Reload all breakpoints (useful when they become unbound)
        require('dap').set_breakpoints()
        vim.notify('Breakpoints reloaded', vim.log.levels.INFO)
      end,
      desc = 'Debug: Reload breakpoints',
    },

    {
      '<leader>dc',
      function()
        vim.notify([[
Use Browser DevTools for client-side debugging:
1. Open browser (any browser) to http://localhost:5173
2. Press F12 to open DevTools
3. Set breakpoints in Sources tab
4. Code in Neovim, debug in browser

For server-side (+server.ts, API routes):
1. Run: npm run dev:debug
2. Press F5 in Neovim
3. Select "⚙️ Debug: SvelteKit Server"
]], vim.log.levels.INFO, {title = 'Debugging Guide'})
      end,
      desc = 'Debug: Show debugging guide',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Enable DAP logging for debugging
    dap.set_log_level('TRACE')

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    --config Javascript/Typescript Debug
    local js_debug_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug'
    
    -- Verify js-debug is built
    local vsDebugServer = js_debug_path .. '/out/src/vsDebugServer.js'
    if not vim.loop.fs_stat(vsDebugServer) then
      vim.notify('vscode-js-debug not built! Run: cd ' .. js_debug_path .. ' && npm run compile vsDebugServerBundle', vim.log.levels.ERROR)
      return
    end
    
    -- Manually configure adapters (more reliable than dap-vscode-js auto-setup)
    for _, adapter in ipairs { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' } do
      dap.adapters[adapter] = {
        type = 'server',
        host = '127.0.0.1',
        port = '${port}',
        executable = {
          command = 'node',
          args = { vsDebugServer, '${port}' },
        },
      }
    end
    
    -- Increase timeout for slow Windows systems
    dap.defaults.fallback.timeout = 60000
    
    for _, language in ipairs { 'typescript', 'javascript', 'svelte' } do
      require('dap').configurations[language] = {
        -- Server-side debugging only (no external browser process needed)
        {
          type = 'pwa-node',
          request = 'launch',
          name = '🚀 Debug: Launch File (Node)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
        },
        -- Server-side debugging: Attach to running Vite/Node server
        {
          type = 'pwa-node',
          request = 'attach',
          name = '⚙️ Debug: SvelteKit Server (Port 9229)',
          address = 'localhost',
          port = 9229,
          sourceMaps = true,
          resolveSourceMapLocations = {
            '${workspaceFolder}/**',
            '!**/node_modules/**',
          },
          cwd = '${workspaceFolder}',
          skipFiles = { '${workspaceFolder}/node_modules/**/*.js' },
          restart = true,
        },
        -- only if language is javascript, offer this debug action
        language == 'javascript'
            and {
              -- use nvim-dap-vscode-js's pwa-node debug adapter
              type = 'pwa-node',
              -- launch a new process to attach the debugger to
              request = 'launch',
              -- name of the debug action you have to select for this config
              name = 'Launch file in new node process',
              -- launch current file
              program = '${file}',
              cwd = '${workspaceFolder}',
            }
          or nil,
      }
    end



    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
