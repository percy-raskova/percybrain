# PercyBrain Quick Reference

**Essential commands, shortcuts, and patterns for daily use**

**Last Updated**: 2025-10-21 (Phase 1 & 2 Refactor) **Breaking Changes**: See `claudedocs/KEYBINDING_MIGRATION_2025-10-21.md`

______________________________________________________________________

## 🚀 Essential Commands

### Neovim

```bash
nvim                                    # Start PercyBrain
nvim +checkhealth                      # Diagnose issues
nvim +Lazy                             # Plugin manager
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"  # Count plugins
```

### Testing

```bash
./tests/simple-test.sh                 # Run all tests
stylua lua/                            # Format code
selene lua/                            # Lint code
```

### Git Workflow

```bash
git status && git branch               # Check state (always first!)
git checkout -b feature/name           # Create feature branch
git add . && git commit -m "msg"       # Commit changes
git push -u origin feature/name        # Push feature branch
```

______________________________________________________________________

## ⌨️ Essential Keybindings

**Leader key**: `<space>`

### Core Operations

| Key | Action | | ------------ | ------------------- | | `<leader>e` | Toggle file tree | | `<leader>s` | Save file | | `<leader>q` | Quit | | `<leader>gg` | LazyGit (primary) | | `<leader>L` | Lazy plugin manager | | `<leader>W` | Which-Key help |

### Frequency-Optimized Shortcuts (Phase 2 - MOST IMPORTANT!)

**Speed of thought** - Most frequent operations get shortest keys:

| Key | Action | Frequency | | ----------- | ------------------------- | ------------ | | `<leader>f` | **Find notes** | 50+ /session | | `<leader>n` | **New note (quick)** | 50+ /session | | `<leader>i` | **Inbox capture (quick)** | 20+ /session |

### Zettelkasten (PRIMARY USE CASE)

**All note operations under `<leader>z*` namespace (Phase 1 consolidation)**

| Key | Action | | ------------ | ----------------------------- | | `<leader>n` | **New note (quick)** ⚡ | | `<leader>zn` | New note (with options) | | `<leader>zd` | Daily note | | `<leader>zi` | Inbox note (file) | | `<leader>i` | **Inbox capture (quick)** ⚡ | | `<leader>zq` | Inbox capture (floating) | | `<leader>f` | **Find notes** ⚡ | | `<leader>zf` | Find notes (alternate) | | `<leader>zg` | Search content (grep) | | `<leader>zb` | Show backlinks | | `<leader>zo` | Find orphan notes | | `<leader>zh` | Find hub notes | | `<leader>ad` | AI Draft |

### Mode Switching (Phase 2 - NEW!)

Context-aware workspace configurations:

| Key | Mode | Use Case | | ------------ | ------------ | --------------------------------- | | `<leader>mw` | Writing | Deep focus prose creation | | `<leader>mr` | Research | Multi-window note exploration | | `<leader>me` | Editing | Technical editing with diagnostics| | `<leader>mp` | Publishing | Content preparation with preview | | `<leader>mn` | Normal | Reset to baseline configuration |

### Prose Writing (Phase 1 Expansion)

| Key | Action | | ------------- | ----------------------- | | `<leader>pp` | Prose mode toggle | | `<leader>pf` | Focus mode (Goyo) | | `<leader>pr` | Reading mode | | `<leader>pw` | Word count stats | | `<leader>ps` | Toggle spell check | | `<leader>pg` | Start grammar check | | `<leader>pts` | Timer start | | `<leader>pte` | Timer stop | | `<leader>ptt` | Timer status | | `<leader>ptr` | Timer report |

### Hugo Publishing

| Command | Action | | -------------- | -------- | | `:HugoNew` | New post | | `:HugoServer` | Preview | | `:HugoPublish` | Publish |

______________________________________________________________________

