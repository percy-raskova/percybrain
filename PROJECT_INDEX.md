# PercyBrain Project Index

**Master navigation hub for all PercyBrain documentation**

Last Updated: 2025-10-17

---

## 🚀 Quick Start by Role

### New User - "I want to use PercyBrain"
1. **[README.md](README.md)** - Project overview and quick start (8K)
2. **[PERCYBRAIN_SETUP.md](PERCYBRAIN_SETUP.md)** - Installation and configuration (12K)
3. **[claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md)** - Complete user guide (27K)

### Developer - "I want to understand the codebase"
1. **[CLAUDE.md](CLAUDE.md)** - Technical guide for AI assistants (23K) ⭐ Start here
2. **[PERCYBRAIN_DESIGN.md](PERCYBRAIN_DESIGN.md)** - Architecture and design (38K)
3. **[claudedocs/PERCYBRAIN_DESIGN.md](claudedocs/PERCYBRAIN_DESIGN.md)** - Detailed design analysis (20K)

### Contributor - "I want to contribute"
1. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines (13K)
2. **[tests/README.md](tests/README.md)** - Test suite documentation
3. **[claudedocs/TESTING_PHILOSOPHY.md](claudedocs/TESTING_PHILOSOPHY.md)** - Testing approach (5.7K)

---

## 📚 Core Documentation

### Essential Reading
| Document | Size | Purpose | Audience |
|----------|------|---------|----------|
| **[README.md](README.md)** | 8K | Project overview, installation, quick start | Everyone |
| **[CLAUDE.md](CLAUDE.md)** | 23K | Technical guide for AI assistants, architecture | Developers, AI |
| **[PERCYBRAIN_SETUP.md](PERCYBRAIN_SETUP.md)** | 12K | Setup guide with dependencies | New users |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | 13K | Contribution guidelines and workflow | Contributors |

### Design & Architecture
| Document | Size | Purpose | Audience |
|----------|------|---------|----------|
| **[PERCYBRAIN_DESIGN.md](PERCYBRAIN_DESIGN.md)** | 38K | Complete system architecture and design | Developers |
| **[claudedocs/PERCYBRAIN_DESIGN.md](claudedocs/PERCYBRAIN_DESIGN.md)** | 20K | Detailed design analysis | Developers |
| **[claudedocs/PERCYBRAIN_ANALYSIS.md](claudedocs/PERCYBRAIN_ANALYSIS.md)** | 16K | System analysis and evaluation | Developers |

### User Guides
| Document | Size | Purpose | Audience |
|----------|------|---------|----------|
| **[claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md)** | 27K | Comprehensive user guide | End users |
| **[TROUBLESHOOTING_REPORT.md](TROUBLESHOOTING_REPORT.md)** | 5.6K | Common issues and solutions | Users, developers |

---

## 🔧 Technical Documentation

### Plugin System (68 Plugins, 14 Workflows)

**Workflow Structure** (see [CLAUDE.md:32-46](CLAUDE.md)):
```
lua/plugins/
├── zettelkasten/          # 6 plugins - PRIMARY USE CASE
├── ai-sembr/              # 3 plugins - AI assistance
├── prose-writing/         # 14 plugins (4 subdirs)
├── academic/              # 4 plugins - LaTeX, etc.
├── publishing/            # 3 plugins - Hugo
├── org-mode/              # 3 plugins
├── lsp/                   # 3 plugins - Language servers
├── completion/            # 5 plugins - nvim-cmp
├── ui/                    # 7 plugins - Interface
├── navigation/            # 8 plugins - File/buffer nav
├── utilities/             # 15 plugins - Tools
├── treesitter/            # 2 plugins - Syntax
├── lisp/                  # 2 plugins - Lisp support
└── experimental/          # 4 plugins - Testing ground
```

**Key Plugin References**:
- **IWE LSP** (markdown-oxide): [CLAUDE.md:70-74](CLAUDE.md) - Wiki linking
- **AI Draft Generator**: [CLAUDE.md:92-96](CLAUDE.md) - Note synthesis
- **Hugo Integration**: [CLAUDE.md:179-184](CLAUDE.md) - Publishing
- **ltex-ls**: [CLAUDE.md:87-89](CLAUDE.md) - Grammar checking

### Configuration Files

**Core Config** (see [CLAUDE.md:21-62](CLAUDE.md)):
- `init.lua` - Entry point
- `lua/config/init.lua` - Bootstrap
- `lua/config/options.lua` - Vim options
- `lua/config/keymaps.lua` - Keybindings
- `lua/config/globals.lua` - Global variables
- `lua/config/zettelkasten.lua` - PercyBrain core

**Critical Pattern**: [CLAUDE.md:53-62](CLAUDE.md) - lazy.nvim subdirectory loading

### Keybindings Reference

**Quick Reference** (see [CLAUDE.md:206-367](CLAUDE.md)):
- `<leader>zn` - New Zettelkasten note
- `<leader>ad` - AI Draft Generator
- `<leader>fz` - Zen mode (distraction-free)
- `<leader>zr` - Find backlinks (IWE LSP)
- `:HugoPublish` - Publish to static site

