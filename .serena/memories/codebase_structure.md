# OVIWrite Codebase Structure

## Directory Tree Overview

```
~/.config/nvim/
├── init.lua                        # Entry point: NeoVide GUI config + require('config')
│
├── lua/                            # All Lua code
│   ├── config/                     # Core configuration (loaded on startup)
│   │   ├── init.lua               # Bootstrap: lazy.nvim setup + loader
│   │   ├── globals.lua            # Global variables and theme settings
│   │   ├── keymaps.lua            # Leader key mappings (<space>)
│   │   └── options.lua            # Vim options (spell, wrap, numbers, etc.)
│   │
│   ├── plugins/                    # Plugin specifications (auto-loaded by lazy.nvim)
│   │   ├── init.lua               # Minimal plugin loader (neoconf, neodev)
│   │   ├── lsp/                   # LSP configurations
│   │   │   ├── mason.lua          # Mason LSP installer
│   │   │   ├── lspconfig.lua      # LSP server configurations
│   │   │   └── none-ls.lua        # Null-ls (formatters, linters)
│   │   │
│   │   ├── Long-form Writing:
│   │   │   ├── vimtex.lua         # LaTeX support
│   │   │   ├── vim-pencil.lua     # Line wrapping for prose
│   │   │   ├── fountain.lua       # Screenwriting
│   │   │   ├── nvimorgmode.lua    # Org-mode support
│   │   │   └── vimorg.lua         # Additional Org-mode features
│   │   │
│   │   ├── Spell/Grammar:
│   │   │   ├── LanguageTool.lua   # Advanced grammar checking
│   │   │   ├── vim-grammarous.lua # Grammar checker integration
│   │   │   └── vale.lua           # Prose linting
│   │   │
│   │   ├── Note-taking:
│   │   │   ├── vim-wiki.lua       # Personal wiki system
│   │   │   ├── vim-zettel.lua     # Zettelkasten implementation
│   │   │   ├── obsidianNvim.lua   # Obsidian vault support
│   │   │   ├── org-bullets.lua    # Org-mode visual enhancements
│   │   │   └── headlines.lua      # Markdown heading enhancements
│   │   │
│   │   ├── Distraction-Free:
│   │   │   ├── zen-mode.lua       # Centered writing interface
│   │   │   ├── goyo.lua           # Minimalist writing mode
│   │   │   ├── limelight.lua      # Dim paragraphs (focus mode)
│   │   │   ├── twilight.lua       # Additional focus mode
│   │   │   ├── centerpad.lua      # Center text in buffer
│   │   │   ├── typewriter.lua     # Typewriter scrolling
│   │   │   └── stay-centered.lua  # Keep cursor centered
│   │   │
│   │   ├── Utilities:
│   │   │   ├── telescope.lua      # Fuzzy finder
│   │   │   ├── fzf-lua.lua        # Fast file/text search
│   │   │   ├── fzf-vim.lua        # FZF vim integration
│   │   │   ├── nvim-tree.lua      # File explorer
│   │   │   ├── lazygit.lua        # Git integration
│   │   │   ├── translate.lua      # Built-in translator
│   │   │   ├── img-clip.lua       # Paste images
│   │   │   ├── markdown-preview.lua     # Markdown preview
│   │   │   ├── vim-latex-preview.lua    # LaTeX preview
│   │   │   ├── pomo.lua           # Pomodoro timer
│   │   │   ├── alpha.lua          # Splash screen
│   │   │   └── whichkey.lua       # Keyboard shortcut help
│   │   │
│   │   ├── Color Schemes:
│   │   │   ├── catppuccin.lua     # Catppuccin theme
│   │   │   ├── gruvbox.lua        # Gruvbox theme
│   │   │   └── nightfox.lua       # Nightfox variants
│   │   │
│   │   └── Infrastructure:
│   │       ├── nvim-treesitter.lua     # Treesitter integration
│   │       ├── nvim-cmp.lua            # Autocompletion
│   │       ├── autopairs.lua           # Auto-close brackets
│   │       ├── comment.lua             # Commenting
│   │       ├── noice.lua               # System notifications
│   │       ├── nvim-web-devicons.lua   # Icons
│   │       ├── toggleterm.lua          # Terminal integration
│   │       └── floaterm.lua            # Floating terminal
│   │
│   └── utils/                      # Utility modules (NOT auto-loaded by lazy.nvim)
│       ├── lsp.lua                # LSP utility functions
│       ├── writer_templates.lua   # Writer file templates
│       └── keymapper.lua          # Keymap helper functions
│
├── scripts/                        # Validation and development scripts
│   ├── validate.sh                # Master validation script (entry point)
│   ├── validate-layer1.sh         # Static validation (syntax, duplicates, deprecated)
│   ├── validate-layer2.lua        # Structural validation (plugin specs, keymaps)
│   ├── validate-startup.sh        # Startup test (Layer 3a)
│   ├── validate-health.sh         # Health check (Layer 3b)
│   ├── validate-plugin-loading.lua     # Plugin loading test (Layer 3c)
│   ├── validate-documentation.lua      # Documentation sync (Layer 4)
│   ├── validate-markdown.sh       # Markdown formatting
│   ├── setup-dev-env.sh           # Development environment setup
│   ├── extract-keymaps.lua        # Generate keymap documentation
│   ├── pre-commit                 # Git pre-commit hook (Layer 1-2)
│   ├── pre-push                   # Git pre-push hook (Layer 1-3)
│   └── deprecated-patterns.txt    # Deprecated API patterns to avoid
│
├── spell/                          # Spell check dictionaries
├── assets/                         # Screenshots and images for README
├── claudedocs/                     # Claude Code documentation and reports
├── .github/                        # GitHub workflows and CI
├── lazy-lock.json                  # Plugin version lockfile
├── package.json                    # Node.js dependencies (neovim package)
├── CLAUDE.md                       # Claude Code project documentation
├── CONTRIBUTING.md                 # Contribution guidelines
├── README.md                       # Project README
├── .gitignore                      # Git ignore patterns
└── .mcp.json                       # MCP server configuration

```

