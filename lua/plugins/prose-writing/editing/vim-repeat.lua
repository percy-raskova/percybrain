-- Plugin: vim-repeat
-- Purpose: Enable dot-repeat (.) for plugin mappings like surround, commentary
-- Workflow: prose-writing
-- Why: Consistency and muscle memory optimization - makes plugin commands repeatable
--      with the standard Vim '.' operator, reducing cognitive load by maintaining
--      predictable behavior across all editing operations. Essential for building
--      reliable muscle memory patterns with plugins like nvim-surround.
-- Config: none
--
-- Usage:
--   . (dot) - Repeat last supported plugin command (e.g., cs"', ds", ysiw])
--
-- Dependencies:
--   none
--
-- Configuration Notes:
--   Zero-config library plugin that extends '.' repeat behavior to compatible plugins.
--   Works automatically with nvim-surround, vim-commentary, and other Tim Pope plugins.
--   No user-facing commands - pure infrastructure enhancement.

return {
  "tpope/vim-repeat",
  event = "VeryLazy",
}
