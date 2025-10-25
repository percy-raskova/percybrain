# Issue #11: Terminal Web Browsing Integration (Lynx/W3M)

**Labels:** `enhancement`, `browser`, `nice-to-have`, `low-priority`

## Description

Integrate terminal-based web browsers (Lynx/W3M) into Neovim for in-editor web browsing, research, and reference lookup without leaving the Zettelkasten workflow.

## Context

Current workflow requires switching to external browser for research and web content **Gap**: No in-editor web browsing capability for quick lookups and reference gathering **Priority**: Nice-to-have feature, not critical for core Zettelkasten functionality

## Requirements

### 1. Browser Integration

Terminal browser support:

- Lynx integration (text-based browser)
- W3M integration (alternative text browser)
- Browser selection (user preference)
- Configuration management (browser settings)

### 2. Workflow Integration

Seamless Zettelkasten integration:

- Quick lookup from Zettelkasten note
- URL capture from browser to note
- Bookmark management
- History tracking
- Search integration

### 3. UI Components

Browser interface:

- Floating window for browser display
- Split window support
- Tab management for multiple pages
- Navigation controls (back/forward/reload)
- Status line integration

### 4. Content Extraction

Research workflow support:

- Copy text from browser to note
- Extract links and references
- Save page as markdown
- Capture citations
- Image link extraction

## Acceptance Criteria

- [ ] Browser integration: Both Lynx and W3M supported
- [ ] Workflow commands: `<leader>wb` (browse), `<leader>wu` (URL lookup)
- [ ] Content capture: Text/link extraction working
- [ ] UI polish: Floating window with navigation
- [ ] Configuration: User preference settings
- [ ] Documentation: User guide for web browsing workflow
- [ ] Performance: Browser launches in \<2 seconds

## Implementation Tasks

### Phase 1: Browser Detection & Setup (2-3 hours)

- [ ] Detect Lynx installation
- [ ] Detect W3M installation
- [ ] Create browser selection logic
- [ ] Document installation requirements
- [ ] Create fallback behavior (no browser installed)

### Phase 2: Basic Integration (3-4 hours)

- [ ] Create browser launch function
- [ ] Implement URL opening
- [ ] Create floating window for browser
- [ ] Add split window support
- [ ] Implement browser closure and cleanup

### Phase 3: Workflow Commands (2-3 hours)

- [ ] Add `<leader>wb` (browse) keybinding
- [ ] Add `<leader>wu` (URL lookup) keybinding
- [ ] Implement bookmark management
- [ ] Add history tracking
- [ ] Integrate with Telescope for search

### Phase 4: Content Extraction (3-4 hours)

- [ ] Implement text capture from browser
- [ ] Add link extraction functionality
- [ ] Create markdown conversion (page → .md)
- [ ] Add citation capture
- [ ] Implement image link extraction

### Phase 5: Polish & Documentation (2-3 hours)

- [ ] Add navigation controls (back/forward)
- [ ] Implement status line integration
- [ ] Create user configuration options
- [ ] Write user guide
- [ ] Add example workflows

## Testing Strategy

- **Browser Detection**: Test with/without browsers installed
- **URL Handling**: Test various URL formats (http, https, file)
- **Content Extraction**: Test text/link capture accuracy
- **Window Management**: Test floating/split/tab scenarios
- **Performance**: Measure browser launch time
- **Documentation**: User guide with screenshots

## Success Metrics

- **Browser Support**: Both Lynx and W3M working
- **Launch Time**: \<2 seconds from command to browser
- **Content Capture**: >95% accuracy for text/links
- **User Adoption**: Clear documentation enables self-service
- **Stability**: No crashes or buffer leaks

## Estimated Effort

12-16 hours

## Dependencies

- Lynx (optional: `sudo apt install lynx` or `brew install lynx`)
- W3M (optional: `sudo apt install w3m` or `brew install w3m`)
- Telescope (for search integration)
- Plenary (for async job control)

## Related Files

- `lua/plugins/utilities/web-browser.lua` (NEW - browser integration plugin)
- `lua/config/keymaps/utilities.lua` (UPDATE - add web browsing keybindings)
- `docs/how-to/WEB_BROWSING_GUIDE.md` (NEW - user guide)
- `docs/reference/KEYBINDINGS_REFERENCE.md` (UPDATE - document new keybindings)

## Notes

- **Alternative Approach**: Could use external browser with hotkeys instead of embedding
- **Privacy Consideration**: Terminal browsers offer better privacy than GUI browsers
- **Performance**: Text-based browsers are faster and lighter than GUI alternatives
- **Markdown Workflow**: Browser content → markdown → Zettelkasten note (complete research loop)
