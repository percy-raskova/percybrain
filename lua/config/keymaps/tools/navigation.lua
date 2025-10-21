-- Navigation Keymaps
-- Namespace: <leader>e (explorer), <leader>y (yazi)

local registry = require("config.keymaps")

local keymaps = {
  -- NvimTree file explorer
  { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "🌳 Toggle file tree" },
  { "<leader>x", "<cmd>NvimTreeFocus<CR>", desc = "🎯 Focus file tree" },

  -- Yazi file manager
  { "<leader>y", "<cmd>Yazi<cr>", desc = "📁 Open Yazi file manager" },

  -- FzfLua (alternative finder)
  { "<leader>fzl", "<cmd>FzfLua files<CR>", desc = "🔍 FzfLua files" },
  { "<leader>fzg", "<cmd>FzfLua live_grep<CR>", desc = "🔎 FzfLua grep" },
  { "<leader>fzm", "<cmd>FzfLua marks<CR>", desc = "🔖 FzfLua marks" },
}

return registry.register_module("navigation", keymaps)
