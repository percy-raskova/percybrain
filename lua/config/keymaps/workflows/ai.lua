-- AI and SemBr Keymaps
-- Namespace: <leader>a (AI)

local registry = require("config.keymaps")

local keymaps = {
  -- AI operations
  { "<leader>aa", "<cmd>AIMenu<cr>", desc = "🤖 AI menu" },
  { "<leader>ac", "<cmd>AIChat<cr>", desc = "💬 AI chat" },
  { "<leader>ae", "<cmd>AIExplain<cr>", desc = "📖 Explain selection" },
  { "<leader>as", "<cmd>AISummarize<cr>", desc = "📝 Summarize" },
  { "<leader>ad", "<cmd>AIDraft<cr>", desc = "✍️  Draft text" },
  { "<leader>ar", "<cmd>AIRewrite<cr>", desc = "✨ Rewrite" },
  { "<leader>am", "<cmd>AIModelSelect<cr>", desc = "🔧 Select model" },
}

return registry.register_module("ai", keymaps)
