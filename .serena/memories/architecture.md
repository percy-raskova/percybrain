# OVIWrite Architecture

## File Structure

```
~/.config/nvim/
├── init.lua                        # Entry point: NeoVide config + requires('config')
├── lua/
│   ├── config/                     # Core configuration
│   │   ├── init.lua               # Bootstrap: lazy.nvim setup + loads globals/keymaps/options
│   │   ├── globals.lua            # Global variables and settings
│   │   ├── keymaps.lua            # Leader key mappings (<space> is <leader>)
│   │   └── options.lua            # Vim options (spell, search, appearance, behavior)
│   ├── plugins/                    # Plugin specifications (auto-loaded by lazy.nvim)
│   │   ├── init.lua               # Minimal plugin loader (neoconf, neodev)
│   │   ├── [plugin-name].lua      # Individual plugin configs (lazy-loaded)
│   │   └── lsp/                   # LSP configurations (mason, lspconfig, none-ls)
│   └── utils/                      # Utility modules (NOT auto-loaded)
│       ├── lsp.lua
│       ├── writer_templates.lua
│       └── keymapper.lua
├── scripts/                        # Validation and development scripts
├── spell/                          # Spell check dictionaries
├── assets/                         # Screenshots and images
└── lazy-lock.json                  # Plugin version lockfile
```

## Loading Sequence

> **Implementation Details**: See `configuration_patterns` memory for bootstrap patterns and LSP setup

1. `init.lua` → Sets NeoVide GUI config
2. `require('config')` → Calls `lua/config/init.lua`
3. `lua/config/init.lua`:
   - Bootstraps lazy.nvim (auto-installs if missing) → See `percybrain_lazy_nvim_pattern` for critical import requirements
   - Loads `config.globals`, `config.keymaps`, `config.options`
   - Calls `require("lazy").setup('plugins', opts)`
4. lazy.nvim auto-loads all `lua/plugins/*.lua` files
5. Plugins lazy-load based on triggers (event, cmd, keys, ft)

**Critical Pattern**: `lua/plugins/init.lua` MUST have explicit imports (see `percybrain_lazy_nvim_pattern`):

```lua
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 workflow imports
}
```

**Validation**: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"` should show 68+, not 3

## Plugin Architecture

> **Implementation Details**: See `configuration_patterns` memory for plugin spec templates and standards

- **One plugin per file**: `lua/plugins/plugin-name.lua`
- **lazy.nvim spec format**: Each file returns `{ "author/repo", ... }` table
- **Lazy loading by default**: Plugins load on trigger (VeryLazy, BufReadPre, cmd, keys, ft)
- **Auto-discovery**: lazy.nvim scans `lua/plugins/` and loads all `.lua` files

**Plugin Spec Template** (from `configuration_patterns`):

```lua
return {
  "author/plugin-name",
  lazy = true,
  event = "VeryLazy",  -- or cmd/keys/ft
  config = function()
    -- Plugin setup
    -- Keymaps managed by registry (see keymap_architecture_patterns)
  end,
}
```

## Core Configuration Files

### lua/config/options.lua

Writer-focused defaults:

- `opt.spell = true` - Spell checking ON by default
- `opt.spelllang = 'en'` - English spell check
- `opt.wrap = true` - Line wrapping for prose
- `opt.number = true` - Line numbers
- `opt.relativenumber = true` - Relative line numbers
- `opt.scrolloff = 10` - Keep 10 lines visible above/below cursor
- `opt.clipboard:append("unnamedplus")` - System clipboard integration

### lua/config/keymaps.lua

> **Implementation Details**: See `keymap_architecture_patterns` memory for registry system and namespace design

Leader key: `<space>` (spacebar) Core shortcuts: File tree, save, quit, splits, terminal, LazyGit, writing modes

**Registry System** (from `keymap_architecture_patterns`):

