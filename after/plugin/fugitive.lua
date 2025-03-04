vim.keymap.set("n", "<leader>gstat", vim.cmd.Git)
vim.keymap.set("n", "<leader>ggraph", ":Git log --graph --oneline --decorate --all<CR>", { noremap = true, silent = true })
