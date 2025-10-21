-- Dashboard Keymaps
-- Namespace: <leader>d (dashboard)

local registry = require("config.keymaps")

local keymaps = {
  -- Alpha dashboard
  { "<leader>da", "<cmd>Alpha<CR>", desc = "🏠 Alpha dashboard" },
}

return registry.register_module("dashboard", keymaps)