```lua
-- Central conflict detection
local registry = require("config.keymaps")
registry.register_module("workflows.zettelkasten", keymaps)
```

**14 Primary Namespaces**:

- `<leader>a*` - AI/SemBr (7 keymaps)
- `<leader>d*` - Dashboard (1 keymap)
- `<leader>f*` - Find (7 keymaps)
- `<leader>g*` - Git (19 keymaps)
- `<leader>o*` - Organization/GTD (4 keymaps) → See `gtd_implementation_reference`
- `<leader>z*` - Zettelkasten (13 keymaps)
- ... 14 total namespaces, 121 keymaps

### lua/config/globals.lua

Global variables and theme settings

## Plugin Categories

- **Long-form writing**: vimtex, vim-pencil, fountain, nvim-orgmode
- **Spell/Grammar**: LanguageTool, vim-grammarous, vale
- **Note-taking**: vim-wiki, vim-zettel, obsidianNvim
- **Distraction-free**: zen-mode, goyo, limelight, twilight, centerpad, typewriter
- **Utilities**: telescope, fzf-lua, nvim-tree, lazygit, translate, img-clip
- **Color schemes**: catppuccin, gruvbox, nightfox

## NeoVide Support

GUI-specific settings in `init.lua`:

- Custom font: Hack Nerd Font Mono 18pt
- Transparency and blur effects
- macOS-style keyboard shortcuts (Cmd+S, Cmd+C, Cmd+V)

## GTD Module Integration

> **Complete Implementation**: See `gtd_implementation_reference` memory for full architecture

**Directory Structure** (under `~/Zettelkasten/gtd/`):

```
gtd/
├── inbox.md              # 📥 Quick capture
├── next-actions.md       # ⚡ Context-aware actions
├── projects.md           # 📋 Multi-step outcomes
├── someday-maybe.md      # 💭 Future possibilities
├── waiting-for.md        # ⏳ Delegated items
├── reference.md          # 📚 Reference material
└── contexts/             # @home, @work, @computer, @phone, @errands
```

**Module APIs** (from `gtd_implementation_reference`):

- `gtd.setup()` - Initialize GTD system (idempotent)
- `capture.quick_capture(text)` - One-line capture to inbox
- `clarify.clarify_item(text, decision)` - Process inbox items
- `ai.decompose_task(bufnr, line)` - AI-powered task breakdown

**Keymaps** (`<leader>o*` namespace):

- `<leader>oc` - Quick capture
- `<leader>op` - Process inbox
- `<leader>oi` - Inbox count
- `<leader>od` - Decompose task (AI)

## Testing Architecture

> **Complete Patterns**: See `testing_best_practices` memory for templates and standards

**Framework**: Contract-Capability-Regression (Kent Beck TDD)

**Test Organization**:

```
tests/
├── contract/        # System specifications (MUST/MUST NOT/MAY)
├── capability/      # User workflows (CAN user X?)
├── regression/      # ADHD protections, bug prevention
├── unit/           # Isolated function tests
├── integration/    # Cross-module interactions
└── helpers/        # Test utilities, mocks
    ├── gtd_test_helpers.lua
    └── mock_ollama.lua (53x speedup)
```

**6 Test Standards** (from `testing_best_practices`):

1. Helper/mock imports
2. before_each/after_each state management
3. AAA pattern comments (Arrange-Act-Assert)
4. No global pollution (`_G`)
5. Local helper functions
6. No raw assert.contains

**Single Source of Truth**: `tests/minimal_init.lua` for all test initialization

## Implementation Pattern References

### Bootstrap Sequence → Configuration Patterns

**Pattern**: Idempotent lazy.nvim bootstrap **Memory**: `configuration_patterns` → "Bootstrap Pattern" **Usage**: Safe plugin manager initialization without data loss

**Pattern**: Explicit import for nested directories **Memory**: `percybrain_lazy_nvim_pattern` → "Solution Pattern" **Critical**: Without explicit imports, only 3 plugins load (blank screen)

