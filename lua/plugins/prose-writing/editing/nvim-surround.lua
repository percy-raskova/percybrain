-- Plugin: nvim-surround
-- Purpose: Surround text with quotes, brackets, tags - fast pair manipulation
-- Workflow: prose-writing
-- Why: Efficiency and error prevention - dramatically reduces keystrokes for common
--      formatting operations (adding quotes, changing brackets, deleting parens).
--      ADHD-optimized through predictable mnemonic operators (ys=you surround,
--      cs=change surround, ds=delete surround) that build reliable muscle memory.
--      Critical for markdown formatting (**bold**, _italic_, `code`) and academic
--      citations.
-- Config: minimal
--
-- Usage:
--   ysiw" - Surround word with quotes: word → "word"
--   cs"' - Change quotes: "word" → 'word'
--   ds" - Delete quotes: "word" → word
--   yss) - Surround line with parens
--   S<tag> (visual) - Surround selection with tag
--
-- Dependencies:
--   none (vim-repeat recommended for '.' repeat support)
--
-- Configuration Notes:
--   Zero-config by design - works with default mappings. Supports dot-repeat with
--   vim-repeat plugin. Handles nested surroundings, multi-line selections, and
--   custom surroundings. Fast, Lua-native reimplementation of vim-surround.

return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
