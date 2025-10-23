-- Note Creation Keymaps
-- Namespace: <leader>n (notes)
--
-- DESIGN RATIONALE:
-- Note creation is separated from navigation (IWE LSP in <leader>z).
-- Writers create notes 50+ times per session - deserves dedicated namespace.
-- <leader>n = quick note creation for "speed of thought" workflow.
--
-- ARCHITECTURE:
-- - <leader>n* = Note creation/templates
-- - <leader>z* = IWE LSP navigation/refactoring (see iwe.lua)
-- - <leader>h* = Publishing/static site (see hugo.lua)

local registry = require("config.keymaps")

local keymaps = {
  -- ========================================================================
  -- NOTE CREATION (<leader>n* prefix)
  -- ========================================================================

  -- Quick note (most frequent operation - single key after leader)
  {
    "<leader>n",
    function()
      require("config.zettelkasten").new_note()
    end,
    desc = "📝 New note (quick)",
  },

  -- Note types with templates
  {
    "<leader>nn",
    function()
      require("config.zettelkasten").new_note()
    end,
    desc = "📝 New note (with template)",
  },
  {
    "<leader>nd",
    function()
      require("config.zettelkasten").daily_note()
    end,
    desc = "📅 Daily note",
  },
  {
    "<leader>ni",
    function()
      require("config.zettelkasten").inbox_note()
    end,
    desc = "📥 Inbox capture",
  },

  -- ========================================================================
  -- KNOWLEDGE GRAPH ANALYSIS (<leader>n* prefix)
  -- ========================================================================

  { "<leader>no", "<cmd>PercyOrphans<cr>", desc = "🏝️  Find orphan notes" },
  { "<leader>nh", "<cmd>PercyHubs<cr>", desc = "🌟 Find hub notes" },

  -- ========================================================================
  -- BROWSING & DISCOVERY (<leader>n* prefix)
  -- ========================================================================

  {
    "<leader>nt",
    function()
      require("config.zettelkasten").show_tags()
    end,
    desc = "🏷️  Browse tags",
  },
  {
    "<leader>nc",
    function()
      require("config.zettelkasten").show_calendar()
    end,
    desc = "📅 Calendar picker",
  },
}

return registry.register_module("workflows.notes", keymaps)
