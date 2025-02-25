
require('mason').setup() -- Ensure Mason is initialized

require('mason-lspconfig').setup({
  automatic_installation = true, -- This ensures Mason installs missing LSPs
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })
    end,
  },
})
