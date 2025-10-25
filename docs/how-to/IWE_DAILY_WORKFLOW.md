# IWE Daily Workflow

**Category**: How-to Guide **Audience**: Users familiar with IWE basics **Goal**: Efficient daily note-taking and knowledge management patterns

______________________________________________________________________

## Quick Reference

| Task           | Keybinding   | Description                           |
| -------------- | ------------ | ------------------------------------- |
| Find note      | `gf`         | Telescope file picker                 |
| Search content | `g/`         | Live grep across all notes            |
| Follow link    | `gd`         | Go to definition (creates if missing) |
| Show backlinks | `gb`         | Who links to this note?               |
| View outline   | `go`         | Table of contents                     |
| Code actions   | `<leader>ca` | Extract, inline, refactor             |
| Format note    | `<leader>f`  | Auto-format current note              |
| Rename note    | `<leader>rn` | Rename + update all references        |

______________________________________________________________________

## Morning Routine: Daily Note Creation

### 1. Open Today's Note

```vim
:e ~/Notes/daily/$(date +%Y-%m-%d).md
```

Or create an alias in your shell:

```bash
alias dn='nvim ~/Notes/daily/$(date +%Y-%m-%d).md'
```

### 2. Use This Template

```markdown
---
title: 2025-10-23
tags:
  - daily
  - journal
---

# 2025-10-23

## 🎯 Goals
- [ ]
- [ ]

## 📝 Notes


## 🔗 Connections
-

## ✅ Done
-
```

### 3. Link to Active Projects

As you work, link to your project notes:

```markdown
## 📝 Notes
- Working on [[Rust Learning]] - completed chapter 5
- Updated [[Blog Post Ideas]] with new concept
```

Press `gd` on links to jump to those notes.

______________________________________________________________________

## Capture Ideas Quickly

### Inbox Pattern

Keep an `inbox.md` for quick captures:

```vim
:e ~/Notes/inbox.md
```

Add thoughts:

```markdown
# Inbox

- Idea: Create a tutorial on [[Neovim LSP]]
- Research: How does [[Zettelkasten]] compare to [[PARA Method]]?
- Todo: Refactor [[Project Structure]] documentation
```

**Process weekly:**

1. Open `inbox.md`
2. Press `gd` on each link to create proper notes
3. Move content from inbox to permanent notes
4. Clear inbox

______________________________________________________________________

## Search and Discovery

### Find Notes by Name

Press `gf`, type partial name:

```
gf → "neur" → finds "neurodiversity-design.md"
```

### Find Notes by Content

Press `g/`, type search term:

```
g/ → "typescript" → shows all notes mentioning typescript
```

### Find Related Notes

1. Open a note
2. Press `gb` (backlinks)
3. See all notes that link TO this one

Example: In `rust-learning.md`:

```vim
gb
```

Shows:

```
daily/2025-10-23.md:4: - Working on [[Rust Learning]]
programming.md:12: See also [[Rust Learning]]
```

______________________________________________________________________

## Refactoring Your Knowledge

### Extract Section to New Note

**Problem**: Section is getting too long

**Solution**:

1. Place cursor on section header
2. Press `<leader>ca`
3. Select "Extract section to new file"
4. IWE creates new file and replaces with link

**Before** (`programming.md`):

```markdown
## Design Patterns

### Singleton
The singleton pattern...

### Observer
The observer pattern...
```

**After**:

- `programming.md` → `[[Design Patterns]]`
- `design-patterns.md` → Created with full content

### Inline Reference Back

**Problem**: Note is too small, should be merged back

**Solution**:

1. Open note with link (e.g., `[[Design Patterns]]`)
2. Place cursor on link
3. Press `<leader>ca`
4. Select "Inline reference"
5. Content merges back into current note

### Rename Note (Updates All References!)

**Problem**: Need to rename `rust-learning.md` to `rust-book-notes.md`

**Solution**:

1. Open `rust-learning.md`
2. Press `<leader>rn`
3. Type new name: `rust-book-notes`
4. Press Enter

**IWE automatically updates ALL links across ALL notes!**

______________________________________________________________________

## Organization Patterns

### Topic-Based Structure

```
~/Notes/
├── programming/
│   ├── rust.md
│   ├── python.md
│   └── typescript.md
├── philosophy/
│   ├── stoicism.md
│   └── ethics.md
├── daily/
│   ├── 2025-10-23.md
│   └── 2025-10-24.md
└── index.md
```

### Tag-Based Discovery

Use frontmatter tags:

```markdown
---
tags:
  - programming
  - rust
  - learning
  - active
---
```

Search by tag with grep:

```vim
g/ → tag:active
```

### MOC (Map of Content) Pattern

Create index notes for topics:

`programming-moc.md`:

```markdown
# Programming MOC

## Active Learning
- [[Rust Book]] 📖
- [[TypeScript Tutorial]] ✅

## Reference
- [[Design Patterns]]
- [[Code Style Guide]]

## Projects
- [[Personal Website]]
- [[CLI Tool Development]]
```

