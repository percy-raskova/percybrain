# Workflow Integration Patterns

**Type**: Technical Reference | **Version**: 2025-10-21 | **Scope**: PercyBrain Integration Architecture

## Overview

Consolidated patterns for integrating IWE LSP, SemBr Git, Ollama AI, and publishing workflows in PercyBrain. Covers tool responsibilities, workflow pipelines, configuration patterns, and integration best practices.

______________________________________________________________________

## IWE LSP Integration

### Tool Responsibilities Pattern

**Problem**: Two tools (Telekasten, IWE) work with markdown notes. Risk of overlap and confusion.

**Solution**: Assign complementary responsibilities based on tool strengths.

**Telekasten** (Visual Navigation & Creation):

- Daily/weekly note creation with calendar
- Template-based note creation with variable substitution
- Visual search and navigation
- Quick capture workflows

**IWE LSP** (Graph Refactoring & Structure):

- Extract section → atomic note
- Inline multiple notes → synthesis
- LSP navigation for wikilinks
- Safe rename with automatic link updates

**Shared** (Format Compatibility):

- Both use WikiLink `[[note]]` format
- Both support backlink discovery
- Both work with `~/Zettelkasten` directory

### Configuration

```lua
-- Telekasten: Enable WikiLink format
link_notation = "wiki"  -- Outputs: [[note]]

-- IWE LSP: Match format
settings = {
  library_path = vim.fn.expand("~/Zettelkasten"),
  link_type = "WikiLink",  -- Parse: [[note]]
}
```

**Result**: Seamless LSP integration, no format conflicts.

### Directory Structure Pattern

**Problem**: Traditional Zettelkasten uses flat or topic-based folders. Both have issues.

**Solution**: Organize by workflow state (temporal/functional position).

```
~/Zettelkasten/
├── daily/          # Transient: Today's capture
├── weekly/         # Transient: This week's review
├── zettel/         # Permanent: Distilled insights
├── sources/        # Input: Literature notes
├── mocs/           # Navigation: Maps of Content
├── drafts/         # Output: Work in progress
├── templates/      # System: Note templates
└── assets/         # Supporting: Images, media
```

**Rationale**:

- State is universal across all knowledge domains
- Topics emerge from `[[wikilinks]]`, not folders
- Predictable structure reduces ADHD decision paralysis
- Clear workflow progression (daily → zettel → draft)

### Template Pattern

**Telekasten Variable Substitution**:

```markdown
---
title: {{title}}
created: {{date}}
tags: []
---

# {{title}}

## Content

[Your notes here]

## References
```

**Variables Supported**:

- `{{title}}` - User-provided title
- `{{date}}` - ISO format (2025-10-21)
- `{{hdate}}` - Long format (Monday, October 21st, 2025)
- `{{week}}`, `{{monday}}`-`{{sunday}}` - Week dates
- `{{time24}}`, `{{time12}}` - Time formats

**Design Principles**:

1. Minimal variables (only common needs)
2. YAML frontmatter (Hugo/Obsidian compatible)
3. Structural markers (`## Content`, `## References`)
4. Empty sections for user completion

### Bidirectional Refactoring Workflow

**Pattern**: Extract/Inline as analysis/synthesis cycle.

**Extract** (Analysis Phase):

- Source: Daily notes, long documents
- Action: `<leader>zrx` on section
- Target: New atomic note in `zettel/`
- Auto-creates: WikiLink reference
- Purpose: Create atomic insights

**Inline** (Synthesis Phase):

- Source: Multiple zettel notes
- Action: `<leader>zri` on wikilink
- Target: Current document (draft)
- Replaces: `[[note]]` with full content
- Purpose: Compose long-form writing

**Complete Cycle**:

```
Daily note → Extract → Zettel (atomic)
              ↓
         Link related zettels
              ↓
Draft ← Inline ← Zettel collection
```

**Use Cases**:

- Research: Reading notes → extract ideas → synthesize paper
- Writing: Freewriting → extract themes → inline into article
- Learning: Course notes → extract concepts → synthesize review

### Keybinding Consolidation

**Pattern**: Single namespace for all note operations.

**Primary namespace** (`<leader>z*`):

