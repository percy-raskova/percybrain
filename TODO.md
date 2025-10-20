# PercyBrain Development TODO

## Current Session Progress

### ✅ Completed

- [x] Fix network graph to use [markdown](links) not \[\[wikilinks\]\]
- [x] Fix dashboard to use [markdown](links) not \[\[wikilinks\]\]
- [x] Change Hugo keybinding from <leader>p to <leader>h with menu
- [x] Create dashboard keybinding <leader>d with menu (toggle, refresh, config, network)

### 🔄 In Progress

- [ ] Write TDD tests for ASCII neural network display

### 📋 Pending

- [ ] Write TDD tests for dashboard functionality
- [ ] Write TDD tests for Hugo menu functionality
- [ ] Create plugin loader for new percybrain modules (DONE - need to verify)
- [ ] Complete Sequential thinking workflow gap analysis (thought 11/22)
- [ ] Design TDD contracts for AI workflow components
- [ ] Generate implementation roadmap

## Files Created This Session

### Code/Implementation

- `/home/percy/.config/nvim/lua/percybrain/hugo-menu.lua` - Hugo publishing menu (<leader>h)
- `/home/percy/.config/nvim/lua/percybrain/dashboard-menu.lua` - Dashboard menu (<leader>d)
- `/home/percy/.config/nvim/lua/plugins/utilities/percybrain-dashboard.lua` - Plugin loader
- `/home/percy/.config/nvim/TODO.md` - Session progress tracking

### Templates (TDD Artifacts)

- `/home/percy/Zettelkasten/templates/fleeting.md` - Ultra-simple fleeting note (7 lines)
- `/home/percy/Zettelkasten/templates/wiki.md` - Hugo-compatible wiki with BibTeX (22 lines)

### Tests (TDD - Written BEFORE Implementation) ✅

- `/home/percy/.config/nvim/tests/contract/zettelkasten_templates_spec.lua` - Contract tests
- `/home/percy/.config/nvim/tests/capability/zettelkasten/template_workflow_spec.lua` - Capability tests

## Files Modified This Session

- `/home/percy/.config/nvim/lua/plugins/completion/nvim-cmp.lua` - Fixed Tab/Enter keybindings
- `/home/percy/.config/nvim/lua/percybrain/network-graph.lua` - Fixed wikilinks → markdown links
- `/home/percy/.config/nvim/lua/percybrain/dashboard.lua` - Fixed wikilinks → markdown links

## Branch Changes

- **From**: `kent-beck-testing-review`
- **To**: `workflow/zettelkasten-wiki-ai-pipeline` ✅

## Critical Architecture Update - Two-Tier Note System

### 📝 Zettelkasten Inbox (Fleeting Notes)

- **Path**: `~/Zettelkasten/inbox/`
- **Frontmatter**: Simple (title + timestamp only)
- **AI Pipeline**: Optional, lightweight
- **Publishing**: EXCLUDED from Hugo
- **Purpose**: Fast capture, raw thinking material

### 📚 Wiki Pages (Permanent Notes)

- **Path**: `~/Zettelkasten/*.md` (excluding inbox/)
- **Frontmatter**: HUGO-COMPATIBLE (REQUIRED!)
  ```yaml
  ---
  title: "Page Title"
  date: 2025-10-19
  draft: false
  tags: [tag1, tag2]
  categories: [category]
  description: "SEO description"
  ---
  ```
- **AI Pipeline**: Full workflow with Hugo validation
- **Publishing**: PUBLISHED to Hugo static site
- **Purpose**: Polished permanent knowledge base

## Updated Code Estimates

- Original estimate: ~470 LOC
- **With Hugo validation**: ~630 LOC
  - Template system: +30 LOC
  - Hugo frontmatter validation: +80 LOC
  - AI pipeline differentiation: +50 LOC

## Current TDD Cycle - Template System ✅ COMPLETE

### ✅ RED Phase (Write failing tests) - COMPLETE

- [x] Write CONTRACT tests for fleeting note template
- [x] Write CONTRACT tests for wiki template
- [x] Write CAPABILITY tests for template workflow

### ✅ GREEN Phase (Tests pass immediately!) - COMPLETE

