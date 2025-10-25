# Issue #8: Integration Testing Suite - End-to-End Workflow Validation

**Labels:** `testing`, `quality`, `workflow`, `medium-priority`

## Description

Create comprehensive integration test suite validating complete Zettelkasten workflow from capture to publication.

## Context

Current test coverage: 161 unit tests (contract + capability) across 5 modules **Gap**: No end-to-end integration tests validating complete workflow

## Requirements

### 1. Complete Workflow Testing

Test full pipeline:

1. Fleeting note capture (quick capture)
2. Note editing with AI processing
3. Wiki page creation with Hugo frontmatter
4. Hugo frontmatter validation
5. Publishing eligibility check
6. Hugo build verification

### 2. Two-Tier Note System Validation

- Fleeting notes (inbox) workflow
  - Simple frontmatter (title + timestamp)
  - Optional AI processing
  - Excluded from Hugo publishing
- Wiki pages workflow
  - Hugo-compatible frontmatter required
  - Full AI pipeline processing
  - Published to Hugo site

### 3. Cross-Module Integration

- Template system → Quick capture integration
- Quick capture → Write-quit pipeline integration
- Write-quit pipeline → AI model selection integration
- Hugo validation → Publishing workflow integration

### 4. Error Handling & Recovery

- Test graceful degradation when Ollama unavailable
- Test Hugo validation failures with helpful messages
- Test file system errors (permissions, disk space)
- Test concurrent operations (rapid note captures)

### 5. Performance Validation

- Capture workflow completes in \<100ms
- AI processing doesn't block editor
- Hugo build completes in \<3 seconds (for test notes)
- Background processing queue management

## Acceptance Criteria

- [ ] Integration test suite: 20+ tests covering complete workflow
- [ ] Fleeting note workflow: Capture → Edit → Optional AI → Inbox storage
- [ ] Wiki page workflow: Capture → Edit → AI → Hugo validation → Publish eligibility
- [ ] Cross-module integration: All 5 modules work together seamlessly
- [ ] Error handling: Graceful degradation with helpful messages
- [ ] Performance: No workflow step blocks editor (all async)
- [ ] CI/CD ready: Tests run in headless Neovim without user interaction

## Implementation Tasks

### Phase 1: Test Infrastructure (2-3 hours)

- [ ] Create `tests/integration/` directory structure
- [ ] Build test harness for workflow orchestration
- [ ] Create mock Ollama for integration tests
- [ ] Setup temporary Zettelkasten directory for tests

### Phase 2: Fleeting Note Workflow (2-3 hours)

- [ ] Test: Quick capture → Inbox storage
- [ ] Test: Fleeting note editing
- [ ] Test: Optional AI processing
- [ ] Test: Hugo publishing exclusion

### Phase 3: Wiki Page Workflow (3-4 hours)

- [ ] Test: Wiki page creation with Hugo frontmatter
- [ ] Test: Write-quit AI pipeline processing
- [ ] Test: Hugo frontmatter validation
- [ ] Test: Publishing eligibility check
- [ ] Test: Hugo build with test content

### Phase 4: Cross-Module Integration (2-3 hours)

- [ ] Test: Template system → Quick capture
- [ ] Test: Quick capture → Write-quit pipeline
- [ ] Test: Write-quit → AI model selection
- [ ] Test: AI processing → Hugo validation

### Phase 5: Error & Performance (2-3 hours)

- [ ] Test: Ollama unavailable (graceful degradation)
- [ ] Test: Invalid Hugo frontmatter (helpful errors)
- [ ] Test: File system errors (permissions, disk space)
- [ ] Test: Concurrent operations (rapid captures)
- [ ] Test: Performance benchmarks (all workflows \<100ms)

## Testing Strategy

- **Test Isolation**: Each test creates temporary Zettelkasten directory
- **Mock External Dependencies**: Mock Ollama, mock Hugo build
- **Async Testing**: Verify non-blocking behavior with timer checks
- **Cleanup**: All tests clean up temporary files/directories
- **CI/CD Integration**: Tests run in GitHub Actions

## Success Metrics

- **Coverage**: 20+ integration tests covering complete workflow
- **Reliability**: 0% flakiness (deterministic tests)
- **Performance**: All tests complete in \<30 seconds
- **CI/CD**: Tests pass in GitHub Actions without modification

## Estimated Effort

8-12 hours

## Dependencies

- Plenary (test framework)
- Mock Ollama implementation
- Temporary file system utilities
- Hugo (for build validation tests)

## Related Files

- `tests/integration/` (NEW - integration test directory)
- `tests/helpers/mock_ollama.lua` (existing mock)
- `tests/helpers/temp_zettelkasten.lua` (NEW - test harness)
- `lua/percybrain/floating-quick-capture.lua`
- `lua/percybrain/write-quit-pipeline.lua`
- `lua/percybrain/hugo-menu.lua`
- `lua/percybrain/ai-model-selector.lua`
