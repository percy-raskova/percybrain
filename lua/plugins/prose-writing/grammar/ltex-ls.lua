-- Plugin: ltex-ls-plus
-- Purpose: Enhanced LanguageTool Language Server
-- Workflow: prose-writing/grammar
-- Config: minimal

return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "ltex-ls-plus", -- LanguageTool Language Server (enhanced version)
    },
  },
}
