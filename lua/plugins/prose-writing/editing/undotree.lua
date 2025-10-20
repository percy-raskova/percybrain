-- Plugin: Undotree
-- Purpose: Visual undo history tree for branching undo exploration
-- Workflow: prose-writing
-- Why: ADHD-optimized error recovery - visualizes undo history as a tree structure,
--      allowing exploration of different editing branches without fear of losing work.
--      Critical safety net for hyperfocus sessions where you might explore multiple
--      directions and need to backtrack. Reduces anxiety about experimentation by
--      making all edit history recoverable.
-- Config: minimal
--
-- Usage:
--   <leader>u - Toggle undo tree visualization
--   j/k - Navigate through history states
--   <Enter> - Restore selected state
--
-- Dependencies:
--   none
--
-- Configuration Notes:
--   Lazy-loads on command to minimize startup impact. Tree visualization shows
--   timestamp, file state, and branch structure. All states persist until file
--   rewritten, providing complete session history.

return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
}
