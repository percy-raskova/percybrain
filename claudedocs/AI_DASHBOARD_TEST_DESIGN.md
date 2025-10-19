# PercyBrain AI Dashboard - Unit Testing Suite Design

**Date**: 2025-10-18 **Component**: `lua/percybrain/dashboard.lua` (372 lines) **Pattern**: Complex Module (similar to ollama_spec.lua, sembr/integration_spec.lua) **Target**: 6/6 PercyBrain testing standards compliance

## Executive Summary

Design for comprehensive unit test suite covering the PercyBrain AI Meta-Metrics Dashboard, a complex knowledge network analysis tool featuring:

- Real-time metrics collection (growth, tags, link density)
- AI-powered suggestions via Ollama
- Floating window dashboard UI
- Auto-analysis on note save
- Intelligent caching (5-minute TTL)

**Expected Test Coverage**: 85-95% (30-35/40 tests) **Estimated Lines**: ~550-650 lines **Time to Implement**: 45-60 minutes

______________________________________________________________________

## 1. System Architecture Analysis

### 1.1 Component Structure

```
percybrain.dashboard (M)
├── Configuration Layer
│   ├── config {} (zettel_path, ollama_url, model, cache_time, auto_analyze)
│   └── cache {} (last_analysis, metrics, ai_suggestions)
│
├── Analysis Functions (Private)
│   ├── analyze_growth() → growth_data[] (7 days)
│   ├── analyze_tags() → sorted_tags[] (frequency-ordered)
│   ├── analyze_link_density() → metrics{} (notes, links, orphans, hubs)
│   └── get_ai_suggestions(content) → string|nil (Ollama integration)
│
├── Metrics Aggregation
│   └── collect_metrics() → full_metrics{} (with caching)
│
├── UI Layer (Public)
│   ├── M.toggle() → Display floating window dashboard
│   ├── M.analyze_on_save() → Background AI analysis
│   └── M.setup() → Register autocmd for auto-analysis
│
└── Dependencies
    ├── vim.fn.systemlist() - File discovery
    ├── io.open() - File reading
    ├── vim.fn.system() - Ollama API calls
    └── vim.api.nvim_* - Buffer/window management
```

### 1.2 Critical Dependencies

| Dependency                  | Purpose                | Mock Required                  |
| --------------------------- | ---------------------- | ------------------------------ |
| `vim.fn.systemlist()`       | Find markdown files    | ✅ Yes (simulate file system)  |
| `io.open()`                 | Read note content      | ✅ Yes (mock file content)     |
| `vim.fn.system()`           | Ollama API calls       | ✅ Yes (simulate AI responses) |
| `os.time()` / `os.date()`   | Timestamps and caching | ✅ Yes (freeze time for tests) |
| `vim.api.nvim_create_buf()` | UI buffer creation     | ✅ Yes (track buffer creation) |
| `vim.api.nvim_open_win()`   | Floating window        | ✅ Yes (verify window options) |
| `vim.notify()`              | User feedback          | ✅ Yes (capture notifications) |

______________________________________________________________________

## 2. Testing Strategy

### 2.1 Pattern: Complex Module

Following established patterns from:

- **ollama_spec.lua** (110 tests, 91% pass) - AI integration
- **sembr/integration_spec.lua** (12 tests, 100% pass) - Complex mocking
- **window-manager_spec.lua** (27 tests, 100% pass) - UI layer

**Key Characteristics**:

- Comprehensive before_each/after_each state management
- Metatable-based vim.\* mocking for complex APIs
- Local helper functions (contains, count, etc.)
- AAA pattern with explicit comments
- Test isolation via mock restoration

### 2.2 Test Organization (8 describe blocks)

```lua
describe("PercyBrain AI Dashboard", function()
  -- Global setup/teardown

  describe("Module Structure", function())         -- 3 tests
  describe("Configuration Management", function()) -- 4 tests
  describe("Growth Analysis", function())          -- 5 tests
  describe("Tag Analysis", function())             -- 6 tests
  describe("Link Density Analysis", function())    -- 7 tests
  describe("AI Suggestions", function())           -- 5 tests
  describe("Metrics Aggregation", function())      -- 4 tests
  describe("Dashboard UI", function())             -- 6 tests
  describe("Auto-Analysis", function())            -- 4 tests
end)
```

**Total**: 40 tests across 8 describe blocks

______________________________________________________________________

## 3. Test Specification

