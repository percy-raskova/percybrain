-- Plugin: nvim-tree
-- Purpose: File explorer sidebar for navigating Zettelkasten directory structure
-- Workflow: navigation
-- Why: Visual file tree provides spatial context for note organization - critical for users who
--      think visually or need to see folder structure. Reduces cognitive load by showing file
--      locations rather than requiring mental mapping. Supports exploration and reorganization
--      of growing knowledge base. Familiar UI pattern from traditional file managers.
-- Config: minimal (uses default sensible settings)
--
-- Usage:
--   <leader>e - Toggle file explorer sidebar
--   Arrow keys or hjkl - Navigate files/folders
--   Enter - Open file
--   a - Create new file/folder
--   d - Delete file/folder
--   r - Rename file/folder
--   c - Copy file/folder
--   x - Cut file/folder
--   p - Paste file/folder
--
-- Dependencies: nvim-web-devicons (for file icons)
--
-- Configuration Notes:
--   - lazy = false: Loads on startup for immediate availability
--   - opts = {}: Uses nvim-tree's default configuration
--   - Keybindings: <leader>e defined in lua/config/init.lua (core keybinding)
--   - Respects .gitignore by default (can be toggled)
--   - Supports file operations (create, delete, rename, copy, move)

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  opts = {},
}
