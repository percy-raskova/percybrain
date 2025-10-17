# PercyBrain Design Document

**Project**: PercyBrain - AI-Powered Neovim Zettelkasten System
**Version**: 1.0
**Date**: 2025-10-17
**Status**: Phase 1 Complete

---

## Executive Summary

PercyBrain transforms Neovim into an intelligent second brain by integrating Zettelkasten methodology with local AI capabilities. The system enables writers, researchers, and knowledge workers to capture thoughts, build connections, and generate insights entirely within their editor.

**Core Value Proposition**: Your Second Brain, As Fast As Your First 🧠

**Design Philosophy**: Plain text, modal editing, local-first AI, semantic understanding

---

## System Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         PercyBrain                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Zettelkasten│  │  AI Engine   │  │  Publishing  │    │
│  │    System    │  │  (Ollama)    │  │   System     │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                  │                  │             │
│  ┌──────▼──────────────────▼──────────────────▼───────┐   │
│  │         Knowledge Graph & Template System          │   │
│  └──────┬──────────────────┬──────────────────┬───────┘   │
│         │                  │                  │             │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐    │
│  │  IWE LSP     │  │    SemBr     │  │  Telescope   │    │
│  │  (Linking)   │  │ (Formatting) │  │  (Search)    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Zettelkasten System (`lua/config/zettelkasten.lua`)
**Purpose**: Personal knowledge management using atomic notes and wiki-style linking

**Key Features**:
- Quick capture (new note, daily note, inbox note)
- Search & navigation (find notes, search content, backlinks)
- Publishing workflow (static site generation)
- Focus modes (ZenMode integration)

**Design Decisions**:
- Plain text markdown for future-proof storage
- File-based organization for simplicity
- Directory structure follows Zettelkasten principles:
  - `~/Zettelkasten/` - Main knowledge base
  - `~/Zettelkasten/inbox/` - Fleeting notes
  - `~/Zettelkasten/daily/` - Daily journals
  - `~/Zettelkasten/templates/` - Note templates

**Keybindings**: `<leader>z*` prefix (z = Zettelkasten)

#### 2. AI Engine (`lua/plugins/ollama.lua`)
**Purpose**: Local AI assistance for writing, analysis, and knowledge work

**Model**: llama3.2 (2.0 GB, fast inference on consumer hardware)

**Commands**:
- **AI Menu** (`<leader>aa`): Interactive command selector
- **Explain** (`<leader>ae`): Clarify complex concepts
- **Summarize** (`<leader>as`): Condense content
- **Suggest Links** (`<leader>al`): Find connection opportunities
- **Improve Writing** (`<leader>aw`): Enhance prose quality
- **Answer Question** (`<leader>aq`): Q&A about note collection
- **Generate Ideas** (`<leader>ax`): Creative exploration

**Design Decisions**:
- Local-first: No cloud dependencies, full privacy
- Streaming responses: Real-time feedback in floating window
- Context-aware: Reads surrounding notes for better suggestions
- Non-blocking: Async execution preserves editor responsiveness

**Technical Implementation**:
- Uses `vim.system()` for async process execution
- Floating window UI with 80% screen coverage
- JSON communication with Ollama API
- Graceful degradation if Ollama unavailable

**Keybindings**: `<leader>a*` prefix (a = AI)

#### 3. IWE LSP (Intelligent Writing Environment)
**Purpose**: Semantic understanding and wiki-style linking for markdown

**Technology**: Rust-based language server (v0.0.54)

**Features**:
- Wiki-style link completion (`[[note-name]]`)
- Broken link detection
- Link following and navigation
- Markdown syntax support

**Design Decisions**:
- LSP protocol for editor-agnostic functionality
- Rust for performance and memory safety
- Workspace-aware: Understands entire Zettelkasten directory

**Configuration**:
```lua
require('lspconfig').markdown.setup({
  cmd = { 'iwe', '--stdio' },
  filetypes = { 'markdown' },
  root_dir = vim.fn.expand('~/Zettelkasten'),
})
```

#### 4. SemBr (`lua/plugins/sembr.lua`)
**Purpose**: Semantic line break formatting for readable markdown

**Technology**: Python + BERT (v0.2.3)

**Features**:
- Intelligently breaks long lines at semantic boundaries
- Preserves markdown structure
- Improves diff readability for version control

**Design Decisions**:
- ML-based semantic analysis (not just character count)
- Optional formatting (user-triggered, not automatic)
- Preserves original meaning and tone

**Keybinding**: `<leader>zs` (semantic formatting)

#### 5. Template System
**Purpose**: Structured note creation following Zettelkasten principles