### 3.1 Module Structure Tests (3 tests)

**Purpose**: Validate module exports and basic structure

```lua
describe("Module Structure", function()
  it("exports expected functions", function()
    -- Arrange: Module loaded in before_each

    -- Act: Check module structure
    local has_toggle = type(dashboard.toggle) == "function"
    local has_analyze = type(dashboard.analyze_on_save) == "function"
    local has_setup = type(dashboard.setup) == "function"

    -- Assert: All public functions exist
    assert.is_table(dashboard)
    assert.is_true(has_toggle, "Should have toggle function")
    assert.is_true(has_analyze, "Should have analyze_on_save function")
    assert.is_true(has_setup, "Should have setup function")
  end)

  it("initializes with default configuration", function()
    -- Arrange & Act: Access internal config via test exposure

    -- Assert: Configuration structure is valid
    -- Note: Requires dashboard to expose config for testing
    -- OR: Test via behavior (cache timing, paths)
  end)

  it("initializes with empty cache", function()
    -- Arrange & Act: Fresh module load

    -- Assert: Cache should be empty on first load
    -- Test via behavior: first metrics call should analyze, not use cache
  end)
end)
```

**Test Pattern**: Simple validation, minimal mocking

______________________________________________________________________

### 3.2 Configuration Management Tests (4 tests)

**Purpose**: Validate configuration structure and cache behavior

```lua
describe("Configuration Management", function()
  it("uses configurable zettelkasten path", function()
    -- Arrange: Mock vim.fn.expand
    local expanded_path = "/test/zettelkasten"
    vim.fn.expand = function(path)
      if path == "~/Zettelkasten" then
        return expanded_path
      end
      return path
    end

    -- Act: Trigger function that uses zettel_path
    -- (via analyze_growth or analyze_link_density)

    -- Assert: Correct path was used in find command
  end)

  it("caches metrics for configured duration", function()
    -- Arrange: Mock os.time to control cache timing
    local mock_time = 1000
    os.time = function() return mock_time end

    -- First call populates cache
    collect_metrics()

    -- Act: Advance time by 4 minutes (< 5 min cache)
    mock_time = mock_time + 240

    -- Assert: Second call uses cache (no new analysis)
    -- Verify via: No new systemlist calls
  end)

  it("invalidates cache after expiration", function()
    -- Arrange: Populate cache
    local mock_time = 1000
    os.time = function() return mock_time end
    collect_metrics()

    -- Act: Advance time by 6 minutes (> 5 min cache)
    mock_time = mock_time + 360

    -- Assert: Cache is invalidated, new analysis runs
  end)

  it("allows cache time configuration", function()
    -- Arrange: Modify config.analysis_cache_time

    -- Act & Assert: Cache behavior reflects new timing
  end)
end)
```

**Test Pattern**: Time-based mocking, cache invalidation logic

______________________________________________________________________

### 3.3 Growth Analysis Tests (5 tests)

**Purpose**: Validate note growth calculation over 7 days

