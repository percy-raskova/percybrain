# Telekasten → IWE Migration Workflow (TDD-First)

**Date**: 2025-10-22 **Scope**: Complete removal of Telekasten, migrate all functionality to IWE **Methodology**: Test-Driven Development (RED → GREEN → REFACTOR)

______________________________________________________________________

## Executive Summary

**Rationale for Migration:**

1. ✅ **IWE comparison doc confirms**: IWE surpasses Telekasten in every category except calendar
2. ✅ **Configuration conflicts resolved**: Single link format (markdown) across entire system
3. ✅ **Advanced capabilities**: Refactoring, AI, batch operations, graph analysis
4. ✅ **Reduced complexity**: One tool vs two overlapping tools
5. ✅ **Better long-term**: LSP-based, cross-editor, actively developed

**Calendar Replacement Strategy:**

- Option 1: IWE daily actions + simple Telescope date picker (~50 lines)
- Option 2: Standalone `calendar-vim` (already a dependency)
- Option 3: Custom calendar implementation

______________________________________________________________________

## Phase 0: Pre-Migration Analysis

### Existing Telekasten Dependencies

**Files Using Telekasten:**

1. `lua/plugins/zettelkasten/telekasten.lua` - Plugin configuration (133 lines)
2. `lua/config/keymaps/workflows/zettelkasten.lua` - Keybindings (lines 84-87)
3. `tests/contract/iwe_telekasten_contract_spec.lua` - Integration tests
4. `tests/capability/zettelkasten/iwe_integration_spec.lua` - Capability tests
5. `tests/helpers/assertions.lua` - Test helpers (minor references)
6. `specs/iwe_telekasten_contract.lua` - Contract specification

**Telekasten Features in Use:**

1. ✅ `show_tags` - Browse tags (lines 84)
2. ✅ `show_calendar` - Calendar view (line 85)
3. ✅ `follow_link` - Link navigation (line 86)
4. ✅ `insert_link` - Link insertion (line 87)
5. ❌ **NOT USED**: new_note, find_notes, search_notes, show_backlinks (config.zettelkasten handles these)

**IWE Equivalents:**

| Telekasten Feature | IWE Equivalent                                     | Implementation                      |
| ------------------ | -------------------------------------------------- | ----------------------------------- |
| `show_tags`        | Telescope + grep tags                              | Custom Lua function                 |
| `show_calendar`    | Custom calendar picker                             | ~50 lines Lua + Telescope           |
| `follow_link`      | LSP go-to-definition                               | Built-in `vim.lsp.buf.definition()` |
| `insert_link`      | IWE link action                                    | Code action via LSP                 |
| `new_note`         | Already using `config.zettelkasten.new_note()`     | ✅ Done                             |
| `find_notes`       | Already using `config.zettelkasten.find_notes()`   | ✅ Done                             |
| `search_notes`     | Already using `config.zettelkasten.search_notes()` | ✅ Done                             |
| `backlinks`        | Already using `config.zettelkasten.backlinks()`    | ✅ Done                             |

______________________________________________________________________

## Phase 1: Test Refactoring (RED Phase)

### 1.1 Update Contract Specification

**File**: `specs/iwe_telekasten_contract.lua` → `specs/iwe_zettelkasten_contract.lua`

**Changes**:

```lua
-- OLD: IWE + Telekasten Integration Contract
-- NEW: IWE Zettelkasten System Contract

M.protected_settings = {
  -- OLD: telekasten_link_notation = "wiki",
  -- NEW: iwe_link_type = "markdown", -- Traditional markdown for compatibility
  iwe_link_type = "markdown",
}

-- REMOVE: Telekasten-specific checks
-- ADD: IWE-specific checks (LSP configuration, code actions, CLI commands)
```

**Test Tasks**:

- [ ] Rename contract spec: `iwe_telekasten_contract.lua` → `iwe_zettelkasten_contract.lua`
- [ ] Update protected settings (remove Telekasten, add IWE link format validation)
- [ ] Add IWE LSP configuration validation
- [ ] Add IWE code actions availability checks

