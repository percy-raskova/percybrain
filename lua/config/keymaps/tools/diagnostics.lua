-- Diagnostics Keymaps
-- Namespace: <leader>x (diagnostics/errors)

local registry = require("config.keymaps")

local keymaps = {
  -- Trouble diagnostics (main interface)
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "🚨 Toggle diagnostics" },
  { "<leader>xd", "<cmd>Trouble diagnostics filter.buf=0<cr>", desc = "📋 Buffer diagnostics" },
  { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "🔤 Symbols (Trouble)" },
  { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "🔍 LSP definitions/references" },
  { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "📍 Location list" },
  { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "🔖 Quickfix list" },
}

return registry.register_module("diagnostics", keymaps)
