-- Telescope Keymaps
-- Namespace: <leader>f (find/search)
--
-- FREQUENCY-BASED OPTIMIZATION (2025-10-21 Phase 2):
-- Writers find NOTES far more frequently than generic files.
-- <leader>f now prioritizes Zettelkasten notes (most frequent operation)
-- <leader>ff finds files anywhere (less frequent, longer combo)
--
-- DESIGN RATIONALE:
-- - <leader>f = Find notes (50+ times/session)
-- - <leader>ff = Find files (5-10 times/session)
-- - Shorter keys = higher frequency operations (speed of thought)

local registry = require("config.keymaps")

local keymaps = {
  -- OPTIMIZED: Find notes FIRST (most frequent for writers)
  {
    "<leader>f",
    function()
      require("telescope.builtin").find_files({
        prompt_title = "Find Notes",
        cwd = vim.fn.expand("~/Zettelkasten"),
        hidden = false,
      })
    end,
    desc = "🔍 Find notes (Zettelkasten)",
  },

  -- Generic file finding (less frequent, longer combo)
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "📁 Find files (filesystem)" },

  -- Content search
  { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "🔎 Search content" },

  -- Buffer and utility searches
  { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "📝 Switch buffers" },
  { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "📖 Search help" },
  { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "🔑 Browse keymaps" },
  { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "📜 Recent files" },
  { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "⌨️  Commands" },
}

return registry.register_module("telescope", keymaps)
