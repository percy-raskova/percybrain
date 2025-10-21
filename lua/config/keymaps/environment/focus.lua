--- Focus Mode Keymaps
--- Namespace: <leader>tz (zen mode), <leader>sp (soft pencil)
--- @module config.keymaps.environment.focus

local registry = require("config.keymaps")

local keymaps = {
  { "<leader>tz", "<cmd>ZenMode<CR>", desc = "🧘 Zen mode" },
  { "<leader>sp", "<cmd>SoftPencil<CR>", desc = "✍️  Soft pencil mode" },
}

return registry.register_module("environment.focus", keymaps)
