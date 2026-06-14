-- Extra Treesitter parsers beyond LazyVim's defaults. `latex` lets
-- Snacks.image locate LaTeX math expressions to render (paired with the
-- tectonic engine). Add others here (css, scss, vue, ...) if you want images
-- embedded inside those document types too.
return {
  "nvim-treesitter/nvim-treesitter",
  opts = { ensure_installed = { "latex" } },
}
