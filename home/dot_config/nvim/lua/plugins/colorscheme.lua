-- Catppuccin Mocha: the Neovim port, matching the terminal/prompt/rest of the
-- stack. flavour is pinned to mocha (no system/background following).
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },
  -- Use it as LazyVim's colorscheme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
