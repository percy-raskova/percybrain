# IWE + Telekasten Integration Patterns

**Date**: 2025-10-21 **Type**: Technical Patterns and Architecture

## Integration Pattern: Complementary Tool Responsibilities

### Problem

Two tools (Telekasten and IWE) both work with markdown notes in a Zettelkasten system. Risk of:

- Overlapping functionality causing confusion
- Conflicting configurations breaking workflows
- User uncertainty about which tool to use when

### Solution

Assign distinct, complementary responsibilities based on tool strengths:

**Telekasten** (Visual Navigation & Creation):

- Daily/weekly note creation with calendar
- Template-based note creation
- Visual search and navigation
- Quick capture workflows

**IWE LSP** (Graph Refactoring & Structure):

- Extract (section → atomic note)
- Inline (multiple notes → synthesis)
- LSP navigation for wikilinks
- Safe rename with link updates

**Shared** (Format Compatibility):

- Both use WikiLink \[\[note\]\] format
- Both support backlink discovery
- Both work with ~/Zettelkasten directory

### Implementation

```lua
-- Telekasten: link_notation = "wiki"
-- IWE: link_type = "WikiLink"
-- Result: Seamless LSP integration
```

### Benefits

- No tool confusion (each has clear role)
- No configuration conflicts
- Users know which tool for which task
- Tools enhance each other instead of competing

## Directory Pattern: Workflow State Organization

### Problem

Traditional Zettelkasten uses either:

- Flat directory (all notes in one place)
- Topic-based folders (notes/programming/, notes/writing/)

Both have issues:

- Flat: Hard to manage thousands of notes
- Topic-based: Premature categorization, rigid structure

### Solution

Organize by **workflow state** (temporal/functional position):

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

### Rationale

**Workflow state is universal:**

- All knowledge goes through same lifecycle
- State changes are clear (daily → zettel → draft)
- No premature categorization needed

**Topics emerge from links:**

- Graph structure created by \[\[wikilinks\]\]
- MOCs provide navigation without rigid hierarchy
- Emergence over enforcement

**ADHD-optimized:**

- Predictable structure (always know where to put things)
- Clear workflow progression
- Reduces decision paralysis

### Usage

- **Capture** in daily/ (low friction)
- **Process** with IWE extract daily/ → zettel/
- **Connect** via \[\[wikilinks\]\] between zettels
- **Navigate** using mocs/ as entry points
- **Create** with IWE inline zettel/ → drafts/

## Testing Pattern: TDD for Configuration Projects

### Problem

Configuration projects (Neovim setups, dotfiles) often have:

- No tests (manual validation only)
- Configuration drift (settings change over time)
- Breaking changes discovered after implementation

### Solution

Apply Kent Beck's TDD to configuration:

**1. Write Specification First**

```lua
-- specs/iwe_telekasten_contract.lua
return {
  directories = { ... },
  link_format = { notation = "wiki" },
  templates = { ... },
  capabilities = { ... },
}
```

**2. Write Tests Before Implementation**

```lua
-- Contract test: Validates specification
it("uses WikiLink notation", function()
  assert.equals("wiki", get_link_notation())
end)

-- Capability test: Validates user workflow
it("CAN extract section to new note", function()
  assert.is_true(can_extract_section())
end)
```

**3. Implement to Make Tests Pass**

```lua
-- Implementation
link_notation = "wiki"  -- Makes test pass
```

**4. Validate**

```bash
mise run test:_run_plenary_file tests/contract/...
# All tests passing: Configuration correct
```

### Benefits

- Configuration changes are validated automatically
- Prevents drift (tests detect when settings change)
- Documents intended behavior (tests as specification)
- Safe refactoring (tests catch breaks)

### Test Types

- **Contract**: System meets specification
- **Capability**: Users CAN DO required workflows
- **Regression**: Critical settings never change

## Template Pattern: Variable Substitution System

### Problem

Creating consistent notes with dynamic content (dates, titles, etc.)

### Solution

Telekasten template system with variable substitution:

**Template File** (`templates/note.md`):

```markdown
---
title: {{title}}
created: {{date}}
tags: []
---

# {{title}}

[Content here]
```

**Variables Supported**:

- `{{title}}` - User-provided title
- `{{date}}` - ISO format (2025-10-21)
- `{{hdate}}` - Long format (Monday, October 21st, 2025)
- `{{week}}` - Week number
- `{{monday}}`-`{{sunday}}` - Week dates
- `{{time24}}`, `{{time12}}` - Time formats