Full keybinding documentation: [CLAUDE.md:206-367](CLAUDE.md)

---

## 🧪 Testing & Quality

### Test Suite Documentation
| Document | Size | Purpose |
|----------|------|---------|
| **[tests/README.md](tests/README.md)** | - | Test suite overview |
| **[claudedocs/TESTING_PHILOSOPHY.md](claudedocs/TESTING_PHILOSOPHY.md)** | 5.7K | Testing approach and rationale |
| **[claudedocs/TESTING_STRATEGY.md](claudedocs/TESTING_STRATEGY.md)** | 28K | Comprehensive testing strategy |
| **[claudedocs/TESTING_SUITE.md](claudedocs/TESTING_SUITE.md)** | 12K | Test suite implementation |
| **[claudedocs/TESTING_QUICKSTART.md](claudedocs/TESTING_QUICKSTART.md)** | 6.8K | Quick start for testing |

**Test Philosophy** (from [claudedocs/TESTING_PHILOSOPHY.md](claudedocs/TESTING_PHILOSOPHY.md)):
> "Purpose: Ensure code works, not corporate compliance"

**Quick Test Commands**:
```bash
./tests/simple-test.sh          # Run full test suite
stylua lua/                      # Format all Lua code
selene lua/                      # Lint all Lua code
```

---

## 📝 Development & Implementation

### Implementation Reports
| Document | Size | Date | Topic |
|----------|------|------|-------|
| **[claudedocs/IMPLEMENTATION_COMPLETE.md](claudedocs/IMPLEMENTATION_COMPLETE.md)** | 15K | Recent | Implementation completion report |
| **[claudedocs/PERCYBRAIN_PHASE1_COMPLETE.md](claudedocs/PERCYBRAIN_PHASE1_COMPLETE.md)** | 11K | Recent | Phase 1 completion |
| **[claudedocs/TEST_SUITE_FIX_SUMMARY.md](claudedocs/TEST_SUITE_FIX_SUMMARY.md)** | 9.6K | Recent | Test suite fixes |
| **[claudedocs/ALPHA_LOGO_FIX.md](claudedocs/ALPHA_LOGO_FIX.md)** | 7.6K | Recent | Alpha screen logo fix |
| **[claudedocs/KEYBINDING_REORGANIZATION.md](claudedocs/KEYBINDING_REORGANIZATION.md)** | 7.8K | Recent | Keybinding updates |

### Planning & Analysis
| Document | Size | Purpose |
|----------|------|---------|
| **[claudedocs/MIGRATION_PLAN.md](claudedocs/MIGRATION_PLAN.md)** | 22K | Migration strategy and planning |
| **[claudedocs/CICD_SETUP.md](claudedocs/CICD_SETUP.md)** | 14K | CI/CD pipeline setup |
| **[claudedocs/AI_SCRATCHPAD.md](claudedocs/AI_SCRATCHPAD.md)** | 16K | Informal analysis and thoughts |

---

## 🗺️ Cross-References

### Architecture & Design
- **Main Architecture**: [PERCYBRAIN_DESIGN.md](PERCYBRAIN_DESIGN.md) (38K)
- **Technical Guide**: [CLAUDE.md](CLAUDE.md) (23K)
- **Analysis**: [claudedocs/PERCYBRAIN_DESIGN.md](claudedocs/PERCYBRAIN_DESIGN.md) (20K)

### User Workflows
- **Setup**: [PERCYBRAIN_SETUP.md](PERCYBRAIN_SETUP.md) → [claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md)
- **Troubleshooting**: [TROUBLESHOOTING_REPORT.md](TROUBLESHOOTING_REPORT.md) → [CLAUDE.md:470-503](CLAUDE.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md) → [tests/README.md](tests/README.md)

### Plugin Development
- **Adding Plugins**: [CLAUDE.md:371-398](CLAUDE.md)
- **Workflow Structure**: [CLAUDE.md:32-46](CLAUDE.md)
- **Lazy.nvim Pattern**: [CLAUDE.md:53-62](CLAUDE.md)

### Testing Workflow
- **Philosophy**: [claudedocs/TESTING_PHILOSOPHY.md](claudedocs/TESTING_PHILOSOPHY.md)
- **Strategy**: [claudedocs/TESTING_STRATEGY.md](claudedocs/TESTING_STRATEGY.md)
- **Implementation**: [claudedocs/TESTING_SUITE.md](claudedocs/TESTING_SUITE.md)
- **Quick Start**: [claudedocs/TESTING_QUICKSTART.md](claudedocs/TESTING_QUICKSTART.md)

---

## 🎯 Key Concepts

### Primary Use Case: Zettelkasten
**Definition**: Knowledge management system with interconnected notes, backlinks, and knowledge graphs.

**Core Features**:
- IWE LSP for wiki-style linking ([CLAUDE.md:70-74](CLAUDE.md))
- Backlinks tracking (`<leader>zr`)
- Note capture workflow (`<leader>zi`, `<leader>zn`, `<leader>zd`)
- AI-assisted draft generation (`<leader>ad`)
- Static site publishing (`:HugoPublish`)

