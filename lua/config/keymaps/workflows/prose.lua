-- Prose Writing Keymaps
-- Namespace: <leader>p (prose/paste/publishing)

local registry = require("config.keymaps")

local keymaps = {
  -- Prose menu
  { "<leader>p", "<cmd>Prose<cr>", desc = "For long form writing" },

  -- Image pasting
  { "<leader>pp", "<cmd>PasteImage<cr>", desc = "📷 Paste clipboard image" },

  -- Markdown doc toggle
  { "<leader>pm", "<cmd>StyledocToggle<cr>", desc = "📝 Toggle StyledDoc" },

  -- Goyo distraction-free mode
  { "<leader>pd", "<cmd>Goyo<CR>", desc = "🎯 Goyo focus mode" },
}

return registry.register_module("prose", keymaps)
