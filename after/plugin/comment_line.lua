require("Comment").setup()

vim.keymap.set("n", "<leader>c", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>c", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { noremap = true, silent = true })
