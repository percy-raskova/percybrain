-- Plugin: vim-textobj-sentence
-- Purpose: Prose-aware sentence text objects for natural writing navigation
-- Workflow: prose-writing
-- Why: Prose optimization - provides intelligent sentence detection that handles
--      abbreviations (Dr., Mrs., etc.) and multi-sentence formatting correctly,
--      unlike Vim's default sentence motion. Enables natural "operate on sentence"
--      workflows (delete sentence, change sentence, yank sentence) critical for
--      academic writing and note refinement. Reduces frustration with Vim's
--      default sentence handling which breaks on common prose patterns.
-- Config: minimal
--
-- Usage:
--   as - Select around sentence (includes trailing space)
--   is - Select inner sentence (text only)
--   Works with operators: das (delete sentence), cis (change sentence), yas (yank)
--
-- Dependencies:
--   kana/vim-textobj-user (text object framework)
--
-- Configuration Notes:
--   Lazy-loads on prose filetypes (markdown, text, tex, org). Disables default
--   mappings to avoid conflicts, uses explicit as/is bindings. Smarter than default
--   Vim sentence motion - handles abbreviations, quotes, parentheses correctly.

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