```lua
describe("Growth Analysis", function()
  it("analyzes note growth over 7 days", function()
    -- Arrange: Mock systemlist to return files with timestamps
    local test_files = {
      "1730000000\t/path/note1.md",  -- 6 days ago
      "1730086400\t/path/note2.md",  -- 5 days ago
      "1730172800\t/path/note3.md",  -- 4 days ago
    }
    vim.fn.systemlist = function(cmd)
      if cmd:match("find.*%.md") then
        return test_files
      end
      return {}
    end

    -- Mock os.date for consistent date parsing
    os.date = function(format, timestamp)
      -- Return predictable dates
      return "2025-10-15"  -- Adjust based on timestamp
    end

    -- Act: Call analyze_growth()
    local growth_data = analyze_growth()

    -- Assert: 7 day entries with correct counts
    assert.equals(7, #growth_data, "Should return 7 days of data")
    assert.is_table(growth_data[1])
    assert.is_string(growth_data[1].date)
    assert.is_number(growth_data[1].count)
  end)

  it("handles empty zettelkasten", function()
    -- Arrange: No markdown files
    vim.fn.systemlist = function() return {} end

    -- Act: Call analyze_growth()
    local growth_data = analyze_growth()

    -- Assert: 7 days, all with count=0
    assert.equals(7, #growth_data)
    for _, day in ipairs(growth_data) do
      assert.equals(0, day.count, "Empty vault should have 0 notes per day")
    end
  end)

  it("correctly groups notes by date", function()
    -- Arrange: Multiple notes on same day
    local test_files = {
      "1730000000\t/path/note1.md",  -- Same day
      "1730000100\t/path/note2.md",  -- Same day (+100 seconds)
      "1730000200\t/path/note3.md",  -- Same day (+200 seconds)
    }
    vim.fn.systemlist = function() return test_files end

    -- Act: Call analyze_growth()
    local growth_data = analyze_growth()

    -- Assert: 3 notes counted on same date
    local target_date_count = 0
    for _, day in ipairs(growth_data) do
      if day.count == 3 then
        target_date_count = target_date_count + 1
      end
    end
    assert.equals(1, target_date_count, "All 3 notes should be on same date")
  end)

  it("handles malformed timestamps gracefully", function()
    -- Arrange: Invalid timestamp format
    local test_files = {
      "invalid\t/path/note1.md",
      "1730000000\t/path/note2.md",  -- Valid
    }
    vim.fn.systemlist = function() return test_files end

    -- Act: Call analyze_growth()
    local ok, growth_data = pcall(analyze_growth)

    -- Assert: Function doesn't crash, counts valid entry
    assert.is_true(ok, "Should handle malformed timestamps without crashing")
  end)

  it("uses unix timestamps for date calculation", function()
    -- Arrange: Known timestamp
    local timestamp = 1730000000  -- Known Unix time

    -- Act: Parse timestamp via os.date
    local date = os.date("%Y-%m-%d", timestamp)

    -- Assert: Correct date format returned
    assert.is_string(date)
    assert.truthy(date:match("%d%d%d%d%-%d%d%-%d%d"))
  end)
end)
```

**Test Pattern**: File system mocking, time-based calculations

______________________________________________________________________

### 3.4 Tag Analysis Tests (6 tests)

**Purpose**: Validate tag extraction and frequency sorting

```lua
describe("Tag Analysis", function()
  local mock_note_content

  before_each(function()
    -- Arrange: Create test note content with tags
    mock_note_content = [[
---
tags: [productivity, zettelkasten, testing]
---

# Test Note

This note discusses #ai and #productivity topics.
Also mentions #testing and #zettelkasten methods.
]]
  end)

  it("extracts tags from YAML frontmatter", function()
    -- Arrange: Mock file reading
    io.open = function(path, mode)
      return {
        read = function(self, format)
          return mock_note_content
        end,
        close = function() end
      }
    end

    vim.fn.systemlist = function()
      return {"/path/note1.md"}
    end

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: Frontmatter tags extracted
    local tag_names = {}
    for _, tag_data in ipairs(tags) do
      table.insert(tag_names, tag_data.tag)
    end

    assert.is_true(contains(tag_names, "productivity"))
    assert.is_true(contains(tag_names, "zettelkasten"))
    assert.is_true(contains(tag_names, "testing"))
  end)

  it("extracts hashtags from content", function()
    -- Arrange: Same as above

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: Hashtags extracted
    local tag_names = {}
    for _, tag_data in ipairs(tags) do
      table.insert(tag_names, tag_data.tag)
    end

    assert.is_true(contains(tag_names, "ai"))
  end)

  it("counts tag frequency correctly", function()
    -- Arrange: Note with duplicate tags
    mock_note_content = [[
tags: [productivity]
# Note
#productivity #productivity
]]

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: productivity appears 3 times total
    for _, tag_data in ipairs(tags) do
      if tag_data.tag == "productivity" then
        assert.equals(3, tag_data.count, "Should count all occurrences")
      end
    end
  end)

  it("sorts tags by frequency descending", function()
    -- Arrange: Multiple notes with varying tag counts

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: Tags sorted by count (highest first)
    for i = 2, #tags do
      assert.is_true(tags[i-1].count >= tags[i].count,
        "Tags should be sorted by frequency")
    end
  end)

  it("handles notes with no tags", function()
    -- Arrange: Note without tags
    mock_note_content = "# Note\n\nJust plain text."

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: Empty tag list (or no entry for this note)
    -- Function should not crash
    assert.is_table(tags)
  end)

  it("handles multi-word tags with hyphens", function()
    -- Arrange: Hyphenated tags
    mock_note_content = "tags: [machine-learning, deep-learning]"

    -- Act: Call analyze_tags()
    local tags = analyze_tags()

    -- Assert: Hyphens preserved
    local tag_names = {}
    for _, tag_data in ipairs(tags) do
      table.insert(tag_names, tag_data.tag)
    end

    assert.is_true(contains(tag_names, "machine-learning"))
    assert.is_true(contains(tag_names, "deep-learning"))
  end)
end)
```

