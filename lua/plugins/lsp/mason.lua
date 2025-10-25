-- Plugin: Mason
-- Purpose: LSP/DAP/linter/formatter installer with GUI package manager
-- Workflow: utilities
-- Why: Simplified tool management for writing-focused Neovim environment.
--      Manages essential LSPs (lua_ls for config, optional grammar/LaTeX servers).
--      ADHD-optimized through visual package manager UI (reduces decision paralysis),
--      automatic installation (eliminates setup friction), and clear status indicators.
-- Config: minimal (writing-focused)
--
-- Usage:
--   :Mason - Open package manager UI
--   :MasonInstall <package> - Install specific tool
--   :MasonUninstall <package> - Remove tool
--   :MasonUpdate - Update all installed packages
--
-- Dependencies:
--   none (integrates with mason-lspconfig, mason-tool-installer)
--
-- Configuration Notes:
--   WRITING ENVIRONMENT: Minimal LSP setup for Zettelkasten/writing workflow
--   - lua_ls: REQUIRED for Neovim configuration editing
--   - ltex_plus: OPTIONAL grammar/spelling checker for prose
--   - texlab: OPTIONAL LaTeX support for academic writing
--   - IWE (iwes): Managed separately via iwe.nvim plugin (see lsp/iwe.lua)
--
--   All web development LSPs removed (tsserver, html, css, tailwind, svelte, etc.)
--   Visual icons: ✓ installed, ➜ pending, ✗ not installed
--   All tools install to ~/.local/share/nvim/mason/ (isolated from system)

return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
        -- FIX: Explicitly enable Mason keybindings to resolve E21 error
        -- Mason UI is non-modifiable by design, but keybindings should work
        keymaps = {
          toggle_package_expand = "<CR>",
          install_package = "i",
          update_package = "u",
          check_package_version = "c",
          update_all_packages = "U",
          check_outdated_packages = "C",
          uninstall_package = "X", -- Changed to capital X to avoid conflicts
          cancel_installation = "<C-c>",
          apply_language_filter = "<C-f>",
        },
      },
    })

    mason_lspconfig.setup({
      -- WRITING ENVIRONMENT: Minimal LSP servers for Zettelkasten workflow
      ensure_installed = {
        "lua_ls", -- REQUIRED: Neovim configuration editing
        -- Optional: Install manually via :MasonInstall if needed
        -- "ltex_plus",  -- Grammar/spelling checker
        -- "texlab",     -- LaTeX support for academic writing
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      -- WRITING ENVIRONMENT: Minimal tooling
      ensure_installed = {
        "stylua", -- REQUIRED: Lua formatter for Neovim config maintenance
        -- All web dev tools removed (prettier, eslint, black, pylint, etc.)
      },
    })
  end,
}
