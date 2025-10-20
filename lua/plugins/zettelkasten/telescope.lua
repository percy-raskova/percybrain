-- Plugin: Telescope
-- Purpose: Fuzzy finder for navigating notes, searching content, and exploring the Zettelkasten
-- Workflow: zettelkasten
-- Why: ADHD optimization - fast, predictable visual search reduces cognitive load when exploring
--      interconnected notes. Dropdown theme provides consistent, focused UI without distraction.
--      Essential for discovering connections across the knowledge base.
-- Config: minimal - themed for consistency
--
-- Usage:
--   <leader>ff - Find files (notes)
--   <leader>fg - Live grep (search content across all notes)
--   <leader>fb - Switch between open buffers
--   <leader>fk - Browse keymaps
--   <leader>fh - Search help tags
--
-- Dependencies: none (pure Neovim plugin)
--
-- Configuration Notes:
--   - dropdown theme: Centered, focused UI without distraction
--   - hidden = true: Shows hidden files for complete note discovery
--   - C-j/C-k navigation: Consistent with vim motion muscle memory

local mapkey = require("utils.keymapper").mapkey

local config = function()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
    pickers = {
      find_files = {
        theme = "dropdown",
        previewer = false,
        hidden = true,
      },
      live_grep = {
        theme = "dropdown",
        previewer = false,
      },
      buffers = {
        theme = "dropdown",
        previewer = false,
      },
    },
  })
end

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.3",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = config,
  keys = {
    mapkey("<leader>fk", "Telescope keymaps", "n"),
    mapkey("<leader>fh", "Telescope help_tags", "n"),
    mapkey("<leader>ff", "Telescope find_files", "n"),
    mapkey("<leader>fg", "Telescope live_grep", "n"),
    mapkey("<leader>fb", "Telescope buffers", "n"),
  },
}
