-- Plugin: Zen Mode
-- Purpose: Distraction-free writing by hiding UI elements and centering content
-- Workflow: prose-writing/distraction-free
-- Why: Critical for ADHD hyperfocus - removes visual distractions (statusline, sidebars, line numbers)
--      to create a calm writing environment. Centering text reduces eye movement. Enables deep
--      focus on content creation without interface noise. Perfect for long-form writing sessions.
-- Config: minimal (uses default distraction-free settings)
--
-- Usage:
--   :ZenMode - Toggle zen mode on/off
--   Automatically called by QuickNote helper (Telekasten integration)
--   Works with auto-save to protect work during deep focus
--
-- Dependencies: none (pure Neovim plugin)
--
-- Configuration Notes:
--   - Default config removes all visual noise (no line numbers, statusline, etc.)
--   - Content is centered for reduced eye strain
--   - Can be customized in opts table for window size, backdrop darkness
--   - Integrates with other UI plugins (auto-disables incompatible features)

return {
  "folke/zen-mode.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
