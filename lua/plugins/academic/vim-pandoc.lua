-- Vim-Pandoc: Pandoc document integration
-- Lazy-loaded: Only for markdown and pandoc filetypes
-- Features: Pandoc conversion, bibliography, citation support
return {
  "vim-pandoc/vim-pandoc",
  dependencies = {
    "vim-pandoc/vim-pandoc-syntax",
  },
  ft = { "markdown", "pandoc", "rst" },
}
