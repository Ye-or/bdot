-- ~/.config/nvim/lua/plugins/yazi.lua
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- Использовать последнюю стабильную версию
  event = "VeryLazy", -- Ленивая загрузка для ускорения старта Neovim
  dependencies = {
    "nvim-lua/plenary.nvim", -- Требуемая зависимость для работы с процессами
  },
  keys = {
    {
      "<leader>-",
      "<cmd>Yazi<cr>",
      desc = "Yazi: открыть в директории текущего файла",
    },
    {
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Yazi: открыть в корневой директории проекта (cwd)",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Yazi: восстановить последнюю сессию",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- Заменить стандартный netrw для открытия директорий (рекомендуется)
    open_for_directories = true,

    -- Настройки плавающего окна для эргономики
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    yazi_floating_window_winblend = 0,

    -- Минималистичный набор хоткеев внутри Yazi
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      send_to_quickfix_list = "<c-q>",
      -- Если используете telescope.nvim или fzf-lua, <c-s> запустит grep по текущей директории
      grep_in_directory = "<c-s>",
    },
  },
  init = function()
    -- Явно отключаем netrw, чтобы он не перехватывал открытие директорий
    -- и не конфликтовал с yazi.nvim
    vim.g.loaded_netrwPlugin = 1
  end,
}
