-- Zettelkasten Navigation Helper
-- Purpose: Smart link following with auto-creation and frontmatter
-- Usage: Map to gf or <CR> for seamless navigation

local M = {}

-- Configuration
M.config = {
  zettelkasten_dir = vim.fn.expand("~/Zettelkasten"),
  auto_add_extension = true, -- Automatically add .md if missing
}

-- Extract link path from markdown link syntax
-- Supports: [text](path), [text](path.md), [[wikilink]]
-- Works when cursor is ANYWHERE in the link (brackets or parentheses)
function M.extract_link_path()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed column

  -- Pattern: [any text](path)
  -- We need to find if cursor is within ANY part of this structure
  local markdown_link_pattern = "%[(.-)%]%((.-)%)"

  local start_pos = 1
  while true do
    local link_start, link_end, _, link_path = line:find(markdown_link_pattern, start_pos)

    if not link_start then
      break -- No more links found
    end

    -- Check if cursor is within this link structure (anywhere from [ to ])
    if col >= link_start and col <= link_end then
      -- Found the link! Return the path from parentheses
      return link_path
    end

    -- Move to next potential link
    start_pos = link_end + 1
  end

  -- Try wiki link: [[wikilink]]
  local wiki_pattern = "%[%[(.-)%]%]"
  start_pos = 1
  while true do
    local wiki_start, wiki_end, wiki_path = line:find(wiki_pattern, start_pos)

    if not wiki_start then
      break
    end

    if col >= wiki_start and col <= wiki_end then
      return wiki_path
    end

    start_pos = wiki_end + 1
  end

  -- No link found
  return nil
end

-- Generate frontmatter template for new notes
function M.generate_frontmatter(filename)
  local title = filename:gsub("%.md$", ""):gsub("-", " "):gsub("^%l", string.upper)
  local date = os.date("%Y-%m-%d %H:%M")

  return table.concat({
    "---",
    "title: " .. title,
    "date: " .. date,
    "draft: false",
    "tags:",
    "  - ",
    "---",
    "",
    "# " .. title,
    "",
    "",
  }, "\n")
end

-- Main function: Follow link or create new file
function M.follow_or_create()
  -- Extract link path
  local link_path = M.extract_link_path()

  if not link_path or link_path == "" then
    vim.notify("❌ No link found under cursor", vim.log.levels.WARN)
    return
  end

  -- Add .md extension if missing and auto_add enabled
  if M.config.auto_add_extension and not link_path:match("%.md$") then
    link_path = link_path .. ".md"
  end

  -- Build full path
  local full_path
  if link_path:match("^/") or link_path:match("^~") then
    -- Absolute path
    full_path = vim.fn.expand(link_path)
  else
    -- Relative to Zettelkasten directory
    full_path = M.config.zettelkasten_dir .. "/" .. link_path
  end

  -- Check if file exists
  local file_exists = vim.fn.filereadable(full_path) == 1

  if file_exists then
    -- File exists: open it
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.notify("📂 Opened: " .. link_path, vim.log.levels.INFO)
  else
    -- File doesn't exist: create it
    local dir = vim.fn.fnamemodify(full_path, ":h")

    -- Create directory if needed
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end

    -- Open new file
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))

    -- Insert frontmatter template
    local frontmatter = M.generate_frontmatter(vim.fn.fnamemodify(full_path, ":t"))
    local lines = vim.split(frontmatter, "\n")
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

    -- Position cursor after "tags:" for immediate input
    vim.api.nvim_win_set_cursor(0, { 5, 4 })
    vim.cmd("startinsert!")

    vim.notify("✨ Created: " .. link_path, vim.log.levels.INFO)
  end
end

return M
