-- Plugin: GTD (Getting Things Done)
-- Purpose: Keybindings for GTD workflow (Capture, Clarify, Organize, Reflect, Engage)
-- Workflow: organization/productivity
-- Why: Implements David Allen's GTD methodology for trusted productivity system.
--      Reduces mental load by capturing everything, clarifying actionability,
--      organizing by context, reflecting weekly, and engaging with confidence.
-- Config: minimal - just keybindings for percybrain.gtd modules
--
-- Usage:
--   <leader>oc - Quick capture to inbox
--   <leader>op - Process inbox (clarify workflow)
--   <leader>oi - View inbox count
--
-- GTD Phases:
--   1. Capture: Collect everything (inbox)
--   2. Clarify: Process into actionable outcomes
--   3. Organize: Put in appropriate lists/contexts
--   4. Reflect: Weekly review to stay current
--   5. Engage: Do work with confidence
--
-- Dependencies:
--   - percybrain.gtd (core GTD modules)
--   - percybrain.gtd.capture (quick capture functionality)
--   - percybrain.gtd.clarify_ui (interactive clarify workflow)

return {
  -- Virtual plugin for GTD keybindings
  -- No actual plugin to load, just keybindings for percybrain.gtd modules
  dir = vim.fn.stdpath("config") .. "/lua/percybrain/gtd",
  name = "percybrain-gtd",
  lazy = false, -- Load immediately to register keybindings
  -- TODO: Add GTD keybindings here using keys = {} spec
  -- keys = {},
}
