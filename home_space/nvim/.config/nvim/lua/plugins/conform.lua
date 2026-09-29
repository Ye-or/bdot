return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Убираем CLI-форматтеры для YAML
      opts.formatters_by_ft.yaml = nil
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if opts.servers.yamlls then
        opts.servers.yamlls.settings = opts.servers.yamlls.settings or {}
        opts.servers.yamlls.settings.yaml = opts.servers.yamlls.settings.yaml or {}

        -- ВКЛЮЧАЕМ форматирование в LSP, иначе он не будет реагировать на ручные запросы
        opts.servers.yamlls.settings.yaml.format = { enable = true }
      end
      return opts
    end,
  },
}
