-- tinted-nvim: base16/base24 colorscheme that follows the active tinty scheme.
-- It watches tinty's current_scheme file, so `tinty apply <scheme>` recolors
-- Neovim live to match the terminal/prompt/etc.
return {
  {
    "tinted-theming/tinted-nvim",
    lazy = false,
    priority = 1000,
    opts = {
      default_scheme = "base24-catppuccin-mocha",
      selector = {
        enabled = true,
        mode = "file",
        path = vim.fn.expand("~/.local/share/tinted-theming/tinty/current_scheme"),
        watch = true,
      },
    },
  },
  -- Use it as LazyVim's colorscheme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "base24-catppuccin-mocha",
    },
  },
}