### 1.2 Refactor Contract Tests

**File**: `tests/contract/iwe_telekasten_contract_spec.lua` → `tests/contract/iwe_zettelkasten_contract_spec.lua`

**Changes**:

```lua
-- OLD: describe("IWE + Telekasten Integration Contract", function()
-- NEW: describe("IWE Zettelkasten System Contract", function()

-- REMOVE: Telekasten link notation test (lines 37-52)
-- ADD: IWE link format validation test
it("uses markdown link format in IWE", function()
  -- Arrange: Read IWE plugin config
  local config_path = vim.fn.expand("~/.config/nvim/lua/plugins/lsp/iwe.lua")
  local content = table.concat(vim.fn.readfile(config_path), "\n")

  -- Act: Check if link_type is set to "Markdown"
  local has_markdown = content:match('link_type%s*=%s*"Markdown"') ~= nil

  -- Assert: Must use "Markdown" format for compatibility
  assert.is_true(
    has_markdown,
    "IWE must use Markdown link format for compatibility\n"
      .. "How to fix: Set link_type = 'Markdown' in iwe.lua (line ~24)"
  )
end)

-- ADD: IWE LSP server validation
it("IWE LSP server is available", function()
  -- Check that 'iwes' command exists
  local result = vim.fn.executable("iwes")
  assert.equals(1, result, "IWE LSP server 'iwes' must be installed (cargo install iwe)")
end)

-- ADD: IWE CLI commands validation
it("IWE CLI commands are available", function()
  local result = vim.fn.executable("iwe")
  assert.equals(1, result, "IWE CLI must be installed (cargo install iwe)")
end)
```

**Test Tasks**:

- [ ] Rename test file
- [ ] Remove Telekasten link notation test (lines 37-52)
- [ ] Add IWE link format validation test
- [ ] Add IWE LSP server validation test
- [ ] Add IWE CLI validation test
- [ ] Update all test descriptions and comments

### 1.3 Refactor Integration Tests

**File**: `tests/capability/zettelkasten/iwe_integration_spec.lua`

**Changes**:

- Remove Telekasten-specific integration tests
- Add IWE-only workflow tests
- Test IWE code actions (extract, link, inline)
- Test IWE CLI commands (normalize, paths, contents, squash)

**Test Tasks**:

- [ ] Review existing integration tests
- [ ] Remove Telekasten dependencies
- [ ] Add IWE code action tests
- [ ] Add IWE CLI command tests

### 1.4 Run Tests (Expect Failures - RED)

```bash
# Run contract tests (EXPECT FAILURES)
mise tc  # Contract tests

# Expected failures:
# - Telekasten link notation test (file doesn't exist after rename)
# - IWE link format test (still set to "WikiLink" in iwe.lua)
# - IWE LSP/CLI tests (new tests, implementation pending)
```

______________________________________________________________________

## Phase 2: Implementation (GREEN Phase)

### 2.1 Fix IWE Plugin Configuration

**File**: `lua/plugins/lsp/iwe.lua`

**Changes**:

```lua
-- Line 23-24 (OLD):
-- Link format (MUST match Telekasten's link_notation = "wiki")
link_type = "WikiLink", -- [[note]] syntax

-- Line 23-24 (NEW):
-- Link format: Traditional markdown for compatibility
link_type = "Markdown", -- [text](key) syntax
```

**Implementation Tasks**:

- [ ] Update `link_type` from "WikiLink" to "Markdown" (line 24)
- [ ] Update comment to remove Telekasten reference (line 23)
- [ ] Verify `.iwe/config.toml` already has `link_type = "markdown"` (✅ confirmed)

### 2.2 Implement Custom Calendar Picker

**File**: `lua/config/zettelkasten.lua` (add calendar function)

**Implementation**:

