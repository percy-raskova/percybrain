# PercyBrain: Neovim Zettelkasten System

Your Neovim-based Obsidian replacement for knowledge management, integrated terminal, and static site publishing.

## Quick Start

### Initial Setup (5 minutes)

1. **Create your Zettelkasten directory**:

   ```bash
   mkdir -p ~/Zettelkasten/{inbox,daily,templates}
   ```

2. **Configure paths** (optional, defaults to ~/Zettelkasten): Edit `lua/config/zettelkasten.lua` if you want different paths:

   ```lua
   M.config = {
     home = vim.fn.expand("~/MyNotes"),  -- Change this
     -- ...
   }
   ```

3. **Start Neovim**:

   ```bash
   nvim
   ```

4. **Test it works**:

   - Press `<leader>zn` (space-z-n) to create a new note
   - Type a title, hit Enter
   - Start writing!

______________________________________________________________________

## Two-Part Workflow

### Part 1: Quick Capture (Fleeting Notes)

**Goal**: Capture ideas instantly without friction

#### Quick Inbox Note

```
<leader>zi   " Create timestamped note in inbox/
```

- Drops you directly into insert mode
- Minimal frontmatter
- Process later

#### New Zettelkasten Note

```
<leader>zn   " Create permanent note with proper structure
```

- Prompts for title
- Creates timestamped filename: `202510170145-my-note.md`
- Includes YAML frontmatter

#### Daily Note

```
<leader>zd   " Open/create today's daily note
```

- One note per day: `daily/2025-10-17.md`
- Journal entries, meeting notes, etc.

### Part 2: Integrate & Publish

#### Search & Navigation

```
<leader>zf   " Find notes by filename (fuzzy search)
<leader>zg   " Search notes content (grep)
<leader>zb   " Find backlinks to current note
```

#### Link Notes (Wiki-style)

