-- PercyBrain Network Graph Module
-- Purpose: Cybernetic Borg-style ASCII visualization of note connections
-- Aesthetic: Hexagonal patterns, tech symbols, cybernetic feel

local M = {}

-- Configuration
local config = {
  zettel_path = vim.fn.expand("~/Zettelkasten"),
  max_nodes = 50, -- Limit for performance
  hub_threshold = 3, -- Notes with 3+ connections are hubs
}

-- Borg/cybernetic symbols
local symbols = {
  hub = "⬢", -- Hexagon for hub notes
  node = "◆", -- Diamond for regular notes
  orphan = "○", -- Circle for orphaned notes
  link = "═", -- Double line for connections
  weak_link = "─", -- Single line for weak connections
  junction = "╬", -- Junction point
  corner = "╔╗╚╝", -- Corners
  vertical = "║",
  horizontal = "═",
  grid = "▓", -- Grid pattern
  tech = "⚡◈◇⬡◊", -- Tech symbols for decoration
}

-- Scan Zettelkasten for notes and connections
local function scan_network()
  local notes = {}
  local connections = {}

  -- Find all markdown files
  local find_cmd = string.format('find "%s" -name "*.md" -type f', config.zettel_path)
  local files = vim.fn.systemlist(find_cmd)

  -- Analyze each file
  for _, filepath in ipairs(files) do
    if #notes >= config.max_nodes then
      break
    end

    local filename = vim.fn.fnamemodify(filepath, ":t:r")
    local file = io.open(filepath, "r")

    if file then
      local content = file:read("*all")
      file:close()

      -- Count markdown links [text](link.md) or [text](link)
      local link_count = 0
      for _ in content:gmatch("%[.-%]%(.-%)") do
        link_count = link_count + 1
      end

      -- Extract title from front matter or filename
      local title = content:match('title:%s*"?([^"\n]+)"?') or filename

      table.insert(notes, {
        filename = filename,
        title = title:sub(1, 20), -- Truncate for display
        path = filepath,
        links = link_count,
        is_hub = link_count >= config.hub_threshold,
        is_orphan = link_count == 0,
      })

      connections[filename] = link_count
    end
  end

  return notes, connections
end

-- Generate cybernetic ASCII header
local function generate_header()
  return [[
╔═══════════════════════════════════════════════════════════════════════╗
║  ⬢  PERCYBRAIN NEURAL NETWORK VISUALIZATION  ⬢  BORG COLLECTIVE  ⬢    ║
╚═══════════════════════════════════════════════════════════════════════╝
  ]]
end

-- Generate node representation
local function node_repr(note)
  if note.is_orphan then
    return symbols.orphan .. " " .. note.title .. " [ISOLATED]"
  elseif note.is_hub then
    return symbols.hub .. " " .. note.title .. " [HUB:" .. note.links .. "]"
  else
    return symbols.node .. " " .. note.title .. " [" .. note.links .. "]"
  end
end