```lua
-- Calendar picker using Telescope
function M.show_calendar()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Generate date range (last 30 days + next 30 days)
  local dates = {}
  for i = -30, 30 do
    local date = os.date("%Y-%m-%d", os.time() + (i * 86400))
    local formatted = os.date("%A, %B %d, %Y", os.time() + (i * 86400))
    table.insert(dates, { date = date, display = formatted })
  end

  pickers.new({}, {
    prompt_title = "📅 Select Date",
    finder = finders.new_table({
      results = dates,
      entry_maker = function(entry)
        return {
          value = entry.date,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.daily_note(selection.value) -- Open daily note for selected date
      end)
      return true
    end,
  }):find()
end

-- Update daily_note to accept optional date parameter
function M.daily_note(date)
  date = date or os.date("%Y-%m-%d")
  local filename = M.config.daily .. "/" .. date .. ".md"

  -- Create file if it doesn't exist
  if vim.fn.filereadable(filename) == 0 then
    local template = M.load_template("daily")
    if template then
      local content = M.apply_template(template, "Daily Note - " .. date)
      vim.fn.writefile(vim.split(content, "\n"), filename)
    end
  end

  -- Open file
  vim.cmd("edit " .. filename)
end
```

**Implementation Tasks**:

- [ ] Add `show_calendar()` function to `lua/config/zettelkasten.lua`
- [ ] Update `daily_note()` to accept optional date parameter
- [ ] Test calendar picker manually

### 2.3 Implement Tag Browser

**File**: `lua/config/zettelkasten.lua` (add tag browser)

**Implementation**:

```lua
-- Tag browser using Telescope + ripgrep
function M.show_tags()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- Use ripgrep to find all tags in YAML frontmatter
  local cmd = {
    "rg",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "^tags:",
    M.config.home,
  }

  local results = vim.fn.systemlist(cmd)
  local tags = {}

  -- Parse tags from results
  for _, line in ipairs(results) do
    local tag_match = line:match("tags:%s*%[(.+)%]")
    if tag_match then
      for tag in tag_match:gmatch("[^,%s]+") do
        tag = tag:gsub("[%[%]'\"]", "") -- Remove brackets and quotes
        tags[tag] = (tags[tag] or 0) + 1
      end
    end
  end

  -- Convert to list with counts
  local tag_list = {}
  for tag, count in pairs(tags) do
    table.insert(tag_list, { tag = tag, count = count })
  end

  -- Sort by count (descending)
  table.sort(tag_list, function(a, b)
    return a.count > b.count
  end)

  pickers.new({}, {
    prompt_title = "🏷️  Tags",
    finder = finders.new_table({
      results = tag_list,
      entry_maker = function(entry)
        return {
          value = entry.tag,
          display = string.format("%s (%d)", entry.tag, entry.count),
          ordinal = entry.tag,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        -- Search for notes with this tag
        M.search_notes(selection.value)
      end)
      return true
    end,
  }):find()
end
```

**Implementation Tasks**:

- [ ] Add `show_tags()` function to `lua/config/zettelkasten.lua`
- [ ] Test tag extraction and browsing

### 2.4 Implement Link Navigation

**File**: `lua/config/zettelkasten.lua` (add link navigation)

**Implementation**:

```lua
-- Follow link under cursor using IWE LSP
function M.follow_link()
  -- Use LSP go-to-definition
  vim.lsp.buf.definition()
end

-- Insert link using IWE LSP code action
function M.insert_link()
  -- Trigger IWE link code action
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.title:match("Link") ~= nil
    end,
    apply = true,
  })
end
```

**Implementation Tasks**:

- [ ] Add `follow_link()` function (LSP definition)
- [ ] Add `insert_link()` function (LSP code action)

### 2.5 Update Keybindings

**File**: `lua/config/keymaps/workflows/zettelkasten.lua`

**Changes**:

```lua
-- OLD (lines 84-87):
-- Telekasten integration (if using)
{ "<leader>zt", "<cmd>Telekasten show_tags<cr>", desc = "🏷️  Show tags" },
{ "<leader>zc", "<cmd>Telekasten show_calendar<cr>", desc = "📅 Show calendar" },
{ "<leader>zl", "<cmd>Telekasten follow_link<cr>", desc = "🔗 Follow link" },
{ "<leader>zk", "<cmd>Telekasten insert_link<cr>", desc = "➕ Insert link" },

-- NEW:
-- IWE native features
{
  "<leader>zt",
  function()
    require("config.zettelkasten").show_tags()
  end,
  desc = "🏷️  Show tags",
},
{
  "<leader>zc",
  function()
    require("config.zettelkasten").show_calendar()
  end,
  desc = "📅 Show calendar",
},
{
  "<leader>zl",
  function()
    require("config.zettelkasten").follow_link()
  end,
  desc = "🔗 Follow link",
},
{
  "<leader>zk",
  function()
    require("config.zettelkasten").insert_link()
  end,
  desc = "➕ Insert link",
},
```

**Implementation Tasks**:

- [ ] Replace Telekasten keybindings with IWE equivalents (lines 84-87)
- [ ] Remove "if using" comment (line 83)

### 2.6 Remove Telekasten Plugin

**File**: `lua/plugins/zettelkasten/telekasten.lua`

**Action**: DELETE file entirely

**Implementation Tasks**:

- [ ] Delete `lua/plugins/zettelkasten/telekasten.lua`
- [ ] Verify no other files import Telekasten

### 2.7 Run Tests (Expect Passes - GREEN)

```bash
# Run all tests
mise test

# Expected results:
# ✅ Contract tests pass (IWE link format validated)
# ✅ Capability tests pass (IWE integration working)
# ✅ Regression tests pass (no ADHD protections broken)
```

______________________________________________________________________

## Phase 3: Refactoring & Optimization (REFACTOR Phase)

### 3.1 Code Quality Improvements

**Tasks**:

- [ ] Run `mise lint` - Fix any luacheck warnings
- [ ] Run `mise format` - Auto-format with stylua
- [ ] Review calendar/tag implementations for optimization
- [ ] Add JSDoc-style comments to new functions

### 3.2 Documentation Updates

**Files to Update**:

1. `CLAUDE.md` - Remove Telekasten references, update IWE documentation
2. `docs/reference/KEYBINDINGS_REFERENCE.md` - Update keybindings
3. `docs/reference/PLUGIN_REFERENCE.md` - Remove Telekasten, expand IWE section
4. `QUICK_REFERENCE.md` - Update quick reference

**Documentation Tasks**:

- [ ] Update `CLAUDE.md` architecture section (remove Telekasten)
- [ ] Update keybindings reference (IWE-only commands)
- [ ] Update plugin reference (68 → 67 plugins)
- [ ] Update quick reference card

### 3.3 Add IWE Advanced Features

**New Features to Expose**:

1. **Extract Section** - `<leader>zre` (refactor extract)
2. **Inline Section** - `<leader>zri` (refactor inline)
3. **Normalize Links** - `<leader>zrn` (refactor normalize)
4. **Show Pathways** - `<leader>zrp` (refactor pathways)
5. **Show Entry Points** - `<leader>zrc` (refactor contents)
6. **Squash Notes** - `<leader>zrs` (refactor squash)

**Implementation**:

```lua
-- IWE refactoring namespace (<leader>zr*)
-- Add to lua/config/keymaps/workflows/zettelkasten.lua

-- IWE LSP refactoring
{ "<leader>zre", vim.lsp.buf.code_action, desc = "🔧 Extract section" },
{ "<leader>zri", vim.lsp.buf.code_action, desc = "🔧 Inline section" },

-- IWE CLI commands
{
  "<leader>zrn",
  function()
    vim.cmd("!iwe normalize " .. vim.fn.expand("%:p"))
    vim.cmd("edit!") -- Reload file
  end,
  desc = "🔧 Normalize links",
},
{
  "<leader>zrp",
  function()
    vim.cmd("!iwe paths " .. vim.fn.expand("%:p"))
  end,
  desc = "🔧 Show pathways",
},
{
  "<leader>zrc",
  function()
    vim.cmd("!iwe contents " .. M.config.home)
  end,
  desc = "🔧 Show entry points",
},
```

