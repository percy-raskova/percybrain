-- PercyBrain AI Meta-Metrics Dashboard
-- Purpose: AI-powered insights about your knowledge network
-- Features: Link density, note growth, tag analysis, AI suggestions

local M = {}

-- Configuration
local config = {
  zettel_path = vim.fn.expand("~/Zettelkasten"),
  ollama_url = "http://localhost:11434",
  ollama_model = "llama3.2",
  analysis_cache_time = 300, -- 5 minutes
  auto_analyze_on_save = true,
}

-- Cache for analysis results
local cache = {
  last_analysis = 0,
  metrics = nil,
  ai_suggestions = nil,
}

-- Analyze note growth over time
local function analyze_growth()
  local notes_by_date = {}
  local find_cmd = string.format('find "%s" -name "*.md" -type f -printf "%%T@\\t%%p\\n"', config.zettel_path)
  local files = vim.fn.systemlist(find_cmd)

  for _, line in ipairs(files) do
    local timestamp, _ = line:match("([^%s]+)%s+(.+)")
    if timestamp then
      local date = os.date("%Y-%m-%d", tonumber(timestamp))
      notes_by_date[date] = (notes_by_date[date] or 0) + 1
    end
  end

  -- Get last 7 days
  local growth_data = {}
  for i = 6, 0, -1 do
    local date = os.date("%Y-%m-%d", os.time() - i * 86400)
    table.insert(growth_data, {
      date = date,
      count = notes_by_date[date] or 0,
    })
  end

  return growth_data
end

-- Analyze tag distribution
local function analyze_tags()
  local tag_counts = {}
  local find_cmd = string.format('find "%s" -name "*.md" -type f', config.zettel_path)
  local files = vim.fn.systemlist(find_cmd)

  for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
      local content = file:read("*all")
      file:close()

      -- Extract tags from front matter
      for tag in content:gmatch("tags:%s*%[([^%]]+)%]") do
        for t in tag:gmatch("[%w%-]+") do
          tag_counts[t] = (tag_counts[t] or 0) + 1
        end
      end

      -- Extract hashtags from content
      for tag in content:gmatch("#([%w%-]+)") do
        tag_counts[tag] = (tag_counts[tag] or 0) + 1
      end
    end
  end

  -- Sort by frequency
  local sorted_tags = {}
  for tag, count in pairs(tag_counts) do
    table.insert(sorted_tags, { tag = tag, count = count })
  end
  table.sort(sorted_tags, function(a, b)
    return a.count > b.count
  end)

  return sorted_tags
end

-- Calculate link density metrics
local function analyze_link_density()
  local total_notes = 0
  local total_links = 0
  local hub_notes = 0 -- Notes with 5+ links
  local orphan_notes = 0 -- Notes with 0 links

  local find_cmd = string.format('find "%s" -name "*.md" -type f', config.zettel_path)
  local files = vim.fn.systemlist(find_cmd)

  for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
      local content = file:read("*all")
      file:close()

      total_notes = total_notes + 1

      -- Count wiki links [[link]]
      local link_count = 0
      for _ in content:gmatch("%[%[.-%]%]") do
        link_count = link_count + 1
      end

      total_links = total_links + link_count

      if link_count >= 5 then
        hub_notes = hub_notes + 1
      elseif link_count == 0 then
        orphan_notes = orphan_notes + 1
      end
    end
  end

  return {
    total_notes = total_notes,
    total_links = total_links,
    avg_density = total_notes > 0 and (total_links / total_notes) or 0,
    hub_notes = hub_notes,
    orphan_notes = orphan_notes,
    orphan_percentage = total_notes > 0 and (orphan_notes / total_notes) * 100 or 0,
  }
end

