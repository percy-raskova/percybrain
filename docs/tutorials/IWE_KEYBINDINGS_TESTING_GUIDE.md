# IWE Keybindings Testing Guide

**Phase 1 Implementation**: 2025-10-23**Status**: Ready for user testing**File Modified**: `lua/plugins/lsp/iwe.lua` (enabled all three keybinding groups)

______________________________________________________________________

## Prerequisites for Testing

1. **Open a markdown file** in your Zettelkasten:

   ```bash
   nvim ~/Zettelkasten/daily/$(date +%Y-%m-%d).md
   # OR any existing note
   nvim ~/Zettelkasten/zettel/some-note.md
   ```

2. **Verify IWE LSP is attached**:

   ```vim
   :LspInfo
   ```

   Should show `iwes` client attached to the buffer.

3. **Check for errors**:

   ```vim
   :messages
   ```

   Should NOT show IWE-related errors.

______________________________________________________________________

## Group 1: Telescope Navigation (`g*` prefix)

These are **markdown-file-only** keybindings that provide project-wide navigation.

### `gf` - Find Files (IWE project-wide)

**What it does**: Opens Telescope file picker scoped to your Zettelkasten directory

**Expected behavior**:

- Press `gf` in normal mode
- Telescope dropdown appears
- Shows all markdown files in `~/Zettelkasten/`
- Can fuzzy search by filename
- Pressing Enter opens the selected file

**What to validate**:

