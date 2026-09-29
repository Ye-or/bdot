return {
  {
    "https://gitlab.com/itaranto/preview.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "aklt/plantuml-syntax",
    },
    opts = {
      previewers_by_ft = {
        plantuml = {
          --name = "plantuml_text",
          --renderer = { type = "buffer" },
          name = "plantuml_svg",
          renderer = {
            type = "command",
            opts = {
              cmd = { "sh", "-c", "DISPLAY=:0 feh" },
            },
          },
        },
      },
      previewers = {
        plantuml_svg = {
          args = { "-headless", "-pipe", "-tpng" },
        },
      },

      render_on_write = true,
    },
  },
}
