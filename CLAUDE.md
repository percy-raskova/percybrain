# CLAUDE.md - PercyBrain AI Context Index

**Project**: Neovim Zettelkasten + AI Writing Environment | **Testing**: 44/44 passing, 6/6 standards | **Arch**: 68 plugins/14 workflows

## Documentation Map

**Core Docs** (repo root):

- `README.md` → Quick start
- `PERCYBRAIN_DESIGN.md` → Architecture (1,129 lines)
- `PERCYBRAIN_SETUP.md` → Install/config
- `PERCYBRAIN_SYSTEM_ANALYSIS.md` → Technical analysis

**AI Memories** (Serena MCP): 30 total

- **Permanent**: `project_overview`, `codebase_structure`, `percybrain_lazy_nvim_pattern`, `percybrain_technical_patterns`, `percy_development_patterns`, `style_and_conventions`, `architecture`
- **Session** (archivable): `session_2025-10-17_workflow_refactoring_complete`, `test_refactoring_session_5_files_complete_2025-10-18`
- **Access**: `list_memories`, `read_memory("name")`

**Reports** (`claudedocs/`): Post-op summaries

- `PERCYBRAIN_PHASE1_COMPLETE.md`, `COMPLETE_TEST_REFACTORING_REPORT.md`, `PRECOMMIT_HOOKS_DESIGN.md`

**Tests** (`tests/`): `README.md`, `PLENARY_TESTING_DESIGN.md`, `PERCYBRAIN_LLM_TEST_DESIGN.md`

**AI Journal** (`claudedocs/scratches/`): NOT YET IMPLEMENTED

## Architecture Essentials

**Bootstrap**: `init.lua` → `require('config')` → `lua/config/init.lua` → lazy.nvim → `lua/plugins/init.lua` → 14 workflow imports

**Plugin Structure** (68 total):

```
lua/plugins/{zettelkasten(6)|ai-sembr(3)|prose-writing(14)|academic(4)|
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
nvim                              # Start
:Lazy sync                        # Update plugins
:checkhealth                      # Diagnose
./tests/run-all-unit-tests.sh    # Test (44/44)
```

**Quality Gates** (pre-commit):

- luacheck (0 warnings), stylua (auto-fix), test-standards (6/6), debug-detector

## Critical Patterns

**lazy.nvim Detection**: `nvim --headless -c "lua print(#require('lazy').plugins())" -c "qall"` → should show 80+, not 3

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

**PercyBrain**: IWE LSP (`cargo install iwe`) ✅, SemBr (`uv tool install sembr`) ✅, Ollama (`ollama pull llama3.2`) ✅, Hugo (optional)

**Dev**: ripgrep, Node.js, Pandoc, LaTeX

## Troubleshooting

**Blank screen** → Check `lua/plugins/init.lua` explicit imports **IWE LSP** → `:LspInfo`, verify `cargo install iwe` **AI fail** → `ollama list`, check llama3.2 **Tests** → `./tests/run-all-unit-tests.sh`

**Reload**: `:source ~/.config/nvim/init.lua` | `:Lazy reload [plugin]` **Health**: `:checkhealth` | `:Lazy health` | `:Lazy restore`

## Status

**Active Dev**: Zettelkasten-first knowledge mgmt + AI writing **Testing**: 44/44 passing, 6/6 standards enforced **Platforms**: ✅ Linux/macOS/Android | ❌ Limited: Windows/iPad **Maintenance**: Seeking maintainers (original author → Emacs)

**Philosophy Shift** (Oct 2025): "Writing environment" → "Zettelkasten-first knowledge mgmt" **Changes**: 68 plugins/14 workflows, +8 plugins (IWE LSP, AI Draft, Hugo, ltex-ls), -7 redundant

______________________________________________________________________

**Detailed info**: Repo root docs + Serena memories (`read_memory("name")`) **Session notes**: `claudedocs/` completion reports