**Test Pattern**: File content mocking, regex extraction validation

______________________________________________________________________

### 3.5 Link Density Analysis Tests (7 tests)

**Purpose**: Validate wiki link counting and network metrics

```lua
describe("Link Density Analysis", function()
  it("counts total notes correctly", function()
    -- Arrange: Mock file system with N markdown files
    vim.fn.systemlist = function()
      return {
        "/path/note1.md",
        "/path/note2.md",
        "/path/note3.md",
      }
    end

    io.open = function()
      return {
        read = function() return "# Test" end,
        close = function() end
      }
    end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: Correct note count
    assert.equals(3, metrics.total_notes)
  end)

  it("counts wiki links in markdown format", function()
    -- Arrange: Note with wiki links
    io.open = function()
      return {
        read = function()
          return "[[link1]] and [[link2]] and [[link3]]"
        end,
        close = function() end
      }
    end

    vim.fn.systemlist = function() return {"/path/note.md"} end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: 3 links counted
    assert.equals(3, metrics.total_links)
  end)

  it("calculates average link density", function()
    -- Arrange: 2 notes with different link counts
    local note_contents = {"[[link1]]", "[[link1]] [[link2]] [[link3]]"}
    local note_index = 0

    io.open = function()
      note_index = note_index + 1
      return {
        read = function() return note_contents[note_index] end,
        close = function() end
      }
    end

    vim.fn.systemlist = function()
      return {"/path/note1.md", "/path/note2.md"}
    end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: Average = (1 + 3) / 2 = 2.0
    assert.equals(2.0, metrics.avg_density)
  end)

  it("identifies hub notes with 5+ links", function()
    -- Arrange: Note with 5 links (hub threshold)
    io.open = function()
      return {
        read = function()
          return "[[1]] [[2]] [[3]] [[4]] [[5]]"
        end,
        close = function() end
      }
    end

    vim.fn.systemlist = function() return {"/path/hub.md"} end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: 1 hub note identified
    assert.equals(1, metrics.hub_notes)
  end)

  it("identifies orphan notes with 0 links", function()
    -- Arrange: Note with no links
    io.open = function()
      return {
        read = function() return "# Orphan Note\n\nNo links here." end,
        close = function() end
      }
    end

    vim.fn.systemlist = function() return {"/path/orphan.md"} end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: 1 orphan note identified
    assert.equals(1, metrics.orphan_notes)
    assert.equals(100, metrics.orphan_percentage)
  end)

  it("calculates orphan percentage correctly", function()
    -- Arrange: 2 orphans out of 10 notes
    local note_index = 0
    io.open = function()
      note_index = note_index + 1
      local content = note_index <= 2 and "No links" or "[[link]]"
      return {
        read = function() return content end,
        close = function() end
      }
    end

    vim.fn.systemlist = function()
      local files = {}
      for i = 1, 10 do
        table.insert(files, "/path/note" .. i .. ".md")
      end
      return files
    end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: 20% orphans
    assert.equals(20.0, metrics.orphan_percentage)
  end)

  it("handles empty vault gracefully", function()
    -- Arrange: No markdown files
    vim.fn.systemlist = function() return {} end

    -- Act: Call analyze_link_density()
    local metrics = analyze_link_density()

    -- Assert: Zero metrics with no division errors
    assert.equals(0, metrics.total_notes)
    assert.equals(0, metrics.total_links)
    assert.equals(0, metrics.avg_density)
    assert.equals(0, metrics.orphan_percentage)
  end)
end)
```

**Test Pattern**: Link regex validation, mathematical calculations

______________________________________________________________________

### 3.6 AI Suggestions Tests (5 tests)

**Purpose**: Validate Ollama integration for AI-powered suggestions

