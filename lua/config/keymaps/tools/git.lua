-- Git Keymaps
-- Namespace: <leader>g (git - writer-focused essentials)
--
-- WRITER-FIRST PHILOSOPHY:
-- Most writers use GUI tools (LazyGit) for complex operations.
-- Keybindings reduced to 6-8 essential operations writers actually use.
-- Advanced operations available via LazyGit GUI.
--
-- DESIGN CHANGES (2025-10-21):
-- - Reduced from 20+ to 8 essential operations
-- - Removed: Diffview sub-namespace (use LazyGit GUI instead)
-- - Removed: Advanced hunk operations (use LazyGit GUI instead)
-- - Kept: Status, commit, push, blame, log, and hunk navigation
-- - Primary workflow: LazyGit GUI for everything complex

local registry = require("config.keymaps")

local keymaps = {
  -- ========================================================================
  -- PRIMARY INTERFACE: LazyGit GUI
  -- ========================================================================
  -- Writers should use LazyGit for all complex git operations
  -- It provides visual interface for diffs, staging, history, etc.

  { "<leader>gg", "<cmd>LazyGit<cr>", desc = "🌿 LazyGit GUI (primary)" },

  -- ========================================================================
  -- ESSENTIAL OPERATIONS: Quick access without GUI
  -- ========================================================================
  -- These 6 operations are frequent enough to warrant direct keybindings

  { "<leader>gs", "<cmd>Git<cr>", desc = "📊 Git status" },
  { "<leader>gc", "<cmd>Git commit<cr>", desc = "💾 Git commit" },
  { "<leader>gp", "<cmd>Git push<cr>", desc = "⬆️  Git push" },
  { "<leader>gb", "<cmd>Git blame<cr>", desc = "👤 Git blame" },
  { "<leader>gl", "<cmd>Git log<cr>", desc = "📜 Git log" },

  -- ========================================================================
  -- HUNK OPERATIONS: Review writing changes
  -- ========================================================================
  -- Writers benefit from seeing paragraph/section changes (hunks)
  -- Navigation and preview useful for reviewing edits

  { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "👁️  Preview hunk" },
  { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "➕ Stage hunk" },
  { "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "↩️  Undo stage" },
  { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "⬇️  Next hunk" },
  { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "⬆️  Previous hunk" },
}

return registry.register_module("git", keymaps)
