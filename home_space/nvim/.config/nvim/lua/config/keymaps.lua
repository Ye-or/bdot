-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>rn", ":IncRename ")
--vim.keymap.set("n", "<leader>rn", function()
--  return ":IncRename " .. vim.fn.expand("<cword>")
--end, { expr = true })
--<Plug>MarkdownPreview
--<Plug>MarkdownPreviewStop
--<Plug>MarkdownPreviewToggle
-- Назначаем <leader>fm (Пробел + f + m) для ручного форматирования
-- Назначаем <leader>fm (Пробел + f + m) для ручного форматирования через LSP
-- Назначаем <leader>fm для ручного форматирования через LSP
vim.keymap.set("n", "<leader>fm", function()
  -- Вызываем нативное форматирование Neovim через подключенный LSP
  vim.lsp.buf.format({
    async = true,
    -- Убедимся, что форматирует только текущий буфер
    filter = function(client)
      return client.name == "yamlls"
    end,
  })
end, { desc = "Format YAML (LSP)" })