- ✅ Telescope opens (doesn't hang or error)
- ✅ Shows only Zettelkasten files (not all of ~/.config/nvim)
- ✅ Fuzzy search works (type "daily" shows daily notes)
- ✅ Enter opens the file

**Potential issues**:

- ❌ If nothing happens: IWE LSP not attached
- ❌ If shows wrong directory: Check library_path in iwe.lua
- ❌ If crashes: Check :messages for error

______________________________________________________________________

### `gb` - Backlinks (LSP references)

**What it does**: Shows all files that link TO the current file

**Expected behavior**:

- Press `gb` in normal mode
- Telescope opens showing all notes that contain links to current note
- Each result shows the line with the link
- Pressing Enter jumps to that reference

**What to validate**:

- ✅ Telescope opens with list of backlinks
- ✅ If current file has no backlinks → shows empty list (not error)
- ✅ Each entry shows: filename + line number + preview
- ✅ Enter jumps to the linking file at correct line

**How to test properly**:

1. Open a note you know has backlinks (e.g., a frequently referenced MOC)
2. Press `gb`
3. Should see multiple results

**Potential issues**:

- ❌ Empty list when you know backlinks exist: LSP index not built yet
- ❌ Error message: IWE LSP not running

______________________________________________________________________

### `g/` - Live Grep (content search)

**What it does**: Full-text search across all notes in Zettelkasten

**Expected behavior**:

- Press `g/` in normal mode
- Telescope opens in live grep mode
- As you type, shows matching lines from all notes
- Results update in real-time

**What to validate**:

- ✅ Telescope opens with search prompt
- ✅ Typing shows results immediately
- ✅ Results show: filename + line number + matching text
- ✅ Enter jumps to that location in the file

**How to test properly**:

1. Press `g/`
2. Type a word you know appears in multiple notes (e.g., "zettelkasten")
3. Should see multiple matches across different files

**Potential issues**:

- ❌ No results for common words: Check library_path scope
- ❌ Slow performance: Normal for large Zettelkasten (>1000 notes)

______________________________________________________________________

### `go` - Document Outline (headers in current file)

**What it does**: Shows all markdown headers in the current file

**Expected behavior**:

- Press `go` in normal mode
- Telescope opens showing all `#`, `##`, `###` headers
- Hierarchical view of document structure
- Enter jumps to that header

**What to validate**:

- ✅ Telescope shows all headers in current file
- ✅ Headers are hierarchical (# → ## → ###)
- ✅ Enter jumps to correct line
- ✅ Empty list if file has no headers (not error)

**How to test properly**:

1. Open a file with multiple headers
2. Press `go`
3. Should see structured outline

**Potential issues**:

- ❌ Missing headers: Check markdown syntax (needs space after #)

______________________________________________________________________

### `gs` - Workspace Symbols (all paths)

**What it does**: Shows all IWE "paths" (structured entry points) in your Zettelkasten

**Expected behavior**:

- Press `gs` in normal mode
- Telescope opens showing all IWE path symbols
- Paths are like "entry points" into the knowledge graph
- Enter navigates to that path

**What to validate**:

- ✅ Telescope opens with symbol list
- ✅ Shows structured paths (if your Zettelkasten has them)
- ✅ Enter navigates to the path location

**NOTE**: This is an advanced IWE feature. If your Zettelkasten doesn't use IWE's path structure, this may be empty or show minimal results. **This is normal and not a bug.**

**Potential issues**:

- ❌ Empty list: Normal if not using IWE path structure

______________________________________________________________________

### `ga` - Namespace Symbols (root-level entries)

**What it does**: Shows IWE "namespace" symbols (top-level organizational structure)

**Expected behavior**:

- Press `ga` in normal mode
- Telescope opens showing namespace-level symbols
- These are root-level organizational units in IWE
- Enter navigates to that namespace

**What to validate**:

- ✅ Telescope opens
- ✅ Shows namespace symbols (if configured)

**NOTE**: Like `gs`, this is an advanced IWE feature. If your Zettelkasten doesn't explicitly use IWE namespaces, this may be empty. **This is normal and not a bug.**

**Potential issues**:

- ❌ Empty list: Normal if not using IWE namespace structure

______________________________________________________________________

## Group 2: LSP Refactoring (`<leader>h`, `<leader>l`)

These are IWE's intelligent refactoring operations for markdown structure.

### `<leader>h` - Rewrite List Section

**What it does**: IWE LSP code action to restructure list-based sections

**Expected behavior**:

- Position cursor on a markdown list (lines starting with `-` or `*`)
- Press `<leader>h`
- IWE analyzes the list structure
- Offers refactoring options (may vary based on content)

**What to validate**:

- ✅ Pressing `<leader>h` triggers LSP action
- ✅ No error message
- ✅ Some UI feedback (even if "no actions available")

**How to test properly**:

1. Create a markdown list:
   ```markdown
   - Item 1
   - Item 2
   - Item 3
   ```
2. Position cursor on any list line
3. Press `<leader>h`

**Potential issues**:

- ❌ "No code actions available": Normal if list doesn't match IWE patterns
- ❌ No response at all: LSP not attached or keybinding conflict

______________________________________________________________________

### `<leader>l` - Rewrite Section List

**What it does**: IWE LSP code action to transform sections into lists

**Expected behavior**:

- Position cursor in a markdown section (under a header)
- Press `<leader>l`
- IWE analyzes section structure
- Offers refactoring to convert to list format

**What to validate**:

- ✅ Pressing `<leader>l` triggers LSP action
- ✅ No error message
- ✅ UI feedback

**How to test properly**:

1. Create a section with multiple paragraphs:
   ```markdown
   ## My Section

   First point here.

   Second point here.
   ```
2. Position cursor in section
3. Press `<leader>l`

**Potential issues**:

- ❌ "No code actions available": Normal if section doesn't match IWE patterns
- ❌ Conflict with Lynx `<leader>l*`: Should not happen in markdown files (IWE takes precedence)

______________________________________________________________________

## Group 3: Markdown Editing (already enabled)

These were already working, but verify they still work:

### `-` - Format Line as Checklist

**Expected**: Pressing `-` in normal mode converts line to `- [ ] ` checklist format

### `<C-n>` - Next Link

**Expected**: Jump to next `[link](url)` in document

### `<C-p>` - Previous Link

**Expected**: Jump to previous `[link](url)` in document

### `/d` - Insert Date

**Expected**: Insert current date in configured format

### `/w` - Insert Week

**Expected**: Insert current week number

______________________________________________________________________

## Standard LSP Operations (Always Available)

These should work in any markdown file when IWE LSP is attached:

### `gd` - Go to Definition (Follow Link)

**What it does**: Follow markdown link under cursor

**Expected behavior**:

- Position cursor on `[link text](target.md)`
- Press `gd`
- Opens target.md (creates file if doesn't exist)

### `gr` - Show References

**What it does**: Same as `gb` but uses standard LSP references

**Expected**: Telescope opens showing all references to current symbol

### `K` - Hover Documentation

**What it does**: Show LSP hover info (may show link target preview)

**Expected**: Popup with contextual information

### `<leader>ca` - Code Actions

**What it does**: Show all available LSP code actions

**Expected behavior**:

- Press `<leader>ca`
- Menu shows available IWE actions:
  - Extract section to new note
  - Inline section from note
  - Normalize links
  - Etc.

### `<leader>rn` - Rename Symbol

**What it does**: Rename across all references

**Expected**: Prompts for new name, updates all references

______________________________________________________________________

## Testing Checklist

Copy this checklist for your testing session:

### Core Navigation (Must Work)

- [ ] `gf` - Find files opens Telescope with Zettelkasten files
- [ ] `gb` - Backlinks shows references (or empty list if none)
- [ ] `g/` - Live grep finds text across notes
- [ ] `go` - Document outline shows headers

### Advanced Navigation (May Be Empty)

- [ ] `gs` - Workspace symbols (empty OK if not using paths)
- [ ] `ga` - Namespace symbols (empty OK if not using namespaces)

### LSP Refactoring (May Show "No Actions")

- [ ] `<leader>h` - Responds without error
- [ ] `<leader>l` - Responds without error
- [ ] No conflict with Lynx (Lynx uses `<leader>lo`, `<leader>le`, etc.)

### Markdown Editing (Should Still Work)

- [ ] `-` - Format as checklist
- [ ] `<C-n>` - Next link
- [ ] `<C-p>` - Previous link
- [ ] `/d` - Insert date
- [ ] `/w` - Insert week

### Standard LSP (Should Work)

- [ ] `gd` - Follow link
- [ ] `<leader>ca` - Code actions menu
- [ ] `:LspInfo` - Shows iwes attached

### Stability

- [ ] No crashes when pressing any keybinding
- [ ] `:messages` shows no IWE errors
- [ ] Nvim startup time not significantly slower

______________________________________________________________________

## Common Issues and Solutions

### "LSP client not attached"

**Solution**:

```vim
:LspInfo
:LspRestart
```

### "No Telescope results"

**Check**:

1. Are you in a markdown file?
2. Is the file inside `~/Zettelkasten/`?
3. Does `~/Zettelkasten/` have markdown files?

### Keybinding doesn't respond

**Check**:

1. `:verbose map gf` (shows what gf is mapped to)
2. `:messages` (shows any errors)
3. File is markdown (`:set filetype?` should show `markdown`)

### "No code actions available"

**This is normal** - IWE code actions only trigger for specific markdown patterns. Not every cursor position will have actions.

______________________________________________________________________

## Reporting Results

After testing, please report:

### What Works ✅

- List each keybinding that worked as expected

### What Doesn't Work ❌

- List each keybinding with issues
- Include error messages from `:messages`
- Include context (what file, what action)

### Unexpected Behavior ⚠️

- Anything that works but behaves differently than expected
- Performance issues (lag, slowness)
- Conflicts with other keybindings

### LSP Status

```vim
:LspInfo
```

Copy the output showing iwes client status.

______________________________________________________________________

## Success Criteria

**Phase 1 is successful if**:

1. At least 4 of 6 navigation keybindings work (`gf`, `gb`, `g/`, `go` must work)
2. No crashes or errors
3. IWE LSP remains attached (`:LspInfo` shows iwes)
4. No conflicts with existing workflows

**Advanced features** (`gs`, `ga`, `<leader>h`, `<leader>l`) may show limited functionality depending on your Zettelkasten structure - **this is expected and OK**.

______________________________________________________________________

**Ready to test!** Open a markdown file and start with `gf` - that's the most important one to verify first.