**Documentation**:
- [PERCYBRAIN_DESIGN.md:104-131](PERCYBRAIN_DESIGN.md) - PercyBrain system overview
- [claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md) - Complete workflow guide

### Workflow-Based Organization
**Philosophy**: Organize plugins by user workflow, not technical type.

**14 Workflow Directories**:
1. **zettelkasten/** - Note-taking and knowledge management (PRIMARY)
2. **ai-sembr/** - AI assistance and semantic line breaks
3. **prose-writing/** - Long-form writing tools
4. **academic/** - LaTeX and academic writing
5. **publishing/** - Static site generation
6. **org-mode/** - Org-mode support
7. **lsp/** - Language servers
8. **completion/** - Autocompletion
9. **ui/** - User interface
10. **navigation/** - File/buffer navigation
11. **utilities/** - General tools
12. **treesitter/** - Syntax highlighting
13. **lisp/** - Lisp development
14. **experimental/** - Testing ground

**Rationale**: [CLAUDE.md:527-560](CLAUDE.md) - Project Evolution section

### lazy.nvim Subdirectory Pattern
**Critical Pattern**: When `lua/plugins/init.lua` returns a table, lazy.nvim stops auto-scanning subdirectories.

**Solution**: Explicit imports required:
```lua
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 workflow directories
}
```

**Why Critical**: Without explicit imports, only 3 plugins load instead of 83, causing blank screen on startup.

**Documentation**: [CLAUDE.md:53-62](CLAUDE.md), [CLAUDE.md:481-503](CLAUDE.md)

---

## 📊 Project Statistics

**Plugin Count**: 68 organized + 15 dependencies = **83 total**

**Documentation**: 20+ markdown files, ~300KB total

**Test Coverage**: 5 test categories (syntax, files, config, formatting, linting)

**Workflow Directories**: 14

**Lines of Configuration**: ~3,000+ lines of Lua

**Primary Language**: Lua (Neovim configuration)

**Dependencies**:
- Neovim >= 0.8.0
- IWE LSP (cargo install iwe)
- SemBr (uv tool install sembr)
- Ollama (local LLM)
- Hugo (static site generator)

---

## 🔄 Recent Changes (October 2025)

### Major Refactoring
- **Reorganization**: Flat 67-plugin structure → 14 workflow directories
- **New Plugins**: 8 plugins added (IWE LSP, AI Draft, Hugo, ltex-ls, prose tools)
- **Removed Plugins**: 7 redundant plugins removed (fountain, twilight, etc.)
- **Focus Shift**: "Writing environment" → "Zettelkasten-first knowledge management"

**Details**: [CLAUDE.md:527-560](CLAUDE.md)

### Documentation Updates
- **CLAUDE.md**: Updated to reflect new structure (23K)
- **AI_SCRATCHPAD.md**: Informal project analysis (16K)
- **PROJECT_INDEX.md**: Master navigation hub (this document)

---

## 🆘 Getting Help

### Common Issues
1. **Blank screen on startup**: [CLAUDE.md:481-503](CLAUDE.md)
2. **Plugins not loading**: [TROUBLESHOOTING_REPORT.md](TROUBLESHOOTING_REPORT.md)
3. **IWE LSP issues**: [CLAUDE.md:478](CLAUDE.md)
4. **AI features failing**: [CLAUDE.md:479](CLAUDE.md)

### Support Resources
- **Issue Tracker**: GitHub Issues (see README.md)
- **Troubleshooting Guide**: [TROUBLESHOOTING_REPORT.md](TROUBLESHOOTING_REPORT.md)
- **User Guide**: [claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md)

---

## 📖 Document Conventions

### File Size Indicators
- **< 10K**: Quick reference, focused topic
- **10-20K**: Comprehensive guide, detailed documentation
- **20-40K**: Deep dive, architectural documentation
- **> 40K**: Extensive system documentation

### Priority Markers
- ⭐ **Essential** - Must read for all developers
- 🎯 **Important** - Recommended reading
- 📚 **Reference** - Consult as needed
- 🧪 **Specialized** - Domain-specific documentation

### Document Types
- **README.md** - Overview and quick start
- **GUIDE.md** - Step-by-step instructions
- **DESIGN.md** - Architecture and design decisions
- **REPORT.md** - Implementation or analysis reports
- **PHILOSOPHY.md** - Principles and rationale

---

## 🔗 External Resources

### Official Documentation
- **Neovim**: https://neovim.io/doc/
- **lazy.nvim**: https://github.com/folke/lazy.nvim
- **IWE LSP**: https://github.com/Feel-ix-343/markdown-oxide
- **Hugo**: https://gohugo.io/documentation/
- **Ollama**: https://ollama.com/

### Community
- **PercyBrain**: See README.md for links
- **Neovim Discourse**: https://neovim.discourse.group/
- **r/neovim**: https://reddit.com/r/neovim

---

**Last Updated**: 2025-10-17
**Index Version**: 1.0
**Maintained By**: PercyBrain Contributors
