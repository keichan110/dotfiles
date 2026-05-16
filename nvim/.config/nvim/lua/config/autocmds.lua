-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Trim trailing whitespace on save (VSCode: files.trimTrailingWhitespace)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_trailing_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.modifiable then
      vim.cmd("%s/\\s\\+$//e")
    end
  end,
})

-- Trim final newlines on save (VSCode: files.trimFinalNewlines)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_final_newlines", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.modifiable then
      local lastline = vim.fn.getline("$")
      if lastline == "" then
        vim.cmd("silent! $delete")
      end
    end
  end,
})
