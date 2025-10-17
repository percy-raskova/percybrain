# 🧠 PercyBrain

**Your second brain, as fast as your first.**

PercyBrain is a personal knowledge management system built on Neovim that transforms your editor into a complete Zettelkasten environment with AI augmentation, semantic formatting, and automated publishing.

---

## What is PercyBrain?

PercyBrain combines the power of:
- 📝 **Zettelkasten Method**: Atomic notes with bidirectional linking
- 🤖 **Local AI**: LLM-powered writing assistance via Ollama
- 📊 **Knowledge Graph**: IWE LSP for intelligent link management
- ✍️ **Semantic Formatting**: ML-based line breaks for better diffs
- 🌐 **Static Publishing**: One-command website generation
- ⌨️ **Terminal Integration**: Everything from within Neovim

## Why PercyBrain?

**Obsidian users** get wiki-style linking, graph views, and plugin ecosystem - but in your terminal with full Vim power.

**Writers** get distraction-free modes, AI-assisted expansion, and automated publishing without leaving the editor.

**Privacy-conscious users** get local-only AI, your data on your machine, and complete control over your knowledge base.

**Developers** get terminal integration, git versioning, and plain text that works with your existing workflow.

---

## Quick Start

### 1. Install Prerequisites

```bash
# IWE LSP (Rust-based markdown intelligence)
cargo install iwe

# SemBr (ML-based semantic line breaks)
pip install sembr

# Ollama (Local LLM)
curl https://ollama.ai/install.sh | sh
ollama pull llama3.2

# Hugo (Static site generator)
brew install hugo  # or your package manager
```

### 2. Create Directory Structure

```bash
mkdir -p ~/Zettelkasten/{inbox,daily,permanent,templates,assets}
```

### 3. Start Using

```bash
nvim
# Press <leader>zn to create your first note
```

---

## Core Features

### ⚡ Quick Capture

| Keymap | Command | Purpose |
|--------|---------|---------|
| `<leader>zn` | `:PercyNew` | Create permanent note |
| `<leader>zd` | `:PercyDaily` | Today's daily note |
| `<leader>zi` | `:PercyInbox` | Quick inbox capture |

### 🔍 Search & Navigate

| Keymap | Purpose |
|--------|---------|
| `<leader>zf` | Fuzzy find notes |
| `<leader>zg` | Search content |
| `<leader>zb` | Find backlinks |
| `<leader>zl` | Follow link (LSP) |
| `<leader>zr` | Show references |

### 🤖 AI Commands

| Keymap | Command | Purpose |
|--------|---------|---------|
| `<leader>zas` | Summarize | AI-generated summary |
| `<leader>zac` | Connections | Suggest related topics |
| `<leader>zae` | Expand | Fleeting → permanent note |
| `<leader>zat` | Tags | Auto-generate tags |
| `<leader>zaq` | Chat | Interactive Q&A |

### ✍️ Formatting

| Keymap | Purpose |
|--------|---------|
| `<leader>zs` | Semantic line breaks |
| `<leader>zw` | Zen mode |

### 🌐 Publishing

| Keymap | Command | Purpose |
|--------|---------|---------|
| `<leader>zp` | `:PercyPublish` | Build & deploy site |
| `<leader>zP` | `:PercyPreview` | Local preview |

---

## Workflows

### 📥 Capture → Expand → Publish

```
1. <leader>zi        # Quick inbox note
2. Write idea        # Capture fleeting thought
3. <leader>zae       # AI expands to permanent
4. <leader>zat       # AI generates tags
5. Add [[links]]     # Link to other notes (IWE autocomplete)
6. <leader>zp        # Publish to website
```

### 🔬 Research Session

```
1. <leader>zn        # New research note
2. Type [[ to link   # IWE autocompletes note names
3. <leader>zl        # Follow link to read context
4. <leader>zb        # See what links here
5. <leader>zas       # AI summarize findings
6. <leader>zs        # Format with semantic breaks
```

### 📅 Daily Routine

```
1. <leader>zd        # Open today's daily note
2. Journal thoughts  # Free-form writing
3. <leader>zi (×N)   # Quick captures during day
4. Review inbox/     # End-of-day processing
5. <leader>zae       # Expand fleeting notes
6. <leader>zp        # Publish to site
```

---

## System Architecture

