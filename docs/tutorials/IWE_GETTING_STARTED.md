# Getting Started with IWE

**Category**: Tutorial **Time**: 20 minutes **Prerequisites**: iwes binary installed, Neovim configured with iwe.nvim plugin **Goal**: Create your first IWE-powered knowledge base and learn core navigation

______________________________________________________________________

## What You'll Learn

By the end of this tutorial, you'll be able to:

- Initialize an IWE project
- Create and link notes using `gd` (go to definition)
- Navigate between notes with LSP keybindings
- Find notes and backlinks with Telescope
- Use code actions for note refactoring

______________________________________________________________________

## Step 1: Verify IWE Installation

First, let's confirm everything is installed correctly.

### Check Health

```vim
:checkhealth iwe
```

You should see:

- ✅ OK iwes command found in PATH
- ✅ OK iwes is executable

If you see errors, install iwes first:

```bash
cargo install --git https://github.com/iwe-org/iwe
```

______________________________________________________________________

## Step 2: Initialize Your First Knowledge Base

Navigate to where you want to store your notes (e.g., `~/Notes`):

```bash
cd ~/Notes
```

Start Neovim:

```bash
nvim
```

Initialize IWE:

```vim
:IWE init
```

This creates a `.iwe` marker directory, which tells IWE this is a project root.

### Verify Initialization

```vim
:IWE lsp status
```

You should see:

```
IWE LSP server is ready to start (will activate in markdown files)
```

______________________________________________________________________

## Step 3: Create Your First Note

Create an index file:

```vim
:e index.md
```

Add some content:

```markdown
# My Knowledge Base

## Topics
- [[Programming]]
- [[Philosophy]]
- [[Daily Notes]]
```

Save the file (`:w`).

**What happened?**

- The `iwes` LSP server started automatically (watch for notification)
- The links `[[Programming]]`, `[[Philosophy]]`, etc. are now interactive

______________________________________________________________________

## Step 4: Navigate with `gd` (Go to Definition)

Place your cursor on `[[Programming]]` and press `gd`.

**What happens:**

1. If the file doesn't exist → **Creates it with YAML frontmatter!**
2. If the file exists → **Opens it**

You'll see a new file `programming.md` with:

```markdown
---
title: Programming
date: 2025-10-23
tags:
  -
---

# Programming


```

Cursor is positioned after `tags:` ready for you to type!

### Add Content

```markdown
---
title: Programming
tags:
  - code
  - learning
---

# Programming

Programming is the art of problem-solving through code.

## Languages I'm Learning
- [[Rust]]
- [[Python]]
```

Save with `:w`.

______________________________________________________________________

## Step 5: Navigate Backwards

Press `<C-o>` (Ctrl+o) to jump back to `index.md`.

**LSP Navigation Stack:**

- `gd` = Go to definition (follow link)
- `<C-o>` = Jump backward
- `<C-i>` = Jump forward

______________________________________________________________________

## Step 6: Create More Notes

From `programming.md`, press `gd` on `[[Rust]]`:

```markdown
---
title: Rust
tags:
  - programming
  - systems
---

# Rust

Rust is a systems programming language focused on safety and performance.

Back to [[Programming]]
```

Now you have three connected notes:

```
index.md → programming.md → rust.md
```

______________________________________________________________________

## Step 7: Find Notes with Telescope

Press `gf` (go find) to open the **Telescope file picker**.

Type `prog` → You'll see `programming.md` in the results.

**Other Telescope Pickers:**

- `gf` = Find files (fuzzy search all notes)
- `g/` = Grep (search content across all notes)
- `gb` = Backlinks (who links to this note?)
- `go` = Outline (table of contents for current note)

Try them now!

______________________________________________________________________

## Step 8: View Backlinks

Open `programming.md` and press `gb` (backlinks).

You'll see:

```
rust.md:9: Back to [[Programming]]
index.md:4: - [[Programming]]
```

**This shows every note that links TO programming.md.**

______________________________________________________________________

## Step 9: Use Code Actions

In `programming.md`, place cursor on the "Languages I'm Learning" section.

Press `<leader>ca` (code actions).

You'll see options like:

- Extract section to new file
- Inline reference
- Rewrite list section
- Rewrite section list

Try **"Extract section to new file"**:

- Creates `languages-im-learning.md`
- Replaces section with link: `[[Languages Im Learning]]`

______________________________________________________________________

## Step 10: Auto-Format Your Notes

Press `<leader>f` to auto-format the current note.

**What it fixes:**

- Normalizes headers
- Cleans up list formatting
- Updates link titles
- Fixes whitespace

______________________________________________________________________

## Key Concepts Review

### 1. The `.iwe` Marker

- Must be in project root
- Enables LSP server activation
- Created with `:IWE init`

### 2. LSP Keybindings (Standard)

- `gd` = Go to definition (follow links, create notes)
- `gr` = Show references
- `K` = Hover documentation
- `<leader>ca` = Code actions
- `<leader>rn` = Rename file (updates all references!)

### 3. IWE Telescope Keybindings

- `gf` = Find files
- `g/` = Grep content
- `gb` = Backlinks (who links here?)
- `go` = Outline (table of contents)
- `gs` = Workspace symbols (paths)
- `ga` = Namespace symbols (roots)

### 4. IWE-Specific LSP Actions

- `<leader>h` = Rewrite list section
- `<leader>l` = Rewrite section list

______________________________________________________________________

## Common Patterns

### Daily Note Workflow

```vim
:e daily/2025-10-23.md
```

Add content:

```markdown
# 2025-10-23

## Done
- Read [[Rust Book]] chapter 5
- Reviewed [[Programming]] notes

## Tomorrow
- Continue [[Rust]]
```

### Tag-Based Organization

```markdown
---
tags:
  - project
  - active
  - rust
---
```

Use `g/` to search by tag: `tag:rust`

______________________________________________________________________

## Next Steps

**You now know how to:**

- ✅ Initialize IWE projects
- ✅ Create and link notes with `gd`
- ✅ Navigate with LSP keybindings
- ✅ Find notes with Telescope
- ✅ Refactor with code actions

**Continue Learning:**

- [IWE Daily Workflow](../how-to/IWE_DAILY_WORKFLOW.md) - Task-oriented recipes
- [IWE Reference](../reference/IWE_REFERENCE.md) - Complete API documentation
- [IWE Architecture](../explanation/IWE_ARCHITECTURE.md) - How IWE works

______________________________________________________________________

## Troubleshooting

### LSP Not Starting

1. Check health: `:checkhealth iwe`
2. Verify `.iwe` directory exists
3. Ensure you're in a markdown file (`:set ft?` → should say `markdown`)

### Keybindings Not Working

1. Check if they're enabled in config:
   ```lua
   mappings = {
     enable_markdown_mappings = true,
     enable_telescope_keybindings = true,
     enable_lsp_keybindings = true,
   }
   ```
2. Reload plugin: `:Lazy reload iwe.nvim`

### No Frontmatter on New Notes

1. Verify autocmd is loaded (restart Neovim)
2. Check `~/.config/nvim/lua/plugins/lsp/iwe.lua` has the BufNewFile autocmd

______________________________________________________________________

**Congratulations!** You've completed the IWE getting started tutorial. Your knowledge base is ready to grow! 🎉