```lua
describe("AI Suggestions", function()
  it("calls Ollama API with correct parameters", function()
    -- Arrange: Capture system command
    local captured_cmd = nil
    vim.fn.system = function(cmd)
      captured_cmd = cmd
      return '{"response": "1. Link to X\n2. Add Y\n3. Consider Z"}'
    end

    vim.v.shell_error = 0

    -- Act: Call get_ai_suggestions()
    local content = "Test note content"
    get_ai_suggestions(content)

    -- Assert: Curl command contains correct model and URL
    assert.truthy(captured_cmd:match("llama3.2"))
    assert.truthy(captured_cmd:match("localhost:11434"))
    assert.truthy(captured_cmd:match("/api/generate"))
  end)

  it("limits note content to 1000 characters for performance", function()
    -- Arrange: Long note (2000 chars)
    local long_content = string.rep("A", 2000)
    local captured_prompt = nil

    vim.fn.system = function(cmd)
      -- Extract prompt from curl command
      captured_prompt = cmd:match('"prompt":%s*"([^"]+)"')
      return '{"response": "Test"}'
    end

    vim.v.shell_error = 0

    -- Act: Call get_ai_suggestions()
    get_ai_suggestions(long_content)

    -- Assert: Only first 1000 chars sent
    assert.is_true(#captured_prompt <= 1100,
      "Prompt should truncate to ~1000 chars + system prompt")
  end)

  it("returns AI suggestions on successful API call", function()
    -- Arrange: Mock successful Ollama response
    vim.fn.system = function()
      return "1. Connect to neuroscience\n2. Add references\n3. Expand methodology"
    end

    vim.v.shell_error = 0

    -- Act: Call get_ai_suggestions()
    local suggestions = get_ai_suggestions("Note content")

    -- Assert: Suggestions returned
    assert.is_string(suggestions)
    assert.truthy(suggestions:match("Connect to"))
  end)

  it("returns nil on Ollama service failure", function()
    -- Arrange: Ollama not available
    vim.fn.system = function() return "" end
    vim.v.shell_error = 1  -- Command failed

    -- Act: Call get_ai_suggestions()
    local suggestions = get_ai_suggestions("Note content")

    -- Assert: nil returned (no crash)
    assert.is_nil(suggestions)
  end)

  it("handles empty AI response gracefully", function()
    -- Arrange: Empty response from Ollama
    vim.fn.system = function() return "" end
    vim.v.shell_error = 0  -- Success but empty

    -- Act: Call get_ai_suggestions()
    local suggestions = get_ai_suggestions("Note content")

    -- Assert: nil returned
    assert.is_nil(suggestions)
  end)
end)
```

**Test Pattern**: External API mocking, error handling

______________________________________________________________________

### 3.7 Metrics Aggregation Tests (4 tests)

**Purpose**: Validate metrics collection and caching logic

```lua
describe("Metrics Aggregation", function()
  it("aggregates all metrics into single object", function()
    -- Arrange: Mock all analysis functions
    -- (Previous mocks already set up)

    -- Act: Call collect_metrics()
    local metrics = collect_metrics()

    -- Assert: All metrics present
    assert.is_table(metrics)
    assert.is_table(metrics.growth)
    assert.is_table(metrics.tags)
    assert.is_table(metrics.link_density)
    assert.is_string(metrics.timestamp)
  end)

  it("adds timestamp to metrics", function()
    -- Arrange: Mock os.date
    os.date = function(format)
      return "2025-10-18 14:30:00"
    end

    -- Act: Call collect_metrics()
    local metrics = collect_metrics()

    -- Assert: Timestamp present and formatted
    assert.equals("2025-10-18 14:30:00", metrics.timestamp)
  end)

  it("notifies user during analysis", function()
    -- Arrange: Capture notifications
    local notifications = {}
    vim.notify = function(msg, level)
      table.insert(notifications, {msg = msg, level = level})
    end

    -- Act: Call collect_metrics() (cache empty, will analyze)
    collect_metrics()

    -- Assert: Analysis notification shown
    assert.is_true(#notifications > 0)
    assert.truthy(notifications[1].msg:match("Analyzing"))
  end)

  it("uses cached metrics within cache window", function()
    -- Arrange: First call populates cache
    local analysis_count = 0
    local original_systemlist = vim.fn.systemlist
    vim.fn.systemlist = function(cmd)
      analysis_count = analysis_count + 1
      return original_systemlist(cmd)
    end

    -- Act: First call
    collect_metrics()
    local first_count = analysis_count

    -- Second call within 5 minutes
    collect_metrics()
    local second_count = analysis_count

    -- Assert: No new analysis on second call
    assert.equals(first_count, second_count,
      "Should use cache, not re-analyze")
  end)
end)
```

**Test Pattern**: Integration testing, cache behavior

______________________________________________________________________

### 3.8 Dashboard UI Tests (6 tests)

