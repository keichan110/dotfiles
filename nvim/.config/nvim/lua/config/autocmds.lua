-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 表示中バッファの外部変更を定期チェックして自動リロード
-- 間隔(ms)はパフォーマンスに応じて調整: 並列数が多い/低スペック環境では長く、少ない/高スペック環境では短く
local auto_reload_timer = vim.uv.new_timer()
auto_reload_timer:start(0, 5000, vim.schedule_wrap(function()
  if vim.fn.getcmdwintype() == "" then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" then
        vim.cmd("checktime " .. buf)
      end
    end
  end
end))

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

-- Markdownのマークアップ記号をそのまま表示
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_conceal", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 0
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
