-- Yazi: Terminal file manager integration
-- Lazy-loaded: Loads on command
-- Features: Fast file browsing, image preview, bulk operations

return {
  "mikavilpas/yazi.nvim",
  cmd = "Yazi",
  keys = {
    { "<leader>y", "<cmd>Yazi<CR>", desc = "📁 Open Yazi file manager" },
  },
}
