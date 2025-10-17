return {
  "preservim/vim-textobj-sentence",
  dependencies = { "kana/vim-textobj-user" },
  ft = { "markdown", "text", "tex", "org" },
  config = function()
    vim.g.textobj_sentence_no_default_key_mappings = 1
    vim.keymap.set({ "n", "x", "o" }, "as", "<Plug>TextobjSentenceA")
    vim.keymap.set({ "n", "x", "o" }, "is", "<Plug>TextobjSentenceI")
  end,
}
