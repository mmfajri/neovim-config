return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- === ADD THIS SECTION BELOW ===
      -- Override the 'Visual' highlight group to make the selection less bright.
      -- The 'tokyonight-night' theme's default selection might be too intense.
      -- Experiment with different hex codes to find what looks best for you.
      -- A darker background color often works well.
      vim.api.nvim_set_hl(0, 'Visual', {
        bg = '#3B4261', -- Example: A slightly darker blue-grey from Tokyo Night palette
        -- You can also try a more neutral dark grey, e.g., '#303030' or '#3C4048'
        -- fg = '#FFFFFF', -- Optional: Set foreground color if you want to explicitly control text color on selection
        -- blend = 50,     -- Optional: Add transparency (0-100) if your terminal supports it
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
