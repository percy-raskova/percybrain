-- Plugin: mason-lspconfig
-- Purpose: Bridge between Mason and nvim-lspconfig for automatic LSP setup
-- Workflow: utilities
-- Why: Reduced configuration friction - automatically connects Mason-installed LSP
--      servers to nvim-lspconfig. ADHD-optimized through elimination of setup steps.
-- Config: minimal (writing-focused)
--
-- Usage:
--   Automatic - no direct commands (works behind the scenes)
--   Ensures Mason-installed servers are available to lspconfig
--
-- Dependencies:
--   williamboman/mason.nvim (required parent plugin)
--
-- Configuration Notes:
--   WRITING ENVIRONMENT: Minimal LSP setup for Zettelkasten/writing workflow
--   - lua_ls: REQUIRED for Neovim configuration editing
--   - IWE (iwes): Managed separately via iwe.nvim plugin (not in this list)
--   - Optional servers (ltex_plus, texlab) can be installed manually via :MasonInstall
--
--   automatic_installation: Auto-installs any server referenced in lspconfig setup
--   Lazy-loads on BufReadPre to avoid startup overhead
--   All web dev servers removed (tsserver, html, css, pyright, jsonls, efm, etc.)

local opts = {
  ensure_installed = {
    "lua_ls", -- REQUIRED: Neovim configuration editing
    "ltex_plus", -- PROSE: Grammar/spelling checker for writing
    -- Optional: Install manually if needed
    -- "texlab",     -- LaTeX support (academic writing)
  },

  automatic_installation = true,
}

return {
  "williamboman/mason-lspconfig.nvim",
  opts = opts,
  event = "BufReadPre",
  dependencies = "williamboman/mason.nvim",
}