-- Generate network topology section
local function generate_topology(notes)
  local lines = {}

  table.insert(
    lines,
    "╔════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                    NETWORK TOPOLOGY                                ║")
  table.insert(
    lines,
    "╚════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")

  -- Sort notes: hubs first, then regular, then orphans
  table.sort(notes, function(a, b)
    if a.is_hub ~= b.is_hub then
      return a.is_hub
    end
    if a.is_orphan ~= b.is_orphan then
      return not a.is_orphan
    end
    return a.links > b.links
  end)

  -- Display nodes
  for i, note in ipairs(notes) do
    if i > 20 then
      table.insert(lines, "  ... (" .. (#notes - 20) .. " more nodes)")
      break
    end
    table.insert(lines, "  " .. node_repr(note))
  end

  return table.concat(lines, "\n")
end

-- Generate ASCII art network graph
local function generate_graph(notes)
  local lines = {}

  table.insert(lines, "")
  table.insert(
    lines,
    "╔════════════════════════════════════════════════════════════════════╗"
  )
  table.insert(lines, "║                 CYBERNETIC NETWORK GRAPH                          ║")
  table.insert(
    lines,
    "╚════════════════════════════════════════════════════════════════════╝"
  )
  table.insert(lines, "")

  -- Create simple ASCII graph representation
  local hubs = vim.tbl_filter(function(n)
    return n.is_hub
  end, notes)
  local regulars = vim.tbl_filter(function(n)
    return not n.is_hub and not n.is_orphan
  end, notes)
  local orphans = vim.tbl_filter(function(n)
    return n.is_orphan
  end, notes)

  -- Display hub cluster
  if #hubs > 0 then
    table.insert(lines, "   HUB CLUSTER:")
    table.insert(lines, "")
    table.insert(lines, "            ⬢─────⬢")
    table.insert(lines, "           ╱ ║ ║ ║ ╲")
    table.insert(lines, "          ⬢══╬═╬═╬══⬢")
    table.insert(lines, "           ╲ ║ ║ ║ ╱")
    table.insert(lines, "            ⬢─────⬢")
    table.insert(lines, "")

    for _, hub in ipairs(hubs) do
      table.insert(lines, "      " .. symbols.hub .. " " .. hub.title .. " (" .. hub.links .. " links)")
    end
    table.insert(lines, "")
  end

  -- Display connected nodes
  if #regulars > 0 then
    table.insert(lines, "   CONNECTED NODES:")
    table.insert(lines, "")
    table.insert(lines, "      ◆═══◆═══◆")
    table.insert(lines, "      ║   ║   ║")
    table.insert(lines, "      ◆═══╬═══◆")
    table.insert(lines, "      ║   ║   ║")
    table.insert(lines, "      ◆═══◆═══◆")
    table.insert(lines, "")

    for i, node in ipairs(regulars) do
      if i > 10 then
        table.insert(lines, "      ... (" .. (#regulars - 10) .. " more)")
        break
      end
      table.insert(lines, "      " .. symbols.node .. " " .. node.title)
    end
    table.insert(lines, "")
  end

  -- Display orphans
  if #orphans > 0 then
    table.insert(lines, "   ISOLATED NODES:")
    table.insert(lines, "")
    table.insert(lines, "      ○   ○   ○")
    table.insert(lines, "")
    for i, orphan in ipairs(orphans) do
      if i > 5 then
        table.insert(lines, "      ... (" .. (#orphans - 5) .. " more)")
        break
      end
      table.insert(lines, "      " .. symbols.orphan .. " " .. orphan.title)
    end
    table.insert(lines, "")
  end

  return table.concat(lines, "\n")
end

-- Generate statistics panel
local function generate_stats(notes, connections)
  local hubs = vim.tbl_filter(function(n)
    return n.is_hub
  end, notes)
  local orphans = vim.tbl_filter(function(n)
    return n.is_orphan
  end, notes)

  local total_links = 0
  for _, count in pairs(connections) do
    total_links = total_links + count
  end

  local avg_links = #notes > 0 and (total_links / #notes) or 0

  return string.format(
    [[
╔════════════════════════════════════════════════════════════════════╗
║                    NETWORK STATISTICS                              ║
╚════════════════════════════════════════════════════════════════════╝

  ⬢ Total Nodes:        %d
  ⬢ Hub Nodes:          %d (%.1f%%)
  ⬢ Connected Nodes:    %d (%.1f%%)
  ⬢ Isolated Nodes:     %d (%.1f%%)
  ⬢ Total Connections:  %d
  ⬢ Average Density:    %.2f links/node
  ⬢ Network Health:     %s

]],
    #notes,
    #hubs,
    (#hubs / #notes) * 100,
    #notes - #orphans - #hubs,
    ((#notes - #orphans - #hubs) / #notes) * 100,
    #orphans,
    (#orphans / #notes) * 100,
    total_links,
    avg_links,
    (#orphans / #notes) < 0.2 and "⚡ EXCELLENT" or (#orphans / #notes) < 0.5 and "⚠️  GOOD" or "❌ NEEDS WORK"
  )
end

-- Display Borg visualization in floating window
M.show_borg = function()
  vim.notify("🤖 Assimilating knowledge network...", vim.log.levels.INFO)

  -- Scan network
  local notes, connections = scan_network()

  if #notes == 0 then
    vim.notify("❌ No notes found in Zettelkasten", vim.log.levels.ERROR)
    return
  end

  -- Generate visualization
  local content = {}
  table.insert(content, generate_header())
  table.insert(content, generate_stats(notes, connections))
  table.insert(content, generate_topology(notes))
  table.insert(content, generate_graph(notes))

  -- Add footer
  table.insert(
    content,
    [[
╔════════════════════════════════════════════════════════════════════╗
║  ⬢  RESISTANCE IS FUTILE  ⬢  YOUR KNOWLEDGE WILL BE ASSIMILATED  ║
╚════════════════════════════════════════════════════════════════════╝
]]
  )

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(table.concat(content, "\n"), "\n"))
  vim.api.nvim_buf_set_option(buf, "filetype", "text")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Create floating window
  local width = 75
  local height = math.min(vim.o.lines - 10, 40)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "double",
    title = " ⬢ BORG COLLECTIVE NEURAL NETWORK ⬢ ",
    title_pos = "center",
  }

  local _ = vim.api.nvim_open_win(buf, true, win_opts)

  -- Keymaps
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })

  vim.notify("🤖 Network visualization complete - Press 'q' to close", vim.log.levels.INFO)
end

-- Quick stats in status message
M.quick_stats = function()
  local notes, _ = scan_network()

  local hubs = vim.tbl_filter(function(n)
    return n.is_hub
  end, notes)
  local orphans = vim.tbl_filter(function(n)
    return n.is_orphan
  end, notes)

  vim.notify(
    string.format("🤖 Network: %d nodes | %d hubs | %d orphans", #notes, #hubs, #orphans),
    vim.log.levels.INFO
  )
end

return M