**Purpose**: Validate floating window creation and formatting

```lua
describe("Dashboard UI", function()
  it("creates floating window with correct dimensions", function()
    -- Arrange: Mock window creation
    local window_opts = nil
    vim.api.nvim_open_win = function(buf, enter, opts)
      window_opts = opts
      return 1001  -- Mock window ID
    end

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: Window options correct
    assert.is_table(window_opts)
    assert.equals("editor", window_opts.relative)
    assert.equals(77, window_opts.width)
    assert.equals("double", window_opts.border)
    assert.truthy(window_opts.title:match("AI METRICS"))
  end)

  it("creates buffer with dashboard content", function()
    -- Arrange: Capture buffer lines
    local buffer_lines = nil
    vim.api.nvim_buf_set_lines = function(buf, start, end_, strict, lines)
      buffer_lines = lines
    end

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: Buffer contains metrics sections
    local content = table.concat(buffer_lines, "\n")
    assert.truthy(content:match("LINK DENSITY"))
    assert.truthy(content:match("NOTE GROWTH"))
    assert.truthy(content:match("TOP TAGS"))
  end)

  it("formats link density metrics correctly", function()
    -- Arrange: Mock metrics

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: Link density section formatted
    -- Check for: Total Notes, Total Links, Average Density, Hub/Orphan counts
  end)

  it("displays 7-day growth chart", function()
    -- Arrange: Mock growth data

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: 7 lines with date + bar chart
  end)

  it("limits tag display to top 10", function()
    -- Arrange: Mock 20 tags

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: Only 10 tags shown + "... (10 more)" message
  end)

  it("includes AI suggestions if available in cache", function()
    -- Arrange: Populate AI cache
    cache.ai_suggestions = "1. Test\n2. Test2\n3. Test3"

    -- Act: Call M.toggle()
    M.toggle()

    -- Assert: AI section present in dashboard
  end)
end)
```

**Test Pattern**: UI component testing, buffer/window validation

______________________________________________________________________

### 3.9 Auto-Analysis Tests (4 tests)

**Purpose**: Validate background AI analysis on save

```lua
describe("Auto-Analysis", function()
  it("registers BufWritePost autocmd on setup", function()
    -- Arrange: Mock autocmd creation
    local autocmds = {}
    vim.api.nvim_create_autocmd = function(event, opts)
      table.insert(autocmds, {
        event = event,
        pattern = opts.pattern,
        callback = opts.callback
      })
    end

    -- Act: Call M.setup()
    M.setup()

    -- Assert: Autocmd registered for *.md files
    assert.equals(1, #autocmds)
    assert.equals("BufWritePost", autocmds[1].event)
    assert.is_true(contains(autocmds[1].pattern, "*.md"))
  end)

  it("triggers AI analysis on markdown save", function()
    -- Arrange: Setup autocmd and mock AI call
    local ai_called = false
    vim.fn.system = function()
      ai_called = true
      return "Test suggestions"
    end

    M.setup()

    -- Act: Simulate buffer save (trigger autocmd)
    M.analyze_on_save()

    -- Assert: AI analysis triggered
    -- Note: Analysis is deferred, need to wait or mock vim.defer_fn
  end)

  it("respects auto_analyze_on_save config", function()
    -- Arrange: Disable auto-analysis
    config.auto_analyze_on_save = false

    -- Act: Call analyze_on_save()
    M.analyze_on_save()

    -- Assert: No AI call made
    -- (verify via vim.fn.system not called)
  end)

  it("runs analysis in background without blocking", function()
    -- Arrange: Mock vim.defer_fn
    local deferred_functions = {}
    vim.defer_fn = function(fn, delay)
      table.insert(deferred_functions, {fn = fn, delay = delay})
    end

    -- Act: Call analyze_on_save()
    M.analyze_on_save()

    -- Assert: Function deferred (non-blocking)
    assert.equals(1, #deferred_functions)
    assert.equals(100, deferred_functions[1].delay)
  end)
end)
```

**Test Pattern**: Autocmd registration, deferred execution

______________________________________________________________________

## 4. Mock Factory Design

### 4.1 Dashboard Mock Object

