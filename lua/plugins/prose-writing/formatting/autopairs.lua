-- Plugin: nvim-autopairs
-- Purpose: Auto-close brackets, quotes, parentheses during insert mode
-- Workflow: prose-writing
-- Why: Error prevention and flow maintenance - automatically inserts closing pairs
--      reducing syntax errors and maintaining writing flow. ADHD-optimized through
--      reduced interruptions (no manual closing), predictable behavior (always pairs),
--      and smart context awareness (doesn't pair inside strings/comments inappropriately).
--      Critical for maintaining hyperfocus during rapid note-taking or coding.
-- Config: minimal
--
-- Usage:
--   Automatic - type opening character (, [, {, ", ' and closing pair is inserted
--   <CR> - Smart newline between pairs (indent, cursor positioning)
--   <BS> - Delete both pairs if immediately after opening
--
-- Dependencies:
--   none (integrates with nvim-cmp if available)
--
-- Configuration Notes:
--   Zero-config default behavior works for most cases. Lazy-loads on InsertEnter to
--   minimize startup impact. Integrates with nvim-cmp for completion-aware pairing.
--   Handles markdown code blocks, LaTeX delimiters, and prose quotes intelligently.

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {}, -- this is equalent to setup({}) function
}
