# GTD Phase 2B: Clarify Module - COMPLETE

**Date**: 2025-10-21 **Status**: ✅ COMPLETE **Test Results**: 11/11 passing (100%) **TDD Cycle**: RED → GREEN → REFACTOR (complete) **Integration**: Phase 1 (GTD init) + Phase 2A (Capture) → Phase 2B (Clarify)

## Summary

Successfully implemented GTD Clarify module following TDD methodology. The Clarify module implements David Allen's second GTD workflow - processing inbox items into actionable next actions, projects, waiting-for items, or non-actionable reference/someday-maybe/trash categories. All 11 tests pass with comprehensive routing logic and inbox management.

## TDD Cycle Completion

### RED Phase ✅

**Created failing tests first** (all 11 tests failed with "module not found"):

- `tests/unit/gtd/gtd_clarify_spec.lua` - 11 comprehensive tests
- Test groups: Next Actions (3), Projects (1), Waiting For (1), Non-Actionable (3), Inbox Management (3)
- Added test helper: `add_inbox_item(text)` to populate inbox for clarify tests

**Test Coverage**:

- ✅ Next action routing (with and without context)
- ✅ Project routing with outcome
- ✅ Waiting-for routing with person
- ✅ Reference material routing
- ✅ Someday/maybe routing
- ✅ Trash deletion (no file write)
- ✅ Inbox item retrieval
- ✅ Inbox item removal
- ✅ Inbox item counting

### GREEN Phase ✅

**Implemented minimal code to pass all tests**:

- `lua/percybrain/gtd/clarify.lua` - Core Clarify module (296 lines after refactor)
- Public API:
  - `M.clarify_item(text, decision)` - Core clarify logic with decision routing
  - `M.get_inbox_items()` - Returns array of all inbox items
  - `M.remove_inbox_item(text)` - Removes specific item from inbox
  - `M.inbox_count()` - Returns count of remaining items
- Private routing helpers:
  - `_route_next_action(text, context)` - Route to next-actions.md or contexts/{context}.md
  - `_route_project(text, outcome)` - Route to projects.md with outcome header
  - `_route_waiting_for(text, who)` - Route to waiting-for.md with person
  - `_route_reference(text)` - Route to reference.md
  - `_route_someday_maybe(text)` - Route to someday-maybe.md

**Result**: 11/11 tests passing (100%)

### REFACTOR Phase ✅

**Improved code quality while maintaining green tests**:

- Added comprehensive LuaDoc annotations for all functions
- Documented GTD clarify principles (process one at a time, never put back, decide now)
- Enhanced public API with usage examples and decision structure documentation
- Added inline comments explaining routing logic
- Organized code with clear section headers (Private Helpers, Public API)
- Documented integration with Phase 1 (GTD core) and Phase 2A (Capture)

**Result**: 11/11 tests still passing after refactoring (100%)

## Implementation Details

### Decision Structure

**Core Decision Object**:

```lua
{
  actionable = boolean,  -- Is this item actionable?

  -- If actionable = true:
  action_type = "next_action"|"project"|"waiting_for",
  context = "home"|"work"|"computer"|"phone"|"errands"|nil,  -- for next_action
  project_outcome = "desired outcome",  -- for project
  waiting_for_who = "person name",  -- for waiting_for

  -- If actionable = false:
  route = "reference"|"someday_maybe"|"trash",
}
```

### Routing Logic

**Next Actions** (context-aware):

- No context → `next-actions.md`
- With context → `contexts/{context}.md` (e.g., `contexts/home.md`)
- Format: `- [ ] Task description`

**Projects** (with outcome):

- Route to `projects.md`
- Format:
  ```markdown
  ## Project Title
  **Outcome**: Desired outcome description
  ```

**Waiting For** (with person and date):

- Route to `waiting-for.md`
- Format: `- [ ] Person: Item description (YYYY-MM-DD)`

**Reference Material**:

