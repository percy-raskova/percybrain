--- GTD (Getting Things Done) System
--- Core GTD functionality for task management following David Allen's methodology
--- Implements the 5 core GTD workflows:
---   1. Capture - Collect everything that has your attention
---   2. Clarify - Process what it means and what to do about it
---   3. Organize - Put it where it belongs
---   4. Reflect - Review frequently
---   5. Engage - Simply do
--- @module percybrain.gtd

local M = {}

--- GTD configuration
--- Defines the structure and organization of the GTD system
--- @class GTDConfig
--- @field gtd_root string Root directory for GTD files
--- @field base_files table<{name: string, header: string}> Core GTD files with headers
--- @field contexts table<{name: string, icon: string, file: string}> GTD contexts
--- @field directories string[] Subdirectories to create
M.config = {
  gtd_root = vim.fn.expand("~/Zettelkasten/gtd"),

  -- Core GTD files following Allen's methodology
  base_files = {
    {
      name = "inbox.md",
      header = "# 📥 Inbox\n\nQuick capture of all incoming items.\n\n## Guidelines\n"
        .. "- Capture everything that has your attention\n"
        .. "- Process regularly (daily recommended)\n"
        .. "- Keep it clean - move items out during clarification\n",
    },
    {
      name = "next-actions.md",
      header = "# ⚡ Next Actions\n\nActionable tasks organized by context.\n\n## Guidelines\n"
        .. "- Single, physical, visible activities\n"
        .. "- Can be done in one sitting\n"
        .. "- Organized by context (@home, @work, etc.)\n",
    },
    {
      name = "projects.md",
      header = "# 📋 Projects\n\nMulti-step outcomes requiring more than one action.\n\n## Guidelines\n"
        .. "- Any outcome requiring more than one step\n"
        .. "- Review weekly\n"
        .. "- Each project needs at least one next action\n",
    },
    {
      name = "someday-maybe.md",
      header = "# 💭 Someday/Maybe\n\nIdeas and possibilities for future consideration.\n\n## Guidelines\n"
        .. "- Things you might want to do but not now\n"
        .. "- Review during weekly review\n"
        .. "- Move to projects when ready to commit\n",
    },
    {
      name = "waiting-for.md",
      header = "# ⏳ Waiting For\n\nItems delegated or waiting on others.\n\n## Guidelines\n"
        .. "- Track what you're waiting for from others\n"
        .. "- Review weekly to follow up\n"
        .. "- Include who and when\n",
    },
    {
      name = "reference.md",
      header = "# 📚 Reference\n\nInformation to keep for future reference.\n\n## Guidelines\n"
        .. "- No action required, just information\n"
        .. "- Organized by topic or project\n"
        .. "- Easy to retrieve when needed\n",
    },
  },

  -- GTD contexts - where/when/how you can do actions
  contexts = {
    { name = "home", icon = "🏠", file = "contexts/home.md" },
    { name = "work", icon = "💼", file = "contexts/work.md" },
    { name = "computer", icon = "💻", file = "contexts/computer.md" },
    { name = "phone", icon = "📱", file = "contexts/phone.md" },
    { name = "errands", icon = "🚗", file = "contexts/errands.md" },
  },

  -- Directory structure
  directories = {
    "contexts", -- Context-specific action lists
    "projects", -- Project support materials
    "archive", -- Completed items and old projects
  },
}

--- Create GTD directory structure
--- @private
local function create_directories()
  local gtd_root = M.config.gtd_root

  -- Create GTD root directory
  if vim.fn.isdirectory(gtd_root) == 0 then
    vim.fn.mkdir(gtd_root, "p")
  end

  -- Create subdirectories
  for _, dir in ipairs(M.config.directories) do
    local dir_path = gtd_root .. "/" .. dir
    if vim.fn.isdirectory(dir_path) == 0 then
      vim.fn.mkdir(dir_path, "p")
    end
  end
end

--- Create GTD base files with headers
--- @private
local function create_base_files()
  local gtd_root = M.config.gtd_root

  for _, file_def in ipairs(M.config.base_files) do
    local file_path = gtd_root .. "/" .. file_def.name

    -- Only create file if it doesn't exist (don't overwrite)
    if vim.fn.filereadable(file_path) == 0 then
      vim.fn.writefile(vim.split(file_def.header, "\n"), file_path)
    end
  end
end

--- Create GTD context files
--- @private
local function create_context_files()
  local gtd_root = M.config.gtd_root

  for _, context in ipairs(M.config.contexts) do
    local context_path = gtd_root .. "/" .. context.file
    local header = string.format("# %s @%s\n\nNext actions for %s context.\n", context.icon, context.name, context.name)

    -- Only create file if it doesn't exist (don't overwrite)
    if vim.fn.filereadable(context_path) == 0 then
      vim.fn.writefile(vim.split(header, "\n"), context_path)
    end
  end
end

--- Initialize GTD system
--- Creates directory structure, base files, and context files
--- Safe to call multiple times (won't overwrite existing files)
function M.setup()
  create_directories()
  create_base_files()
  create_context_files()
end

--- Get the absolute path to the inbox file
--- @return string Absolute path to inbox.md
function M.get_inbox_path()
  return M.config.gtd_root .. "/inbox.md"
end

--- Get the absolute path to the next-actions file
--- @return string Absolute path to next-actions.md
function M.get_next_actions_path()
  return M.config.gtd_root .. "/next-actions.md"
end

--- Get the absolute path to the projects file
--- @return string Absolute path to projects.md
function M.get_projects_path()
  return M.config.gtd_root .. "/projects.md"
end

--- Get the GTD root directory path
--- @return string Absolute path to GTD root directory
function M.get_gtd_root()
  return M.config.gtd_root
end

return M
