-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- VSCode settings alignment
local opt = vim.opt

-- Indentation and tabs
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Line wrapping
opt.wrap = true
opt.textwidth = 120
opt.linebreak = true

-- Display
opt.number = true
opt.relativenumber = true
opt.scrolloff = 15
opt.sidescrolloff = 5
opt.cursorline = false -- VSCode: renderLineHighlight = "none"
opt.smoothscroll = true

-- Whitespace and special characters
opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
  extends = "»",
  precedes = "«",
}
opt.list = true

-- Cursor
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Font (for GUI neovim like Neovide, GNvim)
opt.guifont = "PlemolJP:h14.5,HackGen:h14.5,Cica:h14.5"
opt.linespace = 5 -- lineHeight: 1.85 to approximate linespace

-- File handling
opt.autoread = true -- 外部変更を検知した際に自動リロード（checktimeと組み合わせて使用）
opt.autowrite = false
opt.autowriteall = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
