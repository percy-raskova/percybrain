-- Plugin: toggleterm
-- Purpose: Persistent terminal windows with toggle/multi-terminal support
-- Workflow: utilities
-- Why: Seamless terminal integration - provides persistent terminal buffers that
--      toggle on/off without losing state, reducing context switching overhead.
--      ADHD-optimized through quick toggle keybinding (instant access), state
--      persistence (don't lose running processes), and multiple terminal support
--      (separate contexts for different tasks). Critical for running Hugo dev server,
--      Git operations, and shell commands without leaving editor.
-- Config: minimal
--
-- Usage:
--   Default toggle (configure with keys = {})
--   <C-\> (in terminal) - Toggle terminal window
--   Multiple terminals: :ToggleTerm 1, :ToggleTerm 2, etc.
--   :TermExec cmd="..." - Execute command in terminal
--
-- Dependencies:
--   none
--
-- Configuration Notes:
--   Zero-config default provides basic toggle terminal. Recommended to add keybinding
--   configuration for <C-\> toggle. Terminals persist across toggles (processes keep
--   running). Supports horizontal/vertical/float layouts. Integrates well with
--   lazygit.nvim for visual Git interface in terminal.

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = true,
}