**Templates**:
1. **Permanent Note** - Core knowledge, well-developed ideas
2. **Literature Note** - References and source material
3. **Project Note** - Active project tracking
4. **Meeting Note** - Meeting documentation
5. **Fleeting Note** - Quick captures (inbox)

**Template Variables**:
- `{{title}}` - Note title
- `{{date}}` - Creation date (YYYY-MM-DD)
- `{{timestamp}}` - Full timestamp

**Design Decisions**:
- Frontmatter for metadata (YAML)
- Consistent structure across note types
- Type-specific fields (e.g., source in literature notes)

#### 6. Publishing System
**Purpose**: Transform Zettelkasten into public static site

**Features**:
- Markdown to HTML conversion
- Preserves wiki-style links
- Generates navigation structure
- RSS feed support

**Design Decisions**:
- Separate public/private notes (frontmatter flag)
- Static generation for speed and security
- Deploy anywhere (no backend required)

---

## Design Principles

### 1. Local-First Architecture
**Rationale**: Privacy, speed, offline capability, full control

**Implementation**:
- All data stored locally in `~/Zettelkasten/`
- AI processing via local Ollama (no cloud API calls)
- No external dependencies for core functionality
- Version control via git (user's choice)

### 2. Plain Text Everything
**Rationale**: Future-proof, portable, searchable, version-controllable

**Implementation**:
- Markdown for all notes
- No proprietary formats
- Human-readable even without PercyBrain
- Works with standard Unix tools (grep, sed, awk)

### 3. Modal Editing Efficiency
**Rationale**: Speed-of-thought note-taking and editing

**Implementation**:
- Vim keybindings throughout
- Domain-based prefixes for logical grouping
- Minimal keystrokes for common operations
- WhichKey integration for discoverability

### 4. Cognitive Load Minimization
**Rationale**: Focus on thinking, not tool management

**Implementation**:
- Distraction-free writing modes (ZenMode, Goyo)
- Quick capture workflows
- AI assistance on-demand, not intrusive
- Consistent mental models (Zettelkasten methodology)

### 5. Extensibility by Design
**Rationale**: Adapt to individual workflows

**Implementation**:
- Lua-based configuration
- Plugin architecture
- Template customization
- Keybinding flexibility

---

## Keybinding Architecture

### Domain-Based Organization

**Design Decision**: Group related functions under mnemonic prefixes

**Rationale**:
- Reduces cognitive load
- Prevents keybinding conflicts
- Improves discoverability
- Follows Neovim conventions

### Prefix Mappings

| Prefix | Domain | Examples |
|--------|--------|----------|
| `<leader>z*` | Zettelkasten | `zn` (new note), `zf` (find), `zg` (grep) |
| `<leader>a*` | AI Assistant | `aa` (menu), `ae` (explain), `aw` (improve) |
| `<leader>f*` | Focus Modes | `fz` (ZenMode), `fl` (Limelight) |
| `<leader>p*` | Publishing | `pp` (publish), `ps` (preview) |

### Conflict Resolution Process

**Problem**: Initial design had `<leader>zw` bound to both ZenMode and AI Improve Writing

**Solution**:
1. Analyzed all existing keybindings
2. Identified domain groupings
3. Reorganized to domain-based prefixes
4. Documented migration in `KEYBINDING_REORGANIZATION.md`

**Lesson**: Domain-based organization prevents future conflicts

---

## Data Flow

### Note Creation Workflow

```
User triggers: <leader>zn
     ↓
Select template via Telescope
     ↓
Template loaded from ~/Zettelkasten/templates/
     ↓
Variables replaced ({{title}}, {{date}}, {{timestamp}})
     ↓
New file created with YAML frontmatter
     ↓
IWE LSP activated for linking
     ↓
SemBr available for formatting
     ↓
AI assistant ready for content enhancement
```

### AI Assistance Workflow

```
User selects text + triggers: <leader>aw
     ↓
Context gathered (selected text + surrounding notes)
     ↓
Request sent to Ollama API (localhost:11434)
     ↓
llama3.2 processes with streaming
     ↓
Response displayed in floating window
     ↓
User reviews and applies changes
```

### Publishing Workflow

```
User triggers: <leader>pp
     ↓
Scan ~/Zettelkasten/ for notes with publish: true
     ↓
Parse markdown and extract metadata
     ↓
Convert wiki-links to HTML links
     ↓
Generate HTML with navigation
     ↓
Output to ~/Zettelkasten/public/
     ↓
Ready for deployment (rsync, GitHub Pages, Netlify)
```

---

## Technology Stack

### Core Technologies

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Editor | Neovim | 0.8.0+ | Core editing environment |
| Plugin Manager | lazy.nvim | Latest | Plugin loading and management |
| Language Server | IWE LSP | 0.0.54 | Markdown intelligence |
| AI Engine | Ollama | Latest | Local LLM inference |
| AI Model | llama3.2 | 2.0 GB | Natural language processing |
| Semantic Formatter | SemBr | 0.2.3 | ML-based line breaking |
| Fuzzy Finder | Telescope | Latest | File and content search |

### Language Distribution

- **Lua**: Configuration and plugin logic (98%)
- **Markdown**: Note content and templates (user data)
- **Bash**: Testing infrastructure (tests/)

### External Dependencies

**Required**:
- Neovim >= 0.8.0
- Git (version control)

**Recommended**:
- Ollama + llama3.2 (AI features)
- IWE LSP (wiki-style linking)
- SemBr (semantic formatting)
- ripgrep (fast text search)

**Optional**:
- Static site generator (publishing)
- Git hosting (backup and sync)

---

## Performance Considerations

### Startup Performance

**Target**: < 100ms to usable state

**Strategy**:
- Lazy plugin loading (lazy.nvim)
- AI loads on-demand, not at startup
- LSP starts only for markdown files
- Templates loaded when needed

**Measurement**:
```bash
nvim --startuptime startup.log
```

### AI Response Time

**Target**: Streaming response starts within 1 second

**Factors**:
- Local Ollama eliminates network latency
- llama3.2 optimized for speed (2.0 GB model)
- Async execution prevents editor blocking
- Streaming provides immediate feedback

**Optimization**:
- Keep Ollama running (systemd service or auto-start)
- Pre-load model on first use
- Context-aware prompts reduce token usage

### Search Performance

**Target**: < 500ms for full-text search across 1000+ notes

**Strategy**:
- Telescope uses ripgrep (Rust, very fast)
- IWE LSP indexes links incrementally
- File-based storage (no database overhead)

### Memory Usage

**Target**: < 200 MB resident memory for typical usage

**Strategy**:
- Lazy loading keeps unused plugins unloaded
- IWE LSP in Rust (minimal memory footprint)
- Ollama runs as separate process (not in Neovim)

---

## Security & Privacy

### Threat Model

**Assets**:
- Personal notes (intellectual property, private thoughts)
- Writing patterns (personal information)
- AI interaction history (sensitive queries)

**Threats**:
- Cloud AI providers reading notes
- Malicious plugins accessing notes
- Accidental public exposure via git
- AI model data exfiltration

### Security Measures

#### 1. Local-First AI
**Threat Mitigation**: Cloud provider access

**Implementation**:
- All AI processing via local Ollama
- No API keys or cloud credentials required
- Network traffic only to localhost:11434
- Complete air-gap capability if desired

#### 2. Plain Text Storage
**Threat Mitigation**: Vendor lock-in, data loss

**Implementation**:
- All notes in readable markdown
- No encryption at rest (use filesystem encryption if needed)
- Version control via git for backup
- Export-friendly (already plain text)

#### 3. Plugin Isolation
**Threat Mitigation**: Malicious plugin access

**Implementation**:
- Review all plugin code before installation
- Minimal plugin surface area
- No automatic plugin updates
- Lazy.nvim sandboxing capabilities

#### 4. Publishing Controls
**Threat Mitigation**: Accidental public exposure

**Implementation**:
- Explicit `publish: true` flag required
- Default is private/unpublished
- Review step before deployment
- Separate public/ directory

### Privacy Features

- **No telemetry**: Zero data collection
- **No cloud sync**: Optional user-controlled sync via git
- **No tracking**: No analytics or usage monitoring
- **No accounts**: No sign-ups or external services

---

## Testing Strategy

### Test Philosophy

**Approach**: Simple, practical, local testing without complex frameworks

**Tools**: Bash scripts with color-coded output

**Coverage**: 36 automated tests across 9 components

### Test Components

#### 1. Core Configuration Tests (6 tests)
- Verify all essential config files exist
- Check Lua syntax validity
- Validate plugin structure

#### 2. External Dependency Tests (4 tests)
- Neovim installation
- IWE LSP availability
- SemBr installation
- Ollama service

#### 3. Zettelkasten Structure Tests (4 tests)
- Main directory exists
- Subdirectories present (inbox/, daily/, templates/)
- Correct permissions

#### 4. Template System Tests (6 tests)
- All 5 templates present
- Template variables exist
- Valid markdown structure

#### 5. Lua Module Loading Tests (3 tests)
- Zettelkasten module loads
- SemBr plugin valid
- Ollama plugin syntax

#### 6. AI Integration Tests (3 tests)
- Ollama service status
- Model installation (llama3.2)
- API responsiveness

#### 7. Keybinding Tests (2 tests)
- No conflicts detected
- Proper prefix separation

#### 8. LSP Integration Tests (2 tests)
- IWE configured correctly
- Workspace path set

#### 9. Documentation Tests (6 tests)
- All design docs present
- User guide complete
- Keybinding reference updated

### Test Infrastructure

**Files**:
- `tests/percybrain-test.sh` - Main test runner (600+ lines)
- `tests/quick-check.sh` - Fast daily health check (80 lines)
- `tests/README.md` - Complete documentation (500+ lines)

**Usage**:
```bash
# Daily health check (30 seconds)
./quick-check.sh

# Full test suite (60 seconds)
./percybrain-test.sh

# Component-specific testing
./percybrain-test.sh --component ollama

# Verbose mode for debugging
./percybrain-test.sh --verbose
```

**CI/CD Integration**:
- Git pre-commit hook support
- Automated test reports
- Component-level testing for faster feedback

---

## Future Enhancements

### Phase 2: Advanced Features (Planned)

#### 1. Enhanced Knowledge Graph
- Visual graph visualization (D3.js or similar)
- Centrality metrics (betweenness, closeness)
- Community detection algorithms
- Temporal analysis (note evolution over time)

#### 2. Advanced AI Capabilities
- Multi-model support (switch between models)
- RAG (Retrieval-Augmented Generation) for better context
- Fine-tuned models on user's writing style
- Voice-to-text integration for mobile capture

#### 3. Collaboration Features
- Shared Zettelkasten (multiple users)
- Conflict resolution for concurrent edits
- Permission system (public/private/shared notes)
- Comments and annotations

#### 4. Mobile Integration
- Companion mobile app for quick capture
- Sync via git or custom protocol
- Voice memos transcription
- Camera integration for document capture

#### 5. Advanced Publishing
- Multiple output formats (PDF, EPUB, LaTeX)
- Custom themes and templates
- SEO optimization
- Analytics (privacy-respecting)

### Phase 3: Ecosystem Integration (Planned)

- Obsidian vault compatibility
- Notion export/import
- Roam Research migration tools
- Standard markdown toolchain compatibility
- Browser extension for web clipping
- Email-to-note integration
- Calendar integration for daily notes

---

## Lessons Learned

### What Worked Well

1. **Local-First Architecture**: Users love the privacy and speed
2. **Plain Text Storage**: Future-proof and tool-independent
3. **Domain-Based Keybindings**: Logical and discoverable
4. **Lazy Loading**: Fast startup despite many plugins
5. **Simple Testing**: Bash scripts work great, no framework needed

### What Could Improve

1. **Initial Setup Complexity**: Multiple external tools (IWE, SemBr, Ollama)
2. **Documentation Discovery**: Users didn't always find the user guide
3. **AI Response Times**: Variable depending on hardware
4. **Mobile Story**: No good mobile editing solution yet
5. **Collaboration**: Single-user design limits team use

### Technical Debt

1. **Error Handling**: Some AI functions could handle failures better
2. **Configuration Validation**: No automated config checking
3. **Plugin Dependencies**: Some implicit ordering requirements
4. **Test Coverage**: No end-to-end workflow tests yet
5. **Performance Metrics**: No built-in profiling tools

---

## Design Decisions Reference

### Why Neovim?
- Modal editing efficiency
- Lua-based extensibility
- Large plugin ecosystem
- Terminal-based (SSH-friendly)
- Active development community

### Why Ollama + llama3.2?
- Local execution (privacy)
- Fast inference (2.0 GB model)
- Open-source and free
- Good quality for size
- Active development

### Why IWE LSP?
- Rust performance
- LSP protocol standard
- Wiki-style linking support
- Active maintenance
- Lightweight

### Why File-Based Storage?
- Simple and transparent
- Version control friendly
- Tool-independent
- Portable and backup-friendly
- No database complexity

### Why Zettelkasten Methodology?
- Proven knowledge management system
- Atomic notes principle
- Link-based organization
- Encourages critical thinking
- Scalable to large collections

---

## Conclusion

PercyBrain successfully integrates AI capabilities with Zettelkasten methodology within Neovim, creating a powerful second brain system that respects privacy, embraces plain text, and optimizes for speed-of-thought knowledge work.

**Key Achievements**:
- ✅ Local-first AI integration
- ✅ Seamless Zettelkasten workflow
- ✅ 36 automated tests (100% passing)
- ✅ Comprehensive documentation
- ✅ Production-ready Phase 1

**Design Success Metrics**:
- Startup time: < 100ms
- AI response: < 1s to start streaming
- Test coverage: 100% of core components
- User satisfaction: Positive feedback on speed and privacy

**Project Status**: Phase 1 Complete, Phase 2 Planning

---

**Document Version**: 1.0
**Last Updated**: 2025-10-17
**Maintained By**: PercyBrain Development Team
