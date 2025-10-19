-- Minimal Neovim Configuration for Testing
-- Isolated environment for Plenary test execution

-- Set up runtime paths
vim.opt.rtp:append(".")
vim.opt.packpath:append(".")

-- CRITICAL: Ensure vim.inspect exists as a FUNCTION before loading Plenary
-- This is required by Plenary's busted.lua for error reporting
-- In Neovim 0.10+, vim.inspect is a module/table, we need the function
if type(vim.inspect) ~= "function" then
  local inspect_module = vim.inspect or require("vim.inspect")
  vim.inspect = inspect_module.inspect or inspect_module

  -- If still not a function, create a simple polyfill
  if type(vim.inspect) ~= "function" then
    vim.inspect = function(obj, opts)
      return vim.fn.string(obj)
    end
  end
end

-- Disable unnecessary plugins for faster testing
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Bootstrap lazy.nvim if needed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load Plenary from the existing installation
local plenary_path = vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")
if vim.fn.isdirectory(plenary_path) == 1 then
  vim.opt.rtp:append(plenary_path)

  -- Ensure Plenary's dependencies are available
  pcall(function()
    require("plenary")
  end)
else
  -- If Plenary isn't installed via lazy, install it for testing
  require("lazy").setup({
    { "nvim-lua/plenary.nvim", lazy = false },
  }, {
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
end

-- Add test helpers to runtime path and Lua package path
vim.opt.rtp:append("tests")

-- CRITICAL: Add project root to Lua package path for require('tests.helpers')
local project_root = vim.fn.getcwd()
package.path = package.path .. ";" .. project_root .. "/?.lua"
package.path = package.path .. ";" .. project_root .. "/?/init.lua"

-- Set up test-specific options
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.termguicolors = true
vim.opt.hidden = true

-- Minimal test-specific configuration
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Load test helpers globally (optional, wrapped in pcall)
local helpers_ok, helpers = pcall(require, "tests.helpers")
if helpers_ok then
  _G.test_helpers = helpers
else
  -- Provide minimal stubs if helpers fail to load
  _G.test_helpers = {
    create_test_buffer = function()
      return vim.api.nvim_create_buf(false, true)
    end,
    cleanup_buffer = function(buf)
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  }
end

local assertions_ok, assertions = pcall(require, "tests.helpers.assertions")
if assertions_ok then
  _G.test_assertions = assertions
end

local mocks_ok, mocks = pcall(require, "tests.helpers.mocks")
if mocks_ok then
  _G.test_mocks = mocks
end

-- Utility function for running tests
_G.run_test_file = function(file)
  require("plenary.busted").run(file)
end

-- Utility function for running test directory
_G.run_test_directory = function(directory)
  require("plenary.test_harness").test_directory(directory, { minimal_init = "tests/minimal_init.lua" })
end
