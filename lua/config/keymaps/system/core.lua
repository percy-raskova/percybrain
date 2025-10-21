-- Core Vim Keymaps
-- Namespace: <leader> + single letters (basic operations)
--
-- FREQUENCY-BASED OPTIMIZATION (2025-10-21 Phase 2):
-- <leader>n now reserved for "New note" (most frequent writer action)
-- Line number toggle moved to <leader>vn (view numbers - less frequent)
--
-- DESIGN RATIONALE:
-- Writers toggle line numbers 1-2 times per session.
-- Writers create new notes 50+ times per session.
-- Shorter keys = higher frequency operations (speed of thought).

local registry = require("config.keymaps")

local keymaps = {
  -- File operations
  { "<leader>s", "<cmd>w!<CR>", desc = "💾 Save file" },
  { "<leader>q", "<cmd>q!<CR>", desc = "🚪 Quit" },
  { "<leader>c", "<cmd>close<CR>", desc = "❌ Close window" },

  -- Splits
  { "<leader>v", "<cmd>vsplit<CR>", desc = "⚡ Vertical split" },

  -- View toggles (moved from <leader>n to avoid conflict with new note)
  {
    "<leader>vn",
    function()
      vim.opt.number = not vim.opt.number:get()
      vim.opt.relativenumber = not vim.opt.relativenumber:get()
    end,
    desc = "🔢 Toggle line numbers",
  },

  -- Plugin management
  { "<leader>L", "<cmd>Lazy<CR>", desc = "🔌 Lazy plugin manager" },

  -- WhichKey
  { "<leader>W", "<cmd>WhichKey<CR>", desc = "❓ WhichKey help" },
}

return registry.register_module("core", keymaps)
