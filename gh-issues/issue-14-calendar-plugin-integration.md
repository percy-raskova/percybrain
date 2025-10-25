# Issue #14: Calendar Plugin Integration

**Labels:** `enhancement`, `calendar`, `gtd`, `time-tracking`, `crm`, `high-priority`

## Description

Custom calendar plugin providing unified interface for daily notes, task management, time tracking, planning workflows, and Monica CRM synchronization. Integrates IWE daily notes, GTD workflows, Pendulum time tracking, and Monica API with Blood Moon UI theme.

## Context

**Current State**: Telekasten provides basic calendar (date picker), but limited integration **Decision**: Remove Telekasten, build custom calendar with deep workflow integration **Priority**: HIGH - Central coordination point for knowledge management system

## Requirements

### 1. IWE Daily Notes Integration

Calendar as navigation interface for IWE daily notes:

- Click date → Open/create daily note via IWE action
- Visual indicators for existing notes
- Month/week/day views
- Quick navigation (keyboard shortcuts)
- Date range browsing (past/future)

### 2. GTD Workflow Integration

Calendar coordinates all 5 GTD phases:

- **Capture** (`<leader>oc`): Quick capture timestamped to selected date
- **Clarify** (`<leader>op`): Process inbox items with date context
- **Organize** (`<leader>oo`): Schedule tasks to calendar dates
- **Reflect** (Weekly review): Calendar view for weekly GTD review
- **Engage** (Daily execution): Today's view shows actionable tasks

### 3. Pendulum Time Tracking Integration

Calendar visualizes time tracking data:

- Display time logged per day (from `~/.pendulum.log`)
- Visual indicators for tracking status (active/stopped)
- Integration with timer commands (`<leader>pt*`)
- Time reports by date range
- Planning mode: Estimate time allocations

### 4. Planning Workflows

Calendar supports strategic planning:

- **Week View**: Monday-Sunday with time blocks
- **Month View**: Bird's eye project planning
- **Day View**: Detailed daily schedule
- **Drag-and-drop**: Reschedule tasks (future enhancement)
- **Time blocking**: Allocate time slots for focus work

### 5. Blood Moon UI Integration

Calendar maintains visual consistency:

- Color palette: `#1a0000` (background), `#ffd700` (gold), `#dc143c` (crimson)
- Floating window: 75-77 columns, centered, double border
- ADHD optimization: Clear visual hierarchy, 5-7 choice limit
- Consistent keybindings: `<leader>c*` namespace
- Emoji indicators: 📅 calendar, ✅ completed, 🔄 in-progress

### 6. Monica CRM API Integration

Calendar syncs personal relationship management:

- **Reminders**: Monica reminders → calendar events
- **Activities**: Contact interactions appear on calendar
- **Tasks**: Monica tasks integrated with GTD
- **Contacts**: Quick access to contact info from calendar
- **API**: RESTful JSON at configured Monica instance

## Architecture

### Core Module Structure

```lua
lua/percybrain/calendar/
├── init.lua                 -- Main setup and initialization
├── core.lua                 -- Calendar logic (date math, rendering)
├── views/
│   ├── month.lua           -- Month view implementation
│   ├── week.lua            -- Week view implementation
│   └── day.lua             -- Day view implementation
├── integrations/
│   ├── iwe.lua             -- IWE daily notes integration
│   ├── gtd.lua             -- GTD workflow integration
│   ├── pendulum.lua        -- Time tracking integration
│   └── monica.lua          -- Monica CRM API client
├── ui.lua                  -- Blood Moon themed UI components
└── commands.lua            -- User commands and keybindings
```

### Data Model

**CalendarEvent**:

```lua
{
  id = "uuid",
  date = "2025-10-22",            -- ISO format
  time = "14:30",                 -- Optional time
  title = "Event title",
  description = "Details...",
  type = "task|reminder|activity|note",
  source = "gtd|monica|iwe|manual",
  status = "pending|completed|cancelled",
  duration = 60,                  -- Minutes (optional)
  tags = { "work", "important" },
  metadata = {
    gtd_context = "@home",
    gtd_priority = "high",
    monica_contact_id = 123,
    pendulum_log_entry = "line:456",
  }
}
```

**CalendarState**:

```lua
{
  view = "month|week|day",
  current_date = os.date("*t"),
  selected_date = nil,             -- User selection
  events = {},                     -- Loaded events
  filters = {
    show_tasks = true,
    show_reminders = true,
    show_activities = true,
    sources = { "gtd", "monica", "iwe" },
  }
}
```

