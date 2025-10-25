# Issue #9: TDD Tests for Dashboard & Hugo Menu UI Components

**Labels:** `testing`, `quality`, `ui`, `medium-priority`

## Description

Complete TDD test coverage for user-facing UI components that currently lack comprehensive tests: Dashboard, Hugo menu, and ASCII neural network display.

## Context

Current test coverage: 161 unit tests across 5 modules (Zettelkasten workflow) **Gap**: UI components (dashboard, Hugo menu, ASCII display) lack systematic TDD coverage

## Requirements

### 1. Dashboard Functionality Tests

Test complete dashboard system:

- Dashboard layout and component rendering
- Menu item display and selection
- Navigation to different sections
- Status indicators and notifications
- Keyboard interaction (j/k navigation, Enter selection)
- Window management (floating window behavior)

### 2. Hugo Menu Functionality Tests

Test Hugo publishing menu system:

- Menu display with publishing options
- Frontmatter validation integration
- Publishing workflow execution
- Error handling and user feedback
- File eligibility checks
- Hugo build integration

### 3. ASCII Neural Network Display Tests

Test visual network representation:

- ASCII art generation from network data
- Node positioning and layout
- Connection line rendering
- Interactive navigation
- Real-time updates during training
- Performance with large networks

### 4. UI Component Integration

- Dashboard → Hugo menu navigation
- Dashboard → Network display navigation
- Consistent UI patterns across components
- Shared utility functions (window creation, keybindings)

## Acceptance Criteria

- [ ] Dashboard tests: 15+ tests covering all menu items and interactions
- [ ] Hugo menu tests: 12+ tests covering publishing workflow
- [ ] ASCII network tests: 10+ tests covering rendering and interaction
- [ ] Integration tests: 5+ tests covering component navigation
- [ ] All tests follow 6/6 test standards (AAA, no `_G.`, helpers, etc.)
- [ ] Test coverage: >85% for all UI components
- [ ] No flakiness: Deterministic UI tests with proper cleanup

## Implementation Tasks

### Phase 1: Dashboard Tests (2-3 hours)

- [ ] Test: Dashboard window creation and layout
- [ ] Test: Menu item rendering (12 items)
- [ ] Test: Keyboard navigation (j/k/Enter)
- [ ] Test: Menu item selection callbacks
- [ ] Test: Status indicators and notifications
- [ ] Test: Window cleanup and closure

### Phase 2: Hugo Menu Tests (2-3 hours)

- [ ] Test: Hugo menu display and options
- [ ] Test: Frontmatter validation before publishing
- [ ] Test: Publishing workflow execution
- [ ] Test: Error handling (invalid frontmatter)
- [ ] Test: File eligibility checks (inbox exclusion)
- [ ] Test: Hugo build integration

### Phase 3: ASCII Network Display Tests (2-3 hours)

- [ ] Test: Network data → ASCII art conversion
- [ ] Test: Node positioning algorithms
- [ ] Test: Connection line rendering
- [ ] Test: Interactive navigation (pan/zoom)
- [ ] Test: Real-time updates (training progress)
- [ ] Test: Performance benchmarks (100+ nodes)

### Phase 4: Integration Tests (1-2 hours)

- [ ] Test: Dashboard → Hugo menu navigation
- [ ] Test: Dashboard → Network display navigation
- [ ] Test: Shared UI utilities (window creation)
- [ ] Test: Consistent keybinding patterns
- [ ] Test: Error recovery across components

## Testing Strategy

- **Test Framework**: Plenary (existing framework)
- **Mock Strategy**: Mock Neovim API calls (nvim_create_buf, nvim_open_win)
- **UI Testing**: Test logical behavior, not visual appearance
- **Isolation**: Each test creates clean UI state
- **Cleanup**: All tests close windows and delete buffers
- **Standards**: Follow 6/6 test standards for consistency

## Success Metrics

- **Coverage**: 42+ tests covering all UI components
- **Quality**: 100% compliance with test standards
- **Reliability**: 0% flakiness (deterministic tests)
- **Performance**: All UI tests complete in \<15 seconds
- **Maintainability**: Clear test names and AAA structure

## Estimated Effort

6-8 hours

## Dependencies

- Plenary (test framework)
- Mock Neovim API utilities
- Existing UI components (dashboard, Hugo menu, network display)
- Test helpers for window and buffer management

## Related Files

- `lua/percybrain/dashboard.lua` (existing dashboard implementation)
- `lua/percybrain/hugo-menu.lua` (existing Hugo menu implementation)
- `lua/percybrain/network-graph.lua` (existing network display implementation)
- `tests/contract/dashboard_spec.lua` (NEW - contract tests)
- `tests/contract/hugo_menu_ui_spec.lua` (NEW - contract tests)
- `tests/contract/ascii_network_spec.lua` (NEW - contract tests)
- `tests/capability/dashboard/workflow_spec.lua` (NEW - capability tests)
- `tests/capability/hugo_menu/ui_workflow_spec.lua` (NEW - capability tests)
- `tests/capability/network_display/rendering_spec.lua` (NEW - capability tests)
