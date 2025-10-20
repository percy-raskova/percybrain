-- Plugin: mason-lspconfig
-- Purpose: Bridge between Mason and nvim-lspconfig for automatic LSP setup
-- Workflow: utilities
-- Why: Reduced configuration friction - automatically connects Mason-installed LSP
--      servers to nvim-lspconfig without manual path configuration. ADHD-optimized
--      through elimination of repetitive setup steps and guaranteed consistency between
--      installed servers and active configurations. Critical infrastructure that makes
--      LSP "just work" after Mason installation.
-- Config: minimal
--
-- Usage:
--   Automatic - no direct commands (works behind the scenes)
--   Ensures Mason-installed servers are available to lspconfig
--
-- Dependencies:
--   williamboman/mason.nvim (required parent plugin)
--
-- Configuration Notes:
--   ensure_installed: Minimal core server list (efm, pyright, lua_ls, jsonls)
--   automatic_installation: Auto-installs any server referenced in lspconfig setup
--   Lazy-loads on BufReadPre to avoid startup overhead
--   Works in tandem with main mason.lua for comprehensive tool management

local opts = {
  ensure_installed = {
    "efm",
    "pyright",
    "lua_ls",
    "jsonls",
  },

  automatic_installation = true,
}

return {
  "williamboman/mason-lspconfig.nvim",
  opts = opts,
  event = "BufReadPre",
  dependencies = "williamboman/mason.nvim",
}