-- AI analysis using Ollama (fast, <30 seconds)
local function get_ai_suggestions(current_note_content)
  -- Lightweight AI analysis - just get suggestions
  local prompt = string.format(
    [[Analyze this note and provide 3 brief suggestions for connections or improvements.
Be concise (max 50 words total). Format as:
1. [suggestion]
2. [suggestion]
3. [suggestion]

Note content:
%s]],
    current_note_content:sub(1, 1000) -- Limit to 1000 chars for speed
  )

  local ollama_cmd = string.format(
    [[curl -s -X POST %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}' | jq -r '.response']],
    config.ollama_url,
    config.ollama_model,
    vim.fn.json_encode(prompt)
  )

  local response = vim.fn.system(ollama_cmd)

  if vim.v.shell_error == 0 and response ~= "" then
    return response
  else
    return nil
  end
end

-- Generate full metrics
local function collect_metrics()
  local now = os.time()

  -- Use cache if recent
  if cache.metrics and (now - cache.last_analysis) < config.analysis_cache_time then
    return cache.metrics
  end

  vim.notify("📊 Analyzing network metrics...", vim.log.levels.INFO)

  local metrics = {
    growth = analyze_growth(),
    tags = analyze_tags(),
    link_density = analyze_link_density(),
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
  }

  cache.metrics = metrics
  cache.last_analysis = now

  return metrics
end

-- Display dashboard in floating window
M.toggle = function()
  local metrics = collect_metrics()

  local lines = {}

  -- Header
  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║           🤖 PERCYBRAIN AI META-METRICS DASHBOARD 🤖                 ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")
  table.insert(lines, "  Last updated: " .. metrics.timestamp)
  table.insert(lines, "")

  -- Link Density Section
  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                        LINK DENSITY                                   ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")
  table.insert(lines, string.format("  📝 Total Notes:       %d", metrics.link_density.total_notes))
  table.insert(lines, string.format("  🔗 Total Links:       %d", metrics.link_density.total_links))
  table.insert(lines, string.format("  📊 Average Density:   %.2f links/note", metrics.link_density.avg_density))
  table.insert(lines, string.format("  ⬢  Hub Notes:         %d (5+ links)", metrics.link_density.hub_notes))
  table.insert(
    lines,
    string.format(
      "  ○  Orphan Notes:      %d (%.1f%%)",
      metrics.link_density.orphan_notes,
      metrics.link_density.orphan_percentage
    )
  )
  table.insert(lines, "")

  -- Note Growth Section
  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                      NOTE GROWTH (7 DAYS)                             ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")

  for _, day in ipairs(metrics.growth) do
    local bar = string.rep("█", day.count)
    table.insert(lines, string.format("  %s: %s %d", day.date, bar, day.count))
  end
  table.insert(lines, "")

  -- Tag Analysis Section
  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                      TOP TAGS (by frequency)                          ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")

  for i, tag_data in ipairs(metrics.tags) do
    if i > 10 then
      table.insert(lines, "  ... (" .. (#metrics.tags - 10) .. " more tags)")
      break
    end
    table.insert(lines, string.format("  #%-20s %d notes", tag_data.tag, tag_data.count))
  end
  table.insert(lines, "")

  -- AI Suggestions Section (if available)
  if cache.ai_suggestions then
    table.insert(
      lines,
      "╔═══════════════════════════════════════════════════════════════════════╗"
    )
    table.insert(lines, "║                    AI SUGGESTED CONNECTIONS                           ║")
    table.insert(
      lines,
      "╚═══════════════════════════════════════════════════════════════════════╝"
    )
    table.insert(lines, "")
    table.insert(lines, cache.ai_suggestions)
    table.insert(lines, "")
  end

  -- Footer
  table.insert(
    lines,
    "╔═══════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║  Press 'r' to refresh | 'q' to close | 'g' for network graph          ║")
  table.insert(
    lines,
    "╚═══════════════════════════════════════════════════════════════════════╝"
  )

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "text")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Create floating window
  local width = 77
  local height = math.min(vim.o.lines - 6, #lines + 2)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "double",
    title = " 🤖 AI METRICS DASHBOARD 🤖 ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Keymaps
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "r",
    "<cmd>close | lua require('percybrain.dashboard').toggle()<cr>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "g",
    "<cmd>close | lua require('percybrain.network-graph').show_borg()<cr>",
    { noremap = true, silent = true }
  )

  vim.notify("📊 Dashboard loaded - Press 'q' to close, 'r' to refresh", vim.log.levels.INFO)
end

-- Auto-analyze on save (lightweight)
M.analyze_on_save = function()
  if not config.auto_analyze_on_save then
    return
  end

  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Run AI analysis in background (non-blocking)
  vim.defer_fn(function()
    local suggestions = get_ai_suggestions(content)
    if suggestions then
      cache.ai_suggestions = suggestions
    end
  end, 100)
end

-- Setup auto-analyze on save
M.setup = function()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.md" },
    callback = function()
      M.analyze_on_save()
    end,
  })
end

return M
