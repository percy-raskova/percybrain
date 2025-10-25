# CLAUDE.md - PercyBrain AI Context Index

**Project**: Neovim Zettelkasten + AI Writing Environment | **Testing**: 44/44 passing, 6/6 standards | **Arch**: 67 plugins/14 workflows (17 imports)

## Documentation Map

Documentation follows [Diataxis framework](https://diataxis.fr/) (tutorial/how-to/reference/explanation):

**🎓 Tutorials** (learning-oriented):

- `docs/tutorials/GETTING_STARTED.md` → Zero to first linked note (30 min)
- `docs/tutorials/ZETTELKASTEN_TUTORIAL.md` → Build first 20 notes in 7 days
- `docs/tutorials/ACADEMIC_WRITING_TUTORIAL.md` → First academic paper with LaTeX/citations (60-90 min)
- `PERCYBRAIN_SETUP.md` → Complete installation guide

**📖 How-To Guides** (task-oriented):

- `docs/how-to/ZETTELKASTEN_DAILY_PRACTICE.md` → Quick reference for ongoing habits
- `docs/how-to/AI_USAGE_GUIDE.md` → Ollama setup + AI commands
- `docs/how-to/MISE_USAGE.md` → Task runner and tool management
- `docs/how-to/MIGRATION_FROM_OBSIDIAN.md` → Switch from Obsidian
- `docs/development/PRECOMMIT_HOOKS.md` → Quality gates

**📋 Reference** (information-oriented):

- `docs/reference/KEYBINDINGS_REFERENCE.md` → Complete keymap catalog
- `docs/reference/LSP_REFERENCE.md` → Language Server Protocol details
- `docs/reference/PLUGIN_REFERENCE.md` → All 67 plugins documented
- `docs/testing/TEST_COVERAGE_REPORT.md` → Current metrics (44/44 passing)
- `docs/testing/TESTING_GUIDE.md` → Validation architecture
- `QUICK_REFERENCE.md` → Keyboard shortcuts

**🛠️ Troubleshooting**:

- `docs/troubleshooting/TROUBLESHOOTING_GUIDE.md` → Common issues and solutions

**💡 Explanation** (understanding-oriented):

- `docs/explanation/WHY_PERCYBRAIN.md` → Problems solved, philosophy
- `docs/explanation/NEURODIVERSITY_DESIGN.md` → ADHD/autism-first design
- `docs/explanation/COGNITIVE_ARCHITECTURE.md` → Distributed cognition system
- `docs/explanation/LOCAL_AI_RATIONALE.md` → Privacy, offline-first
- `docs/explanation/MISE_RATIONALE.md` → Why Mise for task running and tool management
- `docs/explanation/AI_TESTING_PHILOSOPHY.md` → Active testing paradigm

**🔧 Technical** (architecture/design):

- `PROJECT_INDEX.json` → Comprehensive project structure index (606 lines, machine-readable)
- `PERCYBRAIN_DESIGN.md` → System architecture (1,129 lines)
- `CLAUDE.md` → This file (AI assistant context)

**🤖 AI Memories** (Serena MCP): 30+ total

- **Permanent**: `project_overview`, `codebase_structure`, `percy_development_patterns`, `documentation_consolidation_token_optimization_2025-10-19`
- **Access**: `list_memories`, `read_memory("name")`

**📝 Session Reports**: Archived in git history (git log for detailed completion reports)

## Architecture Essentials

**Bootstrap**: `init.lua` → `require('config')` → `lua/config/init.lua` → lazy.nvim → `lua/plugins/init.lua` → 14 workflow imports

**Plugin Structure** (67 total):

```
lua/plugins/{zettelkasten(5)|ai-sembr(3)|prose-writing(14)|academic(4)|
publishing(3)|org-mode(3)|lsp(3)|completion(5)|ui(7)|navigation(8)|
utilities(15)|treesitter(2)|lisp(2)|experimental(4)}
```

**⚠️ CRITICAL**: `lua/plugins/init.lua` MUST have explicit imports:

```lua
return {
  { import = "plugins.zettelkasten" },
  { import = "plugins.ai-sembr" },
  -- ... all 14 workflows
}
```

Without imports → blank screen (lazy.nvim stops auto-scan when table returned)

**Config Files**:

- `lua/config/options.lua`: spell=true, wrap=true (prose-optimized)
- `lua/config/keymaps.lua`: `<space>` = leader
- `lua/config/globals.lua`: Theme/globals
- `lua/config/zettelkasten.lua`: Core Zettelkasten module

## Key Workflows

**Zettelkasten** (PRIMARY):

- Capture: `<leader>zi` (inbox), `<leader>zn` (new), `<leader>zd` (daily)
- Organize: `<leader>zf` (find), `<leader>zg` (grep), `<leader>zb` (backlinks), `<leader>zp` (publish)
- AI: `<leader>aa` (menu), `<leader>ae` (explain), `<leader>as` (summarize), `<leader>ad` (draft)

**Dev Workflow**:

```bash
nvim                    # Start
:Lazy sync              # Update plugins
:checkhealth            # Diagnose

# Testing (Mise Framework - PRIMARY)
mise test               # Full suite: startup → contract → capability → regression → integration
mise test:quick         # Fast feedback: startup + contract + regression (~30s)
mise tc                 # Contract tests only (specs compliance)
mise tcap               # Capability tests only (features work)
mise tr                 # Regression tests only (ADHD protections)
mise ti                 # Integration tests only (component interactions)

# Testing (Legacy Scripts - ALTERNATIVE)
./tests/run-all-unit-tests.sh           # All unit tests
./tests/run-health-tests.sh             # Health checks
./tests/run-keymap-tests.sh             # Keymap validation
./tests/run-integration-tests.sh        # Integration tests
./tests/run-ollama-tests.sh             # AI/Ollama tests

# Code Quality
mise lint               # Luacheck static analysis
mise format             # Auto-format with stylua
mise check              # Full quality check: lint + format + test:quick + hooks
```

**Test Architecture** (Kent Beck):

Philosophy: "Test capabilities, not configuration"

- **Contract** (`mise tc`): Verify specs adherence (Zettelkasten templates, Hugo frontmatter, AI models)
- **Capability** (`mise tcap`): Features work as expected (Zettelkasten, AI, Write-Quit pipeline)
- **Regression** (`mise tr`): ADHD optimizations preserved (critical protections)
- **Integration** (`mise ti`): Component interactions validated
- **Startup** (`mise ts`): Smoke tests for clean boot

**Quality Gates** (pre-commit):

- luacheck (0 warnings), stylua (auto-fix), test-standards (6/6), debug-detector

**Setup** (first time):

```bash
# Install pre-commit hooks
uvx --from pre-commit-uv pre-commit install

# Initialize secrets baseline
uvx --from detect-secrets detect-secrets scan > .secrets.baseline

# Or use mise setup (handles all of above)
mise setup
```

## Critical Patterns

**lazy.nvim Detection**: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"` → should show 80+, not 3

**⚠️ Headless Nvim Warning**: Only call headless nvim with timeout/termination mechanism. Otherwise it hangs indefinitely.

**Environment Variables** (.mise.toml):

- `LUA_PATH`: Enables `require()` from lua/ and tests/ directories (critical for test execution)
- `TEST_PARALLEL=false`: Neovim tests MUST run sequentially (shared state, cannot parallelize)
- `NPM_CONFIG_AUDIT=false`: Suppress npm audit noise during CI/development
- `NPM_CONFIG_FUND=false`: Suppress npm funding messages

**Plugin Spec**:

```lua
return {
  "author/repo",
  lazy = true,
  event = "VeryLazy",  -- or cmd/keys/ft
  config = function() end,
}
```

**Test Standards** (6/6):

1. Helper/mock imports (when used)
2. before_each/after_each
3. AAA comments (Arrange/Act/Assert)
4. No `_G.` pollution
5. Local helper functions
6. No raw assert.contains

## Dependencies

**Required**: Neovim ≥0.8.0, Git ≥2.19.0, Nerd Font

**Mise** (task runner + tool manager): `curl https://mise.jdx.dev/install.sh | sh`

- Testing: `mise test`, `mise test:quick`, `mise tc/tcap/tr/ti`
- Quality: `mise lint`, `mise format`, `mise check`
- Setup: `mise setup` (first-time development environment)

**PercyBrain**: IWE CLI + LSP (`cargo build --release` from source) ✅, SemBr (`uv tool install sembr`) ✅, Ollama (`ollama pull llama3.2`) ✅, Hugo (optional)

**Dev**: ripgrep, Node.js, Pandoc, LaTeX, pre-commit (`uvx --from pre-commit-uv`)

## Troubleshooting

**Blank screen** → Check `lua/plugins/init.lua` explicit imports **IWE LSP** → `:LspInfo`, verify `iwes` in PATH (build from source) **AI fail** → `ollama list`, check llama3.2 **Tests fail** → `mise test:quick` for fast feedback, `mise test:debug` for verbose output **Plugin detection** → `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"` (should show 67+)

**Reload**: `:source ~/.config/nvim/init.lua` | `:Lazy reload [plugin]` **Health**: `:checkhealth` | `:Lazy health` | `:Lazy restore` **Quality**: `mise check` (lint + format + test:quick + hooks)

## Status

**Active Dev**: Zettelkasten-first knowledge mgmt + AI writing **Testing**: 44/44 passing, 6/6 standards enforced **Platforms**: ✅ Linux/macOS/Android | ❌ Limited: Windows/iPad **Maintenance**: Seeking maintainers (original author → Emacs)

**Philosophy Shift** (Oct 2025): "Writing environment" → "Zettelkasten-first knowledge mgmt" **Changes**: 67 plugins/14 workflows, IWE-only (removed Telekasten 2025-10-22), custom calendar/tags/navigation via LSP and Telescope

______________________________________________________________________

**Detailed info**: Repo root docs + Serena memories (`read_memory("name")`) **Session notes**: `claudedocs/` completion reports

- Only call a headless NeoVim command if you work in a timeout or have some way to terminate the function. Otherwise it will never terminate and you'll get stuck.