- `<leader>zn` - New note (Telekasten)
- `<leader>zd` - Daily note (Telekasten)
- `<leader>zf` - Find notes (Telekasten)
- `<leader>zF` - Find files (IWE)
- `<leader>zS` - Workspace symbols (IWE)

**Refactoring sub-namespace** (`<leader>zr*`):

- `<leader>zrx` - Extract section (IWE)
- `<leader>zri` - Inline note (IWE)
- `<leader>zrf` - Format document (IWE)
- `<leader>zrh` - Heading → list (IWE)
- `<leader>zrl` - List → heading (IWE)

**Benefits**:

- ONE namespace, no prefix switching
- Easy discovery via which-key
- "Speed of thought" access for writers
- Reduces cognitive load for ADHD users

______________________________________________________________________

## SemBr Git Integration

### Extension Pattern: Wrap, Don't Reinvent

**Philosophy**: Extend battle-tested tools rather than building from scratch.

**Plugin Stack**:

1. **vim-fugitive** (10/10 trust) - Core Git operations
2. **gitsigns.nvim** (9.7/10) - Visual Git integration
3. **diffview.nvim** (8.5/10) - Advanced diff viewing (optional)

**Our SemBr Layer** (~300 lines):

- `lua/percybrain/sembr-git.lua` - Core integration (237 lines)
- Wraps commands with SemBr-specific settings
- Configures Git for markdown handling
- Preserves all original functionality

### Core Module Architecture

```lua
M = {
  setup_git_config()      -- Configure Git for SemBr
  setup_gitattributes()   -- Create .gitattributes
  sembr_diff()           -- Enhanced diff with wrapping
  sembr_blame()          -- Blame with line breaks
  stage_sembr_hunk()     -- Stage with preview
  sembr_commit()         -- Commit with SemBr formatting
  setup_commands()       -- Create user commands
  setup_keymaps()        -- Define keybindings
  setup()               -- Main initialization
}
```

### Git Configuration

**Word-level diff for markdown**:

```bash
git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"
git config diff.algorithm patience
git config diff.wordDiff true
```

**`.gitattributes` (auto-created)**:

```gitattributes
*.md diff=markdown
*.md merge=union
*.markdown diff=markdown
*.markdown merge=union
```

### Commands & Keymaps

**Commands**:

- `:GSemBrDiff` - Git diff with word wrap
- `:GSemBrBlame` - Git blame with SemBr formatting
- `:GSemBrStage` - Stage hunk with SemBr preview
- `:GSemBrCommit` - Commit with SemBr formatting
- `:SemBrFormat` - Format buffer/selection with sembr
- `:SemBrToggle` - Toggle auto-format on save

**Keymaps**:

- `<leader>zs` - Format with semantic line breaks
- `<leader>zt` - Toggle SemBr auto-format
- `<leader>gsd` - SemBr Git diff
- `<leader>gsb` - SemBr Git blame
- `<leader>gss` - SemBr stage hunk
- `<leader>gsc` - SemBr Git commit

### Workflow

**Daily Use**:

1. Write naturally in long paragraphs
2. `<leader>zs` to format before committing
3. Git shows meaningful clause-level changes
4. Hugo renders continuous paragraphs

**Auto-Format Toggle**:

- OFF during initial drafting (natural flow)
- ON during editing/revision (prepare for Git)

### Integration Points

**With PercyBrain Zettelkasten**:

- Formats notes before committing for clean diffs
- Preserves markdown syntax (code blocks, tables, lists)
- Works with daily notes and inbox capture

**With Hugo Publishing**:

- Hugo automatically renders paragraphs correctly
- Line breaks within paragraphs are ignored
- No special configuration needed

**With Ollama AI**:

- SemBr-formatted text pipes to LLM for processing
- Better context understanding with clause-based breaks

______________________________________________________________________

## Ollama AI Integration

### Key Discovery: OpenAI-Compatible API

**Problem**: Need unified AI backend for IWE and GTD without custom abstraction.

**Solution**: Ollama provides built-in OpenAI-compatible API at `http://localhost:11434/v1/`.

**Architecture**:

```
IWE LSP → http://localhost:11434/v1/chat/completions
GTD AI  → http://localhost:11434/v1/chat/completions
          (Unified Ollama backend)
```

### Core Components

