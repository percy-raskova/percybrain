-- PercyBrain Configuration
-- Personal knowledge management system powered by Neovim

local M = {}

-- Configuration
M.config = {
  -- Path to your Zettelkasten
  home = vim.fn.expand("~/Zettelkasten"),
  inbox = vim.fn.expand("~/Zettelkasten/inbox"),
  daily = vim.fn.expand("~/Zettelkasten/daily"),
  templates = vim.fn.expand("~/Zettelkasten/templates"),

  -- Static site export
  export_path = vim.fn.expand("~/blog/content/zettelkasten"),
}

-- Create directories if they don't exist
function M.setup()
  local dirs = {
    M.config.home,
    M.config.inbox,
    M.config.daily,
    M.config.templates,
  }

  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end

  -- Set up commands
  M.setup_commands()
end

-- Template system
function M.load_template(template_name)
  local template_path = M.config.templates .. "/" .. template_name .. ".md"

  if vim.fn.filereadable(template_path) == 1 then
    local lines = vim.fn.readfile(template_path)
    return table.concat(lines, "\n")
  else
    return nil
  end
end

function M.select_template(callback)
  local templates = vim.fn.globpath(M.config.templates, "*.md", false, true)

  if #templates == 0 then
    vim.notify("⚠️  No templates found in " .. M.config.templates, vim.log.levels.WARN)
    return callback(nil)
  end

  -- Extract template names
  local template_names = {}
  for _, path in ipairs(templates) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    table.insert(template_names, name)
  end

  -- Use Telescope picker
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "📝 Select Template",
      finder = finders.new_table({
        results = template_names,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          callback(selection[1])
        end)
        return true
      end,
    })
    :find()
end

function M.apply_template(template_content, title)
  local timestamp = os.date("%Y%m%d%H%M")
  local date = os.date("%Y-%m-%d %H:%M")

  -- Replace template variables
  local content = template_content:gsub("{{title}}", title):gsub("{{date}}", date):gsub("{{timestamp}}", timestamp)

  return content
end

-- Keymaps now managed in lua/config/keymaps/zettelkasten.lua
-- Business logic only below

-- Create new note with minimal Quartz-compatible frontmatter
-- Writing-first workflow: just frontmatter + title + blank lines
-- Use AI commands later to format into IWE MOC structure
function M.new_note()
  local title = vim.fn.input("Note title: ")
  if title == "" then
    return
  end

  local timestamp = os.date("%Y%m%d%H%M")
  local filename = string.format("%s-%s.md", timestamp, title:gsub(" ", "-"):lower())
  local filepath = M.config.home .. "/" .. filename

  -- Minimal Quartz-compatible frontmatter
  local lines = {
    "---",
    'title: "' .. title .. '"',
    "date: " .. os.date("%Y-%m-%d"),
    "draft: false",
    "tags: []",
    "---",
    "",
    "# " .. title,
    "",
    "",
  }
  local content = table.concat(lines, "\n")

  -- Write file
  local file = io.open(filepath, "w")
  if file then
    file:write(content)
    file:close()
    vim.cmd("edit " .. filepath)

    -- Position cursor after blank lines (line 10, ready to write)
    vim.api.nvim_win_set_cursor(0, { 10, 0 })
    vim.cmd("startinsert")

    vim.notify("✨ New note created - write freely, format with AI later!", vim.log.levels.INFO)
  else
    vim.notify("❌ Failed to create note", vim.log.levels.ERROR)
  end
end

-- Create/open daily note (with optional date parameter)
function M.daily_note(date)
  -- Default to today if no date provided
  date = date or os.date("%Y-%m-%d")

  local filepath = M.config.daily .. "/" .. date .. ".md"

  if vim.fn.filereadable(filepath) == 0 then
    -- Try to use daily template
    local template = M.load_template("daily")
    local content

    if template then
      -- Apply template with date variable
      content = M.apply_template(template, "Daily Note - " .. date)
      content = content:gsub("{{date}}", date)
      vim.fn.writefile(vim.split(content, "\n"), filepath)
      vim.notify("📅 Created daily note for " .. date, vim.log.levels.INFO)
    else
      -- Fallback if no template
      local lines = {
        "---",
        "title: Daily Note " .. date,
        "date: " .. date,
        "tags: [daily]",
        "---",
        "",
        "# " .. date,
        "",
        "## Notes",
        "",
      }
      vim.fn.writefile(lines, filepath)
      vim.notify("📅 Created daily note for " .. date .. " (no template)", vim.log.levels.WARN)
    end
  end

  vim.cmd("edit " .. filepath)
