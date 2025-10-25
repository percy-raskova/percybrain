# Issue #3: Implement GTD Phase 6 - Engage Module

**Parent Epic:** Complete GTD Workflow Implementation

**Labels:** `enhancement`, `gtd`, `phase-6`, `high-complexity`, `integration`

## Description

Complete the Engage module for context-aware task selection, time tracking integration, and dashboard visualization.

## Requirements

1. Complete `lua/percybrain/gtd/engage.lua` (partially implemented)
2. Implement Pendulum time tracking integration
3. Implement Telekasten calendar scheduling
4. Create GTD dashboard widget for Alpha
5. Implement time-blocking and Pomodoro features
6. Write comprehensive test suite (target: 12+ tests)

## Acceptance Criteria

- [ ] `track_task()` starts Pendulum tracking for current task
- [ ] `schedule_task()` adds tasks to Telekasten calendar
- [ ] Dashboard shows GTD metrics (inbox count, next actions, waiting)
- [ ] Context-aware task selection via Telescope
- [ ] Time-blocking integration functional
- [ ] All tests passing (12+ new tests)
- [ ] Keymaps complete: `<leader>oT` (track), `<leader>oS` (schedule), etc.
- [ ] Dashboard integration tested on Alpha

## Implementation Details

```lua
-- lua/percybrain/gtd/engage.lua (COMPLETE)
local M = {}

function M.track_task()
  -- Extract task from current line
  -- Start Pendulum with task name
  -- Notify user tracking started
end

function M.schedule_task()
  -- Prompt for date (default: today)
  -- Add scheduled:YYYY-MM-DD tag
  -- Create calendar entry via Telekasten
end

function M.select_by_context()
  -- Show current context (@home, @work, etc.)
  -- Display tasks for that context
  -- Enable quick task selection
end

-- Dashboard widget
function M.get_dashboard_widget()
  -- Count tasks in inbox, next-actions, waiting
  -- Generate Alpha dashboard section
  -- Color-code based on urgency
end

return M
```

## Testing Strategy

- Unit tests for task tracking logic
- Integration tests for Pendulum/Telekasten
- Mock external dependencies for fast testing
- Visual validation for dashboard widget

## Dependencies

- `pendulum.nvim` plugin installed and configured
- `telekasten.nvim` calendar feature enabled
- `alpha-nvim` dashboard configured

## Estimated Effort

10-15 hours (higher complexity due to integrations)

## Related Files

- `lua/percybrain/gtd/engage.lua` (COMPLETE)
- `lua/percybrain/gtd/dashboard.lua` (NEW)
- `tests/unit/gtd/gtd_engage_spec.lua` (NEW)
- `lua/config/keymaps/workflows/gtd.lua` (UPDATE)
- `lua/plugins/ui/alpha.lua` (UPDATE - integrate widget)
- `claudedocs/GTD_IMPLEMENTATION_WORKFLOW.md` (REFERENCE - archived)
