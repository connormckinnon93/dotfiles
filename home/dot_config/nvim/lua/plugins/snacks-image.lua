-- Enable Snacks.image: inline image rendering in Neovim. Ghostty speaks the
-- kitty graphics protocol, so raster images (png/jpg/svg/...) render directly.
-- Snacks turns on document (`doc`) and math rendering by default, so once the
-- renderers are on PATH everything just works: PDF previews via ghostscript
-- (`gs`), LaTeX math via tectonic + ImageMagick (`magick`), and Mermaid
-- diagrams via `mmdc` (installed through mise). All provisioned by the brew
-- bundle / mise config. Verify with :checkhealth snacks
return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = true },
  },
}
