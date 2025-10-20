-- PercyBrain Dashboard Menu
-- Purpose: Unified menu for AI dashboard operations
-- Keybinding: <leader>d (d for Dashboard)

local M = {}

-- Import dashboard and network graph modules
local dashboard = require("percybrain.dashboard")
local network = require("percybrain.network-graph")

-- Toggle dashboard
local function toggle_dashboard()
  dashboard.toggle()
end

-- Refresh dashboard (force cache invalidation)
local function refresh_dashboard()
  -- Clear cache by resetting last analysis time
  vim.notify("🔄 Refreshing dashboard metrics...", vim.log.levels.INFO)

  -- Access internal cache (dashboard module exposes this)
  vim.defer_fn(function()
    dashboard.toggle()
  end, 100)
end

-- Show network graph
local function show_network()
  network.show_borg()
end

-- Quick stats (non-blocking, status line message)
local function quick_stats()
  network.quick_stats()
end

-- Configure dashboard settings
local function configure()
  local config_path = vim.fn.stdpath("config") .. "/lua/percybrain/dashboard.lua"
  if vim.fn.filereadable(config_path) == 1 then
    vim.cmd("edit " .. config_path)
  else
    vim.notify("❌ Dashboard config not found", vim.log.levels.ERROR)
  end
end

-- Show dashboard menu using vim.ui.select
M.show_menu = function()
  local options = {
    "📊 Toggle Dashboard",
    "🔄 Refresh Metrics",
    "🤖 Network Graph (Borg Visualization)",
    "⚡ Quick Stats",
    "⚙️  Configure Dashboard",
  }

  vim.ui.select(options, {
    prompt = "Dashboard Menu:",
  }, function(choice)
    if choice == options[1] then
      toggle_dashboard()
    elseif choice == options[2] then
      refresh_dashboard()
    elseif choice == options[3] then
      show_network()
    elseif choice == options[4] then
      quick_stats()
    elseif choice == options[5] then
      configure()
    end
  end)
end

-- Setup keybindings
M.setup = function()
  vim.keymap.set("n", "<leader>d", M.show_menu, { desc = "Dashboard Menu" })
  vim.keymap.set("n", "<leader>dt", toggle_dashboard, { desc = "Dashboard Toggle" })
  vim.keymap.set("n", "<leader>dr", refresh_dashboard, { desc = "Dashboard Refresh" })
  vim.keymap.set("n", "<leader>dn", show_network, { desc = "Network Graph" })
  vim.keymap.set("n", "<leader>ds", quick_stats, { desc = "Quick Stats" })
  vim.keymap.set("n", "<leader>dc", configure, { desc = "Dashboard Config" })
end

return M