```markdown
# In your note:
This connects to [[another-note]] and [[2025-10-17-ideas]].

# Automatic linking:
- Type `[[` and start typing
- Use <C-n> / <C-p> to autocomplete
- Creates link to existing note
```

#### Writing Mode

```
<leader>zw   " Enter distraction-free Zen mode
```

#### Publish to Static Site

```
:PercyPublish   " Export to Hugo/Jekyll/etc.
:PercyPreview   " Start local preview server
```

______________________________________________________________________

## Complete Keyboard Reference

### Zettelkasten Operations

| Key | Command | Description | | ------------ | --------------- | -------------------------- | | `<leader>zn` | `:PercyNew` | Create new permanent note | | `<leader>zd` | `:PercyDaily` | Open today's daily note | | `<leader>zi` | `:PercyInbox` | Quick capture to inbox | | `<leader>zf` | Find notes | Fuzzy find by filename | | `<leader>zg` | Search notes | Live grep through content | | `<leader>zb` | Backlinks | Find links to current note | | `<leader>zw` | Zen mode | Distraction-free writing | | `<leader>zp` | `:PercyPublish` | Export to static site |

### Writing Tools (Inherited from OVIWrite)

| Key | Command | Description | | ------------ | ----------- | ------------------ | | `<leader>z` | Zen mode | Centered writing | | `<leader>o` | Goyo | Minimalist mode | | `<leader>sp` | Soft pencil | Soft line wrapping |

### Navigation (Telescope)

| Key | Command | Description | | ------------ | ---------- | ----------------------- | | `<leader>ff` | Find files | Project-wide fuzzy find | | `<leader>fg` | Live grep | Search all files | | `<leader>fb` | Buffers | Switch open files |

### Terminal (Built-in)

| Key | Command | Description | | ------------ | -------------- | ------------------------ | | `<leader>t` | Terminal | Open integrated terminal | | `<leader>ft` | Float terminal | Floating terminal window |

______________________________________________________________________

## Zettelkasten Best Practices

### Note Structure

**Permanent Note Example**:

```markdown
---
title: My Brilliant Idea
date: 2025-10-17 01:45
tags: [philosophy, productivity]
---

# My Brilliant Idea

## Context
Where did this idea come from?

## Main Argument
The core insight...

## Connections
- Related to [[atomic-notes]]
- Contrasts with [[opposing-view]]
- Builds on [[foundation-concept]]

## Sources
- Book: *Thinking Fast and Slow*, p. 42
```

### Linking Strategy

**Wiki-style Links**:

```markdown
[[note-title]]              # Link to note
[[note-title|Custom Text]]  # Link with different display text
```

**Tags for Discovery**:

```yaml
tags: [#concept, #project/myproject, #source/book]
```

### Processing Workflow

**Inbox → Permanent Notes**:

1. Review `inbox/` daily/weekly
2. Expand fleeting notes into permanent notes
3. Add connections `[[links]]`
4. Add proper tags
5. Delete or archive processed inbox items

**Find orphan notes** (notes with no links):

```vim
:PercyOrphans  " TODO: Implement this
```

______________________________________________________________________

## Static Site Publishing

### Option 1: Hugo (Recommended)

**Setup Hugo site**:

```bash
cd ~
hugo new site blog
cd blog
git init
git submodule add https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
echo "theme = 'PaperMod'" >> config.toml
```

**Configure in zettelkasten.lua**:

```lua
M.config = {
  export_path = vim.fn.expand("~/blog/content/zettelkasten"),
}
```

**Publish**:

```vim
:PercyPublish   " Copies notes to ~/blog/content/
:PercyPreview   " Starts Hugo server at localhost:1313
```

### Option 2: Quartz (Obsidian-like)

[Quartz](https://quartz.jzhao.xyz/) creates Obsidian-style websites with graph view:

```bash
npm install -g @jackyzha0/quartz
cd ~/Zettelkasten
npx quartz create
```

Update `zettelkasten.lua`:

```lua
function M.publish()
  vim.fn.system('cd ~/Zettelkasten && npx quartz build')
end
```

### Option 3: Jekyll (GitHub Pages)

Free hosting with GitHub Pages:

```bash
gem install jekyll bundler
jekyll new ~/blog
```

______________________________________________________________________

## Cleanup: Remove Unused Plugins

Since you don't care about upstream, remove dev-focused plugins:

```bash
cd ~/.config/nvim/lua/plugins

# Remove LSP/dev tools (you don't need these for writing)
rm -rf lsp/
rm lazygit.lua
rm hardtime.lua
rm screenkey.lua

# Optional: Remove if you don't use
rm vimtex.lua        # Only if you don't write LaTeX
rm fountain.lua      # Only if you don't write screenplays
rm quicklispnvim.lua # Lisp development
rm cl-neovim.lua     # Common Lisp
```

**Test after removal**:

```bash
nvim --headless -c "quit"  # Should start without errors
```

______________________________________________________________________

## Enhancing Your System

### Add Obsidian.nvim (Full Obsidian Compatibility)

**Why**: Best of both worlds - Neovim + Obsidian features

Edit `lua/plugins/obsidianNvim.lua`:

```lua
return {
  "epwalsh/obsidian.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "main",
        path = "~/Zettelkasten",
      },
    },

    notes_subdir = "inbox",
    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
    },

    completion = {
      nvim_cmp = true,  -- Autocomplete [[links]]
      min_chars = 2,
    },

    -- Customize note creation
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return os.date("%Y%m%d%H%M") .. "-" .. suffix
    end,

    -- Follow links with 'gf'
    follow_url_func = function(url)
      vim.fn.jobstart({"xdg-open", url})
    end,
  },

  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Today's note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Show links" },
  },
}
```

**Benefits**:

- Link autocomplete
- Backlinks panel
- Daily note templates
- Obsidian app integration (can use both!)
- Graph view (if using Obsidian desktop occasionally)

### Add Neorg (Alternative to Org-mode)

**Why**: Better than org-mode for modern Neovim, GTD support

```lua
-- lua/plugins/neorg.lua
return {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    load = {
      ["core.defaults"] = {},
      ["core.concealer"] = {},
      ["core.dirman"] = {
        config = {
          workspaces = {
            notes = "~/Zettelkasten/neorg",
          },
          default_workspace = "notes",
        },
      },
      ["core.completion"] = {
        config = { engine = "nvim-cmp" },
      },
    },
  },
}
```

______________________________________________________________________

## Workflow Examples

### Morning Routine

```vim
# 1. Open today's daily note
<leader>zd

# 2. Review inbox from yesterday
<leader>zf
# Type: inbox/
# Process each note

# 3. Check what you worked on yesterday
<leader>zg
# Search: "TODO" or yesterday's date

# 4. Start writing in zen mode
<leader>zw
```

### Research Session

```vim
# 1. Quick capture ideas as you read
<leader>zi

# 2. Search related notes
<leader>zg
# Search: concept name

# 3. Create permanent note linking ideas
<leader>zn
# Title: "Connection Between X and Y"
# Add [[links]] to related notes

# 4. View backlinks
<leader>zb
# See what connects to this idea
```

### Publishing

```vim
# 1. Review notes ready to publish
<leader>zf

# 2. Clean up formatting
# Remove drafts, fix links

# 3. Publish
:PercyPublish

# 4. Preview locally
:PercyPreview
# Visit http://localhost:1313

# 5. Deploy to web
# (in terminal)
cd ~/blog && git add . && git commit -m "Update" && git push
```

______________________________________________________________________

## Troubleshooting

### "No such file or directory: ~/Zettelkasten"

Create the directory:

```bash
mkdir -p ~/Zettelkasten/{inbox,daily,templates}
```

### Links don't autocomplete

Install and configure obsidian.nvim (see "Enhancing Your System" above)

### Can't find telescope

Install telescope properly:

```bash
nvim
:Lazy install telescope.nvim
```

### Terminal doesn't work

Use built-in terminal:

```
:terminal
# Or
<leader>t
```

### Want to use Obsidian app alongside Neovim?

**Yes! You can use both!**

1. Set Obsidian vault to `~/Zettelkasten`
2. Use Obsidian for:
   - Graph view
   - Mobile access
   - Plugin ecosystem
3. Use Neovim for:
   - Fast editing
   - Terminal integration
   - Writing flow
   - Publishing workflow

They share the same markdown files perfectly!

______________________________________________________________________

## Next Steps

### Immediate Actions

1. ✅ **Test the system**:

   ```bash
   nvim
   # Press <leader>zn and create a note
   ```

2. ✅ **Create your first notes**:

   - Daily note: `<leader>zd`
   - Permanent note: `<leader>zn`
   - Quick capture: `<leader>zi`

3. ✅ **Set up static site** (optional):

   - Choose Hugo/Quartz/Jekyll
   - Configure export path
   - Test: `:PercyPublish`

### Customization

4. **Adjust paths** (if needed):

   - Edit `lua/config/zettelkasten.lua`
   - Change `M.config.home` to your preferred location

5. **Add obsidian.nvim** (recommended):

   - Better link autocomplete
   - Backlinks panel
   - Obsidian compatibility

6. **Create templates**:

   - Add files to `~/Zettelkasten/templates/`
   - Use in zettelkasten.lua

### Advanced

7. **Custom commands**:

   - Add to `lua/config/zettelkasten.lua`
   - Weekly reviews
   - Tag management
   - Graph generation

8. **Automation**:

   - Git auto-commit
   - Auto-publish on save
   - Backup scripts

______________________________________________________________________

## Resources

### Zettelkasten Method

- [zettelkasten.de](https://zettelkasten.de/) - The definitive guide
- [How to Take Smart Notes](https://www.amazon.com/How-Take-Smart-Notes-Nonfiction/dp/1542866502) - Book

### Static Site Generators

- [Hugo](https://gohugo.io/) - Fast, simple
- [Quartz](https://quartz.jzhao.xyz/) - Obsidian-like
- [Jekyll](https://jekyllrb.com/) - GitHub Pages

### Neovim Plugins

- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim)
- [telekasten.nvim](https://github.com/renerocksai/telekasten.nvim)
- [neorg](https://github.com/nvim-neorg/neorg)

______________________________________________________________________

## Support

**Issues or Questions?**

- Check validation: `./scripts/validate.sh`
- Neovim health: `:checkhealth`
- Plugin status: `:Lazy`

**This is your system now!** Customize, extend, and make it work for you.

Happy note-taking! 📝🧠
