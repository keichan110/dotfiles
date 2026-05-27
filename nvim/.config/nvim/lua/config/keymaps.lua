-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "i", "v" }, "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

vim.keymap.set("n", "x", '"_x', { desc = "Delete char without yanking" })
vim.keymap.set("n", "s", '"_s', { desc = "Delete char and insert without yanking" })

vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zz'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zz'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("n", "*", "*zz", { desc = "Search word under cursor and center" })
vim.keymap.set("n", "#", "#zz", { desc = "Search word under cursor backward and center" })

vim.keymap.set("n", "<leader>h", "^", { desc = "Go to first non-blank character" })
vim.keymap.set("n", "<leader>l", "$", { desc = "Go to end of line" })

vim.keymap.set("n", ";", ":", { desc = "Enter command mode" })
vim.keymap.set("n", ":", ";", { desc = "Repeat f/t motion" })
