-- Vim-Pandoc: Pandoc document integration
-- Lazy-loaded: Only for markdown and pandoc filetypes
-- Features: Pandoc conversion, bibliography, citation support
return {
  "vim-pandoc/vim-pandoc",
  dependencies = {
    "vim-pandoc/vim-pandoc-syntax",
  },
  ft = { "markdown", "pandoc", "rst" },
  config = function()
    -- Disable default keybindings (they have ugly names in which-key)
    vim.g["pandoc#keyboard#enabled_submodules"] = {}

    -- Disable specific keyboard modules to prevent ugly which-key entries
    vim.g["pandoc#modules#disabled"] = { "keyboard" }
  end,
}