```lua
-- tests/helpers/mocks.lua addition
function mocks.dashboard(opts)
  opts = opts or {}

  local mock = {
    zettel_path = opts.zettel_path or "/test/zettelkasten",
    ollama_available = opts.ollama_available ~= false,
    mock_files = opts.files or {},
    mock_ai_response = opts.ai_response or "1. Test\n2. Test2\n3. Test3",
  }

  function mock:setup_vim()
    local original_vim = {
      systemlist = vim.fn.systemlist,
      system = vim.fn.system,
      expand = vim.fn.expand,
      create_buf = vim.api.nvim_create_buf,
      open_win = vim.api.nvim_open_win,
      set_lines = vim.api.nvim_buf_set_lines,
      notify = vim.notify,
      shell_error = vim.v.shell_error,
    }

    -- Mock file system
    vim.fn.systemlist = function(cmd)
      if cmd:match("find.*%.md") then
        return self.mock_files
      end
      return {}
    end

    -- Mock Ollama API
    vim.fn.system = function(cmd)
      if cmd:match("ollama") or cmd:match("api/generate") then
        return self.ollama_available and self.mock_ai_response or ""
      end
      return ""
    end

    vim.v.shell_error = self.ollama_available and 0 or 1

    -- Mock path expansion
    vim.fn.expand = function(path)
      if path == "~/Zettelkasten" then
        return self.zettel_path
      end
      return path
    end

    return original_vim
  end

  function mock:mock_io_open(file_contents)
    local original_io_open = io.open

    io.open = function(path, mode)
      return {
        read = function(self, format)
          return file_contents[path] or "# Test Note"
        end,
        close = function() end
      }
    end

    return original_io_open
  end

  function mock:mock_time(initial_time)
    initial_time = initial_time or 1730000000

    local original_time = os.time
    local original_date = os.date

    local current_time = initial_time

    os.time = function()
      return current_time
    end

    os.date = function(format, timestamp)
      timestamp = timestamp or current_time
      return original_date(format, timestamp)
    end

    -- Return controller for advancing time
    return {
      advance = function(seconds)
        current_time = current_time + seconds
      end,
      restore = function()
        os.time = original_time
        os.date = original_date
      end
    }
  end

  return mock
end
```

______________________________________________________________________

## 5. Implementation Roadmap

### Phase 1: Foundation (15 minutes)

1. Create test file: `tests/plenary/unit/percybrain/dashboard_spec.lua`
2. Add imports (helpers, mocks, local contains function)
3. Implement before_each/after_each with state restoration
4. Write Module Structure tests (3 tests) - validate exports

### Phase 2: Analysis Functions (20 minutes)

5. Write Growth Analysis tests (5 tests) - time-based calculations
6. Write Tag Analysis tests (6 tests) - regex extraction
7. Write Link Density tests (7 tests) - network metrics

### Phase 3: Integration (15 minutes)

8. Write AI Suggestions tests (5 tests) - Ollama mocking
9. Write Metrics Aggregation tests (4 tests) - caching logic

### Phase 4: UI & Setup (10 minutes)

10. Write Dashboard UI tests (6 tests) - buffer/window validation
11. Write Auto-Analysis tests (4 tests) - autocmd registration

### Phase 5: Validation (5 minutes)

12. Run luacheck for syntax validation
13. Execute test suite: `nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/plenary/unit/percybrain/dashboard_spec.lua')" -c "qa!"`
14. Fix any failing tests
15. Document results

______________________________________________________________________

## 6. Success Criteria

**6/6 Testing Standards**:

- ✅ Helper/mock imports at top
- ✅ before_each/after_each pattern
- ✅ AAA comments on all tests
- ✅ No \_G. pollution
- ✅ Local helper functions (contains, etc.)
- ✅ Comprehensive mocking

**Quality Metrics**:

- **Test Coverage**: 85-95% (30-35/40 tests passing)
- **Code Quality**: Luacheck clean (0 errors)
- **Documentation**: Inline AAA comments
- **Maintainability**: Reusable mock factory

**Expected Failures**:

- 2-5 tests may fail due to edge cases in file I/O
- 1-2 tests may fail on time-based calculations (timezone issues)
- Overall pass rate target: 85%+

______________________________________________________________________

## 7. Advanced Patterns

### 7.1 Time Mocking Pattern

```lua
-- Freeze time for deterministic tests
local time_controller = mock:mock_time(1730000000)

-- Run test
collect_metrics()

-- Advance time by 6 minutes
time_controller.advance(360)

-- Verify cache invalidation
collect_metrics()  -- Should re-analyze

-- Cleanup
time_controller.restore()
```

### 7.2 File System Virtualization

