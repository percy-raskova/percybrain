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

  -- Set up keymaps
  M.setup_keymaps()

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

-- Keymaps for Zettelkasten workflow
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- Quick capture (z = Zettelkasten)
  vim.keymap.set("n", "<leader>zn", M.new_note, opts)
  vim.keymap.set("n", "<leader>zd", M.daily_note, opts)
  vim.keymap.set("n", "<leader>zi", M.inbox_note, opts)

  -- Search & navigation
  vim.keymap.set("n", "<leader>zf", M.find_notes, opts)
  vim.keymap.set("n", "<leader>zg", M.search_notes, opts)
  vim.keymap.set("n", "<leader>zb", M.backlinks, opts)

  -- Publishing
  vim.keymap.set("n", "<leader>zp", M.publish, opts)

  -- Focus modes (f = focus)
  vim.keymap.set("n", "<leader>fz", "<cmd>ZenMode<cr>", opts)
end

-- Create new note with template
function M.new_note()
  local title = vim.fn.input("Note title: ")
  if title == "" then
    return
  end

  -- Try to use template system
  M.select_template(function(template_name)
    local timestamp = os.date("%Y%m%d%H%M")
    local filename = string.format("%s-%s.md", timestamp, title:gsub(" ", "-"):lower())
    local filepath = M.config.home .. "/" .. filename

    local content
    if template_name then
      -- Load and apply template
      local template_content = M.load_template(template_name)
      if template_content then
        content = M.apply_template(template_content, title)
      end
    end

    -- Fallback to default frontmatter if no template
    if not content then
      local lines = {
        "---",
        "title: " .. title,
        "date: " .. os.date("%Y-%m-%d %H:%M"),
        "tags: []",
        "---",
        "",
        "# " .. title,
        "",
        "",
      }
      content = table.concat(lines, "\n")
    end

    -- Write file
    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
      vim.cmd("edit " .. filepath)
    else
      vim.notify("❌ Failed to create note", vim.log.levels.ERROR)
    end
  end)
end

-- Create/open daily note
function M.daily_note()
  local date = os.date("%Y-%m-%d")
  local filepath = M.config.daily .. "/" .. date .. ".md"

  if vim.fn.filereadable(filepath) == 0 then
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

-- Publish to static site
function M.publish()
  print("📤 Publishing to static site...")

  -- Copy notes to export path
  local cmd = string.format('rsync -av --exclude="inbox" %s/ %s/', M.config.home, M.config.export_path)
  vim.fn.system(cmd)

  -- Build static site (adjust for your generator)
  local blog_dir = vim.fn.fnamemodify(M.config.export_path, ":h:h")
  vim.fn.system("cd " .. blog_dir .. " && hugo")

  print("✅ Published successfully!")
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

-- Set up user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("PercyNew", M.new_note, {})
  vim.api.nvim_create_user_command("PercyDaily", M.daily_note, {})
  vim.api.nvim_create_user_command("PercyInbox", M.inbox_note, {})
  vim.api.nvim_create_user_command("PercyPublish", M.publish, {})
  vim.api.nvim_create_user_command("PercyPreview", function()
    local blog_dir = vim.fn.fnamemodify(M.config.export_path, ":h:h")
    vim.fn.system("cd " .. blog_dir .. " && hugo server -D &")
    print("🌐 Preview server started at http://localhost:1313")
  end, {})
  vim.api.nvim_create_user_command("PercyOrphans", M.find_orphans, { desc = "Find orphan notes (no links)" })
  vim.api.nvim_create_user_command("PercyHubs", M.find_hubs, { desc = "Find hub notes (most connected)" })
end

return M