## 📁 Directory Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/                 # Core configuration
│   │   ├── init.lua           # Bootstrap
│   │   ├── options.lua        # Vim options
│   │   ├── keymaps.lua        # Keybindings
│   │   └── zettelkasten.lua   # PercyBrain core
│   └── plugins/                # Plugin configurations
│       ├── init.lua           # Explicit imports (CRITICAL)
│       ├── zettelkasten/      # 6 plugins (PRIMARY)
│       ├── ai-sembr/          # 3 plugins
│       ├── prose-writing/     # 14 plugins (4 subdirs)
│       └── ... (14 total dirs)
├── tests/                      # Test suite
├── claudedocs/                 # AI documentation
└── *.md                        # User documentation
```

______________________________________________________________________

## 🔧 Common Tasks

### Adding a Plugin

1. **Choose workflow directory**:

   - Zettelkasten → `lua/plugins/zettelkasten/`
   - Writing tools → `lua/plugins/prose-writing/editing/`
   - Experimental → `lua/plugins/experimental/`

2. **Create file**: `lua/plugins/[workflow]/plugin-name.lua`

3. **Plugin spec**:

```lua
return {
  "author/plugin-repo",
  event = "VeryLazy",
  config = function()
    require("plugin").setup({})
  end,
}
```

4. **For new workflow dirs**: Add to `lua/plugins/init.lua`:

```lua
{ import = "plugins.new-dir" }
```

### Debugging Blank Screen

```bash
# 1. Check plugin count
nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"
# Should show 80+, not 3

# 2. Check lua/plugins/init.lua has explicit imports:
cat lua/plugins/init.lua | grep import
# Should show 14+ import lines

# 3. Verify config loads:
nvim --headless -c "lua require('config')" -c "qall"
```

### Fixing Test Failures

```bash
# Format issues
stylua lua/                    # Auto-fix formatting

# Syntax errors
selene lua/ --display-style=quiet  # Show errors only

# Config errors
nvim --headless -c "lua require('config')" -c "qall"
```

______________________________________________________________________

## 🚨 Critical Patterns

### lazy.nvim Subdirectory Loading

**PROBLEM**: Blank screen, only 3 plugins load

**CAUSE**: `lua/plugins/init.lua` returns table without explicit imports

**SOLUTION**: Add explicit imports for ALL workflow directories:

```lua
return {
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim", opts = {} },

  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 directories
}
```

### Quote Style Consistency

**PROJECT STANDARD**: Double quotes `"` not single quotes `'`

**AUTO-FIX**: `stylua lua/`

**WHY**: Enforced by StyLua, catches in CI

______________________________________________________________________

## 📊 Quick Stats

- **Plugins**: 83 total (68 organized + 15 deps)
- **Workflows**: 14 directories
- **Tests**: 5 categories
- **Config Lines**: ~3,000+ Lua
- **Docs**: 20+ markdown files

______________________________________________________________________

## 🔗 Quick Links

| Document | Purpose | | -------------------------------------------- | ------------------------ | | [PROJECT_INDEX.json](PROJECT_INDEX.json) | Master navigation hub ⭐ | | [CLAUDE.md](CLAUDE.md) | Technical guide (23K) ⭐ | | [PERCYBRAIN_DESIGN.md](PERCYBRAIN_DESIGN.md) | Architecture (38K) | | [PERCYBRAIN_SETUP.md](PERCYBRAIN_SETUP.md) | Setup guide (12K) | | [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guide (13K) |

______________________________________________________________________

## 💡 Pro Tips

1. **Always check git status first**: `git status && git branch`
2. **Use feature branches**: Never work on main/master
3. **Run tests before commit**: `./tests/simple-test.sh`
4. **Format automatically**: Add pre-commit hook for StyLua
5. **Read CLAUDE.md**: It's the definitive technical guide
6. **Check PROJECT_INDEX.json**: Master navigation for all docs

______________________________________________________________________

## 🆘 Emergency Contacts

### Blank Screen

→ [CLAUDE.md:481-503](CLAUDE.md)

### Plugin Not Loading

→ Check `lua/plugins/init.lua` imports

### Test Failures

→ [claudedocs/TESTING_QUICKSTART.md](claudedocs/TESTING_QUICKSTART.md)

### IWE LSP Issues

→ `cargo install iwe` + check `:LspInfo`

### AI Features Broken

→ `ollama list` + `ollama pull llama3.2`

______________________________________________________________________

**Last Updated**: 2025-10-19 **For Full Details**: See [PROJECT_INDEX.json](PROJECT_INDEX.json)