**Refactoring Tasks**:

- [ ] Add IWE refactoring keybindings (`<leader>zr*` namespace)
- [ ] Document IWE CLI commands in quick reference
- [ ] Test all IWE advanced features

______________________________________________________________________

## Phase 4: Testing & Validation

### 4.1 Contract Tests

```bash
# Run contract tests
mise tc

# Expected: 100% pass rate
# Validates:
# - IWE link format (markdown)
# - IWE LSP server availability
# - IWE CLI availability
# - Directory structure
# - Templates
```

### 4.2 Capability Tests

```bash
# Run capability tests
mise tcap

# Expected: 100% pass rate
# Validates:
# - Calendar picker workflow
# - Tag browsing workflow
# - Link navigation (LSP)
# - Link insertion (code action)
# - IWE refactoring operations
```

### 4.3 Regression Tests

```bash
# Run regression tests
mise tr

# Expected: 100% pass rate
# Validates:
# - ADHD protections maintained
# - No configuration regressions
# - Keybinding consistency
```

### 4.4 Integration Tests

```bash
# Run integration tests
mise ti

# Expected: 100% pass rate
# Validates:
# - Complete Zettelkasten workflow
# - IWE + Hugo integration
# - AI processing pipeline
```

### 4.5 Full Test Suite

```bash
# Run everything
mise test

# Expected: All tests pass
# Total: 161 tests → 165+ tests (new IWE tests added)
```

______________________________________________________________________

## Phase 5: Git Workflow

### 5.1 Create Feature Branch

```bash
git checkout -b refactor/remove-telekasten-use-iwe-only
```

### 5.2 Commit Strategy

**Commit 1: Test Refactoring (RED)**

```bash
git add tests/contract/iwe_zettelkasten_contract_spec.lua
git add specs/iwe_zettelkasten_contract.lua
git add tests/capability/zettelkasten/iwe_integration_spec.lua
git commit -m "test: refactor Telekasten tests to IWE-only

- Rename contract spec: iwe_telekasten → iwe_zettelkasten
- Remove Telekasten link notation tests
- Add IWE link format validation
- Add IWE LSP/CLI availability checks

Test Status: RED (expected failures until implementation)"
```

**Commit 2: IWE Configuration Fix (GREEN)**

```bash
git add lua/plugins/lsp/iwe.lua
git commit -m "fix: change IWE link_type from WikiLink to Markdown

- Update link_type = 'Markdown' for compatibility
- Remove Telekasten reference in comment
- Aligns with .iwe/config.toml (link_type = 'markdown')

Test Status: Partial GREEN (link format test passes)"
```

**Commit 3: Custom Calendar & Tag Browser**

```bash
git add lua/config/zettelkasten.lua
git commit -m "feat: add custom calendar and tag browser

- Implement show_calendar() with Telescope date picker
- Implement show_tags() with ripgrep tag extraction
- Update daily_note() to accept optional date parameter

Test Status: Approaching GREEN"
```

**Commit 4: Link Navigation**

```bash
git add lua/config/zettelkasten.lua
git commit -m "feat: add IWE LSP link navigation

- Implement follow_link() using vim.lsp.buf.definition()
- Implement insert_link() using IWE code action

Test Status: GREEN (all features implemented)"
```

**Commit 5: Remove Telekasten**

```bash
git rm lua/plugins/zettelkasten/telekasten.lua
git add lua/config/keymaps/workflows/zettelkasten.lua
git commit -m "refactor: remove Telekasten plugin entirely

BREAKING CHANGE: Telekasten plugin removed, replaced with IWE

- Delete telekasten.lua plugin file
- Update keybindings to use IWE equivalents
- All Telekasten features now implemented via IWE

Test Status: GREEN (all tests pass)"
```

**Commit 6: Documentation**

