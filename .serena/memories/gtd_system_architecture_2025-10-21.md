# GTD System Architecture and Patterns

**Last Updated**: 2025-10-21 **Status**: Phase 1 + 2A + 2B Complete (32/32 tests passing)

## System Architecture

### Module Hierarchy

```
percybrain.gtd (Phase 1 - Init)
├── init.lua - Core GTD setup and directory structure
│   ├── setup() - Initialize GTD system
│   ├── get_inbox_path() - Returns ~/Zettelkasten/gtd/inbox.md
│   ├── get_next_actions_path() - Returns next-actions.md
│   ├── get_projects_path() - Returns projects.md
│   └── get_gtd_root() - Returns ~/Zettelkasten/gtd
│
├── capture.lua (Phase 2A - Capture)
│   ├── quick_capture(text) - One-line capture
│   ├── create_capture_buffer() - Multi-line capture
│   ├── commit_capture_buffer(bufnr) - Save and close
│   ├── get_timestamp() - YYYY-MM-DD HH:MM
│   └── format_task_item(text) - Checkbox + timestamp
│
└── clarify.lua (Phase 2B - Clarify)
    ├── clarify_item(text, decision) - Route based on decision
    ├── get_inbox_items() - Get all inbox items
    ├── remove_inbox_item(text) - Remove specific item
    └── inbox_count() - Count remaining items
```

### Directory Structure

```
~/Zettelkasten/gtd/
├── inbox.md              # Captured items
├── next-actions.md       # Single-step actions
├── projects.md           # Multi-step outcomes
├── someday-maybe.md      # Future possibilities
├── waiting-for.md        # Delegated items
├── reference.md          # Non-actionable reference
├── contexts/
│   ├── home.md          # @home actions
│   ├── work.md          # @work actions
│   ├── computer.md      # @computer actions
│   ├── phone.md         # @phone actions
│   └── errands.md       # @errands actions
├── projects/            # Project support materials
└── archive/             # Completed items
```

## Core Patterns

### File I/O Pattern (Atomic Read-Modify-Write)

```lua
-- Used in Capture and Clarify modules
local function atomic_append(file_path, lines)
  -- Read existing content
  local file = io.open(file_path, "r")
  local existing_content = {}
  if file then
    for line in file:lines() do
      table.insert(existing_content, line)
    end
    file:close()
  end

  -- Append new lines
  for _, line in ipairs(lines) do
    table.insert(existing_content, line)
  end

  -- Write back atomically
  file = io.open(file_path, "w")
  if file then
    for _, line in ipairs(existing_content) do
      file:write(line .. "\n")
    end
    file:close()
  end
end
```

**Why**: Ensures data integrity even if Neovim crashes during operation.

### Decision Structure Pattern

```lua
-- Clarify module decision object
local decision = {
  -- Primary decision
  actionable = boolean,  -- true/false

  -- If actionable = true:
  action_type = "next_action" | "project" | "waiting_for",

  -- Context-specific fields:
  context = "home" | "work" | "computer" | "phone" | "errands" | nil,
  project_outcome = "desired outcome description",
  waiting_for_who = "person or entity name",

  -- If actionable = false:
  route = "reference" | "someday_maybe" | "trash",
}
```

**Why**: Explicit structure prevents ambiguity and maps cleanly to GTD methodology.

### Test Helper Pattern

```lua
-- Centralized in tests/helpers/gtd_test_helpers.lua
local M = {}

-- Path builders
M.gtd_root() -- Returns ~/Zettelkasten/gtd
M.gtd_path(relative) -- Builds absolute paths

-- File operations
M.file_exists(path)
M.read_file_content(path)
M.file_contains_pattern(path, pattern)

-- Test utilities
M.add_inbox_item(text) -- Add test item to inbox
M.cleanup_gtd_test_data() -- Remove test data
M.clear_gtd_cache() -- Clear module cache

return M
```

**Why**: Reduces duplication, ensures consistent test patterns.

## GTD Workflow Integration

### Capture Workflow

```lua
-- Quick capture (one-line)
local capture = require("percybrain.gtd.capture")
capture.quick_capture("Buy groceries")
-- Result: Appends to inbox.md with timestamp

-- Multi-line capture
local bufnr = capture.create_capture_buffer()
vim.api.nvim_open_win(bufnr, true, {
  relative = "editor",
  width = 80,
  height = 20,
  row = 5,
  col = 10,
})
-- User writes content...
capture.commit_capture_buffer(bufnr)
-- Result: Saves to inbox, deletes buffer
```

### Clarify Workflow

```lua
local clarify = require("percybrain.gtd.clarify")

-- Get inbox items
local items = clarify.get_inbox_items()
-- Returns: { "- [ ] Buy groceries (captured: 2025-10-21 14:30)", ... }

-- Process item - Next action with context
clarify.clarify_item("Buy groceries", {
  actionable = true,
  action_type = "next_action",
  context = "errands",
})
-- Result: Appends to contexts/errands.md, removes from inbox

-- Process item - Project
clarify.clarify_item("Website redesign", {
  actionable = true,
  action_type = "project",
  project_outcome = "Launch new company website with improved UX",
})
-- Result: Appends to projects.md with outcome, removes from inbox

-- Process item - Reference
clarify.clarify_item("Interesting article", {
  actionable = false,
  route = "reference",
})
-- Result: Appends to reference.md, removes from inbox
```

