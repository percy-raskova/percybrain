---
title: Getting Started with PercyBrain
category: tutorial
tags:
  - tutorial
  - beginner
  - zettelkasten
  - getting-started
last_reviewed: '2025-10-19'
---

# Getting Started with PercyBrain

Welcome to PercyBrain! This hands-on tutorial will take you from complete beginner to having a working Zettelkasten knowledge system with linked notes in just 30 minutes.

## Before You Begin

### What You'll Learn

By the end of this tutorial, you'll be able to:

- Create and organize notes in your personal Zettelkasten
- Link notes together to build a knowledge network
- Search and navigate your notes instantly
- Build a daily journaling workflow
- Understand the basics of the Zettelkasten method

### Prerequisites

You need:

- **Neovim ≥0.8.0** - Check with `nvim --version`
- **Git ≥2.19.0** - Check with `git --version`
- **A Nerd Font** - For proper icon display (optional but recommended)
- **Basic text editing knowledge** - You should know how to save and exit a file in Neovim (`i` for insert mode, `Esc` to exit insert mode, `:wq` to save and quit)

Don't worry if you're not a Vim expert! This tutorial assumes you know just the absolute basics.

### Time Estimate

**30 minutes** - Follow along step by step, and you'll have a working knowledge management system by the end.

### What is Zettelkasten?

The Zettelkasten (German for "slip box") is a note-taking method where you:

1. Write **atomic notes** - one idea per note
2. **Link notes together** - create connections between ideas
3. Let **structure emerge** - don't impose rigid hierarchies upfront
4. **Think through writing** - develop insights by connecting notes

Think of it like building a personal Wikipedia of your thoughts, where every page links to related concepts.

______________________________________________________________________

## Step 1: Installation & First Launch (5 minutes)

### Create Your Zettelkasten Directory

PercyBrain stores your notes in `~/Zettelkasten` by default. Let's create the necessary folders:

```bash
mkdir -p ~/Zettelkasten/{inbox,daily,templates}
```

**What these folders do:**

- `inbox/` - Quick captures, fleeting thoughts (process later)
- `daily/` - One note per day for journaling
- `templates/` - Reusable note templates (optional)
- Root `~/Zettelkasten/` - Your permanent notes live here

### Verify Installation

Start Neovim and check that everything is working:

```bash
nvim
```

Inside Neovim, run:

```vim
:checkhealth
```

Look for any errors related to PercyBrain or telescope. If you see warnings about optional dependencies (like `ripgrep` or `fd`), you can install them later for enhanced searching.

To exit the health check, press `:q` and Enter.

### Test Basic Functionality

Let's verify PercyBrain is loaded correctly. In Neovim, press these keys in sequence (don't hold them down - press space, then z, then n):

```
<leader>zn
```

**Note:** `<leader>` is the space bar by default in PercyBrain.

You should see a prompt asking for a note title. If you do - congratulations! PercyBrain is working. Press `Esc` to cancel for now.

**🎓 Learning Checkpoint:** You've successfully installed PercyBrain and verified it works!

**Troubleshooting:**

- **"No such file or directory: ~/Zettelkasten"** → Run the `mkdir` command from above
- **"Unknown command: PercyNew"** → PercyBrain might not be loaded. Restart Neovim: `:quit` then `nvim`
- **Nothing happens when pressing `<leader>zn`** → Make sure you're in normal mode (press `Esc` first), then try again

______________________________________________________________________

## Step 2: Your First Note (5 minutes)

### Create an Inbox Note

Let's start with the simplest type of note - a quick capture to your inbox. Press:

```
<space>zi
```

(`<space>` means the space bar, `z` then `i`)

**What happens:**

1. A new file opens in `~/Zettelkasten/inbox/` with a timestamp filename
2. You're automatically in **insert mode** (ready to type)
3. The file has minimal frontmatter (YAML metadata at the top)

### Write Your First Thought

Type anything you want! For example:

```markdown
---
title: Quick Note
date: 2025-10-19 14:30:45
tags: [inbox]
---

I'm learning PercyBrain and this is my first note!

The Zettelkasten method seems powerful because it lets me build
connections between ideas instead of organizing them in rigid folders.
```

**Tips for writing:**

- Press `i` to enter insert mode (if you're not already in it)
- Press `Esc` to exit insert mode (back to normal mode)
- In normal mode, press `:w` and Enter to save (or `:wq` to save and quit)

### Save Your Note

1. Press `Esc` to exit insert mode
2. Type `:w` and press `Enter` to save
3. Type `:q` and press `Enter` to close the file

**Alternative:** Type `:wq` and press `Enter` to save and quit in one command.

**🎓 Learning Checkpoint:** You just created your first note! It's saved in `~/Zettelkasten/inbox/` as a plain markdown file.

**Troubleshooting:**

- **Can't type anything** → Press `i` to enter insert mode
- **Characters appear as commands** → You're in normal mode. Press `i` to switch to insert mode
- **File won't save** → Make sure you're in normal mode (press `Esc`), then type `:w` and Enter

______________________________________________________________________

## Step 3: Creating Linked Notes (10 minutes)

This is where PercyBrain becomes powerful. Let's create permanent notes and link them together.

### Create a Permanent Note

Press `<space>zn` (space, then z, then n). You'll see a prompt:

```
Note title:
```

Type: `Learning Zettelkasten Method`

Press `Enter`.

**What happens:**

1. PercyBrain creates a new file with a timestamp: `202510191430-learning-zettelkasten-method.md`
2. The file opens with proper frontmatter (title, date, tags)
3. The cursor is positioned for you to start writing

### Add Content to Your Note

Press `i` to enter insert mode, then type (or copy-paste):

```markdown
---
title: Learning Zettelkasten Method
date: 2025-10-19 14:30
tags: []
---

# Learning Zettelkasten Method

## What is Zettelkasten?

The Zettelkasten method is a personal knowledge management system based on:

1. **Atomic notes** - One idea per note
2. **Linking** - Connecting related ideas
3. **Emergent structure** - Organization grows organically
4. **Active thinking** - Understanding through writing

## Why It Works

Instead of filing notes into rigid folders, Zettelkasten lets ideas connect
naturally. This mirrors how our brains actually work - through associations.

## Related Concepts

- See also: [[note-taking-systems]]
- Contrasts with: [[hierarchical-organization]]
```

**Notice the double square brackets `[[...]]`** - These are **wiki-style links**. We'll create these linked notes next!

Save your note: Press `Esc`, then type `:w` and Enter.

### Create Your First Linked Note

With your cursor on the word between `[[note-taking-systems]]`, press `gf` (in normal mode).

**What happens:**

- If the file doesn't exist, you'll see an error
- That's okay! We'll create it manually

Let's create it the proper way. Press `<space>zn` and when prompted for a title, type:

```
Note Taking Systems
```

Press `i` to enter insert mode and add some content:

```markdown
---
title: Note Taking Systems
date: 2025-10-19 14:32
tags: [productivity, knowledge-management]
---

# Note Taking Systems

Common note-taking approaches:

## Traditional Methods
- Bullet journals
- Cornell notes
- Outline method

## Digital Methods
- Folder hierarchies (traditional file systems)
- Tag-based systems
- Graph-based (like [[Learning Zettelkasten Method]])

## Comparison

Traditional folder systems force you to choose ONE location for a note.
But ideas don't fit into single categories - they connect to multiple concepts.

This is why linking systems like Zettelkasten are powerful.
```

**Notice:** We've linked BACK to our first note using `[[Learning Zettelkasten Method]]`. This creates a **bidirectional connection**.

Save and close: `Esc`, `:wq`, Enter.

### Navigate Between Notes

Now the fun part! Open your first note again by pressing:

```
<space>zf
```

This opens the **fuzzy finder**. Start typing `learning` and you'll see your note appear. Press `Enter` to open it.

**To follow a link:**

1. Move your cursor (using arrow keys or `h`/`j`/`k`/`l`) to a `[[link]]`
2. Press `gf` (in normal mode)
3. The linked file opens!

Try it now - navigate to `[[note-taking-systems]]` and press `gf`.

**To go back:**

Press `Ctrl-o` (that's the letter O, not zero). This takes you back to the previous file.

**🎓 Learning Checkpoint:** You now have a linked knowledge network! You can navigate between connected ideas instantly.

**Tips:**

- Create links as you write - don't worry if the file doesn't exist yet
- Come back later to create the linked notes
- Every link is an invitation to expand your knowledge base

______________________________________________________________________

## Step 4: Finding Your Notes (5 minutes)

As your Zettelkasten grows, you need powerful ways to find notes. PercyBrain gives you three main tools:

### Fuzzy Find by Filename

Press `<space>zf` (space, z, f)

**What you see:**

- A searchable list of all your notes
- Type any part of the filename or title
- Results update as you type

**Try it:**

1. Press `<space>zf`
2. Type `zettel`
3. See your "Learning Zettelkasten Method" note appear
4. Press `Enter` to open it
5. Press `Esc` to close the finder without selecting

### Search Note Content

Press `<space>zg` (space, z, g) for "grep" (search text)

**What you see:**

- A live search through ALL your notes
- Type any word or phrase
- See matching lines with context

**Try it:**

1. Press `<space>zg`
2. Type `atomic`
3. See all notes mentioning "atomic notes"
4. Press `Enter` on a result to jump to that line
5. Press `Esc` to cancel

### Find Backlinks

Backlinks show you what notes link TO the current note. This is incredibly powerful for discovering connections.

**Try it:**

1. Open your "Learning Zettelkasten Method" note (`<space>zf`, type `learning`, Enter)
2. Press `<space>zb` (space, z, b for "backlinks")
3. You should see "Note Taking Systems" because it links back to this note

**Understanding backlinks:**

If note A links to note B with `[[note-b]]`, then note B's backlinks show note A. This reveals how ideas connect throughout your knowledge base.

**🎓 Learning Checkpoint:** You can now find any note in seconds, whether by name, content, or connections!

**Power user tip:** The more links you create, the more useful backlinks become. They reveal unexpected connections you didn't consciously make.

______________________________________________________________________

## Step 5: Daily Notes Workflow (5 minutes)

Daily notes are perfect for journaling, meeting notes, daily logs, or anything time-bound.

### Create Today's Daily Note

Press `<space>zd` (space, z, d for "daily")

**What happens:**

1. PercyBrain creates (or opens if it exists) today's daily note
2. The filename is the date: `2025-10-19.md`
3. It's stored in `~/Zettelkasten/daily/`

### Write in Your Daily Note

Press `i` to enter insert mode and add some content:

```markdown
---
title: Daily Note 2025-10-19
date: 2025-10-19
tags: [daily]
---

# 2025-10-19

## Notes

Today I started learning PercyBrain. Key insights:

- The Zettelkasten method uses [[Learning Zettelkasten Method]]
- Linking notes creates a knowledge graph
- Daily notes help capture time-bound thoughts

## Ideas to Explore

- How do I decide when an inbox note becomes a permanent note?
- What's the difference between tags and links?
- Can I publish my Zettelkasten as a website?

## Quick Captures

- Remember to process inbox notes weekly
- The fuzzy finder (<space>zf) is incredibly fast
```

**Notice how we linked to our permanent note** using `[[Learning Zettelkasten Method]]`. This connects today's journal to your knowledge base.

Save your daily note: `Esc`, `:w`, Enter

### Building the Daily Habit

Here's a powerful workflow:

**Morning:**

1. Press `<space>zd` to open today's note
2. Review yesterday's daily note for continuity
3. Plan your day

**During the day:**

1. Press `<space>zi` for quick captures (inbox notes)
2. Don't worry about perfect formatting
3. Just capture ideas fast

**Evening:**

1. Press `<space>zd` to review today
2. Press `<space>zf`, type `inbox/` to see inbox notes
3. Decide which inbox notes deserve to become permanent notes
4. Create those permanent notes with `<space>zn`
5. Link them to your knowledge base

**🎓 Learning Checkpoint:** You've established a capture routine! Daily notes anchor your knowledge work in time.

**Tips:**

- Don't stress about processing inbox notes immediately
- Daily notes are low-friction - just write
- Review and process weekly (or when you feel like it)
- The system grows organically as you use it

______________________________________________________________________

## Next Steps

Congratulations! You now have a working Zettelkasten with linked notes. Here's where to go from here:

### Deepen Your Practice

**This week:**

- Create at least 5 permanent notes
- Link each new note to at least 2 existing notes
- Use daily notes every day

**This month:**

- Develop your own note templates in `~/Zettelkasten/templates/`
- Experiment with tags vs. links for organization
- Review your knowledge graph weekly to find unexpected connections

### Explore Advanced Features

**AI Integration** (requires Ollama):

- Install Ollama and pull llama3.2 model
- See [PERCYBRAIN_USER_GUIDE.md](../PERCYBRAIN_USER_GUIDE.md) for AI commands
- Use `<space>zas` to summarize notes, `<space>zac` for connection suggestions

**Publishing Your Notes:**

- Set up Hugo or Quartz for static site generation
- Use `<leader>zp` to publish your Zettelkasten as a website
- See [PERCYBRAIN_SETUP.md](../../PERCYBRAIN_SETUP.md) for publishing setup

**IWE LSP Integration:**

- Install IWE LSP for enhanced link management: `cargo install iwe`
- Get graph views, better autocomplete, and semantic understanding
- See [how-to-use-iwe.md](../how-to-use-iwe.md) for setup

### Learn More About Zettelkasten

**Workflows:**

- [ZETTELKASTEN_WORKFLOW.md](../how-to/ZETTELKASTEN_WORKFLOW.md) - Daily usage patterns
- [WHY_PERCYBRAIN.md](../explanation/WHY_PERCYBRAIN.md) - Philosophy and vision

**External Resources:**

- [zettelkasten.de](https://zettelkasten.de/) - The definitive guide to the method
- "How to Take Smart Notes" by Sönke Ahrens - The essential book

### Customize Your Setup

**Edit configuration:**

- Main config: `~/.config/nvim/lua/config/zettelkasten.lua`
- Change the Zettelkasten directory path
- Customize keybindings
- Add your own commands

**Create templates:**

- Add files to `~/Zettelkasten/templates/`
- When creating notes with `<space>zn`, PercyBrain will offer to use templates
- Templates can have variables like `{{title}}` and `{{date}}`

______________________________________________________________________

## Troubleshooting Common Issues

### "I pressed `<space>zn` but nothing happened"

**Solution:**

1. Make sure you're in **normal mode** (press `Esc` first)
2. Try again: `<space>`, then `z`, then `n`
3. If still nothing, restart Neovim: `:quit` then `nvim`

### "I can't find the note I just created"

**Solution:**

1. Press `<space>zf` to fuzzy find
2. Type any part of the note's title
3. Check the correct directory:
   - Inbox notes: `~/Zettelkasten/inbox/`
   - Daily notes: `~/Zettelkasten/daily/`
   - Permanent notes: `~/Zettelkasten/` (root)

### "Links don't work when I press `gf`"

**Solution:**

1. Make sure the link format is correct: `[[note-title]]` (no `.md` extension)
2. The linked file must exist - create it with `<space>zn`
3. Alternatively, install IWE LSP for better link handling

### "I'm stuck in insert mode"

**Solution:**

- Press `Esc` to return to normal mode
- In normal mode, you can navigate and use commands
- Press `i` only when you want to type text

### "How do I know if I'm in normal mode or insert mode?"

**Look at the bottom left of your screen:**

- `-- INSERT --` means you're in insert mode (typing)
- Nothing (or your filename/status) means you're in normal mode (navigation)

### "The fuzzy finder shows too many files"

**Solution:**

- Just start typing to filter results
- Type part of the filename or note title
- Use arrow keys or `Ctrl-j`/`Ctrl-k` to navigate results

______________________________________________________________________

## Quick Reference Card

Keep this handy as you learn:

### Essential Keybindings

| Keys            | What It Does                | When To Use                   |
| --------------- | --------------------------- | ----------------------------- |
| `<space>zn`     | Create new permanent note   | Developing a complete thought |
| `<space>zd`     | Today's daily note          | Journaling, daily capture     |
| `<space>zi`     | Quick inbox capture         | Fast idea capture             |
| `<space>zf`     | Find notes (fuzzy)          | Finding notes by name         |
| `<space>zg`     | Search content (grep)       | Finding text in notes         |
| `<space>zb`     | Find backlinks              | See what links here           |
| `gf`            | Follow link under cursor    | Navigate between notes        |
| `Ctrl-o`        | Go back to previous file    | Return after following link   |
| `i`             | Enter insert mode           | Start typing                  |
| `Esc`           | Exit insert mode            | Return to normal mode         |
| `:w` + `Enter`  | Save file                   | Save changes                  |
| `:q` + `Enter`  | Quit file                   | Close current file            |
| `:wq` + `Enter` | Save and quit               | Save and close                |
| `<space>fz`     | Zen mode (distraction-free) | Focused writing               |

### Note Types

**Inbox notes** (`~/Zettelkasten/inbox/`):

- Quick captures
- Fleeting thoughts
- Process later
- Created with `<space>zi`

**Daily notes** (`~/Zettelkasten/daily/`):

- One per day
- Time-bound content
- Journal, logs, meetings
- Created with `<space>zd`

**Permanent notes** (`~/Zettelkasten/`):

- Fully developed ideas
- Well-linked
- Atomic (one concept)
- Created with `<space>zn`

### Linking Syntax

```markdown
[[note-title]]                    # Basic link
[[note-title|Display Text]]       # Link with custom text
See also: [[related-concept]]     # Inline reference
```

### Frontmatter Template

```markdown
---
title: Your Note Title
date: 2025-10-19 14:30
tags: [concept, productivity, reference]
---

# Your Note Title

Your content here...
```

______________________________________________________________________

## You're Ready!

You've completed the getting started tutorial! You now know how to:

- ✅ Create notes in your Zettelkasten
- ✅ Link notes together to build connections
- ✅ Search and navigate your knowledge base
- ✅ Maintain a daily journaling practice
- ✅ Understand the Zettelkasten philosophy

**Remember:**

- Your Zettelkasten grows organically - don't force structure
- Links are more powerful than tags for knowledge work
- Process inbox notes regularly (weekly is fine)
- The system gets better the more you use it

**Keep learning:**

- Practice daily note-taking for two weeks
- Experiment with linking strategies
- Explore advanced features when you're ready
- Join the community and share your workflows

You're doing great! Welcome to the world of networked thought.

______________________________________________________________________

## Getting Help

**Resources:**

- [QUICK_REFERENCE.md](../../QUICK_REFERENCE.md) - Essential commands
- [PERCYBRAIN_USER_GUIDE.md](../PERCYBRAIN_USER_GUIDE.md) - Comprehensive guide
- [WHY_PERCYBRAIN.md](../explanation/WHY_PERCYBRAIN.md) - Philosophy and vision

**Technical Issues:**

- Run `:checkhealth` in Neovim
- Check `~/Zettelkasten/` directory exists
- Verify lazy.nvim loaded plugins: `:Lazy`

**Questions:**

- Check existing documentation in `docs/`
- Review the setup guide: [PERCYBRAIN_SETUP.md](../../PERCYBRAIN_SETUP.md)
- Examine the config: `~/.config/nvim/lua/config/zettelkasten.lua`

Happy note-taking! 📝🧠
