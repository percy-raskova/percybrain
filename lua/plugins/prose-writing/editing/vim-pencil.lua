-- Plugin: vim-pencil
-- Purpose: Prose-optimized text behavior (soft wrapping, sentence navigation, formatting)
-- Workflow: prose-writing/editing
-- Why: Transforms Neovim's code-centric editing into prose-friendly behavior. Soft wrapping at word
--      boundaries (not hard line breaks) improves readability. Sentence-aware motion commands (e.g., ")")
--      match how writers think. Auto-formatting and punctuation handling reduce friction in writing flow.
--      Essential for natural prose creation vs. code editing.
-- Config: none (activates via FileType autocmd or manual :Pencil command)
--
-- Usage:
--   :Pencil - Enable pencil mode manually
--   :PencilSoft - Soft wrap mode (default for prose)
--   :PencilHard - Hard wrap mode (for formats requiring line breaks)
--   :PencilToggle - Switch between modes
--   :PencilOff - Disable pencil mode
--
-- Dependencies: none (pure Vim plugin)
--
-- Configuration Notes:
--   - Typically auto-enabled via FileType autocmd for markdown, text files
--   - Soft wrap: Display wrapping without inserting newlines (readable, git-friendly)
--   - Hard wrap: Inserts newlines at textwidth (for email, legacy formats)
--   - Works with vim-textobj-sentence for semantic navigation
--   - Configurable via lua/config/options.lua autocmds

return {
  "reedes/vim-pencil",
}
