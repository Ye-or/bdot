-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Общие настройки
vim.opt.clipboard = "unnamedplus" -- + в clipboard
vim.opt.swapfile = false -- без своп-файлов
vim.opt.updatetime = 200 -- быстрее alt-tab
vim.opt.timeoutlen = 300 -- короче timeout для Leader
vim.opt.redrawtime = 1000
vim.opt.ttimeoutlen = 10
-- Подсветка
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "auto"
vim.opt.colorcolumn = "80"
-- Поиск
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- Tab/Indent
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
-- Удобство
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.mouse = "nv"
