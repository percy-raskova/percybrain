# GTD Implementation Patterns

**Date**: 2025-10-21 **Context**: PercyBrain GTD system implementation patterns and best practices

## Core Patterns

### TDD Workflow for GTD Features

**Pattern**: RED → GREEN → REFACTOR methodology for all GTD implementations

**Structure**:

```lua
-- 1. RED Phase: Write failing tests first
describe("GTD Feature", function()
  before_each(function()
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  it("should implement expected behavior", function()
    -- Arrange: Set up test conditions
    -- Act: Execute the feature
    -- Assert: Verify expected outcomes
  end)
end)

-- 2. GREEN Phase: Minimal implementation
function M.feature()
  -- Minimal code to pass tests
  -- No over-engineering
end

-- 3. REFACTOR Phase: Improve while keeping tests green
-- Add documentation
-- Optimize code structure
-- Enhance readability
```

**Benefits**:

- Fast feedback (~20 min TDD cycle)
- Fearless refactoring
- Self-documenting code via tests
- Prevents over-engineering

### GTD Directory Structure Pattern

**Pattern**: Hierarchical organization matching GTD methodology

```
~/Zettelkasten/gtd/
├── inbox.md              # Capture: Everything that has attention
├── next-actions.md       # Organize: Actionable items by context
├── projects.md           # Organize: Multi-step outcomes
├── someday-maybe.md      # Organize: Future possibilities
├── waiting-for.md        # Organize: Delegated items
├── reference.md          # Organize: Reference information
├── contexts/             # Contexts: Where/when/how to do actions
│   ├── home.md
│   ├── work.md
│   ├── computer.md
│   ├── phone.md
│   └── errands.md
├── projects/             # Project support materials
└── archive/              # Completed items
```

**Key Principles**:

- Follow David Allen's 5 GTD workflows (Capture, Clarify, Organize, Reflect, Engage)
- Use emoji icons for visual scanning (📥, ⚡, 📋, 💭, ⏳, 📚)
- Include GTD guidelines in each file header
- Separate base files from context files
- Archive completed items (don't delete)

### Idempotent Setup Pattern

**Pattern**: Safe to run setup multiple times without data loss

```lua
function M.setup()
  -- 1. Check before creating directories
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end

  -- 2. Check before creating files (preserve existing)
  if vim.fn.filereadable(file_path) == 0 then
    vim.fn.writefile(lines, file_path)
  end

  -- 3. No errors on re-run
  -- Safe for config reloads, plugin reinstalls, etc.
end
```

**Benefits**:

- No data loss on accidental re-run
- Safe for Neovim config reloads
- User can run `:lua require('percybrain.gtd').setup()` anytime
- Plugin updates don't destroy user data

### Test Helper Reuse Pattern

**Pattern**: Centralized test utilities following DRY principles

**Structure**:

```lua
-- tests/helpers/gtd_test_helpers.lua
local M = {}

-- Path building
function M.gtd_root() end
function M.gtd_path(relative) end

-- File system checks
function M.dir_exists(path) end
function M.file_exists(path) end
function M.read_file_content(path) end
function M.file_contains_pattern(path, pattern) end

-- Test lifecycle
function M.cleanup_gtd_test_data() end
function M.clear_gtd_cache() end

-- Test data
function M.get_base_files() end
function M.get_context_files() end
function M.get_gtd_directories() end

return M
```

**Benefits**:

- Consistent test infrastructure
- Reduced test code duplication
- Easier test maintenance
- Matches existing keymap test helpers pattern

### GTD File Header Pattern

**Pattern**: Markdown headers with guidelines for each GTD file

```markdown
# 📥 Inbox

Quick capture of all incoming items.

## Guidelines
- Capture everything that has your attention
- Process regularly (daily recommended)
- Keep it clean - move items out during clarification

## Items

[User content goes here]
```

**Benefits**:

- Self-documenting GTD files
- Reduces cognitive load (guidelines always visible)
- Matches ADHD-friendly design principles
- Helps users learn GTD methodology

## mkdnflow.nvim Integration Patterns

### Hierarchical Todo Pattern

**Pattern**: Parent/child checkbox relationships with auto-update

```markdown
- [ ] Project: Implement GTD system
  - [x] Phase 1: Core infrastructure
  - [-] Phase 2: Capture & Clarify
  - [ ] Phase 3: AI integration
```

**Todo States**:

- `[ ]` - Not started
- `[-]` - In progress
- `[x]` - Complete

**Auto-update**: Parent checkbox updates when children change

### Todo State Cycling

**Keymap**: `<C-Space>` toggles todo state

**Cycle**: `[ ]` → `[-]` → `[x]` → `[ ]`

**Benefits**:

- Visual progress tracking
- Matches GTD's action status
- Parent tasks auto-update
- Keyboard-driven workflow

### Link Navigation Pattern

**Pattern**: Wiki-style links with markdown standard

```markdown
Follow link: [[note-title]]
Create new: [[new-note-name]]
```

**Keymaps**:

- `<CR>` - Follow link (creates if doesn't exist)
- `<Tab>` / `<S-Tab>` - Next/previous link
- `<BS>` - Go back

**Benefits**:

- Markdown-native (works in any editor)
- No vendor lock-in
- Fast Zettelkasten-style linking

## LSP Configuration Patterns

### Standalone LSP Binary Pattern

**Pattern**: LSP server as binary, not Neovim plugin

```lua
-- ❌ Wrong: Loading as plugin
return {
  "author/lsp-plugin",
  config = function() ... end
}

-- ✅ Correct: Binary configured in lspconfig
-- Plugin file: Empty or minimal
return {}

-- LSP config file: Direct lspconfig setup
lspconfig["lsp_name"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "filetype" },
})
```

**Examples**:

- IWE LSP: Binary via `cargo install iwe`
- Lua LS: Binary via Mason or system package
- Rust Analyzer: Binary via rustup

**Benefits**:

- Clear separation: editor config vs language tools
- System-wide LSP availability
- No plugin bloat

### LSP-Specific Keymaps Pattern

**Pattern**: Additional keymaps in LSP on_attach for domain-specific features

```lua
lspconfig["iwe"].setup({
  on_attach = function(client, bufnr)
    -- 1. Call global on_attach (standard LSP keymaps)
    on_attach(client, bufnr)

    -- 2. Add LSP-specific keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }

    opts.desc = "Find backlinks (IWE-specific)"
    keymap.set("n", "<leader>zr", vim.lsp.buf.references, opts)

    opts.desc = "Extract section (IWE-specific)"
    keymap.set("n", "<leader>za", vim.lsp.buf.code_action, opts)
  end,
})
```

**Benefits**:

- Standard LSP features available everywhere (gd, K, gr)
- Domain-specific features only where relevant
- Clear separation of concerns

## GTD Module API Patterns

### Clear Public API

**Pattern**: Expose only necessary functions, keep internals private

```lua
local M = {}

-- Private functions (local)
local function create_directories() end
local function create_base_files() end
local function create_context_files() end

-- Public API
function M.setup() end                    -- Initialize GTD system
function M.get_inbox_path() end          -- Path helpers
function M.get_next_actions_path() end
function M.get_projects_path() end
function M.get_gtd_root() end

return M
```

**Benefits**:

- Clear contract for users
- Internal refactoring doesn't break API
- Easy to test (public surface is small)
- Self-documenting

### Configuration as Data Pattern

**Pattern**: Separate configuration from logic

```lua
M.config = {
  gtd_root = vim.fn.expand("~/Zettelkasten/gtd"),

  base_files = {
    { name = "inbox.md", header = "# 📥 Inbox\n..." },
    { name = "next-actions.md", header = "# ⚡ Next Actions\n..." },
    -- ...
  },

  contexts = {
    { name = "home", icon = "🏠", file = "contexts/home.md" },
    { name = "work", icon = "💼", file = "contexts/work.md" },
    -- ...
  },
}
```

**Benefits**:

- Easy to extend (add new contexts, files)
- Testable (check config structure)
- User-customizable (override M.config)
- Clear data/logic separation

## Testing Patterns

### AAA (Arrange-Act-Assert) Pattern

**Pattern**: Clear test structure with comments

```lua
it("should create GTD directory structure", function()
  -- Arrange: Set up test conditions
  local gtd_root = helpers.gtd_root()
  assert.is_false(helpers.dir_exists(gtd_root))

  -- Act: Execute the feature
  local gtd = require("percybrain.gtd")
  gtd.setup()

  -- Assert: Verify expected outcomes
  assert.is_true(helpers.dir_exists(gtd_root))
end)
```

**Benefits**:

- Clear test intent
- Easy to debug failures
- Self-documenting
- Matches existing test standards

### Test Isolation Pattern

**Pattern**: Clean state before/after each test

```lua
describe("GTD Feature", function()
  before_each(function()
    -- Clean slate for each test
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  after_each(function()
    -- Remove test artifacts
    helpers.cleanup_gtd_test_data()
    helpers.clear_gtd_cache()
  end)

  it("test 1", function() end)
  it("test 2", function() end)
end)
```

**Benefits**:

- No test interdependence
- Reliable test results
- Parallel test execution safe
- Easy to add/remove tests

## Anti-Patterns Avoided

### ❌ Plugin for LSP Binary

**Problem**: Loading LSP server as Neovim plugin when it's standalone binary

**Symptom**: `module not found` or nil handler errors

**Solution**: Empty plugin file, configure in lspconfig only

### ❌ Overwriting User Data

**Problem**: Running setup destroys existing GTD files

**Symptom**: User loses work on config reload

**Solution**: Check `filereadable()` before writing

### ❌ Implementation Before Tests

**Problem**: Writing code without tests (no TDD)

**Symptom**: Hard to refactor, bugs discovered late

**Solution**: Always RED → GREEN → REFACTOR

### ❌ Complex Setup Functions

**Problem**: setup() does too much, hard to test

**Symptom**: Tests are brittle, setup takes forever

**Solution**: Extract to focused private functions

## Success Metrics

**Phase 1 Results**:

- ✅ 12/12 tests passing (100% coverage)
- ✅ ~20 minute TDD cycle
- ✅ 610 lines (implementation + tests)
- ✅ Zero regressions
- ✅ Idempotent setup
- ✅ Clean API surface

**Quality Indicators**:

- All tests use AAA pattern
- All tests isolated (before_each/after_each)
- Helper functions reused
- No test pollution (\_G)
- Documentation inline with code

______________________________________________________________________

**Next Session**: Apply these patterns to GTD Phase 2 (Capture & Clarify modules)