end

-- Quick inbox capture
function M.inbox_note()
  local timestamp = os.date("%Y%m%d%H%M%S")
  local filepath = M.config.inbox .. "/" .. timestamp .. ".md"

  local lines = {
    "---",
    "title: Quick Note",
    "date: " .. os.date("%Y-%m-%d %H:%M:%S"),
    "tags: [inbox]",
    "---",
    "",
    "",
  }

  vim.fn.writefile(lines, filepath)
  vim.cmd("edit " .. filepath)
  vim.cmd("startinsert")
end

-- Find notes with telescope
function M.find_notes()
  require("telescope.builtin").find_files({
    cwd = M.config.home,
    prompt_title = "🗂️  Find Note",
  })
end

-- Search notes content
function M.search_notes()
  require("telescope.builtin").live_grep({
    cwd = M.config.home,
    prompt_title = "🔍 Search Notes",
  })
end

-- Find backlinks to current file
function M.backlinks()
  local current_file = vim.fn.expand("%:t:r") -- Filename without extension

  require("telescope.builtin").live_grep({
    cwd = M.config.home,
    prompt_title = "🔗 Backlinks to " .. current_file,
    -- Search for Markdown links: [text](filename) or [text](filename.md)
    default_text = "](" .. current_file,
  })
end

-- Publish to static site (mkdocs)
function M.publish()
  vim.notify("📤 Publishing to static site (mkdocs)...", vim.log.levels.INFO)

  -- Copy notes to export path
  local cmd =
    string.format('rsync -av --exclude="inbox" --exclude="daily" %s/ %s/', M.config.home, M.config.export_path)
  local rsync_output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("❌ rsync failed: " .. rsync_output, vim.log.levels.ERROR)
    return
  end

  -- Build static site with mkdocs
  local blog_dir = vim.fn.fnamemodify(M.config.export_path, ":h:h")
  local build_cmd = "cd " .. blog_dir .. " && mkdocs build"
  local build_output = vim.fn.system(build_cmd)

  if vim.v.shell_error == 0 then
    vim.notify("✅ Published successfully with mkdocs!", vim.log.levels.INFO)
  else
    vim.notify("❌ mkdocs build failed: " .. build_output, vim.log.levels.ERROR)
  end
end

-- Preview site with mkdocs serve
function M.preview_site()
  local blog_dir = vim.fn.fnamemodify(M.config.export_path, ":h:h")
  vim.notify("🌐 Starting mkdocs preview server...", vim.log.levels.INFO)

  -- Run in background
  vim.fn.jobstart("cd " .. blog_dir .. " && mkdocs serve", {
    detach = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ mkdocs server stopped", vim.log.levels.INFO)
      else
        vim.notify("❌ mkdocs server exited with code: " .. code, vim.log.levels.ERROR)
      end
    end,
  })

  vim.notify("🌐 Preview server started at http://localhost:8000", vim.log.levels.INFO)
end

-- Build only (no serve)
function M.build_site()
  local blog_dir = vim.fn.fnamemodify(M.config.export_path, ":h:h")
  vim.notify("🔨 Building site with mkdocs...", vim.log.levels.INFO)

  local build_cmd = "cd " .. blog_dir .. " && mkdocs build"
  local output = vim.fn.system(build_cmd)

  if vim.v.shell_error == 0 then
    vim.notify("✅ Build complete!", vim.log.levels.INFO)
  else
    vim.notify("❌ Build failed: " .. output, vim.log.levels.ERROR)
  end
end

