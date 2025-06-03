-- nvim v0.8.0
return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
  },
}
-- NOTE: The prequisite for additional for git/lazygit
-- dif --> git-delta --> cargo install git-delta
-- hightlighting --> bat --> cargo install bat
-- open the git config terminal ==> git config --global --edit
-- paste here the config

-- # ~/.gitconfig
--
-- [core]
--   pager = delta
--
-- [interactive]
--   diffFilter = delta --color-only --features=side-by-side
--
-- [delta]
--   # ====================================================================
--   # Core Appearance & Layout
--   # ====================================================================
--
--   # 1. Side-by-side vs. Full Width
--   # Show diffs side-by-side. Requires a wide terminal.
--   side-by-side = true
--   # If you prefer full-width (old and new code stacked vertically):
--   # side-by-side = false
--
--   # 2. Line Numbers
--   # Display line numbers next to the code.
--   line-numbers = true
--   # Customize line number colors (optional)
--   # line-numbers-left-style = 'blue'
--   # line-numbers-right-style = 'blue'
--
--   # 3. Theme (Light vs. Dark Mode)
--   # Set to true for a light terminal theme, false for a dark terminal theme.
--   light = false # Assuming you have a dark terminal background (like Tokyo Night)
--
--   # 4. Paging
--   # If the diff output is longer than your terminal height,
--   # 'true' will pipe it through a pager (like `less`).
--   # 'false' will print everything directly.
--   # This is separate from [core] pager.
--   pager = true
--
--   # ====================================================================
--   # Colors & Styles (Highly Customizable!)
--   # ====================================================================
--
--   # Note: Colors can be names (e.g., 'red', 'green', 'blue'),
--   # or hex codes (e.g., '#FF0000'), or RGB values (e.g., '255 0 0').
--   # Styles can be 'bold', 'italic', 'underline', 'blink', 'reverse', ' dimmed'.
--
--   # Styles for lines added (prefixed with '+')
--   plus-style = 'green'
--   # Styles for lines removed (prefixed with '-')
--   minus-style = 'red'
--
--   # Styles for lines that are the same but were part of a changed block
--   # (context lines, often subtly highlighted)
--   # syntax-theme for context lines (if you have bat installed)
--   # syntax-theme can be specified globally or per line type.
--   # If you want to use the same syntax highlighting theme as your Neovim,
--   # ensure `bat` is installed and set `syntax-theme`.
--   syntax-theme = 'tokyonight' # Replace with a theme 'bat' supports (e.g., 'GitHub', 'Nord', 'OneHalfDark', 'Dracula')
--
--   # Background colors for added/removed lines
--   # These are important for selection contrast within Lazygit
--   plus-empha-style = 'white bold ul' # Example: bold underline
--   minus-empha-style = 'red bold ul' # Example: bold underline
--
--   # Styles for the line numbers in the side-by-side view
--   # For matching Tokyo Night, you might use:
--   # line-numbers-left-style = '109' # An ANSI color code for a subtle grey
--   # line-numbers-right-style = '109'
--
--   # Styles for other UI elements in the diff
--   commit-style = 'bold yellow'             # The commit hash and message
--   file-style = 'bold blue ul'             # File path in the diff header
--   hunk-header-style = 'bold magenta'      # The `@@ -X,Y +A,B @@` header
--   hunk-header-file-style = 'magenta'      # File name in hunk header
--   hunk-header-line-number-style = 'blue'  # Line numbers in hunk header
--
--   # ====================================================================
--   # Advanced Features & Navigation
--   # ====================================================================
--
--   # 5. Syntax Highlighting (Requires 'bat'!)
--   # If you want syntax highlighting within your diffs, you need to install `bat`.
--   # (e.g., `brew install bat` on macOS, `sudo apt install bat` on Debian/Ubuntu)
--   # Then, specify a `syntax-theme` here.
--   # You can see available themes by running `bat --list-themes`.
--   # Use the same theme as your Neovim colorscheme for consistency!
--   # syntax-theme = "Tokyonight" # Example, case-sensitive for bat themes
--
--   # 6. Navigation
--   # Allow navigating between diff hunks with 'n' (next) and 'p' (previous).
--   navigate = true
--
--   # 7. True Color Support
--   # Ensures full 24-bit color support if your terminal emulator allows it.
--   true-color = auto # 'auto', 'always', or 'never'
--
--   # 8. Diff Output Appearance (e.g., for `git log -p`)
--   # `diff-highlight` like functionality.
--   # This enables word-level diffs within changed lines.
--   features = "side-by-side" # You already set this in `diffFilter`
--   # features = "colors-only, side-by-side, decorations" # You can list multiple
--   # More common:
--   # features = "diff-highlight"
--
--   # 9. Decorations (Optional, if you want specific borders/styles around elements)
--   # E.g., for the box around the line numbers
--   # line-numbers-right-format = "{nm} | "