### Integration Interfaces

#### IWE Daily Notes API

```lua
-- Open/create daily note for date
function M.iwe_daily_note(date)
  -- Uses IWE action.daily configuration
  -- Template: ~/Zettelkasten/templates/daily.md
  -- Path: ~/Zettelkasten/daily/YYYY-MM-DD.md
  local iwe = require("percybrain.calendar.integrations.iwe")
  iwe.open_daily_note(date)
end

-- Check if daily note exists
function M.has_daily_note(date)
  local path = string.format("~/Zettelkasten/daily/%s.md", date)
  return vim.fn.filereadable(vim.fn.expand(path)) == 1
end
```

#### GTD Integration API

```lua
-- Quick capture for selected date
function M.gtd_capture(date, text)
  local gtd_capture = require("percybrain.gtd.capture")
  local task_item = gtd_capture.format_task_item(text)

  -- Append to daily note or inbox with date context
  local target = date == os.date("%Y-%m-%d")
    and "inbox"
    or string.format("daily/%s.md", date)

  gtd_capture.append_to_file(target, task_item)
end

-- Get tasks for date range
function M.get_tasks_for_range(start_date, end_date)
  -- Parse daily notes and inbox for tasks
  -- Return tasks with metadata (status, context, priority)
end

-- Schedule task to date
function M.schedule_task(task_id, date)
  -- Move task from inbox to daily note
  -- Update task metadata with scheduled date
end
```

#### Pendulum Integration API

```lua
-- Get time logged for date
function M.get_time_logged(date)
  -- Parse ~/.pendulum.log for entries matching date
  -- Format: YYYY-MM-DD HH:MM:SS | START|STOP | description
  -- Return: { total_minutes, entries = {...} }
end

-- Get time tracking status
function M.get_tracking_status()
  -- Check if timer currently running
  -- Return: { active = true/false, current_task = "..." }
end

-- Start timer for calendar event
function M.start_timer_for_event(event_id)
  local pendulum = require("pendulum")
  pendulum.start(event.title)
end
```

#### Monica CRM API

```lua
-- Monica API Client
local M = {}

M.config = {
  base_url = vim.env.MONICA_URL or "http://localhost:8000",
  api_key = vim.env.MONICA_API_KEY,
  api_version = "v1",
}

-- Get reminders for date range
function M.get_reminders(start_date, end_date)
  -- GET /api/reminders?from={start_date}&to={end_date}
  -- Returns Monica reminder objects
end

-- Get activities for date
function M.get_activities(date)
  -- GET /api/activities?date={date}
  -- Returns contact interaction history
end

-- Get tasks
function M.get_tasks(params)
  -- GET /api/tasks?completed={false}&due_date={date}
  -- Returns Monica task objects
end

-- Create reminder
function M.create_reminder(params)
  -- POST /api/reminders
  -- Body: { contact_id, title, description, scheduled_at }
end

-- Sync calendar events to Monica
function M.sync_to_monica(events)
  -- Convert calendar events to Monica reminders/tasks
  -- Batch API calls for efficiency
end
```

### UI/UX Specification

#### Month View

**Layout** (75 columns wide):

```
╔═════════════════════════════════════ October 2025 ══════════════════════════╗
║                                                                              ║
║   Mon   Tue   Wed   Thu   Fri   Sat   Sun                                   ║
║   ───   ───   ───   ───   ───   ───   ───                                   ║
║    29    30     1     2     3     4     5                                    ║
║                 ✓     •     •                                                ║
║     6     7     8     9    10    11    12                                    ║
║     •     •     •     ✓     ✓                                                ║
║    13    14    15    16    17    18    19                                    ║
║     •     ✓     •     •     ✓                                                ║
║    20    21    22    23    24    25    26                                    ║
║     ✓     •    [•]    •     •                                                ║
║    27    28    29    30    31     1     2                                    ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📅 Selected: 2025-10-22 │ ✅ 12 completed │ 🔄 5 pending │ ⏱️  8.5 hrs      ║
╚══════════════════════════════════════════════════════════════════════════════╝

Indicators:
  ✓ - Daily note exists + tasks completed
  • - Daily note exists / tasks pending
  [•] - Currently selected date
  (blank) - No daily note
```

**Keybindings**:

