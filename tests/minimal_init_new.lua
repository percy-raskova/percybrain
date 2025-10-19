-- Minimal Test Initialization for Kent Beck Testing Framework
-- This provides just enough setup for tests to run in isolation

-- Add project root to runtime path
vim.opt.rtp:append(".")
vim.opt.packpath:append(".")

-- Set up module paths for test helpers
package.path = package.path .. ";./tests/?.lua;./tests/?/init.lua"
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Bootstrap lazy.nvim if needed (for plugin testing)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- In test environment, we might not have lazy.nvim
  -- That's OK - tests should work without it where possible
  vim.notify("lazy.nvim not found - running in minimal mode", vim.log.levels.INFO)
else
  vim.opt.rtp:prepend(lazypath)
end

-- Load plenary for test framework
local plenary_path = vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")
if vim.fn.isdirectory(plenary_path) == 1 then
  vim.opt.rtp:append(plenary_path)
  require("plenary.busted")
else
  -- Try to find plenary in other common locations
  local alt_plenary = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
  if vim.fn.isdirectory(alt_plenary) == 1 then
    vim.opt.rtp:append(alt_plenary)
    require("plenary.busted")
  else
    error("Plenary.nvim not found - please install it first")
  end
end

-- Load test framework helpers
local ok, helpers = pcall(require, "helpers.test_framework")
if ok then
  -- Make helpers globally available for tests
  _G.TestHelpers = helpers
end

-- Set minimal options for consistent test environment
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.shadafile = "NONE"

-- Disable unnecessary plugins in test mode
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
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Test environment indicator
vim.g.percybrain_test_mode = true

-- Ensure clean test environment
vim.cmd("silent! mapclear")
vim.cmd("silent! mapclear!")

-- Load contract specification if available
local contract_ok, contract = pcall(require, "specs.percybrain_contract")
if contract_ok then
  _G.PercyBrainContract = contract
end

-- Helper function for test isolation
function _G.with_test_isolation(test_fn)
  if _G.TestHelpers then
    return _G.TestHelpers.run_isolated(test_fn)
  else
    -- Fallback if helpers aren't loaded
    local result = test_fn()
    return result
  end
end

-- Helper for timed tests
function _G.with_timing(test_fn, max_ms)
  if _G.TestHelpers then
    return _G.TestHelpers.run_timed(test_fn, max_ms)
  else
    local start = vim.loop.hrtime()
    local result = test_fn()
    local elapsed = (vim.loop.hrtime() - start) / 1000000
    return result, elapsed
  end
end

-- Print test environment info
if vim.env.TEST_VERBOSITY == "verbose" then
  print("PercyBrain Test Environment Initialized")
  print("  Neovim version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
  print("  Test mode: " .. (vim.g.percybrain_test_mode and "enabled" or "disabled"))
  print("  Helpers loaded: " .. (ok and "yes" or "no"))
  print("  Contract loaded: " .. (contract_ok and "yes" or "no"))
  print("")
end