**1. Ollama Manager** (`lua/percybrain/ollama-manager.lua`, 370 lines):

- Auto-start Ollama server on Neovim launch
- Model management (change, pull, configure)
- Health checks and status monitoring

**Commands**:

- `:OllamaStart` - Start server manually
- `:OllamaHealth` - Show health status
- `:OllamaModel <name>` - Change active model

**2. IWE Config** (`~/Zettelkasten/templates/.iwe/config-ollama.toml`, 140 lines):

```toml
[llm]
base_url = "http://localhost:11434/v1"
api_key = "ollama"  # pragma: allowlist secret
model = "llama3.2"

[actions.expand]
prompt = "Expand this text with more detail..."
```

**Actions**: expand, rewrite, keywords, emoji

**3. GTD-IWE Bridge** (`lua/percybrain/gtd/iwe-bridge.lua`, 110 lines):

- Task detection in extracted notes
- Auto-decompose prompting
- Integration with IWE extraction workflow

**Commands**:

- `:GtdDecomposeNote` - Decompose all tasks in note
- `:GtdToggleAutoDecompose` - Toggle auto-decompose

### API Format

**OpenAI Endpoint**:

```json
{
  "model": "llama3.2",
  "messages": [
    {"role": "user", "content": "prompt"}
  ],
  "stream": false
}
```

**Response**:

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "response text"
      }
    }
  ]
}
```

### Workflow Pipeline

**Integrated Extract → Format → Decompose**:

1. User extracts section with IWE (`<leader>zrx`)
2. SemBr auto-formats (semantic line breaks)
3. Task detection triggers
4. GTD AI decomposes if user confirms
5. Result: Formatted note with decomposed tasks

### Keybindings

**IWE AI Transformations** (`<leader>za*`):

- `<leader>zae` - Expand text
- `<leader>zaw` - Rewrite for clarity
- `<leader>zak` - Bold keywords
- `<leader>zam` - Add emojis

**GTD AI Operations** (`<leader>zr*`):

- `<leader>zrd` - Decompose task
- `<leader>zrc` - Suggest context
- `<leader>zrp` - Infer priority
- `<leader>zra` - Auto-enhance (all-in-one)

### Configuration

**Default Setup** (`lua/config/init.lua`):

```lua
require("percybrain.ollama-manager").setup({
  enabled = true,
  model = "llama3.2",
  auto_pull = false,
  timeout = 30,
})

require("percybrain.gtd.iwe-bridge").setup({
  auto_decompose = false,
})
```

**User Overrides**:

```lua
-- Disable auto-start
vim.g.ollama_config = { enabled = false }

-- Change model
vim.g.ollama_config = { model = "mistral" }

-- Auto-decompose without prompting
vim.g.gtd_iwe_auto_decompose = true
```

### Installation

**Prerequisites**:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull model
ollama pull llama3.2

# Set env var
export OLLAMA_API_KEY="ollama"  # pragma: allowlist secret
```

**Setup**:

```bash
# Copy IWE config
cp ~/Zettelkasten/templates/.iwe/config-ollama.toml \
   ~/Zettelkasten/.iwe/config.toml
```

**Verify**:

```vim
:OllamaHealth
```

______________________________________________________________________

## Publishing Pipeline

### Hugo Integration

**Pattern**: SemBr-formatted markdown → Hugo → Clean HTML.

**Why It Works**:

- Hugo renders markdown paragraphs correctly
- Line breaks within paragraphs are ignored
- No special Hugo configuration needed

**Workflow**:

1. Write in `~/Zettelkasten/drafts/`
2. Format with SemBr (`<leader>zs`)
3. Publish with Telekasten (`<leader>zp`)
4. Hugo generates site with continuous paragraphs

### Publishing Keybindings

**Telekasten Publishing** (`<leader>z*`):

- `<leader>zp` - Publish to Hugo
- `<leader>zw` - Hugo server (preview)

**Integration**: Publishing uses existing Hugo setup, no special configuration.

______________________________________________________________________

## Integration Best Practices

### 1. Test-Driven Configuration

**Pattern**: Write specification before implementation.

**Process**:

1. Define contract specification (expected behavior)
2. Write contract tests (validate spec adherence)
3. Write capability tests (validate user workflows)
4. Implement configuration to pass tests