- `h/j/k/l` - Navigate dates (vim style)
- `<Enter>` - Open daily note for selected date
- `n` - Create new event on selected date
- `t` - Toggle task view
- `w` - Switch to week view
- `d` - Switch to day view
- `q` - Close calendar
- `r` - Refresh (sync Monica)

#### Week View

**Layout**:

```
╔════════════════════════════════ Week 43: Oct 20-26 ══════════════════════════╗
║ Time   │ Mon 20  │ Tue 21  │ Wed 22  │ Thu 23  │ Fri 24  │ Sat 25  │ Sun 26 ║
║────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼────────║
║ 08:00  │         │         │ 🤖 AI   │         │         │         │        ║
║        │         │         │ draft   │         │         │         │        ║
║ 09:00  │ ✅ GTD  │         │         │         │ 📞 Call │         │        ║
║        │ review  │         │         │         │ client  │         │        ║
║ 10:00  │         │ 📝 Write│         │ 🔬 Code │         │         │        ║
║        │         │ blog    │         │ review  │         │         │        ║
║ ...    │         │         │         │         │         │         │        ║
║ 14:00  │         │         │ [•]     │         │         │         │        ║
║        │         │         │ Focus   │         │         │         │        ║
║        │         │         │ time    │         │         │         │        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ ⏱️  Total: 25.5 hrs │ ✅ 8 completed │ 🔄 12 pending │ 📞 3 reminders        ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Keybindings**:

- `h/l` - Previous/next week
- `j/k` - Navigate time slots
- `<Enter>` - View/edit event
- `n` - New event at cursor
- `m` - Switch to month view
- `d` - Switch to day view
- `q` - Close calendar

#### Day View

**Layout**:

```
╔═══════════════════════════════ Wednesday, October 22 ════════════════════════╗
║                                                                              ║
║ Morning                                                                      ║
║   08:00 - 09:00  🤖 AI draft writing           [✅ Completed] ⏱️  1.2 hrs   ║
║   09:00 - 10:00  📝 Research notes             [🔄 In Progress]             ║
║                                                                              ║
║ Afternoon                                                                    ║
║   14:00 - 16:00  🔬 Code review               [⏳ Scheduled]                ║
║   16:30 - 17:00  📞 Team sync                 [📅 Reminder]                 ║
║                                                                              ║
║ Tasks                                                                        ║
║   • Finish GTD Phase 4 implementation          @code #high                  ║
║   • Review Monica API documentation            @research                    ║
║   • Write calendar plugin spec                 @writing #urgent             ║
║                                                                              ║
║ Notes                                                                        ║
║   Daily note: daily/2025-10-22.md exists                                    ║
║   Time logged: 8.5 hours                                                    ║
║   Monica activities: 2 (call with Alice, email to Bob)                      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Quick Actions: [n]ew task │ [c]apture │ [t]imer start │ [r]eminder │ [q]uit ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Keybindings**:

- `j/k` - Navigate events
- `<Enter>` - Edit event details
- `n` - New task/event
- `c` - Quick capture (GTD)
- `t` - Start/stop timer (Pendulum)
- `x` - Toggle task completion
- `m` - Switch to month view
- `w` - Switch to week view
- `q` - Close calendar

### Keybinding Namespace

**Primary namespace**: `<leader>c*` (Calendar)

**Core Operations**:

- `<leader>cc` - Open calendar (month view)
- `<leader>ct` - Open today's view
- `<leader>cw` - Open week view
- `<leader>cm` - Open month view
- `<leader>cd` - Open day view

**Quick Actions**:

- `<leader>cn` - New event on today
- `<leader>cc` - Quick capture to today
- `<leader>ct` - Start timer for current task

**Integration**:

- `<leader>cr` - Refresh from Monica
- `<leader>cs` - Sync to Monica
- `<leader>ci` - Import Monica reminders

**Navigation**:

- `<leader>cj` - Go to next day/week/month
- `<leader>ck` - Go to previous day/week/month
- `<leader>cg` - Go to specific date (prompt)

### Configuration

**User config** (`lua/percybrain/calendar/config.lua`):

