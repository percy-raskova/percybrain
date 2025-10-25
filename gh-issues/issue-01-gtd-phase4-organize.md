# Issue #1: Implement GTD Phase 4 - Organize Module

**Parent Epic:** Complete GTD Workflow Implementation

**Labels:** `enhancement`, `gtd`, `phase-4`, `medium-complexity`

## Description

Create the Organize module for GTD system to enable context assignment, project assignment, and context-based task views.

## Requirements

1. Create `lua/percybrain/gtd/organize.lua`
2. Implement context assignment function
3. Implement project assignment function
4. Create Telescope integration for context-based views
5. Write comprehensive test suite (target: 10+ tests)

## Acceptance Criteria

- [ ] `assign_context()` function assigns @context tags to tasks
- [ ] `assign_project()` function assigns tasks to projects
- [ ] Telescope integration shows tasks filtered by context
- [ ] All tests passing (10+ new tests)
- [ ] Keymaps integrated: `<leader>ocx` (context), `<leader>ocp` (project)
- [ ] Documentation complete in module and GTD reference docs

## Implementation Details

```lua
-- lua/percybrain/gtd/organize.lua
local M = {}

function M.assign_context()
  -- Interactive context selection from config.contexts
  -- Append @context tag to current line
  -- Handle duplicate context prevention
end

function M.assign_project()
  -- Interactive project selection from projects.md
  -- Create project reference in task
  -- Update project's next actions list
end

function M.by_context()
  -- Telescope live_grep filtered to @context pattern
  -- Grouped display by context
end

return M
```

## Testing Strategy

- Unit tests for context/project assignment logic
- Integration tests for Telescope views
- Edge case tests for duplicate handling

## Estimated Effort

8-12 hours

## Related Files

- `lua/percybrain/gtd/organize.lua` (NEW)
- `tests/unit/gtd/gtd_organize_spec.lua` (NEW)
- `lua/config/keymaps/workflows/gtd.lua` (UPDATE)
- `claudedocs/GTD_IMPLEMENTATION_WORKFLOW.md` (REFERENCE - archived)
