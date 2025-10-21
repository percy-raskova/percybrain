-- Quick Capture Keymaps
-- Namespace: <leader>zq (zettelkasten quick capture - consolidated)
--
-- DESIGN CHANGE (2025-10-21 Phase 1):
-- Moved from <leader>qc to <leader>zq for writer-first consolidation.
-- All Zettelkasten operations now unified under <leader>z* namespace.
-- Mnemonic: z=zettelkasten, q=quick capture
--
-- FREQUENCY-BASED OPTIMIZATION (2025-10-21 Phase 2):
-- <leader>i = Single-key shortcut for quick capture (very frequent)
-- <leader>zq = Still available for discoverability via Which-Key
--
-- DESIGN RATIONALE:
-- Writers capture fleeting thoughts 20+ times per session.
-- Single-key access removes friction from rapid ideation workflow.
--
-- NOTE: <leader>zi already used for inbox_note() - different workflow
-- Quick capture (<leader>i) = floating window for rapid thoughts
-- Inbox note (<leader>zi) = create new inbox file in Zettelkasten

local registry = require("config.keymaps")

local keymaps = {
  -- OPTIMIZED: Single-key quick capture (very frequent operation)
  {
    "<leader>i",
    function()
      require("percybrain.floating-quick-capture").open_capture_window()
    end,
    desc = "📥 Inbox capture (quick)",
  },

  -- Floating quick capture (consolidated into zettelkasten namespace)
  {
    "<leader>zq",
    function()
      require("percybrain.floating-quick-capture").open_capture_window()
    end,
    desc = "⚡ Quick capture (floating)",
  },
}

return registry.register_module("quick-capture", keymaps)
