vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    --Download The Nerd Icon Later
    --https://www.nerdfonts.com/
    --
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    --use 'xiyaowong/transparent.nvim'
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    -- use({
    -- 	'rose-pine/neovim',
    -- 	as = 'rose-pine',
    -- 	config = function()
    -- 		vim.cmd('colorscheme rose-pine')
    -- 	end
    -- })
    use({
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {}
    })
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use('tpope/vim-fugitive')
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use 'mbbill/undotree'
    use({ 'hrsh7th/nvim-cmp' })
    use({ 'hrsh7th/cmp-nvim-lsp' })
    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>", { noremap = true, silent = true })
        end,
    })
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
end)
