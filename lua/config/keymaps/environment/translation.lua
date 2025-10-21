--- Translation Keymaps
--- Namespace: <leader>tf (French), <leader>tt (Tamil), <leader>ts (Sinhala)
--- @module config.keymaps.environment.translation

local registry = require("config.keymaps")

local keymaps = {
  { "<leader>tf", "<cmd>Translate fr<CR>", desc = "🇫🇷 Translate French" },
  { "<leader>tt", "<cmd>Translate ta<CR>", desc = "🇮🇳 Translate Tamil" },
  { "<leader>ts", "<cmd>Translate si<CR>", desc = "🇱🇰 Translate Sinhala" },
}

return registry.register_module("environment.translation", keymaps)