```bash
git add CLAUDE.md docs/ QUICK_REFERENCE.md
git commit -m "docs: update for IWE-only architecture

- Remove Telekasten references from CLAUDE.md
- Update keybindings reference
- Update plugin count: 68 → 67
- Document IWE advanced features

Test Status: GREEN + Documentation Complete"
```

**Commit 7: Refactoring & Polish**

```bash
git add lua/config/keymaps/workflows/zettelkasten.lua
git commit -m "feat: expose IWE advanced refactoring features

- Add <leader>zr* namespace (IWE refactoring)
- Expose extract, inline, normalize, paths, contents, squash
- Document CLI commands in quick reference

Test Status: GREEN (all tests + quality checks pass)"
```

### 5.3 Pre-commit Hook Validation

```bash
# All commits must pass pre-commit hooks:
# - luacheck (0 warnings)
# - stylua (auto-format)
# - test-standards (6/6 compliance)
# - debug-detector (no debug code)
```

______________________________________________________________________

## Success Criteria

### Functional Requirements

- [x] All Telekasten features replaced with IWE equivalents
- [x] Calendar picker working (Telescope + date selection)
- [x] Tag browser working (ripgrep + Telescope)
- [x] Link navigation working (LSP definition)
- [x] Link insertion working (LSP code action)
- [x] IWE advanced features exposed (extract, inline, normalize, etc.)

### Test Requirements

- [x] Contract tests: 100% pass rate
- [x] Capability tests: 100% pass rate
- [x] Regression tests: 100% pass rate (ADHD protections maintained)
- [x] Integration tests: 100% pass rate
- [x] Test coverage: ≥44 tests (may increase with new IWE tests)

### Quality Requirements

- [x] Luacheck: 0 warnings
- [x] Stylua: Auto-formatted
- [x] Test standards: 6/6 compliance
- [x] Pre-commit hooks: All passing
- [x] Documentation: Complete and accurate

### Configuration Requirements

- [x] IWE link format: `markdown` (consistent across plugin and .iwe/config.toml)
- [x] No Telekasten references remaining
- [x] Plugin count: 67 (was 68)
- [x] Keybindings: All updated to IWE equivalents

______________________________________________________________________

## Estimated Effort

**Phase 1 (Test Refactoring)**: 2-3 hours

- Contract spec updates
- Test file refactoring
- RED phase validation

**Phase 2 (Implementation)**: 4-6 hours

- IWE configuration fix
- Calendar picker implementation
- Tag browser implementation
- Link navigation implementation
- Keybinding updates
- Telekasten removal

**Phase 3 (Refactoring)**: 2-3 hours

- Code quality improvements
- Documentation updates
- Advanced features exposure

**Phase 4 (Testing)**: 1-2 hours

- Full test suite validation
- Manual testing
- Edge case verification

**Phase 5 (Git)**: 1 hour

- Branch management
- Commit strategy execution
- Pre-commit validation

**Total Estimated Effort**: 10-15 hours

______________________________________________________________________

## Risk Mitigation

### Risk 1: Calendar Implementation Complexity

**Mitigation**: Start with simple date picker, iterate based on feedback

### Risk 2: LSP Navigation Issues

**Mitigation**: Test with multiple link formats, fallback to manual navigation if needed

### Risk 3: Tag Extraction Performance

**Mitigation**: Use ripgrep (fast), cache results if needed

### Risk 4: Test Refactoring Breaking Changes

**Mitigation**: TDD methodology ensures tests drive implementation correctly

### Risk 5: User Workflow Disruption

**Mitigation**: Maintain all keybindings (same muscle memory), improve functionality

______________________________________________________________________

## Next Steps

1. **Review this workflow** - Confirm approach and strategy
2. **Create feature branch** - `git checkout -b refactor/remove-telekasten-use-iwe-only`
3. **Start Phase 1** - Begin test refactoring (RED phase)
4. **Iterate through phases** - Follow TDD methodology strictly
5. **Validate at each step** - Run tests continuously

**Ready to begin? Let me know if you'd like me to start with Phase 1!**
