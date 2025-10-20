-- lua/config/treesitter-health-fix.lua
-- Fix for Python Treesitter parser "except*" syntax error
-- Implements GREEN phase of RED-GREEN-REFACTOR cycle

local M = {}

-- Check if we have the problematic Python highlight query
local function has_except_star_issue()
  local success, error_msg = pcall(function()
    vim.treesitter.query.get("python", "highlights")
  end)

  if not success and tostring(error_msg):match("except%*") then
    return true
  end
  return false
end

-- Create patched highlight query without except* references
local function patch_python_highlights()
  -- Create custom query directory
  local queries_dir = vim.fn.stdpath("config") .. "/after/queries/python"
  vim.fn.mkdir(queries_dir, "p")

  local patched_file = queries_dir .. "/highlights.scm"

  -- Check if we already have a patched version
  if vim.fn.filereadable(patched_file) == 1 then
    return true
  end

  -- Find the original highlights file
  local runtime_paths = vim.api.nvim_list_runtime_paths()
  local original_file = nil

  for _, path in ipairs(runtime_paths) do
    local candidate = path .. "/queries/python/highlights.scm"
    if vim.fn.filereadable(candidate) == 1 then
      -- Check if this is the nvim-treesitter queries
      if path:match("nvim%-treesitter") then
        original_file = candidate
        break
      end
    end
  end

  if not original_file then
    vim.notify(
      "Could not find Python highlights.scm to patch",
      vim.log.levels.WARN,
      { title = "Treesitter Health Fix" }
    )
    return false
  end

  -- Read and patch the file
  local lines = vim.fn.readfile(original_file)
  local patched_lines = {}
  local in_except_star_block = false
  local skip_next_line = false

  for _, line in ipairs(lines) do
    -- Skip lines related to except*
    if line:match('"except%*"') or line:match("except_star") then
      in_except_star_block = true
      skip_next_line = true
    elseif skip_next_line then
      skip_next_line = false
      -- Skip the line after except* definition
    elseif in_except_star_block and (line:match("^%)") or line:match("^%s*$")) then
      -- End of except* block
      in_except_star_block = false
    elseif not in_except_star_block then
      table.insert(patched_lines, line)
    end
  end

  -- Write the patched file
  vim.fn.writefile(patched_lines, patched_file)

  vim.notify(
    "Patched Python highlights to remove except* syntax",
    vim.log.levels.INFO,
    { title = "Treesitter Health Fix" }
  )

  return true
end

-- Update Python parser to latest version
local function update_python_parser()
  -- Check if we need to update the parser
  local parsers = require("nvim-treesitter.parsers")
  local parser_config = parsers.get_parser_configs()

  if not parser_config.python then
    vim.notify("Python parser config not found", vim.log.levels.ERROR, { title = "Treesitter Health Fix" })
    return false
  end

  -- Try to update the parser
  vim.notify("Updating Python parser...", vim.log.levels.INFO, { title = "Treesitter Health Fix" })

  -- Run TSUpdate for Python
  local success = pcall(vim.cmd, "TSUpdate python")

  if success then
    vim.notify("Python parser updated successfully", vim.log.levels.INFO, { title = "Treesitter Health Fix" })
    return true
  else
    vim.notify(
      "Failed to update Python parser, applying query patch instead",
      vim.log.levels.WARN,
      { title = "Treesitter Health Fix" }
    )
    return false
  end
end

-- Apply all fixes for Python Treesitter health
function M.fix_python_treesitter()
  -- Check if we have the issue
  if not has_except_star_issue() then
    return true -- No issue to fix
  end

  vim.notify(
    "Detected Python Treesitter except* issue, applying fixes...",
    vim.log.levels.INFO,
    { title = "Treesitter Health Fix" }
  )

  -- Strategy 1: Try to update the parser first
  local parser_updated = update_python_parser()

  -- Check if the update fixed the issue
  if parser_updated and not has_except_star_issue() then
    vim.notify(
      "Python Treesitter issue fixed by parser update",
      vim.log.levels.INFO,
      { title = "Treesitter Health Fix" }
    )
    return true
  end

  -- Strategy 2: Patch the highlight queries
  local patch_applied = patch_python_highlights()

  if patch_applied then
    -- Note: Neovim automatically reloads query files when they change
    -- No manual cache invalidation needed

    -- Verify the fix worked
    if not has_except_star_issue() then
      vim.notify(
        "Python Treesitter issue fixed by query patch",
        vim.log.levels.INFO,
        { title = "Treesitter Health Fix" }
      )
      return true
    end
  end

  vim.notify(
    "Could not fully resolve Python Treesitter issue",
    vim.log.levels.WARN,
    { title = "Treesitter Health Fix" }
  )
  return false
end

-- Auto-fix on module load if needed
function M.setup()
  -- Run fix asynchronously to not block startup
  vim.defer_fn(function()
    M.fix_python_treesitter()
  end, 100)
end

return M
