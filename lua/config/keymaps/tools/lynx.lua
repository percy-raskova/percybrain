-- Lynx Browser Keymaps
-- Namespace: <leader>l (lynx/browser)

local registry = require("config.keymaps")

local keymaps = {
  -- Lynx browser operations
  { "<leader>lo", "<cmd>LynxOpen<cr>", desc = "🌐 Open URL in Lynx" },
  { "<leader>le", "<cmd>LynxExport<cr>", desc = "📤 Export page to Wiki" },
  { "<leader>lc", "<cmd>LynxCite<cr>", desc = "📚 Generate BibTeX citation" },
  { "<leader>ls", "<cmd>LynxSummarize<cr>", desc = "📝 Summarize page" },
}

return registry.register_module("lynx", keymaps)