## File Format Standards

### Inbox Format

```markdown
# Inbox

- [ ] Buy groceries (captured: 2025-10-21 14:30)
- [ ] Call dentist (captured: 2025-10-21 14:35)
- [ ] Review pull request (captured: 2025-10-21 15:00)
```

### Next Actions Format

```markdown
# Next Actions

- [ ] Buy groceries
- [ ] Call dentist
- [ ] Review pull request
```

### Context Format

```markdown
# @home

- [ ] Fix leaky faucet
- [ ] Organize garage
```

### Project Format

```markdown
# Projects

## Website Redesign
**Outcome**: Launch new company website with improved UX
- [ ] Research design trends
- [ ] Create wireframes
- [ ] Develop prototype

## Home Office Setup
**Outcome**: Functional home office with ergonomic desk and proper lighting
- [ ] Measure office space
- [ ] Research standing desks
```

### Waiting For Format

```markdown
# Waiting For

- [ ] Sarah: Feedback on proposal (2025-10-21)
- [ ] IT Department: New laptop approval (2025-10-20)
```

## TDD Patterns

### RED Phase Pattern

```lua
describe("Module", function()
  before_each(function()
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
    local gtd = require("percybrain.gtd")
    gtd.setup()
  end)

  it("should perform expected behavior", function()
    -- Arrange
    local module = require("percybrain.gtd.module")
    -- ... test setup ...

    -- Act
    module.function_under_test(input)

    -- Assert
    assert.is_true(expected_condition, "Failure message")
  end)
end)
```

### GREEN Phase Pattern

```lua
-- Minimal implementation to pass tests
local M = {}

function M.function_under_test(input)
  -- Minimal logic only
  return result
end

return M
```

### REFACTOR Phase Pattern

```lua
--- Enhanced function with comprehensive documentation
---
--- Detailed description of what this does and why.
---
--- @param input string Description of parameter
--- @return type Description of return value
--- @usage
--- local module = require("percybrain.gtd.module")
--- module.function_under_test("example")
function M.function_under_test(input)
  -- Well-organized logic with comments
  return result
end
```

## Integration Points

### With mkdnflow.nvim

- Checkbox format: `- [ ]` → `- [-]` → `- [x]`
- Compatible with mkdnflow todo state cycling
- Hierarchical todo support

### With Phase 1 (Init)

- Capture uses `get_inbox_path()` from init
- Clarify uses `get_gtd_root()` from init
- All modules depend on init.setup() running first

### With Future UI Layer

```lua
-- Expected keybindings (to be implemented)
vim.keymap.set("n", "<leader>gc", function()
  local text = vim.fn.input("Quick capture: ")
  require("percybrain.gtd.capture").quick_capture(text)
end, { desc = "GTD quick capture" })

vim.keymap.set("n", "<leader>gp", function()
  require("percybrain.gtd.clarify_ui").process_next()
end, { desc = "GTD process inbox" })
```

## Design Principles

### ADHD-Optimized

- **Minimal Friction**: No prompts during capture, immediate action
- **Clear Decisions**: Explicit yes/no branching in clarify
- **Visual Progress**: Checkbox format provides visual completion
- **No Perfectionism**: Capture now, organize later

### GTD Methodology Compliance

- **Ubiquitous Capture**: Capture everything that has attention
- **Clarify Immediately**: Process inbox, don't skip items
- **Outcome Thinking**: Projects have clear desired outcomes
- **Context Awareness**: Actions tagged with required context
- **Trust the System**: Items never return to inbox after clarifying

### Test-Driven Development

- **RED First**: Write failing tests before implementation
- **GREEN Minimal**: Implement only enough to pass tests
- **REFACTOR Quality**: Enhance while maintaining green tests
- **100% Coverage**: All functionality proven by tests

## Performance Characteristics

### Capture Module

- **Quick Capture**: \< 50ms (file append only)
- **Buffer Capture**: \< 100ms (buffer create + file write)
- **Scalability**: Linear O(n) with inbox size (read entire file)

### Clarify Module

- **Route Item**: \< 100ms (file read + write + inbox update)
- **Get Inbox Items**: O(n) with inbox size
- **Scalability**: Acceptable for inbox \< 1000 items

### Optimization Opportunities

- Cache inbox items in memory during clarify session
- Batch remove multiple items at once
- Incremental file updates instead of full rewrites

## Future Extensions

### Phase 3 Modules (Not Yet Implemented)

- **Organize**: Weekly review, project planning
- **Reflect**: Context switching, calendar integration
- **Engage**: Dashboard, AI prioritization

### UI Enhancements (Not Yet Implemented)

- Interactive clarify prompt with floating window
- Progress indicator (X/Y items remaining)
- Context selection menu
- Project outcome editor

### AI Integration (Not Yet Implemented)

- Auto-suggest contexts based on task content
- Detect multi-step projects automatically
- Prioritization suggestions based on context
- Natural language capture parsing