**Example**:

```lua
-- Contract test
it("uses WikiLink notation", function()
  assert.equals("wiki", get_link_notation())
end)

-- Capability test
it("CAN extract section to new note", function()
  assert.is_true(can_extract_section())
end)
```

**Benefits**:

- Prevents configuration drift
- Documents intended behavior
- Safe refactoring (tests catch breaks)
- Automated validation

### 2. ADHD-Optimized UI

**Pattern**: Minimal, predictable, calm design.

**Remove Distractions**:

- No emoji (visual noise)
- No blank lines between items
- No random color highlights

**Keep Structure**:

- Grouped sections (Start Writing, Workflows, Tools)
- Frequency-based order (most used first)
- Consistent formatting (2-space indent, key + description)

**Example**:

```lua
-- Before: Distracting
dashboard.button("n", "📝 " .. " New note", ...)

-- After: Calm
dashboard.button("n", "  n  New note", ...)
```

**Benefits**:

- Faster scanning
- Easier decision-making
- Reduced anxiety
- Better focus

### 3. Complementary Tool Assignment

**Pattern**: Assign distinct responsibilities based on tool strengths.

**Process**:

1. Identify tool strengths
2. Assign non-overlapping responsibilities
3. Ensure format compatibility
4. Document which tool for which task

**Example (IWE + Telekasten)**:

- Telekasten: Visual navigation, creation, templates
- IWE: Graph refactoring, LSP navigation, link maintenance
- Shared: WikiLink format, backlink discovery

**Benefits**:

- No tool confusion
- No configuration conflicts
- Tools enhance each other
- Clear user guidance

### 4. Workflow State Organization

**Pattern**: Organize by temporal/functional state, not by content topic.

**Rationale**:

- State is universal (all knowledge goes through same cycle)
- Topics emerge from links (not folders)
- Supports ADHD need for predictable structure
- Prevents premature categorization

**Implementation**:

- Transient: `daily/`, `weekly/`
- Permanent: `zettel/`, `sources/`
- Active: `drafts/`, `mocs/`
- System: `templates/`, `assets/`

### 5. Extension Over Invention

**Pattern**: Wrap battle-tested tools, don't reinvent.

**Process**:

1. Evaluate existing tools (trust scores)
2. Identify extension points
3. Build thin integration layer
4. Preserve all original functionality

**Example (SemBr Git)**:

- Base: vim-fugitive (10+ years, millions of users)
- Layer: ~300 lines SemBr integration
- Result: Full functionality + SemBr support

**Benefits**:

- Leverage proven reliability
- Minimal custom code
- Easier maintenance
- Community support

### 6. Unified Backend Architecture

**Pattern**: Single backend for multiple frontends.

**Example (Ollama)**:

- Backend: Ollama OpenAI-compatible API
- Frontends: IWE LSP, GTD AI, SemBr (future)
- Protocol: Standard HTTP + JSON

**Benefits**:

- Consistent behavior
- Simplified configuration
- Single point of maintenance
- Easy to add new frontends

______________________________________________________________________

## Tool Integration Matrix

| Function        | Telekasten  | IWE LSP     | SemBr      | Ollama AI  |
| --------------- | ----------- | ----------- | ---------- | ---------- |
| Daily notes     | ✅ Primary  | -           | -          | -          |
| Quick capture   | ✅ Primary  | -           | -          | -          |
| Templates       | ✅ Primary  | -           | -          | -          |
| Calendar view   | ✅ Primary  | -           | -          | -          |
| Extract section | -           | ✅ Primary  | ✅ Format  | ✅ Enhance |
| Inline notes    | -           | ✅ Primary  | ✅ Format  | -          |
| LSP navigation  | -           | ✅ Primary  | -          | -          |
| WikiLink format | ✅ Supports | ✅ Requires | -          | -          |
| Git diff        | -           | -           | ✅ Primary | -          |
| Git commit      | -           | -           | ✅ Primary | -          |
| Format prose    | -           | -           | ✅ Primary | -          |
| Expand text     | -           | -           | -          | ✅ Primary |
| Rewrite clarity | -           | -           | -          | ✅ Primary |
| Task decompose  | -           | -           | -          | ✅ Primary |
| Context suggest | -           | -           | -          | ✅ Primary |

