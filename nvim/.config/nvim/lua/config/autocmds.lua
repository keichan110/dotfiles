-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- バックグラウンドでも外部変更（Claude Code等）を検知するためタイマーで定期 checktime を実行
-- lazygit のターミナルが存在する間のみスキップし、git 操作との競合によるフリーズを防ぐ
local auto_reload_timer = vim.uv.new_timer()
auto_reload_timer:start(0, 5000, vim.schedule_wrap(function()
  if vim.fn.getcmdwintype() ~= "" then
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):find("lazygit", 1, true) then
      return
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "" then
      vim.cmd("checktime " .. buf)
    end
  end
end))

-- Markdownのマークアップ記号をそのまま表示
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_conceal", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- 保存時に末尾空白・末尾空行を削除 (VSCode: trimTrailingWhitespace / trimFinalNewlines)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("buf_write_cleanup", { clear = true }),
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable then return end
    vim.cmd("%s/\\s\\+$//e")
    if vim.fn.getline("$") == "" then
      vim.cmd("silent! $delete")
    end
  end,
})