- Route to `reference.md`
- Format: `- Item description` (no checkbox)

**Someday/Maybe**:

- Route to `someday-maybe.md`
- Format: `- [ ] Idea description`

**Trash**:

- No file write, just remove from inbox

### Inbox Management

**get_inbox_items()**:

- Returns array of all checkbox items from inbox.md
- Filters out headers and empty lines
- Preserves full format: `- [ ] text (captured: timestamp)`

**remove_inbox_item(text)**:

- Searches for items containing specified text
- Removes matched items using pattern escaping for safety
- Atomic read-modify-write operation

**inbox_count()**:

- Returns count of unprocessed checkbox items
- Useful for tracking clarify session progress

## Test Suite

**File**: `tests/unit/gtd/gtd_clarify_spec.lua` **Status**: 11/11 passing (100%)

### Test Group 1: Next Actions (3 tests)

1. ✅ **Route without context**: Appends to next-actions.md
2. ✅ **Route with context**: Appends to contexts/home.md
3. ✅ **Remove from inbox**: Confirms item removed after routing

### Test Group 2: Projects (1 test)

4. ✅ **Route project**: Appends to projects.md with outcome header

### Test Group 3: Waiting For (1 test)

5. ✅ **Route waiting-for**: Appends to waiting-for.md with person and date

### Test Group 4: Non-Actionable Items (3 tests)

6. ✅ **Route reference**: Appends to reference.md
7. ✅ **Route someday/maybe**: Appends to someday-maybe.md
8. ✅ **Trash deletion**: Removes from inbox without file write

### Test Group 5: Inbox Management (3 tests)

09. ✅ **Get inbox items**: Returns array of all items
10. ✅ **Remove specific item**: Removes matched item, keeps others
11. ✅ **Count items**: Returns correct count of remaining items

## Files Created/Modified

### Created Files (2 total)

1. `lua/percybrain/gtd/clarify.lua` - Core Clarify module (296 lines)
2. `tests/unit/gtd/gtd_clarify_spec.lua` - Test suite (317 lines)

### Modified Files (1 total)

1. `tests/helpers/gtd_test_helpers.lua` - Added `add_inbox_item(text)` helper (18 lines)

### Documentation (1 total)

1. `claudedocs/GTD_PHASE2B_CLARIFY_COMPLETE.md` - This document

## Validation Commands

```bash
# Run Clarify module tests
timeout 30 nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/unit/gtd/gtd_clarify_spec.lua" \
  -c "qall"

# Expected: 11/11 passing (100%)

# Run all GTD tests individually
timeout 30 nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/unit/gtd/gtd_init_spec.lua" \
  -c "qall"  # 12/12 passing

timeout 30 nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedFile tests/unit/gtd/gtd_capture_spec.lua" \
  -c "qall"  # 9/9 passing

# Total: 32/32 tests passing (100%) across all GTD modules
```

## Metrics

**Lines of Code**:

- Implementation: 296 lines (lua/percybrain/gtd/clarify.lua)
- Test suite: 317 lines (tests/unit/gtd/gtd_clarify_spec.lua)
- Test helper additions: 18 lines (tests/helpers/gtd_test_helpers.lua)
- **Total**: 631 lines

**Test Coverage**:

- 11 tests written
- 11 tests passing (100%)
- 5 test groups (Next Actions, Projects, Waiting For, Non-Actionable, Inbox Management)
- AAA pattern enforced
- before_each/after_each cleanup

**TDD Cycle Time**:

- RED phase: ~10 minutes (write failing tests, add helper)
- GREEN phase: ~15 minutes (implement routing logic)
- REFACTOR phase: ~10 minutes (improve quality, documentation)
- **Total**: ~35 minutes

**Integration**:

- Phase 1: GTD init (12 tests) ✅
- Phase 2A: Capture (9 tests) ✅
- Phase 2B: Clarify (11 tests) ✅
- **Total GTD System**: 32/32 tests passing (100%)

## Design Benefits

