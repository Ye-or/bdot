return {
  {
    "LazyVim/LazyVim",
    --opts = {
    --  colorscheme = "base16-grayscale-dark",
    --},
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tinted",
        icons_enabled = false,
        section_separators = "",
        component_separators = "",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          cmd = { "/usr/bin/rust-analyzer" },
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
            },
          },
        },
      },
    },
  },
}