______________________________________________________________________

## Testing Architecture

### Test Types

**Contract Tests**: Validate specification adherence

- Directory structure exists
- Link format is WikiLink
- Templates have required variables
- Git configuration correct

**Capability Tests**: Validate user workflows

- CAN extract section to new note
- CAN inline note content
- CAN format with SemBr
- CAN decompose tasks with AI

**Regression Tests**: Prevent critical setting changes

- Link notation remains "wiki"
- Ollama model doesn't change unexpectedly
- Directory structure stable

### Test Execution

```bash
# Contract tests
mise tc

# Capability tests
mise tcap

# All tests
mise test

# Specific file
mise run test:_run_plenary_file tests/contract/...
```

______________________________________________________________________

## Dependencies

### Required

**IWE LSP**:

```bash
cargo install iwe
```

**SemBr**:

```bash
uv tool install sembr
```

**Ollama**:

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2
export OLLAMA_API_KEY="ollama"  # pragma: allowlist secret
```

### Neovim Plugins

**Required** (auto-installed via lazy.nvim):

- vim-fugitive (Git operations)
- gitsigns.nvim (Git visualization)
- telekasten.nvim (Zettelkasten navigation)

**Optional**:

- diffview.nvim (Advanced diff viewing)
- lazy-git.nvim (Interactive Git operations)

______________________________________________________________________

## Complete Workflow Cycle

**1. Capture** (Transient):

- Open daily note: `<leader>zd`
- Write freely in long paragraphs
- Save in `daily/`

**2. Process** (Analysis):

- Review daily note
- Extract key insights: `<leader>zrx`
- Creates atomic notes in `zettel/`
- Auto-formats with SemBr

**3. Connect** (Linking):

- Add `[[wikilinks]]` between related notes
- Use LSP navigation: `gd`, `gr`
- Create MOCs for navigation

**4. Enhance** (AI):

- Expand ideas: `<leader>zae`
- Rewrite for clarity: `<leader>zaw`
- Decompose tasks: `<leader>zrd`

**5. Navigate** (Discovery):

- Find notes: `<leader>zf`
- Search symbols: `<leader>zS`
- Browse MOCs

**6. Create** (Synthesis):

- Create draft: `<leader>zn` in `drafts/`
- Inline notes: `<leader>zri` on `[[links]]`
- Format: `<leader>zs`

**7. Publish** (Output):

- Review draft
- Publish to Hugo: `<leader>zp`
- Preview: `<leader>zw`

**8. Version** (Git):

- Review changes: `<leader>gsd`
- Stage hunks: `<leader>gss`
- Commit: `<leader>gsc`

______________________________________________________________________

## Success Metrics

**IWE LSP Integration**:

- ✅ WikiLink format consistency
- ✅ Extract/inline workflows functional
- ✅ LSP navigation working
- ✅ 14/14 tests passing

**SemBr Git Integration**:

- ✅ Git configured for markdown
- ✅ All commands functional
- ✅ ~300 lines integration code
- ✅ 620+ lines tests

**Ollama AI Integration**:

- ✅ OpenAI-compatible endpoint
- ✅ IWE + GTD unified backend
- ✅ 64 tests passing
- ✅ 100% local, zero external calls

**Publishing Pipeline**:

- ✅ SemBr → Hugo seamless
- ✅ No special configuration
- ✅ Clean HTML output

______________________________________________________________________

## Troubleshooting

**IWE LSP not working**:

```vim
:LspInfo  # Check if IWE attached
:checkhealth lsp  # Verify LSP setup
```

**SemBr formatting fails**:

```bash
which sembr  # Verify installation
sembr --version  # Check version
```

**Ollama connection issues**:

```vim
:OllamaHealth  # Check server status
```

```bash
ollama list  # Verify models installed
curl http://localhost:11434/v1/models  # Test API
```

**Git diff not showing word-level**:

```bash
git config --get diff.markdown.wordRegex  # Verify config
cat .gitattributes  # Check attributes file
```

______________________________________________________________________

**Total Implementation**: ~1000 lines integration code, ~1500 lines tests **Total Time**: ~6 hours across multiple sessions **Status**: ✅ Production ready, 100% test coverage
