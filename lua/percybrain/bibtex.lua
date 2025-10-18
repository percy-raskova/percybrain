-- PercyBrain BibTeX Citation Library Browser
-- Purpose: Browse, search, and insert BibTeX citations
-- Features: Fuzzy search, citation preview, auto-insert

local M = {}

-- Configuration
local config = {
  bibtex_path = vim.fn.expand("~/Zettelkasten/bibliography.bib"),
}

-- Parse BibTeX file
local function parse_bibtex()
  local file = io.open(config.bibtex_path, "r")
  if not file then
    return {}
  end

  local content = file:read("*all")
  file:close()

  local entries = {}
  local current_entry = nil

  -- Parse BibTeX entries
  for line in content:gmatch("[^\r\n]+") do
    -- Match entry start: @article{key,
    local entry_type, cite_key = line:match("^@(%w+){([^,]+),")
    if entry_type and cite_key then
      if current_entry then
        table.insert(entries, current_entry)
      end
      current_entry = {
        type = entry_type,
        key = cite_key,
        fields = {},
        raw = line .. "\n",
      }
    elseif current_entry then
      current_entry.raw = current_entry.raw .. line .. "\n"

      -- Match field: title = {...},
      local field, value = line:match("%s*(%w+)%s*=%s*{([^}]+)}")
      if field and value then
        current_entry.fields[field] = value
      end

      -- Check for entry end
      if line:match("^}") then
        table.insert(entries, current_entry)
        current_entry = nil
      end
    end
  end

  -- Add last entry if exists
  if current_entry then
    table.insert(entries, current_entry)
  end

  return entries
end

-- Format entry for display
local function format_entry(entry)
  local title = entry.fields.title or "No title"
  local author = entry.fields.author or "No author"
  local year = entry.fields.year or "N/A"

  return string.format("[@%s] %s - %s (%s)", entry.key, author, title, year)
end

-- Browse citations with Telescope
M.browse = function()
  local entries = parse_bibtex()

  if #entries == 0 then
    vim.notify("📖 No citations found in " .. config.bibtex_path, vim.log.levels.WARN)
    return
  end

  -- Use Telescope for fuzzy search
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "📖 BibTeX Citation Library",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = format_entry(entry),
            ordinal = entry.key .. " " .. (entry.fields.title or "") .. " " .. (entry.fields.author or ""),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          M.insert_citation(selection.value)
        end)

        -- Preview full entry on <C-p>
        map("i", "<C-p>", function()
          local selection = action_state.get_selected_entry()
          M.preview_entry(selection.value)
        end)

        return true
      end,
    })
    :find()
end

-- Insert citation at cursor
M.insert_citation = function(entry)
  -- Insert cite key in markdown format: [@key]
  local cite = "[@" .. entry.key .. "]"
  vim.api.nvim_put({ cite }, "c", true, true)
  vim.notify("📖 Citation inserted: " .. entry.key, vim.log.levels.INFO)
end

-- Preview full entry
M.preview_entry = function(entry)
  local lines = {}

  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                    BIBTEX ENTRY PREVIEW                               ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")
  table.insert(lines, "Cite Key: @" .. entry.key)
  table.insert(lines, "Type:     " .. entry.type)
  table.insert(lines, "")
  table.insert(lines, "Fields:")
  table.insert(lines, "───────")

  for field, value in pairs(entry.fields) do
    table.insert(lines, string.format("  %-12s: %s", field, value))
  end

  table.insert(lines, "")
  table.insert(lines, "Raw BibTeX:")
  table.insert(lines, "───────────")
  for line in entry.raw:gmatch("[^\r\n]+") do
    table.insert(lines, "  " .. line)
  end

  -- Create preview buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "text")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Create floating window
  local width = 77
  local height = math.min(vim.o.lines - 10, #lines + 2)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "double",
    title = " 📖 CITATION PREVIEW 📖 ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Keymaps
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
end

-- Search citations by keyword
M.search = function(keyword)
  local entries = parse_bibtex()
  local results = {}

  keyword = keyword:lower()

  for _, entry in ipairs(entries) do
    local searchable = (entry.key .. " " .. (entry.fields.title or "") .. " " .. (entry.fields.author or "")):lower()

    if searchable:find(keyword, 1, true) then
      table.insert(results, entry)
    end
  end

  return results
end

-- Add new citation from current note metadata
M.add_from_note = function()
  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
  local content = table.concat(lines, "\n")

  -- Extract title from front matter
  local title = content:match('title:%s*"?([^"\n]+)"?')

  -- Extract source URL
  local source = content:match('source:%s*"?([^"\n]+)"?')

  if not title then
    vim.notify("⚠️  No title found in front matter", vim.log.levels.WARN)
    return
  end

  -- Generate cite key from title
  local cite_key = title:lower():gsub("%s+", ""):sub(1, 20) .. os.date("%Y")

  -- Create BibTeX entry
  local bibtex = string.format(
    [[@misc{%s,
  title = {%s},
  url = {%s},
  year = {%s},
  note = {From PercyBrain Zettelkasten}
}
]],
    cite_key,
    title,
    source or "",
    os.date("%Y")
  )

  -- Append to bibliography
  local file = io.open(config.bibtex_path, "a")
  if file then
    file:write("\n" .. bibtex .. "\n")
    file:close()
    vim.notify("📖 Citation added: @" .. cite_key, vim.log.levels.INFO)

    -- Copy cite key to clipboard
    vim.fn.setreg("+", "@" .. cite_key)
  else
    vim.notify("❌ Failed to write to " .. config.bibtex_path, vim.log.levels.ERROR)
  end
end

-- Export citations to current note
M.export_to_note = function()
  local entries = parse_bibtex()

  vim.ui.select(entries, {
    prompt = "Select citations to export:",
    format_item = format_entry,
  }, function(entry)
    if not entry then
      return
    end

    -- Append entry to current buffer
    local lines = { "", "## References", "", entry.raw }
    vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)

    vim.notify("📖 Citation exported to note", vim.log.levels.INFO)
  end)
end

return M
