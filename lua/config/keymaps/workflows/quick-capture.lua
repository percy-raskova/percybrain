-- Quick Capture Keymaps
-- Namespace: <leader>q (quick capture)

local registry = require("config.keymaps")

local keymaps = {
  -- Floating quick capture
  { "<leader>qc", function() require("percybrain.floating-quick-capture").open_capture_window() end, desc = "⚡ Quick capture (floating)" },
}

return registry.register_module("quick-capture", keymaps)