______________________________________________________________________

## Review Workflows

### Weekly Review

```vim
:e ~/Notes/weekly-review.md
```

Template:

```markdown
# Weekly Review - Week 43, 2025

## Notes Created
- Press `gf` → sort by modified date → list new notes

## Most Linked Notes
- Use `g/` → search for `[[` → see popular topics

## Orphan Notes (No Incoming Links)
- Manual review: Which notes have no backlinks?

## Action Items
- [ ] Merge redundant notes
- [ ] Extract growing sections
- [ ] Update index pages
```

### Monthly Knowledge Graph Check

1. Generate graph preview:

   ```vim
   :IWE preview export-workspace
   ```

2. Review `~/Zettelkasten/preview/graph.svg`

3. Identify:

   - Isolated clusters (need better connections)
   - Over-connected hubs (consider splitting)
   - Missing links between related topics

______________________________________________________________________

## Advanced Patterns

### Template Expansion with Snippets

Create note templates in `~/Notes/templates/`:

`project.md`:

```markdown
---
title: PROJECT_NAME
tags:
  - project
  - active
status: planning
---

# PROJECT_NAME

## Goal


## Resources
-

## Progress
- [ ] Initial research
- [ ] Implementation
- [ ] Documentation
```

Use snippet expansion plugin to fill templates.

### Cross-Project Linking

If you have multiple IWE projects:

```markdown
See also: [System Design](~/Work/notes/system-design.md)
```

LSP won't follow cross-project links, but you can use absolute paths.

### Integration with External Tools

**Export to Hugo/Obsidian Publish:**

```vim
:IWE preview squash
```

Generates single-file export in `~/Zettelkasten/preview/squash.md`

**Generate graph visualizations:**

```vim
:IWE preview export-headers
```

Creates DOT graph with headers as SVG.

______________________________________________________________________

## Productivity Tips

### Fast Note Creation Alias

Add to your shell rc:

```bash
# Quick note
note() {
  nvim ~/Notes/"$1".md
}

# Usage:
note rust-ownership
```

### Git Version Control

```bash
cd ~/Notes
git add -A
git commit -m "Daily notes $(date +%Y-%m-%d)"
```

Hook into IWE:

```vim
:!git add -A && git commit -m "Update knowledge base"
```

### Sync Across Devices

```bash
# Push to remote
cd ~/Notes && git push

# Pull on other device
cd ~/Notes && git pull
```

IWE works offline-first; sync when convenient.

______________________________________________________________________

## Common Workflows

### Literature Note Pattern

After reading an article/book:

1. Create lit note:

   ```vim
   :e ~/Notes/literature/author-title-2025.md
   ```

2. Add metadata:

   ```markdown
   ---
   title: The Rust Book - Chapter 5
   author: Steve Klabnik
   type: literature
   tags:
     - rust
     - reading
   source: https://doc.rust-lang.org/book/
   ---

   ## Summary


   ## Key Points
   -

   ## Connections
   - Relates to [[Programming]]
   - See also [[Ownership Concept]]
   ```

3. Extract permanent notes:

   - Use `<leader>ca` to extract key concepts
   - Create atomic notes for each idea

### Meeting Notes Pattern

```vim
:e ~/Notes/meetings/2025-10-23-team-sync.md
```

```markdown
---
title: Team Sync - 2025-10-23
attendees: Alice, Bob, Charlie
tags:
  - meeting
  - work
---

# Team Sync - 2025-10-23

## Topics
- [[Project Alpha]] status update
- [[Deployment Strategy]] discussion

## Action Items
- [ ] @Percy: Update [[Documentation]]
- [ ] @Alice: Review [[Code Changes]]

## Follow-up
- Next meeting: 2025-10-30
```

______________________________________________________________________

## Troubleshooting Daily Workflows

### LSP Slow on Large Projects

If you have 1000+ notes and LSP is slow:

1. Split into multiple projects:

   ```
   ~/Notes/active/     # Current work
   ~/Notes/archive/    # Old notes
   ```

2. Use separate `.iwe` markers

3. Link across projects with absolute paths when needed

### Broken Links After Rename

If `<leader>rn` didn't catch everything:

1. Search for old name:

   ```vim
   g/ → old-name
   ```

2. Manually update remaining references

### Merge Conflicts from Sync

If git shows merge conflicts:

1. Open conflicted file
2. Manually resolve (IWE can't auto-resolve)
3. Continue: `git add . && git commit`

______________________________________________________________________

## Next Steps

- **Customize**: Edit keybindings in `lua/plugins/lsp/iwe.lua`
- **Extend**: Add custom LSP code actions
- **Automate**: Create shell scripts for common tasks
- **Explore**: Try preview generation with `:IWE preview`

For complete keybinding reference, see [IWE Reference](../reference/IWE_REFERENCE.md).

For understanding IWE's architecture, see [IWE Architecture](../explanation/IWE_ARCHITECTURE.md).