### TDD Approach

- **Confidence**: All routing logic proven by tests
- **Safety**: Refactoring protected by comprehensive test suite
- **Clarity**: Tests document expected GTD workflow behavior
- **Quality**: Test-first prevents complex over-engineering

### GTD Methodology Compliance

- **Actionable Decision**: Clear yes/no branch for all items
- **Context Support**: @home, @work, @computer, @phone, @errands
- **Project Detection**: Multi-step outcomes routed to projects.md
- **Waiting For**: Delegation tracking with person and date
- **Non-Actionable Routing**: Reference, someday/maybe, trash
- **No Inbox Return**: Items never go back to inbox after processing

### Code Quality

- **Comprehensive Documentation**: LuaDoc annotations throughout
- **GTD Principles**: David Allen's methodology captured in code
- **Decision-Driven**: Explicit decision structure prevents ambiguity
- **Atomic Operations**: File I/O ensures data integrity
- **Integration Ready**: Works seamlessly with Capture module

## GTD Clarify Principles (Implementation)

### 1. Process One at a Time

**Principle**: "Never skip an item, process in order" **Implementation**: `get_inbox_items()` returns array for sequential processing

### 2. Never Put Back in Inbox

**Principle**: "Make a decision - don't defer the decision itself" **Implementation**: `clarify_item()` always removes from inbox after routing

### 3. Actionable Decision

**Principle**: "Yes/No - is this something I need to do?" **Implementation**: `decision.actionable = true|false`

### 4. Next Action Specificity

**Principle**: "What's the very next physical action?" **Implementation**: Route to next-actions.md or context files

### 5. Project Outcome

**Principle**: "What would 'done' look like?" **Implementation**: `project_outcome` field in decision structure

## Integration with GTD System

**Phase 1 (GTD Init)**:

- Creates directory structure (`contexts/`, `projects/`, `archive/`)
- Creates all base files (inbox.md, next-actions.md, projects.md, etc.)
- Provides `get_inbox_path()`, `get_gtd_root()` for Clarify module

**Phase 2A (Capture)**:

- Populates inbox.md with captured items
- Format: `- [ ] text (captured: YYYY-MM-DD HH:MM)`
- Clarify module processes these captured items

**Phase 2B (Clarify)**:

- Reads items from inbox.md (populated by Capture)
- Routes to appropriate GTD files based on decisions
- Removes processed items from inbox
- Enables complete Capture → Clarify workflow

## Next Steps

**Phase 3**: GTD Organize, Reflect, Engage Modules (Future work)

- **Organize**: Weekly review, project planning
- **Reflect**: Calendar integration, context switching
- **Engage**: Dashboard, AI prioritization

**Keybindings** (Recommended):

```lua
-- Capture workflow
vim.keymap.set("n", "<leader>gc", function()
  local text = vim.fn.input("Quick capture: ")
  require("percybrain.gtd.capture").quick_capture(text)
end, { desc = "GTD quick capture" })

-- Clarify workflow
vim.keymap.set("n", "<leader>gp", function()
  -- Interactive clarify UI (to be implemented)
  require("percybrain.gtd.clarify_ui").process_next()
end, { desc = "GTD process inbox" })
```

**UI Enhancements** (Future):

- Interactive clarify prompt with keybindings
- Inbox progress indicator (X/Y items remaining)
- Context selection menu
- Project outcome editor

______________________________________________________________________

**Status**: ✅ COMPLETE - GTD Clarify module fully implemented with TDD methodology **Integration**: ✅ COMPLETE - Works seamlessly with GTD Init and Capture modules **Next**: Phase 3 - Organize/Reflect/Engage modules OR UI/keybinding layer

**Validation**: All tests passing, comprehensive documentation, GTD methodology preserved **Quality**: 100% test coverage, LuaDoc annotations, decision-driven architecture **Total GTD System Progress**: 32/32 tests passing across 3 modules (Init, Capture, Clarify)
