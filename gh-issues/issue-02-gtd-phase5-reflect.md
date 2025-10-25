# Issue #2: Implement GTD Phase 5 - Reflect Module

**Parent Epic:** Complete GTD Workflow Implementation

**Labels:** `enhancement`, `gtd`, `phase-5`, `medium-complexity`

## Description

Create the Reflect module for automated weekly and daily GTD reviews with analytics and completion tracking.

## Requirements

1. Create `lua/percybrain/gtd/reflect.lua`
2. Implement weekly review automation
3. Implement daily review workflow
4. Create task analytics (completion rates, aging, etc.)
5. Write comprehensive test suite (target: 8+ tests)

## Acceptance Criteria

- [ ] `weekly_review()` guides user through GTD weekly review process
- [ ] `daily_review()` facilitates daily planning routine
- [ ] Analytics show completion metrics and task aging
- [ ] Review workflows reduce manual overhead by 50%+
- [ ] All tests passing (8+ new tests)
- [ ] Keymaps integrated: `<leader>orw` (weekly), `<leader>ord` (daily)
- [ ] Documentation complete with review checklists

## Implementation Details

```lua
-- lua/percybrain/gtd/reflect.lua
local M = {}

function M.weekly_review()
  -- 1. Collect all loose tasks
  -- 2. Process inbox to zero
  -- 3. Review next actions
  -- 4. Review projects
  -- 5. Update Someday/Maybe
  -- Interactive workflow with progress tracking
end

function M.daily_review()
  -- 1. Review calendar for today
  -- 2. Review next actions
  -- 3. Select Most Important Tasks (MIT)
  -- Floating window with daily plan
end

function M.get_analytics()
  -- Count tasks by status
  -- Calculate completion rate
  -- Identify aging tasks
  -- Generate insights
end

return M
```

## Testing Strategy

- Unit tests for analytics calculation
- Integration tests for review workflow
- Mock file system for predictable test data

## Estimated Effort

6-8 hours

## Related Files

- `lua/percybrain/gtd/reflect.lua` (NEW)
- `tests/unit/gtd/gtd_reflect_spec.lua` (NEW)
- `lua/config/keymaps/workflows/gtd.lua` (UPDATE)
- `claudedocs/GTD_IMPLEMENTATION_WORKFLOW.md` (REFERENCE - archived)
