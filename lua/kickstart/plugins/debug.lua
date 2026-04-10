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
      build = function()
        -- Cross-platform build command for Windows/Unix
        local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
        if is_windows then
          -- Windows PowerShell commands
          vim.fn.system('npm install --force')
          vim.fn.system('npm run compile vsDebugServerBundle')
          -- Windows move command
          if vim.fn.isdirectory('dist') == 1 then
            vim.fn.system('if exist out rmdir /s /q out')
            vim.fn.system('move dist out')
          end
        else
          -- Unix/Linux commands
          vim.fn.system('npm i && npm run compile vsDebugServerBundle && mv dist out')
        end
      end,
    },
  },
  keys = {
    -- Custom F5: Auto-start dev server if needed, then debug
    {
      '<F5>',
      function()
        local dap = require('dap')
        
        -- If already debugging, just continue
        if dap.session() then
          dap.continue()
          return
        end
        
        -- Check if this is a JS/TS/Svelte project
        local cwd = vim.fn.getcwd()
        local package_json = cwd .. '/package.json'
        
        if vim.fn.filereadable(package_json) == 1 then
          -- Check if dev server is already running on port 9229
          local check_port_cmd = 'netstat -ano | findstr ":9229.*LISTENING"'
          local port_check = vim.fn.system(check_port_cmd)
          
          if port_check == '' or port_check:match('^%s*$') then
            -- Server not running - start it!
            vim.notify(
              '🚀 Starting dev server...\n\n' ..
              'Wait for "Local: http://localhost:5173/" message\n' ..
              'Then press F5 again to attach debugger!',
              vim.log.levels.INFO,
              { title = 'Auto-Start Dev Server', timeout = 5000 }
            )
            
            -- Open terminal and start server
            vim.cmd('split')
            vim.cmd('resize 15')
            vim.cmd('terminal')
            
            local term_id = vim.b.terminal_job_id
            vim.fn.chansend(term_id, 'cd "' .. cwd .. '"\r')
            vim.fn.chansend(term_id, 'npm run dev\r')
            
            -- Don't auto-attach, let user press F5 again when ready
          else
            -- Server is running - attach debugger
            vim.notify('✅ Server detected! Attaching debugger...', vim.log.levels.INFO)
            
            -- Directly run attach config (don't rely on filetype)
            dap.run({
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach to Dev Server',
              address = 'localhost',
              port = 9229,
              sourceMaps = true,
              protocol = 'inspector',
              skipFiles = { '<node_internals>/**', '**/node_modules/**' },
              resolveSourceMapLocations = {
                cwd .. '/**',
                '!**/node_modules/**',
              },
              cwd = cwd,
            })
            
            -- Force open DAP UI
            local dapui = require('dapui')
            vim.defer_fn(function()
              dapui.open()
            end, 500)
          end
        else
          -- Not a JS project, use normal continue
          dap.continue()
        end
      end,
      desc = 'Debug: Smart Start (auto-starts dev server if needed)',
    },
    -- F6: Simple attach (use this after server starts!)
    {
      '<F6>',
      function()
        local dap = require('dap')
        local dapui = require('dapui')
        
        -- Force attach to port 9229 (where npm run dev with --inspect listens)
        vim.notify('Attaching debugger to port 9229...', vim.log.levels.INFO)
        
        -- Manually create attach config and run it
        dap.run({
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to port 9229',
          address = 'localhost',
          port = 9229,
          sourceMaps = true,
          protocol = 'inspector',
          skipFiles = { '<node_internals>/**', '**/node_modules/**' },
          cwd = vim.fn.getcwd(),
        })
        
        -- Force open DAP UI
        vim.defer_fn(function()
          dapui.open()
        end, 500)
      end,
      desc = 'Debug: Attach to Dev Server (port 9229)',
    },
    -- F8: Launch Chrome for browser debugging
    {
      '<F8>',
      function()
        local port = vim.fn.input {
          prompt = 'Enter dev server port (default: 5173): ',
          default = '5173',
        }
        if port == '' then
          port = '5173'
        end
        
        local url = 'http://localhost:' .. port
        
        -- Check if server is running
        local check_cmd = 'powershell -Command "Test-NetConnection -ComputerName localhost -Port ' .. port .. ' -InformationLevel Quiet"'
        local is_running = vim.fn.system(check_cmd):match('True')
        
        if not is_running then
          vim.notify(
            '⚠️  Dev server is NOT running on port ' .. port .. '!\n\n' ..
            'Start it first: npm run dev',
            vim.log.levels.ERROR,
            { timeout = 5000 }
          )
          return
        end
        
        -- Find Chrome executable
        local chrome_paths = {
          'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
          'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
          os.getenv('LOCALAPPDATA') .. '\\Google\\Chrome\\Application\\chrome.exe',
        }
        
        local chrome_exe = nil
        for _, path in ipairs(chrome_paths) do
          if vim.fn.filereadable(path) == 1 then
            chrome_exe = path
            break
          end
        end
        
        if not chrome_exe then
          vim.notify(
            '❌ Chrome not found!\n\n' ..
            'Install Chrome or use Browser DevTools (F12) instead.',
            vim.log.levels.ERROR,
            { timeout = 5000 }
          )
          return
        end
        
        -- Launch Chrome with debugging
        local user_data_dir = vim.fn.tempname()
        local cmd = string.format(
          'powershell -Command "Start-Process \'%s\' -ArgumentList \'--remote-debugging-port=9222\',\'--user-data-dir=%s\',\'%s\'"',
          chrome_exe,
          user_data_dir,
          url
        )
        
        vim.fn.system(cmd)
        
        vim.notify(
          '🌐 Chrome launching...\n\n' ..
          'Once Chrome opens and loads:\n' ..
          'Press Shift+F8 to attach debugger',
          vim.log.levels.INFO,
          { timeout = 5000 }
        )
      end,
      desc = 'Debug: Launch Chrome',
    },
    
    -- Shift+F8: Attach/Re-attach to Chrome
    {
      '<S-F8>',
      function()
        local dap = require('dap')
        local dapui = require('dapui')
        local cwd = vim.fn.getcwd()
        
        -- Stop existing session if running
        if dap.session() then
          vim.notify('⏹️  Stopping old session...', vim.log.levels.INFO)
          dap.terminate()
          vim.defer_fn(function()
            dap.close()
          end, 500)
          vim.defer_fn(function()
            -- Re-attach after stopping
            vim.notify('🔗 Re-attaching to Chrome...', vim.log.levels.INFO)
            dap.run({
              type = 'pwa-chrome',
              request = 'attach',
              name = 'Attach to Chrome',
              port = 9222,
              webRoot = cwd,
              sourceMaps = true,
              sourceMapPathOverrides = {
                ['webpack:///./src/*'] = cwd .. '/src/*',
                ['webpack:///./*'] = cwd .. '/*',
                ['webpack:///*'] = '*',
                ['webpack:///src/*'] = cwd .. '/src/*',
              },
            })
            vim.defer_fn(function()
              dapui.open()
              vim.notify(
                '✅ Re-attached! Reload page now\n\n' ..
                '• Ctrl+R in Chrome to reload\n' ..
                '• Breakpoints should work\n' ..
                '• Press F7 if DAP UI not visible',
                vim.log.levels.INFO,
                { timeout = 100000 }
              )
            end, 1500)
          end, 1000)
        else
          -- Fresh attach
          vim.notify('🔗 Attaching to Chrome...', vim.log.levels.INFO)
          
          -- Force open DAP UI first
          dapui.open()
          
          dap.run({
            type = 'pwa-chrome',
            request = 'attach',
            name = 'Attach to Chrome',
            port = 9222,
            webRoot = cwd,
            sourceMaps = true,
            sourceMapPathOverrides = {
              ['webpack:///./src/*'] = cwd .. '/src/*',
              ['webpack:///./*'] = cwd .. '/*',
              ['webpack:///*'] = '*',
              ['webpack:///src/*'] = cwd .. '/src/*',
            },
          })
          
          vim.defer_fn(function()
            -- Open again in case it didn't auto-open
            dapui.open()
            vim.notify(
              '✅ Attached to Chrome!\n\n' ..
              '• Reload page to hit breakpoints (Ctrl+R)\n' ..
              '• If breakpoints stop: Shift+F8 to re-attach\n' ..
              '• Press F7 to toggle DAP UI',
              vim.log.levels.INFO,
              { timeout = 6000 }
            )
          end, 2000)
        end
      end,
      desc = 'Debug: Attach/Re-attach to Chrome',
    },
    -- Shift+F8: Show debug config picker (manual selection)
    {
      '<S-F8>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Show Configuration Picker',
    },
    {
      '<C-F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<C-F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<C-F12>',
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
        local dap_log = vim.fn.stdpath 'cache' .. '/dap.log'
        local js_log = vim.fn.stdpath 'cache' .. '/dap_vscode_js.log'

        vim.cmd 'tabnew'
        vim.cmd('e ' .. dap_log)
        vim.cmd('vsplit ' .. js_log)
        vim.cmd 'wincmd h'

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
      '<leader>ds',
      function()
        -- Start dev server in terminal for manual debugging
        local cwd = vim.fn.getcwd()
        vim.cmd 'split'
        vim.cmd 'terminal'
        vim.cmd 'resize 15'
        
        -- Change to project directory and start server
        local cmd = string.format('cd "%s" && npm run dev', cwd)
        vim.fn.chansend(vim.b.terminal_job_id, cmd .. '\r')
        
        vim.notify(
          '🚀 Dev server starting...\n\n' ..
          'Wait 5-10 seconds, then:\n' ..
          '1. Press F5\n' ..
          '2. Select "🔗 Quick Attach: Port 9229"\n\n' ..
          'Check terminal above for server URL!',
          vim.log.levels.INFO,
          { title = 'Manual Debug Start', timeout = 8000 }
        )
      end,
      desc = 'Debug: Start Dev Server in Terminal',
    },
    {
      '<leader>dp',
      function()
        -- Show running Node processes to help identify which one to attach to
        vim.cmd 'new'
        vim.cmd 'term'
        vim.fn.chansend(vim.b.terminal_job_id, 'echo "Node processes running:"\r')
        if vim.fn.has 'win32' == 1 then
          vim.fn.chansend(vim.b.terminal_job_id, 'tasklist | findstr /i "node.exe"\r')
        else
          vim.fn.chansend(vim.b.terminal_job_id, 'ps aux | grep node | grep -v grep\r')
        end
        vim.notify('Look for "node.exe" with your project path in the command line', vim.log.levels.INFO)
      end,
      desc = 'Debug: Show Node Processes',
    },
    {
      '<leader>dc',
      function()
        vim.notify(
          [[
🌐 WEB DEBUGGING - DEAD SIMPLE:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ ONE-STEP DEBUG (EASIEST) ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Open your Svelte/JS/TS project in Neovim
2. Press F5
3. Select: "🌟 All-in-One: Start & Debug"
4. Wait 10-15 seconds for server to start
5. Check DAP-TERMINAL for URL (usually http://localhost:5173)
6. Open browser to that URL
7. Set breakpoints: <leader>b

That's it! Server starts automatically + debugger attaches.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐛 WINDOWS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ 404 Error?
   → Check terminal for ACTUAL URL (might not be :5173)
   
❌ "Attach failed"?
   → Server not running. Use <leader>ds first!
   
❌ No breakpoint hits?
   → Breakpoints only work for SERVER-SIDE code
   → Use Browser DevTools (F12) for client-side

💡 What to debug where:
   • Neovim: API calls, +server.ts, backend logic
   • Browser: DOM, CSS, click handlers, UI

🔧 Keybindings:
   • <leader>ds = Start dev server
   • F5 = Start debugging
   • <leader>b = Toggle breakpoint
   • F7 = Toggle debug UI
]],
          vim.log.levels.INFO,
          { title = 'Web Debugging Guide', timeout = 20000 }
        )
      end,
      desc = 'Debug: Show debugging guide',
    },
    {
      '<leader>dv',
      function()
        local js_debug_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug'
        local vsDebugServer = js_debug_path .. '/out/src/vsDebugServer.js'
        
        if vim.loop.fs_stat(vsDebugServer) then
          vim.notify('✅ vscode-js-debug is properly installed and built!\nLocation: ' .. vsDebugServer, vim.log.levels.INFO, { title = 'JS Debug Check' })
        else
          vim.notify('❌ vscode-js-debug NOT built. Building now...\nThis may take 1-2 minutes.', vim.log.levels.WARN, { title = 'JS Debug Check' })
          
          -- Rebuild vscode-js-debug
          local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
          
          vim.cmd('cd ' .. js_debug_path)
          
          if is_windows then
            vim.fn.system('npm install --force')
            vim.fn.system('npm run compile vsDebugServerBundle')
            if vim.fn.isdirectory(js_debug_path .. '/dist') == 1 then
              vim.fn.system('if exist out rmdir /s /q out')
              vim.fn.system('move dist out')
            end
          else
            vim.fn.system('npm i && npm run compile vsDebugServerBundle && mv dist out')
          end
          
          -- Check again
          if vim.loop.fs_stat(vsDebugServer) then
            vim.notify('✅ Successfully built vscode-js-debug!\nRestart Neovim and try debugging again.', vim.log.levels.INFO, { title = 'JS Debug Build' })
          else
            vim.notify('❌ Build failed. Check if Node.js and npm are installed.\nRun: node --version && npm --version', vim.log.levels.ERROR, { title = 'JS Debug Build' })
          end
        end
      end,
      desc = 'Debug: Verify/Rebuild JS Debugger',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Enable DAP logging for debugging
    dap.set_log_level 'TRACE'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        -- Disable auto-config for C# (we'll configure it manually below)
        coreclr = function() end,
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    }

    --config Javascript/Typescript Debug
    local js_debug_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug'

    -- Verify js-debug is built
    local vsDebugServer = js_debug_path .. '/out/src/vsDebugServer.js'
    if vim.loop.fs_stat(vsDebugServer) then
      vim.notify('✅ JavaScript/TypeScript debugger loaded successfully', vim.log.levels.INFO)
      
      -- Only configure JS debugging if vscode-js-debug is built
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
          options = {
            -- Increase timeout for Windows
            initialize_timeout_sec = 60,
          },
        }
      end

      -- Increase timeout for slow Windows systems
      dap.defaults.fallback.timeout = 60000

      for _, language in ipairs { 'typescript', 'javascript', 'svelte' } do
        require('dap').configurations[language] = {
          -- ============================================
          -- #1: AUTO-START (SELECT THIS FIRST!)
          -- Starts dev server AND debugger in one click
          -- ============================================
          {
            type = 'pwa-node',
            request = 'launch',
            name = '🌟 #1 All-in-One: Start & Debug (SELECT THIS!)',
            runtimeExecutable = 'npm',
            runtimeArgs = { 'run', 'dev-temp' },
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            protocol = 'inspector',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
            restart = true,
            env = {
              NODE_ENV = 'development',
            },
          },
          -- ============================================
          -- #2: MANUAL ATTACH (only if you manually started server!)
          -- ============================================
          {
            type = 'pwa-node',
            request = 'attach',
            name = '🔗 #2 Attach Only (server must be running!)',  
            address = 'localhost',
            port = 9229,
            sourceMaps = true,
            protocol = 'inspector',
            skipFiles = { '<node_internals>/**', '**/node_modules/**' },
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            restart = true,
            cwd = '${workspaceFolder}',
            timeout = 30000,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = '🚀 Start & Debug: npm run dev (Generic)',
            runtimeExecutable = 'npm',
            runtimeArgs = { 'run', 'dev' },
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            console = 'integratedTerminal',
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
            restart = true,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = '📦 Start & Debug: npm start',
            runtimeExecutable = 'npm',
            runtimeArgs = { 'start' },
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            console = 'integratedTerminal',
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = '📄 Debug: Current File Only (Node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
            console = 'integratedTerminal',
          },
          -- ============================================
          -- ⚙️ ADVANCED - Attach configurations
          -- Requires dev server already running!
          -- ============================================
          {
            type = 'pwa-node',
            request = 'attach',
            name = '⚙️ ATTACH (Advanced): Running Node Process',
            processId = function()
              vim.notify(
                '⚠️  Make sure your dev server is ALREADY RUNNING!\n\n' ..
                'Start it first with: npm run dev\n' ..
                'Then select the node.exe process with your project path.',
                vim.log.levels.WARN
              )
              return require('dap.utils').pick_process { filter = 'node' }
            end,
            sourceMaps = true,
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            cwd = '${workspaceFolder}',
            skipFiles = { '${workspaceFolder}/node_modules/**/*.js', '<node_internals>/**' },
            timeout = 60000,
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = '🔌 ATTACH (Advanced): Custom Debug Port',
            address = 'localhost',
            port = function()
              vim.notify(
                '⚠️  Attach requires server running with --inspect flag!\n\n' ..
                'Example: NODE_OPTIONS="--inspect" npm run dev\n' ..
                'Default debug port is 9229',
                vim.log.levels.WARN
              )
              local port = vim.fn.input {
                prompt = 'Enter debug port (default: 9229): ',
                default = '9229',
              }
              if port == '' then
                port = '9229'
              end
              return tonumber(port)
            end,
            sourceMaps = true,
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
              '!**/.svelte-kit/**',
            },
            outFiles = {
              '${workspaceFolder}/**/*.js',
              '${workspaceFolder}/.svelte-kit/**/*.js',
            },
            cwd = '${workspaceFolder}',
            skipFiles = { '${workspaceFolder}/node_modules/**/*.js', '<node_internals>/**' },
            restart = true,
            timeout = 60000,
          },
          -- ============================================
          -- 🌐 BROWSER DEBUGGING - Debug client-side code in Neovim!
          -- ============================================
          {
            type = 'pwa-chrome',
            request = 'launch',
            name = '🌐 Launch Chrome: Debug Client-Side Code',
            url = function()
              local port = vim.fn.input {
                prompt = 'Enter dev server port (default: 5173): ',
                default = '5173',
              }
              if port == '' then
                port = '5173'
              end
              return 'http://localhost:' .. port
            end,
            sourceMaps = true,
            protocol = 'inspector',
            port = 9222,
            webRoot = '${workspaceFolder}/src',
            -- Skip Vite HMR files
            skipFiles = { 
              '**/node_modules/**/*',
              '**/@vite/*',
              '**/src/client/*',
              '!**/src/**', -- Don't skip our own src files
            },
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
          },
          {
            type = 'pwa-msedge',
            request = 'launch',
            name = '🌐 Launch Edge: Debug Client-Side Code',
            url = function()
              local port = vim.fn.input {
                prompt = 'Enter dev server port (default: 5173): ',
                default = '5173',
              }
              if port == '' then
                port = '5173'
              end
              return 'http://localhost:' .. port
            end,
            sourceMaps = true,
            protocol = 'inspector',
            port = 9222,
            webRoot = '${workspaceFolder}/src',
            skipFiles = { 
              '**/node_modules/**/*',
              '**/@vite/*',
              '**/src/client/*',
              '!**/src/**',
            },
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
          },
        }
      end
    else
      vim.notify(
        '❌ vscode-js-debug NOT built!\n\n' ..
        'JavaScript/TypeScript/Svelte debugging is DISABLED.\n\n' ..
        'To fix:\n' ..
        '1. Press <leader>dv to auto-build\n' ..
        '   OR\n' ..
        '2. Manually run in terminal:\n' ..
        '   cd ' .. js_debug_path .. '\n' ..
        '   npm install\n' ..
        '   npm run compile vsDebugServerBundle\n\n' ..
        'Then restart Neovim.',
        vim.log.levels.WARN,
        { title = 'JS Debug Setup Required' }
      )
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
    
    -- Also close DAP UI when disconnecting
    dap.listeners.after.disconnect['dapui_config'] = function()
      dapui.close()
    end

    -- Show helpful notification when starting JS/TS debugging
    dap.listeners.after.event_initialized['show_dev_server_url'] = function(session)
      local config = session.config
      
      -- Special message for quick attach configuration
      if config and config.request == 'attach' and config.port == 9229 then
        vim.defer_fn(function()
          vim.notify(
            '✅ Debugger attached to dev server!\n\n' ..
            '📍 Check your terminal for the server URL\n' ..
            '   (Usually http://localhost:5173 or :5000)\n\n' ..
            '🔧 Now you can:\n' ..
            '   • Set breakpoints: <leader>b\n' ..
            '   • Toggle debug UI: F7\n' ..
            '   • Step through code: F10 (over), F11 (into)\n\n' ..
            '💡 Open the URL in your browser to trigger breakpoints!',
            vim.log.levels.INFO,
            { title = 'Debug Attached Successfully', timeout = 8000 }
          )
        end, 1000)
      -- Message for launch configurations  
      elseif config and config.runtimeExecutable == 'npm' then
        vim.defer_fn(function()
          vim.notify(
            '🚀 Dev Server Starting...\n\n' ..
            '📍 Default URLs to try:\n' ..
            '   • http://localhost:3000\n' ..
            '   • http://localhost:5173 (Vite)\n' ..
            '   • http://localhost:5000\n' ..
            '   • http://localhost:4200 (Angular)\n\n' ..
            '💡 Check DAP-TERMINAL window for actual URL\n' ..
            '🔧 Press F7 to toggle debug UI\n' ..
            '🛑 Set breakpoints with <leader>b',
            vim.log.levels.INFO,
            { title = 'Debug Session Started', timeout = 8000 }
          )
        end, 2000) -- Wait 2 seconds for server to start
      end
    end

    -- Show helpful tips when attaching (if not using quick attach)
    dap.listeners.before.attach['show_attach_tips'] = function(session, config)
      -- Don't show for quick attach (port 9229)
      if config and config.port == 9229 then
        return
      end
      
      vim.notify(
        '⚠️  ATTACH MODE - Server must be ALREADY RUNNING!\n\n'
          .. 'If server is NOT running:\n'
          .. '1. Press Ctrl+C to cancel\n'
          .. '2. Press <leader>ds to start server\n'
          .. '3. Wait 10 seconds\n'
          .. '4. Press F5 again and select "Quick Attach"\n\n'
          .. 'Finding process manually:\n'
          .. '• Check terminal for port (e.g., :5173)\n'
          .. '• Run: netstat -ano | findstr :<port>\n'
          .. '• Select node.exe with matching project path',
        vim.log.levels.WARN,
        { title = 'DAP Attach Mode' }
      )
    end

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Configure C# debugging (.NET Core/5+)
    dap.adapters.coreclr = {
      type = 'executable',
      command = vim.fn.stdpath 'data' .. '/mason/bin/netcoredbg.cmd',
      args = { '--interpreter=vscode' },
      options = {
        detached = false,
      },
    }

    -- Helper function to find .NET project DLL
    local function find_dotnet_dll()
      local cwd = vim.fn.getcwd()
      
      -- Find .csproj to get project name
      local csproj = vim.fn.glob(cwd .. '/*.csproj')
      if csproj == '' then
        vim.notify('No .csproj found. Run: dotnet build', vim.log.levels.ERROR)
        return nil
      end
      
      local project_name = vim.fn.fnamemodify(vim.split(csproj, '\n')[1], ':t:r')
      
      -- Search for project DLL in common paths
      local patterns = {
        cwd .. '/bin/Debug/net9.0/' .. project_name .. '.dll',
        cwd .. '/bin/Debug/net8.0/' .. project_name .. '.dll',
        cwd .. '/bin/Debug/net7.0/' .. project_name .. '.dll',
        cwd .. '/bin/Debug/net6.0/' .. project_name .. '.dll',
        cwd .. '/bin/Release/net9.0/' .. project_name .. '.dll',
        cwd .. '/bin/Release/net8.0/' .. project_name .. '.dll',
      }
      
      for _, pattern in ipairs(patterns) do
        if vim.fn.filereadable(pattern) == 1 then
          vim.notify('✅ Found: ' .. project_name .. '.dll', vim.log.levels.INFO)
          return pattern
        end
      end
      
      -- If not found, search for any non-dependency DLL
      vim.notify('⚠️  ' .. project_name .. '.dll not found. Searching for main DLL...', vim.log.levels.WARN)
      local all_dlls = vim.fn.glob(cwd .. '/bin/Debug/**/*.dll')
      
      if all_dlls == '' then
        vim.notify('❌ No DLLs found. Run: dotnet build', vim.log.levels.ERROR)
        return nil
      end
      
      local dll_list = vim.split(all_dlls, '\n')
      local main_dlls = {}
      
      -- Filter: Keep only YOUR project DLLs (exclude dependencies)
      for _, path in ipairs(dll_list) do
        local filename = vim.fn.fnamemodify(path, ':t')
        local is_dependency = filename:match('^Microsoft%.') 
                           or filename:match('^System%.') 
                           or filename:match('^netstandard%.') 
                           or filename:match('^Newtonsoft%.') 
                           or filename:match('^Dapper%.') 
                           or filename:match('^AutoMapper%.')
                           or filename:match('^Swashbuckle%.')
                           or filename:match('%.resources%.dll$')
        
        if not is_dependency then
          table.insert(main_dlls, path)
        end
      end
      
      if #main_dlls == 0 then
        vim.notify('❌ No project DLL found (only dependencies)', vim.log.levels.ERROR)
        return nil
      end
      
      if #main_dlls == 1 then
        vim.notify('✅ Found: ' .. vim.fn.fnamemodify(main_dlls[1], ':t'), vim.log.levels.INFO)
        return main_dlls[1]
      end
      
      -- Multiple project DLLs - let user choose
      vim.notify('Multiple DLLs found. Select your main project:', vim.log.levels.INFO)
      local choice = vim.fn.inputlist(
        vim.list_extend(
          { 'Select your project DLL:' },
          vim.tbl_map(function(path)
            return vim.fn.fnamemodify(path, ':t')
          end, main_dlls)
        )
      )
      
      if choice > 0 and choice <= #main_dlls then
        return main_dlls[choice]
      end
      
      return nil
    end

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = '🚀 Launch - .NET Web (Development)',
        request = 'launch',
        program = find_dotnet_dll,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = 'integratedTerminal',
        justMyCode = false,
        env = {
          ASPNETCORE_ENVIRONMENT = 'Development',
        },
      },
      {
        type = 'coreclr',
        name = '🏭 Launch - .NET Web (Production)',
        request = 'launch',
        program = find_dotnet_dll,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = 'integratedTerminal',
        justMyCode = false,
        env = {
          ASPNETCORE_ENVIRONMENT = 'Production',
        },
      },
      {
        type = 'coreclr',
        name = '🚀 Launch - .NET Console (Development)',
        request = 'launch',
        program = find_dotnet_dll,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = 'integratedTerminal',
        env = {
          ASPNETCORE_ENVIRONMENT = 'Development',
        },
      },
      {
        type = 'coreclr',
        name = '🏭 Launch - .NET Console (Production)',
        request = 'launch',
        program = find_dotnet_dll,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = 'integratedTerminal',
        env = {
          ASPNETCORE_ENVIRONMENT = 'Production',
        },
      },
      {
        type = 'coreclr',
        name = '🔌 Attach to Running .NET Process',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }

    -- Configure Rust/C/C++ debugging
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }

    dap.configurations.rust = {
      {
        name = 'Launch Rust',
        type = 'codelldb',
        request = 'launch',
        program = function()
          -- Try to find the binary automatically
          local cwd = vim.fn.getcwd()
          local project_name = vim.fn.fnamemodify(cwd, ':t')
          local binary = cwd .. '/target/debug/' .. project_name
          if vim.fn.has 'win32' == 1 then
            binary = binary .. '.exe'
          end
          if vim.fn.filereadable(binary) == 1 then
            return binary
          end
          return vim.fn.input('Path to executable: ', cwd .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
      {
        name = 'Attach to Rust Process',
        type = 'codelldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
      },
    }

    dap.configurations.cpp = {
      {
        name = 'Launch C++',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
      {
        name = 'Attach to C++ Process',
        type = 'codelldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
      },
    }

    dap.configurations.c = dap.configurations.cpp

    -- Configure Python debugging
    dap.adapters.python = {
      type = 'executable',
      command = vim.fn.stdpath 'data' .. '/mason/bin/debugpy-adapter',
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch Python File',
        program = '${file}',
        pythonPath = function()
          -- Try to detect virtual environment
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
            return cwd .. '/venv/bin/python'
          elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            return cwd .. '/.venv/bin/python'
          else
            return 'python'
          end
        end,
      },
      {
        type = 'python',
        request = 'attach',
        name = 'Attach to running Python',
        connect = {
          host = 'localhost',
          port = 5678,
        },
      },
    }
  end,
}
