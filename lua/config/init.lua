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

require("config.globals")
require("config.keymaps")
require("config.options")
require("config.privacy") -- Privacy protection (clear registers, etc.)
require("config.zettelkasten").setup() -- Zettelkasten system
require("config.window-manager").setup() -- Window management system
require("percybrain.dashboard").setup() -- AI metrics auto-analysis
require("percybrain.error-logger") -- Error logging system

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
