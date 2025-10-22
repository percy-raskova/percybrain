local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.quiet-startup").setup() -- Suppress verbose plugin notifications
require("config.globals")
require("config.options")
require("config.privacy") -- Privacy protection (clear registers, etc.)
require("config.health-fixes").setup() -- Apply checkhealth fixes (TDD implementation)
require("config.zettelkasten").setup() -- Zettelkasten system
require("config.window-manager") -- Window management system (keymaps centralized)
require("percybrain.dashboard").setup() -- AI metrics auto-analysis
require("percybrain.error-logger") -- Error logging system

-- ========================================================================
-- Ollama Integration (Auto-start local AI server)
-- ========================================================================
require("percybrain.ollama-manager").setup({
  enabled = true, -- Enable auto-start (disable with vim.g.ollama_config = { enabled = false })
  model = "llama3.2", -- Default model
  auto_pull = false, -- Don't auto-download models
  timeout = 30, -- Startup timeout in seconds
})

-- GTD AI + IWE Bridge (Task detection and decomposition)
require("percybrain.gtd.iwe-bridge").setup({
  auto_decompose = false, -- Prompt user before decomposing (set true for automatic)
})

-- Load centralized keymaps (Phase 3 - Hierarchical Reorganization)
-- System keymaps (core Vim, dashboard)
require("config.keymaps.system.core")
require("config.keymaps.system.dashboard")

-- Workflow keymaps (Zettelkasten, AI, prose, quick-capture, GTD, modes)
require("config.keymaps.workflows.zettelkasten")
require("config.keymaps.workflows.ai")
require("config.keymaps.workflows.prose")
require("config.keymaps.workflows.quick-capture")
require("config.keymaps.workflows.gtd")
require("config.keymaps.workflows.modes") -- Phase 2: Mode-switching for writer contexts

-- Tool keymaps (telescope, navigation, git, diagnostics, window, lynx)
require("config.keymaps.tools.telescope")
require("config.keymaps.tools.navigation")
require("config.keymaps.tools.git")
require("config.keymaps.tools.diagnostics")
require("config.keymaps.tools.window")
require("config.keymaps.tools.lynx")

-- Environment keymaps (terminal, focus, translation)
require("config.keymaps.environment.terminal")
require("config.keymaps.environment.focus")
require("config.keymaps.environment.translation")

-- Organization keymaps (time-tracking)
require("config.keymaps.organization.time-tracking")

-- Utilities (standalone)
require("config.keymaps.utilities")

-- This is for an experimental plugin
--

local opts = {
  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  rtp = {
    disabled_plugins = {
      "gzip",
      "matchit",
      "matchparen",
      "netrePlugin",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
    },
  },
  change_detection = {
    notify = true,
  },
}

require("lazy").setup("plugins", opts)