```lua
-- Create virtual file system
local file_contents = {
  ["/test/note1.md"] = "[[link1]] [[link2]]",
  ["/test/note2.md"] = "tags: [ai, testing]",
  ["/test/note3.md"] = "# Orphan note",
}

local original_io = mock:mock_io_open(file_contents)

-- Tests run with virtual file system

-- Cleanup
io.open = original_io
```

### 7.3 UI Component Testing

```lua
-- Capture window creation
local window_config = nil
vim.api.nvim_open_win = function(buf, enter, opts)
  window_config = opts
  return 1001
end

-- Trigger UI
M.toggle()

-- Validate window properties
assert.equals(77, window_config.width)
assert.equals("double", window_config.border)
```

______________________________________________________________________

## 8. Integration with Existing Suite

**Test Location**: `tests/plenary/unit/percybrain/dashboard_spec.lua`

**Execution**:

```bash
# Individual test
nvim --headless -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/plenary/unit/percybrain/dashboard_spec.lua')" \
  -c "qa!"

# Full suite
./tests/run-all-unit-tests.sh
```

**Documentation**:

- Add to `COMPLETE_TEST_COVERAGE_REPORT.md`
- Update `PLENARY_TESTING_DESIGN.md` with dashboard patterns
- Create `claudedocs/DASHBOARD_TEST_IMPLEMENTATION.md` (completion report)

______________________________________________________________________

## 9. Risk Assessment

| Risk                          | Probability | Impact | Mitigation                         |
| ----------------------------- | ----------- | ------ | ---------------------------------- |
| File I/O mocking complexity   | High        | Medium | Use comprehensive mock factory     |
| Time-based test flakiness     | Medium      | Low    | Freeze time with mock controller   |
| Ollama API unavailability     | Low         | Low    | Mock all external API calls        |
| UI buffer/window API changes  | Low         | Medium | Test behavior, not implementation  |
| Cache invalidation edge cases | Medium      | Medium | Explicit time advancement in tests |

______________________________________________________________________

## 10. Future Enhancements

**Potential Additions**:

1. **Performance Tests**: Measure analysis speed for large vaults (1000+ notes)
2. **Integration Tests**: Full end-to-end dashboard display cycle
3. **Visual Regression**: Screenshot-based UI validation
4. **Network Graph Tests**: When `network-graph.lua` is implemented
5. **Keybinding Tests**: Validate 'q', 'r', 'g' keymaps in dashboard

**Mock Factory Reusability**:

- `mocks.dashboard()` can be reused for:
  - `network-graph_spec.lua` (future)
  - Any Zettelkasten analysis features
  - Ollama integration tests

______________________________________________________________________

## Appendix A: Complete Test File Structure

```
tests/plenary/unit/percybrain/
└── dashboard_spec.lua (550-650 lines)
    ├── Imports (15 lines)
    ├── Helper functions (20 lines)
    ├── before_each/after_each (40 lines)
    ├── Module Structure (30 lines)
    ├── Configuration Management (50 lines)
    ├── Growth Analysis (80 lines)
    ├── Tag Analysis (90 lines)
    ├── Link Density Analysis (110 lines)
    ├── AI Suggestions (70 lines)
    ├── Metrics Aggregation (50 lines)
    ├── Dashboard UI (90 lines)
    └── Auto-Analysis (50 lines)
```

______________________________________________________________________

## Appendix B: References

**Established Patterns**:

- `tests/plenary/unit/ai-sembr/ollama_spec.lua` (110 tests, AI integration)
- `tests/plenary/unit/sembr/integration_spec.lua` (12 tests, complex mocking)
- `tests/plenary/unit/window-manager_spec.lua` (27 tests, UI testing)

**Documentation**:

- `tests/PLENARY_TESTING_DESIGN.md` (753 lines, standards specification)
- `tests/REFACTORING_GUIDE.md` (531 lines, practical patterns)
- `claudedocs/TEST_REFACTORING_COMPLETE.md` (485 lines, campaign report)

**Tools**:

- Plenary.nvim BDD framework
- luassert assertions
- PercyBrain mock factory (`tests/helpers/mocks.lua`)

______________________________________________________________________

**End of Design Document**

*This comprehensive design provides a complete blueprint for implementing the PercyBrain AI Dashboard unit test suite following all established testing standards and patterns. Estimated implementation time: 45-60 minutes for an experienced developer familiar with the codebase.*