**Usage**:

```vim
:Telekasten new_note
# Prompts for title
# Substitutes {{title}} and {{date}}
# Creates note in configured directory
```

### Design Principles

1. **Minimal variables**: Only what's commonly needed
2. **YAML frontmatter**: Compatible with Hugo, Obsidian
3. **Structural markers**: `## Content`, `## References`, etc.
4. **Empty sections**: User fills in during writing

## Keybinding Pattern: Namespace Consolidation

### Problem

Keybindings scattered across multiple prefixes:

- Navigation in `g*` (go prefix)
- Creation in `<leader>z*` (zettelkasten)
- Refactoring in `<leader>i*` (iwe)

Result: Cognitive overhead, hard to remember

### Solution

Consolidate ALL note operations in `<leader>z*` namespace:

**Primary namespace** (`<leader>z*`):

- `<leader>zn` - New note
- `<leader>zd` - Daily note
- `<leader>zf` - Find notes
- `<leader>zF` - Find files (IWE)

**Refactoring sub-namespace** (`<leader>zr*`):

- `<leader>zrx` - Extract section
- `<leader>zri` - Inline note
- `<leader>zrf` - Format document

**Benefits**:

- ONE namespace for all note operations
- Easy to discover (`<leader>z` + which-key)
- Reduces keystrokes (no prefix switching)
- "Speed of thought" access for writers

## Link Format Pattern: WikiLink Consistency

### Problem

Two link formats in markdown:

- Markdown: `[text](path/to/file.md)`
- WikiLink: `[[note]]`

IWE LSP requires WikiLink for navigation.

### Solution

Enforce WikiLink format across all tools:

**Telekasten**:

```lua
link_notation = "wiki"  -- [[note]] format
```

**IWE LSP**:

```lua
link_type = "WikiLink"  -- Same format
```

**Benefits**:

- Simpler syntax (fewer characters)
- LSP navigation works automatically
- Backlinks work in both tools
- Compatible with Obsidian, Logseq

### Migration Strategy

If existing notes use markdown links:

1. Keep old notes as-is (read-only)
2. New notes use WikiLink
3. Gradually convert during editing

## Workflow Pattern: Bidirectional Refactoring

### Problem

Knowledge work involves both:

- **Analysis** (breaking down complex ideas)
- **Synthesis** (combining ideas into coherent output)

### Solution

Use IWE's extract/inline as bidirectional workflow:

**Extract** (Analysis phase):

- Source: Daily notes, long documents
- Action: `<leader>zrx` on section
- Target: New note in zettel/
- Auto-creates: WikiLink reference
- Purpose: Create atomic insights

**Inline** (Synthesis phase):

- Source: Multiple zettel notes
- Action: `<leader>zri` on wikilink
- Target: Current document (draft)
- Replaces: \[\[note\]\] with note content
- Purpose: Compose long-form writing

**Complete Cycle**:

```
Daily note → Extract → Zettel (atomic)
              ↓
         Link related zettels
              ↓
Draft ← Inline ← Zettel collection
```

### Use Cases

- **Research**: Daily reading notes → extract key ideas → synthesize paper
- **Writing**: Daily freewriting → extract themes → inline into article
- **Learning**: Course notes → extract concepts → synthesize review guide

## ADHD Optimization Pattern: Minimal Visual Noise

### Problem

Default UI dashboards have:

- Excessive emoji (visual distraction)
- Large spacing (requires scrolling)
- Mixed colors (draws attention randomly)

For ADHD users: Each visual element competes for attention

### Solution

Minimal, predictable, calm design:

**Remove distractions**:

- ❌ No emoji
- ❌ No blank lines between items
- ❌ No colorful highlights

**Keep structure**:

- ✅ Grouped sections (Start Writing, Workflows, Tools)
- ✅ Frequency-based order (most used first)
- ✅ Consistent formatting (2-space indent, key + description)

**Example**:

```lua
-- Before: Distracting
dashboard.button("n", "📝 " .. " New note", ...)

-- After: Calm
dashboard.button("n", "  n  New note", ...)
```

### Benefits

- Faster scanning (less visual noise)
- Easier decision-making (clear hierarchy)
- Reduced anxiety (predictable layout)
- Better focus (minimal distractions)

______________________________________________________________________

**These patterns are reusable** across other projects and configurations. **Validation**: All patterns tested and working in production.
