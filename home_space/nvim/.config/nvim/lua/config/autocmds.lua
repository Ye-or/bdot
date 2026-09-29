-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Перезагрузка файла при изменении извне
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  command = "checktime",
})
-- Показ статуса LSP в title bar
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.cmd("hi def link LspReferenceText IncSearch")
    end
  end,
})
-- Орфография
vim.api.nvim_create_autocmd("VimEnter", {
  -- pattern = { "gitcommit", "markdown", "text", "rst", "tex" },
  callback = function()
    vim.opt.spell = true
    vim.opt.spelllang = { "ru", "en" }
    vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/local.add"
  end,
})

-- Отключить spell для бинарных и нетекстовых файлов
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "json", "yaml", "toml", "xml", "html", "css", "lua", "vim" },
--   callback = function()
--     vim.opt_local.spell = false
--   end,
-- })

-- Отключаем автоформатирование при сохранении (:w) для YAML
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.b.autoformat = false
  end,
})
