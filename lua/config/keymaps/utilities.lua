-- Utilities Keymaps
-- Namespace: various utility tools (undotree, mcp-marketplace)

local registry = require("config.keymaps")

local keymaps = {
  -- Undotree (visual undo history)
  { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "🌳 Undo tree" },

  -- MCP Hub (Model Context Protocol server management)
  { "<leader>mh", "<cmd>MCPHub<cr>", desc = "🛍️  MCP Hub" },
  { "<leader>mo", "<cmd>MCPHubOpen<cr>", desc = "📖 MCP Open" },
  { "<leader>mi", "<cmd>MCPHubInstall<cr>", desc = "📥 MCP Install" },
  { "<leader>ml", "<cmd>MCPHubList<cr>", desc = "📋 MCP List" },
  { "<leader>mu", "<cmd>MCPHubUpdate<cr>", desc = "🔄 MCP Update" },
}

return registry.register_module("utilities", keymaps)
