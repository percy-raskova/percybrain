-- PercyBrain Quick Capture Module
-- Purpose: Fast note creation with distraction-free mode
-- Features: Prompt for title, timestamped filenames, auto-Goyo

local M = {}

-- Configuration
local config = {
  zettel_path = vim.fn.expand("~/Zettelkasten"),
  inbox_path = vim.fn.expand("~/Zettelkasten/inbox"),
  template_path = vim.fn.expand("~/Zettelkasten/templates"),
}

-- Generate timestamp in YYYYMMDDHHMMSS format
local function timestamp()
  return os.date("%Y%m%d%H%M%S")
end

-- Create Zettelkasten-style filename: YYYYMMDDHHMMSS-title.md
local function create_filename(title)
  -- Sanitize title for filename
  local safe_title = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
  return string.format("%s-%s.md", timestamp(), safe_title)
end

-- Create YAML front matter for note
local function create_frontmatter(title, tags)
  tags = tags or { "inbox", "quick-capture" }
  local tag_string = table.concat(
    vim.tbl_map(function(tag)
      return "  - " .. tag
    end, tags),
    "\n"
  )

  return string.format(
    [[---
title: "%s"
date: %s
tags:
%s
---

]],
    title,
    os.date("%Y-%m-%d %H:%M:%S"),
    tag_string
  )
end

-- Prompt for new note (with type selection)
M.prompt_new_note = function()
  local note_types = {
    "Zettelkasten note (permanent)",
    "Daily journal entry",
    "Fleeting note (inbox)",
    "Literature note (with source)",
    "Project note",
    "Meeting notes",
  }

  vim.ui.select(note_types, {
    prompt = "Select note type:",
    format_item = function(item)
      return "📝 " .. item
    end,
  }, function(choice)
    if not choice then
      return
    end

    if choice:match("Zettelkasten") then
      require("config.zettelkasten").new_note()
    elseif choice:match("Daily") then
      require("config.zettelkasten").daily_note()
    elseif choice:match("Fleeting") then
      require("config.zettelkasten").inbox_note()
    elseif choice:match("Literature") then
      M.literature_note()
    elseif choice:match("Project") then
      M.project_note()
    elseif choice:match("Meeting") then
      M.meeting_note()
    end
  end)
end

-- Distraction-free writing: prompt → create → open in Goyo
M.distraction_free_start = function()
  -- Prompt for note title
  vim.ui.input({
    prompt = "📝 Note title: ",
    default = "",
  }, function(title)
    if not title or title == "" then
      vim.notify("⚠️  Note creation cancelled", vim.log.levels.WARN)
      return
    end

    -- Create filename with timestamp
    local filename = create_filename(title)
    local filepath = config.inbox_path .. "/" .. filename

    -- Ensure inbox directory exists
    vim.fn.mkdir(config.inbox_path, "p")

    -- Create note with front matter
    local frontmatter = create_frontmatter(title, { "inbox", "writing", "distraction-free" })

    -- Write file
    local file = io.open(filepath, "w")
    if file then
      file:write(frontmatter)
      file:write("\n# " .. title .. "\n\n")
      file:close()

      -- Open file
      vim.cmd("edit " .. vim.fn.fnameescape(filepath))

      -- Move cursor to end (after front matter and title)
      vim.cmd("normal! G")
      vim.cmd("startinsert")

      -- Activate Goyo for distraction-free writing
      vim.defer_fn(function()
        vim.cmd("Goyo")
      end, 100)

      vim.notify("✍️  Distraction-free mode activated: " .. filename, vim.log.levels.INFO)
    else
      vim.notify("❌ Failed to create note", vim.log.levels.ERROR)
    end
  end)
end

-- Literature note (with source citation)
M.literature_note = function()
  vim.ui.input({
    prompt = "📚 Literature title: ",
  }, function(title)
    if not title or title == "" then
      return
    end

    vim.ui.input({
      prompt = "🔗 Source (URL or citation): ",
    }, function(source)
      local filename = create_filename(title)
      local filepath = config.zettel_path .. "/" .. filename

      local frontmatter = create_frontmatter(title, { "literature", "reference" })
      local content = frontmatter
        .. "\n# "
        .. title
        .. "\n\n## Source\n"
        .. (source or "")
        .. "\n\n## Summary\n\n## Key Points\n\n## Related Notes\n\n"

      local file = io.open(filepath, "w")
      if file then
        file:write(content)
        file:close()
        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
        vim.notify("📚 Literature note created: " .. filename, vim.log.levels.INFO)
      end
    end)
  end)
end

-- Project note
M.project_note = function()
  vim.ui.input({
    prompt = "🚀 Project name: ",
  }, function(title)
    if not title or title == "" then
      return
    end

    local filename = create_filename(title)
    local filepath = config.zettel_path .. "/projects/" .. filename

    vim.fn.mkdir(config.zettel_path .. "/projects", "p")

    local frontmatter = create_frontmatter(title, { "project", "active" })
    local content = frontmatter
      .. "\n# "
      .. title
      .. "\n\n## Objective\n\n## Tasks\n- [ ] \n\n## Resources\n\n## Timeline\n\n## Notes\n\n"

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
      vim.cmd("edit " .. vim.fn.fnameescape(filepath))
      vim.notify("🚀 Project note created: " .. filename, vim.log.levels.INFO)
    end
  end)
end

-- Meeting notes
M.meeting_note = function()
  vim.ui.input({
    prompt = "👥 Meeting topic: ",
  }, function(title)
    if not title or title == "" then
      return
    end

    local filename = create_filename(title)
    local filepath = config.zettel_path .. "/meetings/" .. filename

    vim.fn.mkdir(config.zettel_path .. "/meetings", "p")

    local frontmatter = create_frontmatter(title, { "meeting", "notes" })
    local content = frontmatter
      .. "\n# "
      .. title
      .. "\n\n## Attendees\n- \n\n## Agenda\n1. \n\n## Discussion\n\n## Action Items\n- [ ] \n\n## Follow-up\n\n"

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
      vim.cmd("edit " .. vim.fn.fnameescape(filepath))
      vim.notify("👥 Meeting notes created: " .. filename, vim.log.levels.INFO)
    end
  end)
end

return M
