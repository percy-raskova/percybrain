-- Zettelkasten Keymaps
-- Namespace: <leader>z (zettelkasten)
--
-- FREQUENCY-BASED OPTIMIZATION (2025-10-21 Phase 2):
-- <leader>n = Single-key shortcut for new note (most frequent writer action)
-- <leader>zn = Detailed new note with options (less frequent)
--
-- DESIGN RATIONALE:
-- Writers create notes 50+ times per session - deserves shortest possible key.
-- Quick note creation removes friction from "speed of thought" workflow.

local registry = require("config.keymaps")

local keymaps = {
  -- OPTIMIZED: Single-key new note (most frequent operation)
  {
    "<leader>n",
    function()
      require("config.zettelkasten").new_note()
    end,
    desc = "📝 New note (quick)",
  },

  -- Note creation (using config.zettelkasten module)
  {
    "<leader>zn",
    function()
      require("config.zettelkasten").new_note()
    end,
    desc = "📝 New note (with options)",
  },
  {
    "<leader>zd",
    function()
      require("config.zettelkasten").daily_note()
    end,
    desc = "📅 Daily note",
  },
  {
    "<leader>zi",
    function()
      require("config.zettelkasten").inbox_note()
    end,
    desc = "📥 Inbox note",
  },

  -- Note navigation (using config.zettelkasten module)
  {
    "<leader>zf",
    function()
      require("config.zettelkasten").find_notes()
    end,
    desc = "🔍 Find notes",
  },
  {
    "<leader>zg",
    function()
      require("config.zettelkasten").search_notes()
    end,
    desc = "🔎 Search notes content",
  },
  {
    "<leader>zb",
    function()
      require("config.zettelkasten").backlinks()
    end,
    desc = "🔗 Show backlinks",
  },

  -- Knowledge graph analysis
  { "<leader>zo", "<cmd>PercyOrphans<cr>", desc = "🏝️  Find orphan notes" },
  { "<leader>zh", "<cmd>PercyHubs<cr>", desc = "🌟 Find hub notes" },

  -- Publishing
  {
    "<leader>zp",
    function()
      require("config.zettelkasten").publish()
    end,
    desc = "🚀 Publish to Hugo",
  },

  -- Telekasten integration (if using)
  { "<leader>zt", "<cmd>Telekasten show_tags<cr>", desc = "🏷️  Show tags" },
  { "<leader>zc", "<cmd>Telekasten show_calendar<cr>", desc = "📅 Show calendar" },
  { "<leader>zl", "<cmd>Telekasten follow_link<cr>", desc = "🔗 Follow link" },
  { "<leader>zk", "<cmd>Telekasten insert_link<cr>", desc = "➕ Insert link" },
}

return registry.register_module("zettelkasten", keymaps)
