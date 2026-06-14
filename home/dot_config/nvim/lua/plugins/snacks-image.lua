-- Enable Snacks.image: inline image rendering in Neovim. Ghostty speaks the
-- kitty graphics protocol, so raster images (png/jpg/svg/...) render directly.
-- PDF previews use ghostscript (`gs`), installed via the brew bundle. LaTeX and
-- Mermaid stay off (their renderers aren't installed). :checkhealth snacks
return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = true },
  },
}
