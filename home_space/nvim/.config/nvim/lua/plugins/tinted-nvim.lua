return {
  "tinted-theming/tinted-nvim",
  priority = 1000, -- load colorscheme early
  lazy = false, -- apply on startup
  opts = {
    --default_scheme = "base16-grayscale-dark", -- pick any bundled Base16/Base24
    apply_scheme_on_startup = true, -- default `true`
    compile = true, -- default `false`
    custom_schemes_dir = "~/.local/share/tinted-theming/tinty/custom-schemes/",
    selector = {
      enabled = true, -- default `false`

      -- "file" | "env" | "cmd"
      mode = "file", -- default `file`

      -- Expects a file that only contains the scheme name.
      path = "~/.local/share/tinted-theming/tinty/current_scheme", -- default ` "~/.local/share/tinted-theming/tinty/current_scheme"`

      -- Reads the scheme name from an environment variable.
      env = "TINTED_THEME", -- default `"TINTED_THEME"`

      -- Executes a command that returns the scheme name.
      cmd = "tinty current", -- default `"tinty current"`

      -- In "file" mode: watch the file, and reload the scheme on changes.
      watch = true, -- default `true`
    },
  },
  -- External scheme selector (resolves scheme names only).
}
