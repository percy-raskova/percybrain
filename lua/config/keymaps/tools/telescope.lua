-- Telescope Keymaps
-- Namespace: <leader>f (find/search)

local registry = require("config.keymaps")

local keymaps = {
  -- Search and navigation
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "🔍 Find files" },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "🔎 Search content" },
  { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "📝 Switch buffers" },
  { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "📖 Search help" },
  { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "🔑 Browse keymaps" },
  { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "📜 Recent files" },
  { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "⌨️  Commands" },
}

return registry.register_module("telescope", keymaps)