```lua
M.config = {
  -- View preferences
  default_view = "month",           -- month|week|day
  start_of_week = "monday",         -- monday|sunday
  time_format = "24h",              -- 24h|12h

  -- Integrations
  iwe = {
    enabled = true,
    daily_note_path = "~/Zettelkasten/daily/%Y-%m-%d.md",
    template = "~/Zettelkasten/templates/daily.md",
  },

  gtd = {
    enabled = true,
    auto_schedule = false,          -- Prompt before scheduling
    inbox_path = "~/Zettelkasten/inbox.md",
  },

  pendulum = {
    enabled = true,
    log_file = "~/Zettelkasten/.pendulum.log",
    show_in_calendar = true,        -- Display time tracking
  },

  monica = {
    enabled = false,                 -- Requires API key
    base_url = vim.env.MONICA_URL,
    api_key = vim.env.MONICA_API_KEY,
    sync_interval = 3600,            -- Seconds (1 hour)
    auto_sync = false,
  },

  -- UI preferences
  ui = {
    width = 77,                      -- Columns (Blood Moon standard)
    height = 30,                     -- Rows (adaptive)
    border = "double",
    show_time_logged = true,
    show_task_counts = true,
    indicators = {
      has_note = "•",
      completed = "✓",
      selected = "[•]",
      reminder = "📅",
      task = "📝",
      activity = "📞",
    },
  },

  -- Performance
  cache_events = true,
  cache_ttl = 300,                   -- Seconds (5 minutes)
}
```

### Commands

**User Commands**:

```vim
:CalendarOpen            " Open calendar (default view)
:CalendarToday           " Jump to today
:CalendarMonth           " Switch to month view
:CalendarWeek            " Switch to week view
:CalendarDay             " Switch to day view
:CalendarGoto <date>     " Go to specific date (YYYY-MM-DD)
:CalendarNewEvent        " Create event on selected date
:CalendarQuickCapture    " GTD quick capture
:CalendarTimerStart      " Start Pendulum timer
:CalendarTimerStop       " Stop Pendulum timer
:CalendarSyncMonica      " Sync with Monica CRM
:CalendarRefresh         " Reload all data
```

## Acceptance Criteria

- [ ] Month/week/day views implemented with Blood Moon theme
- [ ] IWE daily notes: Click date → open/create note
- [ ] GTD integration: Quick capture, task scheduling, inbox processing
- [ ] Pendulum integration: Display time logged, start/stop timer
- [ ] Monica API: Sync reminders, activities, tasks (if configured)
- [ ] Keybindings: Complete `<leader>c*` namespace
- [ ] UI: Floating window (75-77 cols), double border, emoji indicators
- [ ] Performance: \<30s Monica sync, \<1s view switching
- [ ] Configuration: User-friendly config with sensible defaults
- [ ] Documentation: Complete user guide with screenshots
- [ ] Testing: TDD with contract, capability, and regression tests

## Implementation Tasks

### Phase 1: Core Calendar Logic (4-6 hours)

- [ ] Calendar date math (month/week/day calculations)
- [ ] Event data model and storage
- [ ] View state management
- [ ] Date navigation logic
- [ ] Keybinding registry
- [ ] Contract tests for calendar logic

### Phase 2: UI Implementation (6-8 hours)

- [ ] Blood Moon themed floating window
- [ ] Month view renderer
- [ ] Week view renderer
- [ ] Day view renderer
- [ ] View switching logic
- [ ] Keyboard navigation
- [ ] Capability tests for UI interactions

### Phase 3: IWE Integration (3-4 hours)

- [ ] Daily note detection
- [ ] Daily note creation via IWE action
- [ ] Visual indicators (has note / no note)
- [ ] Template integration
- [ ] Contract tests for IWE integration

### Phase 4: GTD Integration (4-5 hours)

- [ ] Quick capture to calendar date
- [ ] Task scheduling workflow
- [ ] Inbox processing with date context
- [ ] Task status tracking (pending/completed)
- [ ] GTD keybinding integration
- [ ] Capability tests for GTD workflows

### Phase 5: Pendulum Integration (2-3 hours)

- [ ] Parse pendulum log file
- [ ] Display time logged per day
- [ ] Timer start/stop from calendar
- [ ] Time tracking status indicators
- [ ] Contract tests for Pendulum integration

### Phase 6: Monica API Client (6-8 hours)

- [ ] REST API client (GET/POST/PUT/DELETE)
- [ ] Authentication with API key
- [ ] Reminders endpoint integration
- [ ] Activities endpoint integration
- [ ] Tasks endpoint integration
- [ ] Sync logic (calendar ↔ Monica)
- [ ] Error handling and retries
- [ ] Contract tests for API client

### Phase 7: Polish & Documentation (3-4 hours)

