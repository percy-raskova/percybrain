-- Plugin: Mason
-- Purpose: LSP/DAP/linter/formatter installer with GUI package manager
-- Workflow: utilities
-- Why: Simplified tool management - provides one-stop installation and updates for
--      language servers, formatters, and linters without manual PATH configuration.
--      ADHD-optimized through visual package manager UI (reduces decision paralysis),
--      automatic installation (eliminates setup friction), and clear status indicators.
--      Critical infrastructure that eliminates "works on my machine" issues by
--      ensuring consistent tooling across environments.
-- Config: full
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
--   ensure_installed: LSP servers auto-installed (tsserver, lua_ls, pyright, etc.)
--   automatic_installation: Auto-installs servers referenced in lspconfig
--   Tool installer handles formatters (prettier, stylua, black) and linters (pylint, eslint_d)
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
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "tsserver",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
      },
    })
  end,
}
