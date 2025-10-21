-- Core Vim Keymaps
-- Namespace: <leader> + single letters (basic operations)

local registry = require("config.keymaps")

local keymaps = {
  -- File operations
  { "<leader>s", "<cmd>w!<CR>", desc = "💾 Save file" },
  { "<leader>q", "<cmd>q!<CR>", desc = "🚪 Quit" },
  { "<leader>c", "<cmd>close<CR>", desc = "❌ Close window" },

  -- Splits
  { "<leader>v", "<cmd>vsplit<CR>", desc = "⚡ Vertical split" },

  -- Line numbers toggle
  { "<leader>n", "<cmd>set number relativenumber cursorline<CR>", desc = "🔢 Show line numbers" },
  { "<leader>rn", "<cmd>set nonumber norelativenumber<CR>", desc = "🙈 Hide line numbers" },

  -- Plugin management
  { "<leader>L", "<cmd>Lazy<CR>", desc = "🔌 Lazy plugin manager" },

  -- WhichKey
  { "<leader>W", "<cmd>WhichKey<CR>", desc = "❓ WhichKey help" },
}

return registry.register_module("core", keymaps)
