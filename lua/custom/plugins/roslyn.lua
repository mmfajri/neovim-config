return {
  {
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'razor' },
    config = function()
      -- Path to manually installed Roslyn LSP
      -- local roslyn_path = vim.fn.stdpath 'data' .. '/mason/packages/roslyn/libexec'
      local roslyn_path = vim.fn.stdpath 'data' .. '/mason/packages/roslyn-unstable/libexec'
      local roslyn_dll = roslyn_path .. '/Microsoft.CodeAnalysis.LanguageServer.dll'

      -- Check if Roslyn is installed
      if vim.fn.filereadable(roslyn_dll) == 0 then
        vim.notify('Roslyn LSP not found at: ' .. roslyn_dll, vim.log.levels.WARN)
        return
      end

      local cmd = {
        'dotnet',
        roslyn_dll,
        '--logLevel=Information',
        '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
      }

      require('roslyn').setup {
        exe = cmd,
        filetypes = { 'cs', 'razor' },
        settings = {
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      }
    end,
    -- Load on file patterns instead of just filetypes
    event = { 'BufReadPre *.cs', 'BufReadPre *.razor', 'BufReadPre *.cshtml' },
    init = function()
      -- Add Razor file types before plugin loads
      vim.filetype.add {
        extension = {
          razor = 'razor',
          cshtml = 'razor',
        },
      }
    end,
  },
}
