-- Plugin: IWE LSP (Integrated Writing Environment Language Server)
-- Purpose: Smart linking, reference navigation, and Zettelkasten intelligence for markdown
-- Workflow: zettelkasten
-- Why: Provides LSP features specifically designed for interconnected notes - follow links,
--      find backlinks, validate references, autocomplete note titles. Essential for maintaining
--      link integrity in a growing Zettelkasten. Reduces cognitive load by making link navigation
--      automatic and reliable.
-- Config: minimal (actual LSP config in lua/plugins/lsp/lspconfig.lua)
--
-- Usage:
--   gd - Go to definition (follow link)
--   gr - Find references (show backlinks)
--   K - Hover to preview linked note
--   <C-Space> - Trigger completion for note titles
--
-- Dependencies:
--   External tool: iwe (install with: cargo install iwe)
--
-- Configuration Notes:
--   - This file only ensures the plugin is loaded
--   - Actual LSP setup happens in lspconfig.lua
--   - Requires 'iwe' binary in PATH for functionality
--   - Works seamlessly with Telekasten's link notation

return {
  "Feel-ix-343/markdown-oxide",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- IWE LSP is configured via lua/plugins/lsp/lspconfig.lua
    -- This file just ensures the plugin is loaded
  end,
}