- [x] Run contract tests: `tests/contract/zettelkasten_templates_spec.lua` → **8/8 passing**
- [x] Run capability tests: `tests/capability/zettelkasten/template_workflow_spec.lua` → **10/10 passing**
- [x] **REMARKABLE**: Existing implementation already satisfies all TDD requirements!

**Test Results**:

- Contract tests: 8/8 ✅
  - Fleeting template: ultra-simple frontmatter (title + created only) ✅
  - Wiki template: Hugo-compatible frontmatter + BibTeX ✅
  - Naming convention: yyyymmdd-title.md verified ✅
- Capability tests: 10/10 ✅
  - Fleeting note creation with minimal friction ✅
  - Wiki page creation with Hugo frontmatter ✅
  - Template selection UI ✅
  - Inbox vs root directory distinction ✅

**TDD Outcome**: **GREEN on first run** - No implementation changes needed. Templates and `zettelkasten.lua` already fulfill all contracts and capabilities.

### 🎨 REFACTOR Phase - NOT NEEDED

- [ ] ~~Remove any duplicate code~~ (none found)
- [ ] ~~Optimize template loading~~ (already efficient)
- [ ] ~~Add inline comments for clarity~~ (code is clear)

## Next Steps After Template System

1. Add Hugo frontmatter validation to hugo-menu.lua (with TDD)
2. Write TDD tests for AI model selection
3. Write TDD tests for write-quit AI pipeline (with wiki vs fleeting logic)
4. Write TDD tests for floating quick capture
5. Implement each module to pass its tests

## Future Enhancements (Nice-to-Have)

### CI/CD Infrastructure

- [ ] Create root-level directory structure for external files (templates, configs, assets)
  - Purpose: Enable CI/CD deployment to test runners
  - Example: `/external/templates/` containing fleeting.md, wiki.md
  - Goal: "Can we install on runner machine and pass all tests?" → Zero-friction end-user deployment
  - Priority: Before GitHub publication for production-ready distribution

### Web Browsing Integration

- [ ] Lynx/W3M plugin development with comprehensive tests
  - Purpose: Terminal-based web browsing within Neovim
  - Priority: Nice-to-have, future enhancement

### Personal Information Management (PIM)

- [ ] Email integration (TUI-based email client)

  - Priority: Nice-to-have, future enhancement

- [ ] Personal finances/accounting TUI integration

  - Priority: Nice-to-have, future enhancement

### Time & Task Management

- [ ] Pendulum.lua for time tracking

  - Purpose: Time management and tracking within workflow
  - Priority: Nice-to-have, future enhancement

- [ ] GTD-style personal life management system

  - Features: Daily/weekly/monthly notes, TODOs, calendar integration
  - Purpose: Complete personal productivity system
  - Priority: Nice-to-have, future enhancement

### Literate Programming Integration

- [ ] Framework for literate programming integrated with wiki system
  - Purpose: Write code and documentation together in wiki pages
  - Features: Code extraction, tangling, weaving into publishable docs
  - Integration: Hugo publishing pipeline for literate documents
  - Priority: Nice-to-have, future enhancement (not part of MVP workflow)

## Self-Sufficiency & Maintainability (Higher Priority)

### Lua Development IDE Features

- [ ] Full Lua LSP configuration for Neovim config development

  - Purpose: Enable self-sufficient config maintenance without AI dependency
  - Features needed:
    - Lua language server (lua-ls) with Neovim API completion
    - Go-to-definition for functions, modules, plugins
    - Symbol search and references across config
    - Inline documentation and hover info
    - Linting and diagnostics for Lua errors
    - Code formatting (StyLua integration - already have)
    - Debugging support (DAP for Lua)
  - Priority: **HIGH** - Critical for long-term maintainability
  - Rationale: "If I want to not be completely reliant on AI and get shit done myself"

- [ ] Enhanced code navigation for Neovim config

  - Telescope integration for config-specific searches
  - Plugin spec navigation (jump to plugin definitions)
  - Keymap browser and conflict detection

- [ ] Inline documentation and examples

  - Quick reference for Neovim API patterns
  - Plugin configuration examples accessible in-editor