### Plugin Loading → Configuration Patterns

**Pattern**: Standard plugin spec template **Memory**: `configuration_patterns` → "Plugin Specification Best Practices" **Levels**: Minimal (3-10 lines) → Basic (10-30) → Comprehensive (30-100)

**Pattern**: LSP server setup with binary validation **Memory**: `configuration_patterns` → "LSP Configuration Patterns" **Anti-Pattern**: Configuring non-existent LSP servers (markdown_oxide)

### Keymap System → Keymap Architecture Patterns

**Pattern**: Registry-based conflict detection **Memory**: `keymap_architecture_patterns` → "Registry System Architecture" **Benefits**: 100% conflict detection, zero silent overrides

**Pattern**: Hierarchical namespace organization **Memory**: `keymap_architecture_patterns` → "Namespace Strategy" **Structure**: 14 primary namespaces, 121 keymaps across 5 directories

**Pattern**: Frequency-based key allocation **Memory**: `keymap_architecture_patterns` → "Namespace Design Principles" **Tiers**: 50+ uses/session → 1-2 keystrokes (e.g., `<leader>f`)

### GTD Modules → GTD Implementation Reference

**Pattern**: Dual-tier template system **Memory**: `gtd_implementation_reference` → "Phase 1: Core Infrastructure" **Templates**: fleeting.md (7 lines, minimal) vs wiki.md (complete Hugo frontmatter)

**Pattern**: Idempotent setup with data preservation **Memory**: `gtd_implementation_reference` → "Implementation" **Critical**: Check `filereadable()` before writing to avoid data loss

**Pattern**: AI integration with mock testing **Memory**: `gtd_implementation_reference` → "Phase 3: AI Integration" **Performance**: Mock mode (0.386s) vs real Ollama (~120s), 53x speedup

### Testing Framework → Testing Best Practices

**Pattern**: Contract-Capability-Regression framework **Memory**: `testing_best_practices` → "Framework: Contract-Capability-Regression" **Philosophy**: Kent Beck TDD - tests as specifications

**Pattern**: Mock factory pattern for AI testing **Memory**: `testing_best_practices` → "Mock Ollama Testing" **Location**: `tests/helpers/mock_ollama.lua`

**Pattern**: Async testing with wait_for() **Memory**: `testing_best_practices` → "Async Testing with wait_for()" **Implementation**: `tests/helpers/async_helpers.lua`

## Component → Pattern Cross-Reference Map

### Core System Components

**init.lua (Entry Point)**:

- Bootstrap pattern → `configuration_patterns` § "Bootstrap Pattern"
- NeoVide GUI config → Native implementation (no pattern reference)

**lua/config/init.lua (Bootstrap)**:

- lazy.nvim auto-install → `configuration_patterns` § "Bootstrap Pattern"
- Explicit imports → `percybrain_lazy_nvim_pattern` § "Solution Pattern"
- Configuration loading → `configuration_patterns` § "Core Configuration Files"

**lua/config/options.lua (Vim Options)**:

- Writer-focused defaults → Direct implementation
- ADHD visual noise reduction → `testing_best_practices` § "Regression Tests"

**lua/config/keymaps.lua (Keymaps)**:

- Registry system → `keymap_architecture_patterns` § "Registry System Architecture"
- Namespace design → `keymap_architecture_patterns` § "Namespace Strategy"
- Conflict detection → `keymap_architecture_patterns` § "Registry System Architecture"

**lua/config/globals.lua (Globals)**:

- Theme settings → Direct implementation
- Global variables → Direct implementation

### Plugin System Components

**lua/plugins/init.lua (Plugin Loader)**:

- Explicit imports → `percybrain_lazy_nvim_pattern` § "Solution Pattern"
- Critical: Returns table with import declarations
- Diagnostic: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"`

**lua/plugins/\[category\]/\[plugin\].lua (Plugin Specs)**:

- Standard spec template → `configuration_patterns` § "Standard Plugin Spec Template"
- Configuration levels → `configuration_patterns` § "Configuration Complexity Levels"
- Header documentation → `configuration_patterns` § "Header Documentation Standard"

**lua/plugins/lsp/ (LSP Configuration)**:

- Binary validation → `configuration_patterns` § "Correct LSP Server Setup"
- LSP handler errors → `configuration_patterns` § "LSP Handler Error Prevention"
- LSP config template → `configuration_patterns` § "LSP Configuration Template"

### Keymap Components

**lua/config/keymaps/init.lua (Registry)**:

- Conflict detection → `keymap_architecture_patterns` § "Core Pattern: Central Conflict Detection"
- Module registration → `keymap_architecture_patterns` § "Registry System Architecture"
- Debugging support → `keymap_architecture_patterns` § "Registry System Architecture"

**lua/config/keymaps/workflows/ (Workflow Keymaps)**:

- Zettelkasten module → `keymap_architecture_patterns` § "Telekasten Integration"
- AI module → `keymap_architecture_patterns` § "Namespace Strategy"
- GTD module → `keymap_architecture_patterns` § "GTD Integration" + `gtd_implementation_reference` § "Keymaps"
- Prose module → `keymap_architecture_patterns` § "Mode Switching Pattern"

**lua/config/keymaps/tools/ (Tool Keymaps)**:

- Git module → `keymap_architecture_patterns` § "Hierarchical Sub-namespaces"
- Window module → `keymap_architecture_patterns` § "Hierarchical Sub-namespaces"
- Telescope module → `keymap_architecture_patterns` § "Namespace Strategy"

**lua/config/keymaps/environment/ (Environment Keymaps)**:

- Focus module → `keymap_architecture_patterns` § "Template Patterns"
- Terminal module → `keymap_architecture_patterns` § "Directory Selection Criteria"

**lua/config/keymaps/organization/ (Organization Keymaps)**:

- Time-tracking module → `keymap_architecture_patterns` § "Namespace Strategy"

**lua/config/keymaps/system/ (System Keymaps)**:

- Core module → `keymap_architecture_patterns` § "Directory Selection Criteria"
- Dashboard module → `keymap_architecture_patterns` § "Conflict Resolution Patterns"

### GTD Components

**lua/percybrain/gtd/init.lua (Core GTD)**:

- Idempotent setup → `gtd_implementation_reference` § "Idempotent Setup Pattern"
- Directory structure → `gtd_implementation_reference` § "Directory Structure"
- Path helpers → `gtd_implementation_reference` § "Module APIs"

**lua/percybrain/gtd/capture.lua (Capture)**:

- Quick capture → `gtd_implementation_reference` § "Quick Capture Workflow"
- Multi-line buffer → `gtd_implementation_reference` § "Multi-Line Capture Workflow"
- Minimal friction → `gtd_implementation_reference` § "ADHD-Optimized Design"

**lua/percybrain/gtd/clarify.lua (Clarify)**:

- Routing logic → `gtd_implementation_reference` § "Routing Logic"
- Inbox management → `gtd_implementation_reference` § "Inbox Management"
- Decision structure → `gtd_implementation_reference` § "Decision Structure"

**lua/percybrain/gtd/ai.lua (AI Integration)**:

- Ollama API → `gtd_implementation_reference` § "Ollama API Integration"
- Task decomposition → `gtd_implementation_reference` § "Task Decomposition"
- Context suggestion → `gtd_implementation_reference` § "Context Suggestion"
- Priority inference → `gtd_implementation_reference` § "Priority Inference"

### Testing Components

**tests/minimal_init.lua (Test Bootstrap)**:

- Single source of truth → `testing_best_practices` § "Critical Pattern: Unified Initialization"
- Plenary loading → `testing_best_practices` § "Test Initialization"
- Helper runtime paths → `testing_best_practices` § "Test Initialization"

