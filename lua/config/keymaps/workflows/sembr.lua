-- SemBr (Semantic Line Breaks) Keymaps
-- Namespace: <leader>s (sembr)
--
-- DESIGN RATIONALE:
-- SemBr applies ML-powered semantic line breaks for better git diffs.
-- <leader>s namespace chosen for "semantic breaks" and consistency with prose workflows.
--
-- ARCHITECTURE:
-- - <leader>sb = Format buffer with semantic line breaks
-- - <leader>ss = Format selection (visual mode)
-- - <leader>st = Toggle auto-format on save

local registry = require("config.keymaps")

-- Get SemBr module functions from the plugin
local function get_sembr_module()
  -- The plugin creates these functions in its config, we need to call them via user commands
  return {
    format_buffer = function()
      vim.cmd("SemBrFormat")
    end,
    format_selection = function()
      vim.cmd("SemBrFormatSelection")
    end,
    toggle_auto_format = function()
      vim.cmd("SemBrToggle")
    end,
  }
end

local keymaps = {
  -- ========================================================================
  -- SEMBR FORMATTING (<leader>s* prefix)
  -- ========================================================================

  -- Format buffer (normal mode)
  {
    "<leader>sb",
    function()
      get_sembr_module().format_buffer()
    end,
    desc = "🧠 SemBr: Format buffer",
  },

  -- Format selection (visual mode)
  {
    "<leader>ss",
    function()
      get_sembr_module().format_selection()
    end,
    mode = "v",
    desc = "🧠 SemBr: Format selection",
  },

  -- Toggle auto-format
  {
    "<leader>st",
    function()
      get_sembr_module().toggle_auto_format()
    end,
    desc = "🔄 SemBr: Toggle auto-format",
  },
}

return registry.register_module("workflows.sembr", keymaps)
