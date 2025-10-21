-- Mode Switching Keymaps
-- Namespace: <leader>m (modes - context-aware workspace configurations)
--
-- WRITER-FIRST PHILOSOPHY:
-- Writers work in distinct contexts requiring different tool configurations.
-- Mode switching provides one-key access to optimized workspace layouts.
--
-- DESIGN RATIONALE (2025-10-21 Phase 2):
-- - Writing mode: Focus on prose creation (Goyo, spell, no distractions)
-- - Research mode: Knowledge exploration (splits, backlinks, file tree)
-- - Editing mode: Technical editing (diagnostics, LSP, error messages)
-- - Publishing mode: Content preparation (Hugo, preview, build tools)
-- - Normal mode: Reset to baseline PercyBrain defaults
--
-- IMPLEMENTATION NOTES:
-- - Each mode configures vim options, enables/disables plugins
-- - Modes are mutually exclusive (switching resets previous mode)
-- - State changes are notified to user for clarity

local registry = require("config.keymaps")

-- Helper function to check if a command exists
local function command_exists(cmd)
  return vim.fn.exists(":" .. cmd) == 2
end

-- Writing Mode: Focus on prose creation
local function enable_writing_mode()
  -- Enable focus mode if available
  if command_exists("Goyo") then
    vim.cmd("Goyo")
  end

  -- Enable spell checking
  vim.opt.spell = true

  -- Disable distractions
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "no"

  -- Enable soft wrapping for prose
  vim.opt.wrap = true
  vim.opt.linebreak = true

  -- Enable SemBr auto-format if available
  if command_exists("SemBrToggle") then
    vim.cmd("SemBrToggle on")
  end

  vim.notify("✍️  Writing Mode Activated", vim.log.levels.INFO)
end

-- Research Mode: Knowledge exploration and cross-referencing
local function enable_research_mode()
  -- Enable line numbers for navigation
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.signcolumn = "yes"

  -- Open file tree for navigation
  if command_exists("NvimTreeOpen") then
    vim.cmd("NvimTreeOpen")
  end

  -- Create vertical split for multi-window workflow
  vim.cmd("vsplit")

  -- Enable spell checking (still writing, just researching)
  vim.opt.spell = true

  vim.notify("🔬 Research Mode Activated", vim.log.levels.INFO)
end

-- Editing Mode: Technical editing with diagnostics
local function enable_editing_mode()
  -- Ensure focus mode is off
  if command_exists("Goyo") then
    vim.cmd("Goyo!")
  end

  -- Enable all editor features
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.signcolumn = "yes"

  -- Enable diagnostics
  vim.diagnostic.enable()

  -- Open Trouble panel if available
  if command_exists("Trouble") then
    vim.cmd("Trouble diagnostics toggle")
  end

  -- Spell checking less important in editing mode
  vim.opt.spell = false

  vim.notify("✏️  Editing Mode Activated", vim.log.levels.INFO)
end

-- Publishing Mode: Content preparation and preview
local function enable_publishing_mode()
  -- Enable Hugo server if available
  if command_exists("HugoServer") then
    vim.cmd("HugoServer")
  end

  -- Enable markdown preview if available
  if command_exists("MarkdownPreview") then
    vim.cmd("MarkdownPreview")
  end

  -- Keep line numbers for reference
  vim.opt.number = true
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "yes"

  -- Enable spell checking for final review
  vim.opt.spell = true

  vim.notify("📤 Publishing Mode Activated", vim.log.levels.INFO)
end

-- Normal Mode: Reset to baseline PercyBrain defaults
local function reset_to_normal()
  -- Disable Goyo if active
  if command_exists("Goyo") then
    vim.cmd("Goyo!")
  end

  -- Close Trouble if open
  if command_exists("Trouble") then
    vim.cmd("Trouble diagnostics close")
  end

  -- Close file tree
  if command_exists("NvimTreeClose") then
    vim.cmd("NvimTreeClose")
  end

  -- Stop Hugo server if running
  if command_exists("HugoStop") then
    vim.cmd("HugoStop")
  end

  -- Stop markdown preview if active
  if command_exists("MarkdownPreviewStop") then
    vim.cmd("MarkdownPreviewStop")
  end

  -- Reset to baseline options
  vim.opt.number = true
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "yes"
  vim.opt.spell = false
  vim.opt.wrap = true
  vim.opt.linebreak = true

  -- Re-enable diagnostics
  vim.diagnostic.enable()

  vim.notify("🔄 Normal Mode Restored", vim.log.levels.INFO)
end

local keymaps = {
  {
    "<leader>mw",
    enable_writing_mode,
    desc = "✍️  Writing mode (focus, spell, prose)",
  },
  {
    "<leader>mr",
    enable_research_mode,
    desc = "🔬 Research mode (splits, backlinks, tree)",
  },
  {
    "<leader>me",
    enable_editing_mode,
    desc = "✏️  Editing mode (diagnostics, LSP, errors)",
  },
  {
    "<leader>mp",
    enable_publishing_mode,
    desc = "📤 Publishing mode (Hugo, preview, build)",
  },
  {
    "<leader>mn",
    reset_to_normal,
    desc = "🔄 Normal mode (reset to defaults)",
  },
}

return registry.register_module("workflows.modes", keymaps)