**tests/contract/ (Contract Tests)**:

- MUST/MUST NOT/MAY → `testing_best_practices` § "Contract Tests"
- Template validation → `testing_best_practices` § "Template 5: Contract Test"
- API guarantees → `testing_best_practices` § "Contract Tests"

**tests/capability/ (Capability Tests)**:

- User workflows → `testing_best_practices` § "Capability Tests"
- Feature combinations → `testing_best_practices` § "Capability Tests"
- End-to-end scenarios → `testing_best_practices` § "Capability Tests"

**tests/regression/ (Regression Tests)**:

- ADHD optimizations → `testing_best_practices` § "Regression Tests"
- Visual noise reduction → `testing_best_practices` § "Regression Tests"
- Performance protections → `testing_best_practices` § "Regression Tests"

**tests/unit/ (Unit Tests)**:

- Isolated functions → `testing_best_practices` § "Test Organization"
- Module behavior → `testing_best_practices` § "Test Organization"
- AAA pattern → `testing_best_practices` § "Test Structure Standards (6/6)"

**tests/integration/ (Integration Tests)**:

- Cross-module interactions → `testing_best_practices` § "Test Organization"
- Component coordination → `testing_best_practices` § "Template 3: Integration Test"

**tests/helpers/ (Test Utilities)**:

- GTD test helpers → `testing_best_practices` § "Test Helpers"
- Mock Ollama → `testing_best_practices` § "Mock Ollama Testing"
- Async helpers → `testing_best_practices` § "Async Testing with wait_for()"

### Validation Components

**scripts/validate-keybindings.lua (Keymap Validation)**:

- Automated testing script → `keymap_architecture_patterns` § "Automated Testing Script"
- Conflict detection → `keymap_architecture_patterns` § "Validation Patterns"
- Registry inspection → `keymap_architecture_patterns` § "Registry System Architecture"

**.mise.toml (Task Runner)**:

- Test organization → `configuration_patterns` § "Test Initialization"
- DRY violations avoided → `configuration_patterns` § "Anti-Patterns (AVOID)"
- Helper extraction → `configuration_patterns` § "DRY Violations"

## Deep-Dive Pattern Pointers

### Critical Implementation Patterns

**When adding new plugins**:

1. Create plugin spec → `configuration_patterns` § "Standard Plugin Spec Template"
2. Add header documentation → `configuration_patterns` § "Header Documentation Standard"
3. Check binary requirements → `configuration_patterns` § "LSP Configuration Patterns"
4. Register keymaps → `keymap_architecture_patterns` § "Module Template"

**When creating new keymaps**:

1. Choose namespace → `keymap_architecture_patterns` § "Namespace Strategy"
2. Check conflicts → `keymap_architecture_patterns` § "Registry System Architecture"
3. Follow frequency rules → `keymap_architecture_patterns` § "Namespace Design Principles"
4. Register with system → `keymap_architecture_patterns` § "Module Template"

**When implementing new GTD features**:

1. Follow GTD methodology → `gtd_implementation_reference` § "GTD Methodology"
2. Use idempotent setup → `gtd_implementation_reference` § "Idempotent Setup Pattern"
3. Preserve ADHD optimizations → `gtd_implementation_reference` § "ADHD-Optimized Design"
4. Write tests first (TDD) → `testing_best_practices` § "TDD Workflow"

**When writing new tests**:

1. Choose test category → `testing_best_practices` § "When to Use Each Category"
2. Follow 6 standards → `testing_best_practices` § "Test Structure Standards (6/6)"
3. Use AAA pattern → `testing_best_practices` § "AAA Pattern"
4. Select appropriate template → `testing_best_practices` § "Test Templates"

### Common Anti-Patterns (Avoid)

**Plugin configuration**: `configuration_patterns` § "Configuration Anti-Patterns (AVOID)"