```
┌─────────────────────────────────────────┐
│         Neovim (PercyBrain UI)          │
├─────────────────────────────────────────┤
│  Core Module  │  IWE LSP  │  Ollama    │
│  ├─ SemBr     │  ├─ Links │  ├─ AI     │
│  ├─ Keymaps   │  ├─ Graph │  ├─ Tags   │
│  └─ Publish   │  └─ Nav   │  └─ Chat   │
├─────────────────────────────────────────┤
│      ~/Zettelkasten (Plain Text)        │
│  ├─ inbox/    (fleeting notes)          │
│  ├─ daily/    (daily journals)          │
│  ├─ permanent/(processed notes)         │
│  └─ assets/   (images, files)           │
├─────────────────────────────────────────┤
│       ~/blog (Static Site Output)       │
└─────────────────────────────────────────┘
```

---

## Documentation

### 📚 Start Here
- **[PROJECT_INDEX.md](PROJECT_INDEX.md)**: Master navigation hub for all documentation ⭐
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**: Essential commands and shortcuts

### 📖 User Guides
- **[PERCYBRAIN_SETUP.md](PERCYBRAIN_SETUP.md)**: Complete installation and configuration
- **[claudedocs/PERCYBRAIN_USER_GUIDE.md](claudedocs/PERCYBRAIN_USER_GUIDE.md)**: Comprehensive user guide

### 🔧 Technical
- **[CLAUDE.md](CLAUDE.md)**: Technical guide for developers and AI assistants
- **[PERCYBRAIN_DESIGN.md](PERCYBRAIN_DESIGN.md)**: System architecture and design decisions
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Contribution guidelines and workflow

---

## Philosophy

### Local-First
Your notes live on your machine in plain markdown. No cloud lock-in, no vendor dependencies, no privacy concerns.

### AI-Augmented
Ollama brings LLM capabilities without compromising privacy. Summarize notes, generate connections, expand ideas - all locally.

### Terminal-Native
Built for developers and power users who live in the terminal. Full Vim motions, git integration, scriptable automation.

### Zettelkasten Method
Atomic notes with bidirectional links create emergent insights. Your second brain grows organically as you write.

---

## Comparison

| Feature | PercyBrain | Obsidian | Org-mode |
|---------|------------|----------|----------|
| Terminal Integration | ✅ Native | ❌ No | ✅ Yes |
| Wiki Links | ✅ IWE LSP | ✅ Core | ⚠️ Limited |
| Local AI | ✅ Ollama | ❌ Cloud | ❌ No |
| Graph View | ✅ IWE | ✅ Core | ❌ No |
| Publishing | ✅ Hugo/Quartz | ⚠️ Plugin | ✅ Export |
| Semantic Breaks | ✅ SemBr | ❌ No | ❌ No |
| Privacy | ✅ Local-only | ⚠️ Mixed | ✅ Local |
| Mobile | ⚠️ Via Termux | ✅ Native | ⚠️ Via app |

---

## Roadmap

### Phase 1: Core (Current)
- [x] Zettelkasten capture workflow
- [x] IWE LSP integration (design complete)
- [x] SemBr formatting (design complete)
- [x] Ollama AI commands (design complete)
- [x] Publishing pipeline (design complete)

### Phase 2: Enhancement
- [ ] Graph visualization in Neovim
- [ ] Spaced repetition (Anki integration)
- [ ] Web clipper for quick capture
- [ ] Advanced templates system

### Phase 3: Advanced
- [ ] Semantic search (embedding-based)
- [ ] Multi-vault support
- [ ] Collaborative editing
- [ ] Export to PDF/EPUB/LaTeX

---

## Contributing

PercyBrain is built on [OVIWrite](https://github.com/MiragianCycle/OVIWrite), a Neovim writing environment.

Contributions welcome:
- 🐛 Bug reports and fixes
- 💡 Feature suggestions
- 📝 Documentation improvements
- 🔌 Plugin integrations

---

## License

Same as OVIWrite base project.

---

## Credits

**Core Team**:
- Percy Raskova - PercyBrain design and integration

**Built With**:
- [OVIWrite](https://github.com/MiragianCycle/OVIWrite) - Base Neovim writing environment
- [IWE LSP](https://github.com/iwe-org/iwe) - Intelligent markdown LSP
- [SemBr](https://github.com/admk/sembr) - Semantic line breaks
- [Ollama](https://ollama.ai) - Local LLM inference

**Inspired By**:
- Zettelkasten Method (Niklas Luhmann)
- [Obsidian](https://obsidian.md) - Note-taking application
- [Neorg](https://github.com/nvim-neorg/neorg) - Org-mode for Neovim

---

**PercyBrain**: Your second brain, as fast as your first. 🧠⚡
