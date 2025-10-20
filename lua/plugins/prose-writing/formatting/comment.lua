-- Plugin: Comment.nvim
-- Purpose: Smart code and prose commenting with context awareness
-- Workflow: prose-writing
-- Why: Efficiency and consistency - provides fast commenting operations with
--      context-aware behavior (understands different comment styles for different
--      filetypes). ADHD-optimized through predictable keybindings (gc prefix),
--      visual feedback, and one-key toggle behavior. Essential for temporarily
--      disabling sections in notes, config files, and code snippets during
--      experimentation or draft writing.
-- Config: minimal
--
-- Usage:
--   gcc - Toggle line comment
--   gbc - Toggle block comment
--   gc{motion} - Comment using motion (gcap = comment paragraph)
--   gc (visual) - Comment selection
--   gb (visual) - Block comment selection
--
-- Dependencies:
--   none
--
-- Configuration Notes:
--   Zero-config default supports 30+ languages. Understands markdown comments (HTML),
--   LaTeX comments (%), Lua comments (--), and context-switches automatically.
--   Integrates with nvim-ts-context-commentstring for mixed-language files.

return {
  "numToStr/Comment.nvim",
  opts = {},
  lazy = false,
}