- ❌ DRY violations (repeated bash commands)
- ❌ Silent failures (no error reporting)
- ❌ Missing binary checks (LSP crashes)
- ❌ Incomplete error reporting (hide failures)
- ❌ Undocumented configuration (no context)

**Keymap design**: `keymap_architecture_patterns` § "Anti-Patterns to Avoid"

- ❌ Arbitrary key selection (no mnemonic)
- ❌ Flat namespace (no hierarchy)
- ❌ Silent conflicts (registry bypass)
- ❌ Ignoring frequency data (complex keys for common ops)
- ❌ No plugin availability checks (crashes)
- ❌ Scattered related operations (split namespaces)

**GTD implementation**: `gtd_implementation_reference` § "Anti-Patterns Avoided"

- ❌ Plugin for LSP binary (should be standalone)
- ❌ Overwriting user data (no idempotent setup)
- ❌ Implementation before tests (no TDD)
- ❌ Complex setup functions (hard to test)

**Testing patterns**: `testing_best_practices` § "Common Patterns"

- ❌ Testing implementation instead of behavior
- ❌ Missing test isolation (shared state)
- ❌ No async waiting (timing issues)
- ❌ Global pollution (`_G` modifications)

## Quality Validation Checklist

### Plugin Addition

- [ ] Plugin spec uses template from `configuration_patterns`
- [ ] Header documentation complete (Purpose, Workflow, Config Level)
- [ ] Binary dependencies checked before LSP setup
- [ ] Keymaps registered with conflict detection
- [ ] Tests written following `testing_best_practices` standards

### Keymap Changes

- [ ] Namespace follows mnemonic principle (see `keymap_architecture_patterns`)
- [ ] Registered with `registry.register_module()`
- [ ] Frequency-optimized (shortest keys for common ops)
- [ ] No conflicts detected (run `scripts/validate-keybindings.lua`)
- [ ] Documentation updated (KEYBINDINGS_REFERENCE.md)

### GTD Features

- [ ] Follows David Allen methodology (see `gtd_implementation_reference`)
- [ ] Idempotent setup (preserves existing data)
- [ ] ADHD-optimized (minimal friction, visual clarity)
- [ ] TDD workflow (contract → capability → implementation)
- [ ] Mock testing for AI features (53x speedup)

### Test Development

- [ ] 6/6 test standards compliance (see `testing_best_practices`)
- [ ] AAA pattern with comments
- [ ] Appropriate category (contract/capability/regression/unit/integration)
- [ ] Uses `tests/minimal_init.lua` (single source of truth)
- [ ] Mock factories for external dependencies

## Maintenance and Evolution

### Configuration Debt Reduction

**Pattern**: `configuration_patterns` § "Configuration Debt Reduction Pattern" **Progression**: Minimal → Basic → Comprehensive **Prioritization**: PRIMARY workflows first (Zettelkasten, Prose Writing)

### Breaking Change Communication

**Pattern**: `keymap_architecture_patterns` § "Migration Patterns" **Deliverables**: Migration guide + reference update + cheat sheet + completion report

### Test Suite Expansion

**Pattern**: `testing_best_practices` § "Next TDD Targets" **Workflow**: Contract → Capability → Implementation → Validation

______________________________________________________________________

**Related Documentation**:

- Configuration patterns → `configuration_patterns` memory
- Lazy.nvim imports → `percybrain_lazy_nvim_pattern` memory
- Keymap system → `keymap_architecture_patterns` memory
- GTD implementation → `gtd_implementation_reference` memory
- Testing framework → `testing_best_practices` memory

**Validation Commands**:

- Plugin count: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"`
- Keymap validation: `lua scripts/validate-keybindings.lua`
- GTD tests: `mise test gtd`
- Full test suite: `mise test`

**Token Optimization**: This memory provides high-level architecture with deep-dive pointers to specialized memories. For implementation details, reference the specific memory sections listed above.