- [ ] Performance optimization (caching, lazy loading)
- [ ] Error messages and user feedback
- [ ] Configuration validation
- [ ] User guide with examples
- [ ] Troubleshooting section
- [ ] Code documentation (LuaDoc)
- [ ] Regression tests for settings

## Testing Strategy

### Contract Tests

- Calendar logic: Date math accuracy (leap years, month boundaries)
- Event model: Required fields, valid data types
- IWE integration: Daily note paths match config
- GTD integration: Inbox path exists, task format correct
- Pendulum integration: Log file format parsing
- Monica API: Request/response structure validation

### Capability Tests

- **Month view**: CAN display current month, CAN navigate dates
- **Week view**: CAN display time slots, CAN show events
- **Day view**: CAN display tasks, CAN show time logged
- **IWE**: CAN open daily note, CAN create new note
- **GTD**: CAN quick capture, CAN schedule task
- **Pendulum**: CAN start timer, CAN stop timer
- **Monica**: CAN sync reminders, CAN fetch activities

### Regression Tests

- Default view remains "month"
- IWE daily note path stable
- GTD inbox path unchanged
- Pendulum log file location preserved
- Monica API URL/key not leaked in logs

### Performance Tests

- Month view renders in \<200ms
- Week view renders in \<300ms
- Day view renders in \<150ms
- Monica sync completes in \<30s (100 events)
- View switching \<100ms

## Success Metrics

- **View Rendering**: Month/week/day views functional with Blood Moon theme
- **Integration Coverage**: IWE, GTD, Pendulum, Monica all working
- **Performance**: View switching \<100ms, Monica sync \<30s
- **Test Coverage**: 40+ tests passing (contract + capability + regression)
- **Documentation Quality**: User guide enables self-service
- **ADHD Optimization**: Clear visual hierarchy, 5-7 choice limit preserved
- **Keybinding Consistency**: Complete `<leader>c*` namespace

## Estimated Effort

28-38 hours total:

- Phase 1 (Core): 4-6 hours
- Phase 2 (UI): 6-8 hours
- Phase 3 (IWE): 3-4 hours
- Phase 4 (GTD): 4-5 hours
- Phase 5 (Pendulum): 2-3 hours
- Phase 6 (Monica): 6-8 hours
- Phase 7 (Docs): 3-4 hours

## Dependencies

**Required**:

- IWE LSP (`cargo install iwe`) - Daily notes integration
- Telescope.nvim - Pickers for date/event selection
- Plenary.nvim - Async operations and utilities
- Neovim ≥0.8.0 - Floating window API

**Optional**:

- Monica CRM instance - Personal relationship management
- Pendulum plugin - Time tracking integration
- GTD plugin (Phases 1-3) - Task management integration

**External**:

- Monica API: `http://localhost:8000` or configured URL
- Pendulum log: `~/Zettelkasten/.pendulum.log`
- IWE daily notes: `~/Zettelkasten/daily/`

## Related Files

- `lua/percybrain/calendar/` (NEW - complete plugin directory)
- `lua/config/keymaps/workflows/calendar.lua` (NEW - keybindings)
- `lua/plugins/productivity/calendar.lua` (NEW - lazy.nvim config)
- `tests/contract/calendar_spec.lua` (NEW - contract tests)
- `tests/capability/calendar/` (NEW - capability tests directory)
- `docs/how-to/CALENDAR_USAGE.md` (NEW - user guide)
- `docs/reference/KEYBINDINGS_REFERENCE.md` (UPDATE - document calendar bindings)

## Notes

**Replaces Telekasten Calendar**: Telekasten's `show_calendar` is basic date picker. This plugin provides full calendar UI with workflow integration.

**Monica API Optional**: Plugin works without Monica (IWE + GTD + Pendulum). Monica integration requires user setup (`MONICA_URL`, `MONICA_API_KEY`).

**ADHD Optimization**: Calendar views limited to essential information. No cluttered grids, clear visual hierarchy, predictable keybindings.

**Future Enhancements** (not in scope):

- Drag-and-drop task rescheduling
- Recurring events (daily/weekly/monthly)
- Calendar event categories with colors
- Integration with external calendars (CalDAV)
- Mobile sync (Syncthing/Git)

**Blood Moon Integration**: All UI components follow established patterns (floating windows, double borders, gold/crimson colors, emoji indicators).

**Performance Considerations**:

- Cache Monica API responses (5-minute TTL)
- Lazy load daily notes (only visible month)
- Background sync (non-blocking)
- Debounce rapid navigation (reduce redraws)