-- Knowledge graph analysis
function M.analyze_links()
  local notes = {}
  -- Match Markdown links: [text](target.md) or [text](target)
  -- Captures: (1) display text, (2) target filename
  local link_pattern = "%[([^%]]+)%]%(([^%)]+)%)"

  -- Scan all markdown files
  local files = vim.fn.globpath(M.config.home, "**/*.md", false, true)

  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t:r")
    local content = table.concat(vim.fn.readfile(filepath), "\n")

    -- Count outgoing links
    local outgoing = {}
    for _, target in content:gmatch(link_pattern) do
      -- Normalize filename: strip .md extension and path if present
      local normalized = target:gsub("%.md$", ""):match("([^/]+)$") or target
      table.insert(outgoing, normalized)
    end

    -- Count incoming links (backlinks)
    local incoming = 0
    for _, other_file in ipairs(files) do
      if other_file ~= filepath then
        local other_content = table.concat(vim.fn.readfile(other_file), "\n")
        -- Check for both [text](filename) and [text](filename.md)
        -- Escape filename for pattern matching
        local escaped_filename = vim.pesc(filename)
        if
          other_content:match("%]%(" .. escaped_filename .. "%)")
          or other_content:match("%]%(" .. escaped_filename .. "%.md%)")
        then
          incoming = incoming + 1
        end
      end
    end

    notes[filename] = {
      path = filepath,
      outgoing = #outgoing,
      incoming = incoming,
      total = #outgoing + incoming,
    }
  end

  return notes
end

