-- Git Keymaps
-- Namespace: <leader>g (git)

local registry = require("config.keymaps")

local keymaps = {
  -- LazyGit (main GUI interface)
  { "<leader>gg", "<cmd>LazyGit<cr>", desc = "🌿 LazyGit GUI" },

  -- Fugitive (core git operations)
  { "<leader>gs", "<cmd>Git<cr>", desc = "📊 Git status" },
  { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "🔀 Git diff split" },
  { "<leader>gb", "<cmd>Git blame<cr>", desc = "👤 Git blame" },
  { "<leader>gc", "<cmd>Git commit<cr>", desc = "💾 Git commit" },
  { "<leader>gp", "<cmd>Git push<cr>", desc = "⬆️  Git push" },
  { "<leader>gl", "<cmd>Git pull<cr>", desc = "⬇️  Git pull" },
  { "<leader>gL", "<cmd>Git log<cr>", desc = "📜 Git log" },

  -- Diffview (enhanced diff visualization)
  { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "👁️  Open diff view" },
  { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "❌ Close diff view" },
  { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "📅 File history" },
  { "<leader>gdf", "<cmd>DiffviewFileHistory<cr>", desc = "🌲 Full history" },

  -- Gitsigns (hunk operations)
  { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "👁️  Preview hunk" },
  { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "➕ Stage hunk" },
  { "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "↩️  Undo stage hunk" },
  { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "🔄 Reset hunk" },
  { "<leader>ghb", "<cmd>Gitsigns blame_line<cr>", desc = "👤 Blame line" },

  -- Gitsigns navigation
  { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "⬇️  Next hunk" },
  { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "⬆️  Previous hunk" },
}

return registry.register_module("git", keymaps)
