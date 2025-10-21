-- Yazi: Terminal file manager integration
-- Lazy-loaded: Loads on command
-- Features: Fast file browsing, image preview, bulk operations
-- Import keymaps from central registry
local keymaps = require("config.keymaps.tools.navigation")

return {
  "mikavilpas/yazi.nvim",
  cmd = "Yazi",
  keys = keymaps, -- All navigation keymaps managed in lua/config/keymaps/navigation.lua
}
