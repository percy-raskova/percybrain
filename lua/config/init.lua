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

-- ========================================================================
-- Core Keybindings (Basic Vim Operations)
-- ========================================================================
-- Note: Plugin-specific keybindings are defined in each plugin's keys = {}
-- This keeps keybindings colocated with their functionality

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic file operations
vim.keymap.set("n", "<leader>s", "<cmd>w!<CR>", { desc = "💾 Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q!<CR>", { desc = "🚪 Quit" })
vim.keymap.set("n", "<leader>c", "<cmd>close<CR>", { desc = "❌ Close window" })

-- Splits
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "⚡ Vertical split" })

-- View toggles
vim.keymap.set("n", "<leader>vn", function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "🔢 Toggle line numbers" })

-- Plugin management
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "🔌 Lazy plugin manager" })
vim.keymap.set("n", "<leader>W", "<cmd>WhichKey<CR>", { desc = "❓ WhichKey help" })

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