## Key Files and Their Purposes

### Entry Point

- **init.lua**: NeoVide GUI configuration, requires `config` module

### Core Configuration (lua/config/)

- **init.lua**: Bootstraps lazy.nvim, loads globals/keymaps/options, sets up plugin system → See `configuration_patterns` for bootstrap architecture
- **globals.lua**: Global variables, theme settings
- **keymaps.lua**: All keyboard shortcuts (leader = space) → See `keymap_architecture_patterns` for organization strategy
- **options.lua**: Vim options (spell=true, wrap=true, etc.)

### Plugin System (lua/plugins/)

- **init.lua**: Loads neoconf and neodev plugins → See `configuration_patterns` for lazy.nvim integration
- **\[plugin-name\].lua**: Individual plugin configs (one per file)
- **lsp/**: LSP-specific configurations (mason, lspconfig, none-ls)

### Utilities (lua/utils/)

- **lsp.lua**: LSP helper functions
- **writer_templates.lua**: Writer file templates
- **keymapper.lua**: Keymap helper utilities

### Validation System (scripts/)

**4-Layer Pyramid**: → See `testing_best_practices` for validation architecture details

1. **Layer 1** (~5s): Static validation (syntax, duplicates, deprecated APIs)
2. **Layer 2** (~10s): Structural validation (plugin specs, keymaps)
3. **Layer 3** (~60s): Dynamic validation (startup, health, plugin loading)
4. **Layer 4** (~30s): Documentation sync (warnings only)

### Documentation

- **CLAUDE.md**: Primary documentation for Claude Code → See `documentation_strategy` for organization principles
- **CONTRIBUTING.md**: Contribution guidelines and validation system docs
- **README.md**: User-facing project README

## Plugin Count

- **60+ plugins** total (as of last count)
- Categories: Long-form, Spell/Grammar, Note-taking, Distraction-free, Utilities, Color schemes, Infrastructure

## Important Patterns

### Plugin Loading

- lazy.nvim scans `lua/plugins/*.lua` automatically
- Each file must return `{ "author/repo", ... }` spec → See `configuration_patterns` for plugin spec structure
- Lazy loading by default (event triggers)

### Configuration Loading

- `init.lua` → `config/init.lua` → loads config modules → lazy.nvim setup → See `configuration_patterns` for bootstrap sequence

### File Organization Rules

- ✅ One plugin per file in `lua/plugins/`
- ✅ Only 2 allowed `init.lua`: `lua/plugins/init.lua` and `lua/config/init.lua`
- ❌ No module structures in `lua/plugins/` (must return plugin spec)
- ❌ No duplicate plugin files (e.g., nvim-tree.lua + nvimtree.lua)

## Pattern References by Directory

**lua/config/**

- Bootstrap architecture → `configuration_patterns` (lazy.nvim setup)
- Keymap organization → `keymap_architecture_patterns` (workflow-based structure)
- Global variable patterns → `configuration_patterns` (theme setup)

**lua/config/keymaps/**

- Workflow-based keymap organization → `keymap_architecture_patterns`
- Leader key patterns (<space>) → `keymap_architecture_patterns`
- Namespace conventions (zettelkasten, prose, git, etc.) → `keymap_architecture_patterns`

**lua/percybrain/gtd/**

- Task management implementation → `gtd_implementation_reference`
- AI decomposition patterns → `gtd_implementation_reference`
- Inbox processing → `gtd_implementation_reference`

**lua/plugins/**

- Plugin spec structure → `configuration_patterns`
- Lazy loading strategies (event/cmd/keys/ft) → `configuration_patterns`
- One-plugin-per-file rule → `configuration_patterns`
- LSP integration patterns → `configuration_patterns`

**tests/**

- Test architecture (contract/capability/regression/integration) → `testing_best_practices`
- Startup tests → `testing_best_practices`
- Helper/mock patterns → `testing_best_practices`
- AAA comment conventions → `testing_best_practices`
- Test standards enforcement (6/6) → `testing_best_practices`

**scripts/**

- 4-layer validation pyramid → `testing_best_practices`
- Pre-commit hook integration → `testing_best_practices`
- Static validation patterns → `testing_best_practices`

**docs/**

- Diataxis framework application → `documentation_strategy`
- Tutorial/how-to/reference/explanation separation → `documentation_strategy`
- Documentation quality patterns → `documentation_strategy`
- YAML frontmatter best practices → `documentation_strategy`

**Root Configuration Files**

- .mise.toml → Task runner configuration, LUA_PATH setup
- .mcp.json → MCP server configuration for Claude Code
- lazy-lock.json → Plugin version lockfile (DO NOT manually edit)
- .pre-commit-config.yaml → Quality gate definitions

**Cross-Reference Summary**

- Keymap changes → Check `keymap_architecture_patterns` for conventions
- Plugin additions → Check `configuration_patterns` for spec structure
- Test additions → Check `testing_best_practices` for standards
- GTD features → Check `gtd_implementation_reference` for implementation patterns
- Documentation → Check `documentation_strategy` for structure/quality
