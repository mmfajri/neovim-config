return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",  -- Required for nvim-dap-ui
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"leoluz/nvim-dap-go",  -- Go debugging support
		"mxsdev/nvim-dap-vscode-js",
		-- build debugger from source
		{
			"microsoft/vscode-js-debug",
			version = "1.x",
			build = "npm i && npm run compile vsDebugServerBundle && move dist out"
		}
	},
	keys = {
		-- Debug keybindings
		{ "<leader>b", function() require 'dap'.toggle_breakpoint() end, desc = "Toggle breakpoint" },
		{ "<F5>",      function() require 'dap'.continue() end, desc = "Continue/Start" },
		{ "<F10>",     function() require 'dap'.step_over() end, desc = "Step Over" },
		{ "<F11>",     function() require 'dap'.step_into() end, desc = "Step Into" },
		{ "<S-F11>",   function() require 'dap'.step_out() end, desc = "Step Out" },
		{ "<S-F5>",    function() require 'dap'.terminate() end, desc = "Stop" },
		{ "<F7>",      function() require 'dapui'.toggle() end, desc = "Toggle DAP UI" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		
		-- Setup mason-nvim-dap for automatic debugger installation
		require('mason-nvim-dap').setup({
			automatic_installation = true,
			handlers = {
				coreclr = function() end,  -- Manual C# config below
			},
			ensure_installed = {
				-- Add debuggers you want auto-installed
			},
		})
		
		-- Configure breakpoint icons
		vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
		vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
		local breakpoint_icons = vim.g.have_nerd_font
			and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
			or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
		for type, icon in pairs(breakpoint_icons) do
			local tp = 'Dap' .. type
			local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
			vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
		end
		
		-- Setup DAP UI
		dapui.setup()
		
		-- Auto-open/close DAP UI
		dap.listeners.after.event_initialized['dapui_config'] = dapui.open
		dap.listeners.before.event_terminated['dapui_config'] = dapui.close
		dap.listeners.before.event_exited['dapui_config'] = dapui.close
		dap.listeners.after.disconnect['dapui_config'] = dapui.close
		
		-- ========== GO DEBUGGING ==========
		require('dap-go').setup({
			delve = {
				-- On Windows delve must be run attached or it crashes.
				detached = vim.fn.has('win32') == 0,
			},
		})
		
		-- ========== C# DEBUGGING ==========
		dap.adapters.coreclr = {
			type = 'executable',
			command = vim.fn.stdpath('data') .. '/mason/bin/netcoredbg.cmd',
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
		
		-- ========== RUST DEBUGGING ==========
		dap.adapters.codelldb = {
			type = 'server',
			port = '${port}',
			executable = {
				command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
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
					if vim.fn.has('win32') == 1 then
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
		
		-- ========== C/C++ DEBUGGING (uses same adapter as Rust) ==========
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

		vim.notify("DAP loaded: C#, Go, Rust, C/C++ debugging ready!", vim.log.levels.INFO)
	end
}
