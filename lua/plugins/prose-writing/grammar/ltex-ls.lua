-- Plugin: ltex-ls-plus
-- Purpose: Enhanced LanguageTool Language Server for grammar, spelling, and style checking
-- Workflow: prose-writing/grammar
-- Why: Provides real-time grammar and style feedback as you write - critical for writers with
--      language processing differences (dyslexia, EAL). LSP integration means non-intrusive inline
--      suggestions. Supports multiple languages, academic/professional writing styles. Catches errors
--      before they compound, reducing editing anxiety. Works offline (privacy-first).
-- Config: minimal (ensures mason installs it; actual LSP config in lspconfig.lua)
--
-- Usage:
--   Automatic inline diagnostics appear as you write
--   Language selection via LSP settings
--   Code actions for suggested corrections
--   Integrates with nvim-cmp for spelling suggestions
--
-- Dependencies:
--   External: Java Runtime Environment (JRE) for LanguageTool
--   Installed via Mason package manager
--
-- Configuration Notes:
--   - ltex-ls-plus: Enhanced fork with better performance than standard ltex-ls
--   - Actual LSP configuration in lua/plugins/lsp/lspconfig.lua
--   - This file only ensures Mason installs the language server binary
--   - Supports 20+ languages with grammar checking
--   - Can be customized for academic vs. casual writing tone

return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "ltex-ls-plus", -- LanguageTool Language Server (enhanced version)
    },
  },
}
