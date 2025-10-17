-- PercyBrain Plugin Loader
-- Uses lazy.nvim import to load from all workflow subdirectories

return {
  -- Core utilities that need early loading
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },

  -- Import all plugins from subdirectories
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  { import = "plugins.prose-writing.distraction-free" },
  { import = "plugins.prose-writing.editing" },
  { import = "plugins.prose-writing.formatting" },
  { import = "plugins.prose-writing.grammar" },
  { import = "plugins.academic" },
  { import = "plugins.publishing" },
  { import = "plugins.org-mode" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.ui" },
  { import = "plugins.navigation" },
  { import = "plugins.utilities" },
  { import = "plugins.treesitter" },
  { import = "plugins.lisp" },
  { import = "plugins.experimental" },
}