function M.find_orphans()
  vim.notify("🔍 Analyzing knowledge graph...", vim.log.levels.INFO)

  local notes = M.analyze_links()
  local orphans = {}

  for name, data in pairs(notes) do
    if data.total == 0 then
      table.insert(orphans, {
        name = name,
        path = data.path,
      })
    end
  end

  if #orphans == 0 then
    vim.notify("✅ No orphan notes found!", vim.log.levels.INFO)
    return
  end

  -- Display in Telescope
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")

  pickers
    .new({}, {
      prompt_title = "🏝️  Orphan Notes (" .. #orphans .. " found)",
      finder = finders.new_table({
        results = orphans,
        entry_maker = function(entry)
          return {
            value = entry.path,
            display = "📄 " .. entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions.get_selected_entry(prompt_bufnr)
          actions.close(prompt_bufnr)
          vim.cmd("edit " .. selection.value)
        end)
        return true
      end,
    })
    :find()
end

function M.find_hubs()
  vim.notify("🔍 Analyzing knowledge graph...", vim.log.levels.INFO)

  local notes = M.analyze_links()
  local hubs = {}

  for name, data in pairs(notes) do
    table.insert(hubs, {
      name = name,
      path = data.path,
      connections = data.total,
      incoming = data.incoming,
      outgoing = data.outgoing,
    })
  end

  -- Sort by total connections
  table.sort(hubs, function(a, b)
    return a.connections > b.connections
  end)

  -- Take top 10
  local top_hubs = {}
  for i = 1, math.min(10, #hubs) do
    if hubs[i].connections > 0 then
      table.insert(top_hubs, hubs[i])
    end
  end

  if #top_hubs == 0 then
    vim.notify("⚠️  No connected notes found", vim.log.levels.WARN)
    return
  end

  -- Display in Telescope
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")

  pickers
    .new({}, {
      prompt_title = "🌟 Hub Notes (Top 10 Most Connected)",
      finder = finders.new_table({
        results = top_hubs,
        entry_maker = function(entry)
          return {
            value = entry.path,
            display = string.format(
              "🔗 %s (↓%d ↑%d = %d)",
              entry.name,
              entry.incoming,
              entry.outgoing,
              entry.connections
            ),
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions.get_selected_entry(prompt_bufnr)
          actions.close(prompt_bufnr)
          vim.cmd("edit " .. selection.value)
        end)
        return true
      end,
    })
    :find()
end

-- Open wiki browser (file tree) in Zettelkasten directory
function M.wiki_browser()
  -- Change to Zettelkasten directory and open NvimTree
  vim.cmd("cd " .. M.config.home)
  vim.cmd("NvimTreeOpen")
end

-- Calendar picker: Select date for daily note
function M.show_calendar()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- Generate date range (-30 to +30 days)
  local dates = {}
  local current_time = os.time()
  local seconds_per_day = 86400

  for offset = -30, 30 do
    local timestamp = current_time + (offset * seconds_per_day)
    local date_key = os.date("%Y-%m-%d", timestamp)
    local display_text = os.date("%A, %B %d, %Y", timestamp)

    -- Mark today with emoji
    if offset == 0 then
      display_text = "📅 TODAY: " .. display_text
    end

    -- Check if daily note exists
    local daily_path = M.config.daily .. "/" .. date_key .. ".md"
    local exists = vim.fn.filereadable(daily_path) == 1
    if exists then
      display_text = "✅ " .. display_text
    else
      display_text = "➕ " .. display_text
    end

    table.insert(dates, {
      date = date_key,
      display = display_text,
      path = daily_path,
    })
  end

  -- Telescope picker
  pickers
    .new({}, {
      prompt_title = "📅 Select Date for Daily Note",
      finder = finders.new_table({
        results = dates,
        entry_maker = function(entry)
          return {
            value = entry.date,
            display = entry.display,
            ordinal = entry.display,
            path = entry.path,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Daily Note Preview",
        define_preview = function(self, entry, status)
          if vim.fn.filereadable(entry.path) == 1 then
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.fn.readfile(entry.path))
          else
            vim.api.nvim_buf_set_lines(
              self.state.bufnr,
              0,
              -1,
              false,
              { "No daily note for this date yet.", "", "Press <CR> to create." }
            )
          end
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          M.daily_note(selection.value)
        end)
        return true
      end,
    })
    :find()
end

-- Tag browser: Extract and browse tags with frequency
function M.show_tags()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Extract tags via ripgrep
  local cmd = {
    "rg",
    "--no-heading",
    "--with-filename",
    "^tags:",
    M.config.home,
  }

  local results = vim.fn.systemlist(cmd)
  local tags = {} -- Frequency table

  -- Parse tags from each result
  for _, line in ipairs(results) do
    -- Extract tag array: tags: [tag1, tag2, tag3]
    local tag_match = line:match("tags:%s*%[(.-)%]")

    if tag_match then
      -- Split by comma
      for tag in tag_match:gmatch("[^,]+") do
        -- Clean up: remove quotes, brackets, whitespace
        tag = tag:gsub("[%[%]'\"%s]", "")

        if tag ~= "" then
          tags[tag] = (tags[tag] or 0) + 1
        end
      end
    end
  end

  -- Convert to sorted list
  local tag_list = {}
  for tag, count in pairs(tags) do
    table.insert(tag_list, { tag = tag, count = count })
  end

  -- Sort by count (descending)
  table.sort(tag_list, function(a, b)
    return a.count > b.count
  end)

  -- Handle empty results
  if #tag_list == 0 then
    vim.notify("ℹ️  No tags found in Zettelkasten", vim.log.levels.INFO)
    return
  end

  -- Telescope picker
  pickers
    .new({}, {
      prompt_title = "🏷️  Tags (" .. #tag_list .. " unique)",
      finder = finders.new_table({
        results = tag_list,
        entry_maker = function(entry)
          return {
            value = entry.tag,
            display = string.format("%s (%d notes)", entry.tag, entry.count),
            ordinal = entry.tag,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          M.search_notes(selection.value)
        end)
        return true
      end,
    })
    :find()
end

-- Follow link under cursor using IWE LSP
function M.follow_link()
  -- Check if IWE LSP is attached
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local iwe_attached = false

  for _, client in ipairs(clients) do
    if client.name == "iwes" then
      iwe_attached = true
      break
    end
  end

  if not iwe_attached then
    vim.notify("⚠️  IWE LSP not attached. Ensure 'iwes' is running for markdown files.", vim.log.levels.WARN)
    return
  end

  -- Use LSP go-to-definition
  vim.lsp.buf.definition()
end

-- Insert link using IWE LSP code action
function M.insert_link()
  -- Check if IWE LSP is attached
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local iwe_attached = false

  for _, client in ipairs(clients) do
    if client.name == "iwes" then
      iwe_attached = true
      break
    end
  end

  if not iwe_attached then
    vim.notify("⚠️  IWE LSP not attached. Ensure 'iwes' is running for markdown files.", vim.log.levels.WARN)
    return
  end

  -- Trigger IWE link code action
  vim.lsp.buf.code_action({
    filter = function(action)
      -- Match "Link" or "Create Link" actions
      return action.title and action.title:match("[Ll]ink") ~= nil
    end,
    apply = true, -- Auto-apply if only one action matches
  })
end

-- IWE Advanced Refactoring Features (2025-10-22)

-- Extract section to new note (LSP code action)
function M.extract_section()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.title and action.title:match("[Ee]xtract") ~= nil
    end,
    apply = true,
  })
end

-- Inline section from linked note (LSP code action)
function M.inline_section()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.title and action.title:match("[Ii]nline") ~= nil
    end,
    apply = true,
  })
end

-- Normalize links using IWE CLI
function M.normalize_links()
  vim.notify("🔧 Normalizing links in Zettelkasten...", vim.log.levels.INFO)
  local cmd = string.format("cd %s && iwe normalize", M.config.home)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify("✅ Links normalized successfully", vim.log.levels.INFO)
  else
    vim.notify("❌ Link normalization failed: " .. output, vim.log.levels.ERROR)
  end
end

-- Show pathways using IWE CLI
function M.show_pathways()
  vim.notify("🛤️  Generating pathways...", vim.log.levels.INFO)
  local cmd = string.format("cd %s && iwe paths", M.config.home)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    -- Display in new buffer
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
    vim.bo.buftype = "nofile"
    vim.bo.filetype = "markdown"
    vim.notify("📊 Pathways displayed", vim.log.levels.INFO)
  else
    vim.notify("❌ Pathway generation failed: " .. output, vim.log.levels.ERROR)
  end
end

-- Show table of contents using IWE CLI
function M.show_contents()
  vim.notify("📑 Generating table of contents...", vim.log.levels.INFO)
  local cmd = string.format("cd %s && iwe contents", M.config.home)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    -- Display in new buffer
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
    vim.bo.buftype = "nofile"
    vim.bo.filetype = "markdown"
    vim.notify("📚 Contents displayed", vim.log.levels.INFO)
  else
    vim.notify("❌ Contents generation failed: " .. output, vim.log.levels.ERROR)
  end
end

-- Squash notes using IWE CLI
function M.squash_notes()
  -- Get user confirmation
  local confirm = vim.fn.confirm("Squash notes in current directory?", "&Yes\n&No", 2)
  if confirm ~= 1 then
    vim.notify("❌ Squash cancelled", vim.log.levels.INFO)
    return
  end

  vim.notify("🔨 Squashing notes...", vim.log.levels.INFO)
  local cmd = string.format("cd %s && iwe squash", M.config.home)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify("✅ Notes squashed successfully", vim.log.levels.INFO)
  else
    vim.notify("❌ Squash failed: " .. output, vim.log.levels.ERROR)
  end
end

-- Set up user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("PercyNew", M.new_note, { desc = "Create new note with template" })
  vim.api.nvim_create_user_command("PercyDaily", M.daily_note, { desc = "Create/open daily note" })
  vim.api.nvim_create_user_command("PercyInbox", M.inbox_note, { desc = "Quick inbox capture" })
  vim.api.nvim_create_user_command("PercyPublish", M.publish, { desc = "Publish to static site (mkdocs)" })
  vim.api.nvim_create_user_command("PercyPreview", M.preview_site, { desc = "Start mkdocs preview server" })
  vim.api.nvim_create_user_command("PercyBuild", M.build_site, { desc = "Build site with mkdocs" })
  vim.api.nvim_create_user_command("PercyOrphans", M.find_orphans, { desc = "Find orphan notes (no links)" })
  vim.api.nvim_create_user_command("PercyHubs", M.find_hubs, { desc = "Find hub notes (most connected)" })
  vim.api.nvim_create_user_command("PercyWiki", M.wiki_browser, { desc = "Open wiki browser in Zettelkasten" })
end

return M
