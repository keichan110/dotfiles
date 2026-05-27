-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "i", "v" }, "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

vim.keymap.set("n", ";", ":", { desc = "Enter command mode" })
vim.keymap.set("n", ":", ";", { desc = "Repeat f/t motion" })
