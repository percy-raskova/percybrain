# Visual Mode Zettelkasten Workflow Patterns

**Date**: 2025-10-23 **Context**: PercyBrain Neovim - Visual mode keybindings for knowledge management

## Core Philosophy

**Principle**: Transform visual selections into knowledge management primitives

**Pattern**: `Selection → Transformation → Primitive`

**Workflow Acceleration**:

- Speed of thought capture (3 seconds: Select → Transform → Link)
- No mode switching or command typing
- Immediate visual feedback
- Discoverable via which-key

## Visual Mode Categories

### 📓 Zettelkasten Selection (`<leader>z` in visual mode)

**Purpose**: Convert selected text into linked, atomic notes

**Operations**:

1. **`<leader>zl`** → Selection to Link (create if missing)

   ```
   Select: "distributed cognition system"
   Result: [distributed cognition system](distributed-cognition-system)
   Action: Prompts to create note if doesn't exist
   ```

   **Implementation**: `lua/config/visual-zettelkasten.lua`

   - Multi-line selection support (uses first line as link text)
   - Automatic slug generation (lowercase, hyphens, alphanumeric)
   - Smart note creation workflow (prompt if note doesn't exist)
   - Integration with `config.zettelkasten.new_note()`

2. **`<leader>ze`** → Extract selection to new note (IWE LSP)

   ```
   Select: Entire section about "AI workflow patterns"
   Action: IWE custom.extract code action
   Result: New note at zettel/ai-workflow-patterns.md
   Original: [AI workflow patterns](ai-workflow-patterns)
   ```

   **Use Case**: Breaking down long notes into atomic zettels

3. **`<leader>zq`** → Extract as quote to new note (IWE LSP)

   ```
   Select: Important quote from source material
   Action: IWE custom.extract (quote variant)
   Result: Quote preserved as blockquote in new note
   ```

   **Use Case**: Literature notes, preserving attribution

4. **`<leader>zs`** → Format with semantic line breaks (SemBr)

   ```
   Select: Dense paragraph
   Action: SemBr formatting
   Result: One sentence per line (git-friendly, readable)
   ```

   **Use Case**: Making prose version-control friendly

### 🤖 AI Selection (`<leader>a` in visual mode)

**Purpose**: AI-powered transformations on selected text (local Ollama)

**Operations**:

1. **`<leader>ae`** → Explain selection (Ollama)

   - AI explains meaning of selected text
   - Uses AIExplain command

2. **`<leader>as`** → Summarize selection (Ollama)

   - AI creates concise summary
   - Uses AISummarize command

3. **`<leader>ar`** → Rewrite selection (IWE AI)

   - AI rewrites for clarity and readability
   - Uses IWE `custom.rewrite` code action
   - Configured with Ollama dolphin3 model

4. **`<leader>ax`** → Expand selection (IWE AI)

   - AI generates more detail about concept
   - Uses IWE `custom.expand` code action
   - Good for developing sparse ideas

5. **`<leader>ak`** → Bold keywords (IWE AI)

   - AI identifies and bolds important keywords
   - Uses IWE `custom.keywords` code action
   - Improves scanability of prose

6. **`<leader>aj`** → Add emojis (IWE AI)

   - AI adds relevant emojis to headers/lists
   - Uses IWE `custom.emoji` code action
   - Visual organization and personality

### ⚡ Code Actions (`<leader>c` in visual mode)

**Purpose**: LSP-powered operations on selection

**Operations**:

1. **`<leader>ca`** → Show all available code actions
   - Context-aware menu based on selection type
   - Access to all 16 IWE code actions
   - Auto-filtered to relevant actions for selection

## Which-Key Integration

**Normal Mode Groups** (20 total categories):

```lua
-- Core workflows
"<leader>n" → "📝 New Note"
"<leader>f" → "🔍 Find/File"
"<leader>z" → "📓 Zettelkasten"
"<leader>i" → "📥 Inbox"
"<leader>o" → "🎯 Organize/GTD"

-- AI and writing
"<leader>a" → "🤖 AI"
"<leader>p" → "✏️ Prose"

-- Navigation
"<leader>e" → "🌳 Explorer"
"<leader>x" → "📂 eXplore"
"<leader>y" → "📁 Yazi"

-- Git
"<leader>g" → "📦 Git"

-- Tools
"<leader>t" → "🌐 Terminal/Translate"
"<leader>l" → "🔗 Lynx"
"<leader>m" → "🔌 MCP"
"<leader>d" → "🏠 Dashboard"

-- Window management
"<leader>w" → "🪟 Windows"
"<leader>v" → "⚡ View/Split"
"<leader>c" → "❌ Close"

-- System
"<leader>s" → "💾 Save/Pencil"
"<leader>q" → "🚪 Quit"
"<leader>u" → "🕰️ Undo Tree"
```

**Visual Mode Groups** (3 categories):

```lua
"<leader>z" → "📓 Zettelkasten Selection"  -- Transform to links/notes
"<leader>a" → "🤖 AI Selection"            -- AI transformations
"<leader>c" → "⚡ Code Actions"            -- LSP operations
```

**Discovery Pattern**: Press `<leader>` in visual mode → which-key shows available operations

## File Organization

### New Module Created

```
lua/config/visual-zettelkasten.lua
```

**Purpose**: Visual mode Zettelkasten operations **Functions**:

- `selection_to_link()` - Convert selection to markdown link
- `extract_selection()` - Trigger IWE extract code action
- `extract_as_quote()` - Trigger IWE quote extract

### Updated Files

```
lua/config/keymaps/workflows/zettelkasten.lua
  - Added 4 visual mode operations

lua/config/keymaps/workflows/ai.lua
  - Added 6 visual mode AI operations
  - Integrated IWE AI code actions

lua/plugins/ui/whichkey.lua
  - Added 3 visual mode group labels
  - Organized with comments for clarity
```

## Implementation Patterns

### LSP Code Action Filtering

**Pattern**: Trigger specific code action programmatically

```lua
vim.lsp.buf.code_action({
  filter = function(action)
    return action.kind and action.kind:match("custom.rewrite")
  end,
  apply = true,  -- Auto-apply without menu
})
```

**Why**: Direct keybinding to specific AI transformation (no menu selection)

### Visual Selection Handling

**Pattern**: Get visual selection in Lua

```lua
local start_pos = vim.fn.getpos("'<")
local end_pos = vim.fn.getpos("'>")
local lines = vim.fn.getline(start_pos[2], end_pos[2])

-- Handle single-line vs multi-line
if #lines == 1 then
  selected_text = string.sub(lines[1], start_pos[3], end_pos[3])
else
  selected_text = lines[1]  -- Use first line
end
```

**Why**: Robust handling of both single and multi-line selections

### Slug Generation Pattern

**Pattern**: Convert title to filesystem-safe slug

```lua
local slug = title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
```

**Result**: "Distributed Cognition System" → "distributed-cognition-system"

**Why**: Consistent, URL-safe, filesystem-safe identifiers

### Visual Selection Replacement

**Pattern**: Replace visual selection with new text

```lua
vim.cmd(string.format("normal! gv\"_c%s", replacement_text))
vim.cmd("normal! l")  -- Move cursor after replacement
```

**Why**: `gv` re-selects visual area, `"_c` cuts to black hole register, insert text

## User Experience Patterns

### Workflow Example: Concept Extraction

**Scenario**: Reading long note, identify key concept needing own note

**Steps**:

1. **Visual select**: Highlight concept phrase (e.g., "temporal dynamics")
2. **Transform**: Press `<leader>zl` (visual mode)
3. **Create**: Prompt: "Note title: \[temporal dynamics\]" → Enter
4. **Result**: `[temporal dynamics](temporal-dynamics)` link created
5. **Follow-up**: Prompt: "Note doesn't exist. Create it?" → Yes
6. **Write**: Opens new note, write atomically, return to original

**Time**: ~5 seconds (vs ~30 seconds manual method)

### Workflow Example: AI-Enhanced Draft

**Scenario**: Rough draft paragraph needs clarity improvement

**Steps**:

1. **Visual select**: Highlight rough paragraph
2. **Transform**: Press `<leader>ar` (visual mode)
3. **AI rewrite**: IWE calls Ollama dolphin3 model
4. **Result**: Paragraph rewritten for clarity in-place
5. **Iterate**: If needed, undo and try `<leader>ax` (expand) instead

**Privacy**: All processing local via Ollama (no API calls)

### Workflow Example: Quote Extraction

**Scenario**: Reading source material, found important quote

**Steps**:

1. **Visual select**: Highlight quote text
2. **Transform**: Press `<leader>zq` (visual mode)
3. **IWE extract**: Creates new note with quote as blockquote
4. **Metadata**: Prompt for source information
5. **Result**: Quote preserved with attribution, original has link

**Use Case**: Literature notes, maintaining source integrity

## ADHD-Optimized Design

### Cognitive Load Reduction

**Visual Feedback**: Immediate transformation visible in buffer

**Discoverable**: Which-key shows all options on `<leader>` in visual mode

**No Context Switching**: Select → Key combo → Done (no command line, no menus)

**Muscle Memory**: Consistent `<leader>z*` for Zettelkasten, `<leader>a*` for AI

### Flow State Protection

**Fast Operations**: 3-5 second transformations (no waiting)

**Undo-Friendly**: All operations are standard Vim edits (can undo)

**Non-Destructive**: Link creation preserves original text, just adds markup

**Progressive Enhancement**: Start with basic links, evolve to extracts as needed

## Performance Considerations

### LSP Code Action Efficiency

**Filtering at invocation**: Only request specific action types

**Auto-apply**: Skip menu selection for single-action operations

**Lazy loading**: IWE LSP only loads for markdown files

### Memory Usage

**Module loading**: `visual-zettelkasten` only loaded when called

**Visual selection**: Works with large selections (no text copying to Lua)

**IWE caching**: LSP maintains workspace graph in memory

## Testing Strategy

### Manual Testing Checklist

**Selection to Link**:

- [ ] Single-line selection
- [ ] Multi-line selection (uses first line)
- [ ] Note exists (just creates link)
- [ ] Note doesn't exist (prompts to create)
- [ ] Slug generation (spaces, special chars)

**IWE Code Actions**:

- [ ] Extract section (creates new note)
- [ ] Extract quote (blockquote format)
- [ ] Rewrite (AI clarity improvement)
- [ ] Expand (AI elaboration)
- [ ] Keywords (AI bold marking)
- [ ] Emoji (AI visual enhancement)

**Which-Key Discovery**:

- [ ] Visual mode `<leader>` shows 3 groups
- [ ] Each group has 4-6 operations
- [ ] Descriptions are clear and actionable

### Edge Cases Handled

**Empty selection**: Notify user, no-op

**Multi-line link text**: Use first line as link text

**Special characters in title**: Slug strips to alphanumeric + hyphens

**Existing note**: Skip creation prompt, just create link

**LSP not attached**: Code actions gracefully fail with notification

## Related Patterns

**See Also**:

- `keymap_architecture_patterns.md` - Overall keymap organization
- `iwe_telekasten_integration_patterns.md` - IWE vs Telekasten workflows
- `workflow_integration_patterns.md` - Cross-workflow patterns

## Future Enhancements

**Potential Additions**:

- `<leader>zt` (visual) - Add tags to selection
- `<leader>zc` (visual) - Create calendar note from date in selection
- `<leader>zm` (visual) - Create MOC (Map of Content) from selection
- `<leader>zd` (visual) - Create definition note for term

**AI Enhancements**:

- `<leader>at` (visual) - Translate selection
- `<leader>af` (visual) - Fix grammar/spelling in selection
- `<leader>ap` (visual) - Simplify/make more accessible

**Integration Opportunities**:

- Telescope integration for note selection (instead of slugs)
- Preview window for extract operations
- Automatic backlink creation on note creation
