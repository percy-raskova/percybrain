---
title: Migrating from Obsidian to PercyBrain
category: how-to
tags:
  - migration
  - obsidian
  - getting-started
  - workflow-transition
last_reviewed: '2025-10-19'
difficulty: intermediate
time_commitment: 1-2 hours for initial migration, 1-2 weeks for workflow adaptation
prerequisites:
  - Existing Obsidian vault
  - Basic Neovim familiarity (or willingness to learn)
  - Command-line comfort
---

# Migrating from Obsidian to PercyBrain

**Goal**: Transition your knowledge base from Obsidian to PercyBrain while understanding trade-offs, preserving your notes, and adapting your workflow.

**Audience**: Obsidian users considering a terminal-native, privacy-first alternative with local AI and git integration.

## Should You Migrate?

### You'll Love PercyBrain If

- ✅ **Terminal Native**: You live in the terminal and want notes there too
- ✅ **Privacy First**: Local-only AI (Ollama) vs Obsidian's cloud AI
- ✅ **Git Integration**: Native version control, not plugin-based
- ✅ **Keyboard-Driven**: Vim motions, no mouse required
- ✅ **Scriptable**: Plain text + Unix tools = unlimited automation
- ✅ **Speed**: Instant startup, no Electron overhead
- ✅ **Control**: Full system transparency, no proprietary formats

### You'll Miss from Obsidian If

- ❌ **Mobile Apps**: No official iOS/Android (Termux on Android possible)
- ❌ **GUI**: No graphical interface, terminal only
- ❌ **Plugin Ecosystem**: Smaller community, fewer plugins
- ❌ **Graph View UI**: Text-based graph, not interactive GUI
- ❌ **Drag-and-Drop**: File operations via commands, not mouse
- ❌ **Beginner-Friendly**: Steeper learning curve (Vim + terminal)

### Honest Trade-off Assessment

| Feature                 | Obsidian                          | PercyBrain                        |
| ----------------------- | --------------------------------- | --------------------------------- |
| **Platform**            | Windows/Mac/Linux/iOS/Android     | Windows/Mac/Linux (Terminal)      |
| **Interface**           | GUI with themes                   | Terminal with syntax highlighting |
| **Learning Curve**      | Gentle (familiar UI)              | Steep (Vim + terminal)            |
| **Startup Speed**       | ~2-5 seconds                      | Instant (\<0.5s)                  |
| **Privacy**             | Sync via cloud (optional)         | 100% local, zero network          |
| **AI Features**         | Cloud AI (ChatGPT integration)    | Local AI (Ollama, fully private)  |
| **Version Control**     | Git plugin (requires setup)       | Native git integration            |
| **Mobile Access**       | Native apps, polished             | Termux (Android), SSH (limited)   |
| **Plugin Ecosystem**    | 1000+ community plugins           | ~68 integrated features           |
| **Customization**       | CSS snippets, plugins             | Lua configuration, full source    |
| **Graph View**          | Interactive, visual               | Text-based, IWE LSP               |
| **Cost**                | Free (Sync/Publish paid)          | Free, open configuration          |
| **Link Management**     | Built-in autocomplete             | IWE LSP autocomplete              |
| **Publishing**          | Obsidian Publish ($8/month)       | Free (Hugo/Quartz static site)    |
| **Semantic Formatting** | Manual                            | Automated (SemBr ML-based)        |
| **Offline Capability**  | Full (local vaults)               | Full (local-first design)         |
| **Performance (10k+)**  | Slowdown with large vaults        | Fast (LSP indexing)               |
| **Backup Strategy**     | Manual or plugin                  | Git (built-in versioning)         |
| **File Compatibility**  | Markdown (proprietary extensions) | Pure markdown (portable)          |
| **Accessibility**       | Screen reader support             | Terminal screen reader compatible |
| **Community Support**   | Large, active forums              | Smaller, developer-focused        |
| **Future-Proofing**     | Depends on Obsidian development   | Plain text, never lock-in         |

**Reality Check**: If you're unsure about leaving Obsidian's GUI, you can run both systems in parallel. Obsidian syncs via cloud, PercyBrain uses git - they won't conflict.

## Pre-Migration Checklist

### 1. Backup Your Obsidian Vault

**Critical**: Always have a backup before migration.

```bash
# Create timestamped backup
cd ~
tar -czf "obsidian-vault-backup-$(date +%Y%m%d).tar.gz" Documents/ObsidianVault

# Or use rsync for incremental backup
rsync -av ~/Documents/ObsidianVault ~/Backups/ObsidianVault-$(date +%Y%m%d)
```

**Verify Backup**:

```bash
# List backup contents
tar -tzf obsidian-vault-backup-*.tar.gz | head -20

# Check file count
find ~/Documents/ObsidianVault -type f | wc -l
# Compare to backup extraction
```

### 2. Document Your Obsidian Workflow

Before migrating, capture your current habits:

```markdown
# My Obsidian Workflow (Pre-Migration)

## Daily Routine
- Daily notes via template (hotkey: Cmd+D)
- Quick captures to "Inbox" folder
- Weekly review on Sundays

## Plugins I Use Daily
- Calendar (visual daily notes)
- Dataview (dynamic queries)
- Templater (advanced templates)
- Graph Analysis (network visualization)

## Custom Hotkeys
- Cmd+N: New note
- Cmd+O: Quick switcher
- Cmd+E: Toggle edit/preview
- Cmd+B: Bold
- Cmd+I: Italic

## Folders Structure
- 00-Inbox/
- 10-Daily/
- 20-Permanent/
- 30-Projects/
- 40-Archive/

## Linking Patterns
- [[Note Title]] for wiki links
- ![[Image.png]] for embeds
- #tag for tags
```

**Action**: Save this to `obsidian-workflow-reference.md` in your vault.

### 3. Install PercyBrain Prerequisites

**Required Software**:

```bash
# 1. Neovim (≥0.9)
nvim --version

# 2. Git (≥2.19)
git --version

# 3. IWE LSP (Rust-based markdown LSP)
cargo install iwe

# 4. SemBr (ML semantic line breaks)
uv tool install sembr
# Or: pip install sembr

# 5. Ollama (Local AI)
curl https://ollama.ai/install.sh | sh
ollama pull llama3.2

# 6. Hugo (static site generator, optional)
# macOS:
brew install hugo
# Linux:
sudo apt install hugo  # Debian/Ubuntu
# Or download from: https://gohugo.io/installation/
```

**Verify Installation**:

```bash
# Check all components
nvim --version | head -1
git --version
iwe --version
sembr --version
ollama --version
hugo version
```

**Troubleshooting**:

- **Neovim too old**: Use AppImage or compile from source
- **Cargo not found**: Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Ollama connection issues**: Ensure service running: `ollama serve &`

### 4. Set Up PercyBrain Neovim Config

**Clone PercyBrain** (or use existing Neovim config):

```bash
# Backup existing Neovim config
mv ~/.config/nvim ~/.config/nvim.backup-$(date +%Y%m%d)

# Option 1: Clone PercyBrain repo (if public)
git clone <percybrain-repo> ~/.config/nvim

# Option 2: Use this existing config
cd ~/.config/nvim
# Already configured!

# Install plugins
nvim +Lazy sync +qa

# Verify health
nvim +checkhealth
```

**First Launch Test**:

```bash
# Create test note
mkdir -p ~/Zettelkasten/inbox
nvim ~/Zettelkasten/inbox/test-note.md

# Try basic operations
# In Neovim:
# - <leader>zn (new note)
# - <leader>zf (find notes)
# - :q to quit
```

## Feature Mapping: Obsidian → PercyBrain

### Core Features Translation

| Obsidian Feature              | PercyBrain Equivalent            | Keymap / Command                 | Notes                               |
| ----------------------------- | -------------------------------- | -------------------------------- | ----------------------------------- |
| **New Note**                  | New permanent note               | `<leader>zn`                     | Template selection prompt           |
| **Daily Note**                | Open/create daily note           | `<leader>zd`                     | Auto-named with today's date        |
| **Quick Capture**             | Inbox note                       | `<leader>zi`                     | Timestamp-named fleeting note       |
| **Quick Switcher** (Cmd+O)    | Find notes (Telescope)           | `<leader>zf`                     | Fuzzy search by title               |
| **Search** (Cmd+Shift+F)      | Live grep notes                  | `<leader>zg`                     | Full-text search                    |
| **Graph View**                | IWE knowledge graph              | `:PercyGraph`                    | Generates DOT graph (text-based)    |
| **Backlinks Pane**            | Show references                  | `<leader>zb`                     | Lists all notes linking to current  |
| **Insert Link**               | Link autocomplete (IWE LSP)      | Type `[[`                        | Auto-completes existing note titles |
| **Follow Link**               | Jump to definition               | `<leader>zl` or `gd`             | Opens linked note                   |
| **Rename Note**               | Rename with link updates         | `<leader>zR`                     | IWE LSP updates all references      |
| **Outline Pane**              | Symbols outline (LSP)            | `:LSOutlineToggle`               | Shows heading structure             |
| **Tag Search**                | Browse tags (Telescope)          | `<leader>zt`                     | Tag-based filtering                 |
| **Templates**                 | Note templates                   | `~/Zettelkasten/templates/`      | Lua-based templates                 |
| **Canvas**                    | Not available                    | N/A                              | Use graph visualization tools       |
| **PDF Annotations**           | External tools                   | Use Zathura + pdfannots          | Not integrated                      |
| **Spaced Repetition**         | Not available                    | N/A                              | Use Anki with markdown export       |
| **Publish**                   | Hugo static site                 | `<leader>zp`                     | Free, self-hosted                   |
| **Calendar View**             | Calendar picker                  | `<leader>zc`                     | Navigate daily notes by date        |
| **Zen Mode**                  | Focus mode (ZenMode plugin)      | `<leader>fz`                     | Distraction-free writing            |
| **AI Chat** (cloud)           | Local AI (Ollama)                | `<leader>aq`                     | Fully private, offline              |
| **AI Summarize** (cloud)      | Local AI summarize               | `<leader>as`                     | Privacy-preserving                  |
| **Dataview Queries**          | Not available                    | Use custom Lua scripts           | Manual dynamic queries              |
| **Excalidraw**                | External drawing tools           | Use draw.io, export SVG          | Not integrated                      |
| **Kanban Board**              | Not available                    | Use plain markdown checklists    | Or external task manager            |
| **Sliding Panes**             | Vim splits                       | `:vsplit`, `:split`              | Native Neovim window management     |
| **File Explorer**             | Neovim file tree (nvim-tree)     | `<leader>e`                      | Directory tree sidebar              |
| **Starred Notes**             | Vim marks                        | `mA` (set), `'A` (goto)          | Capital letters for global marks    |
| **Recent Files**              | Telescope oldfiles               | `<leader>fr`                     | Recently opened files               |
| **Command Palette** (Cmd+P)   | Telescope commands               | `<leader>fc`                     | Searchable command list             |
| **Reading View**              | Markdown preview                 | `:MarkdownPreview`               | Browser-based preview               |
| **Sync**                      | Git sync                         | `git push` / `git pull`          | Version control, not cloud sync     |
| **Community Plugins**         | Lua plugins / configurations     | `lua/plugins/*.lua`              | Write your own or find on GitHub    |
| **Theme Switching**           | Neovim colorschemes              | `:colorscheme tokyonight`        | 100+ terminal themes                |
| **Workspace Switching**       | Vim sessions                     | `:mksession`, `:source`          | Save/restore editor state           |
| **Hotkey Customization**      | Neovim keymaps                   | Edit `lua/config/keymaps.lua`    | Full Lua configuration              |
| **Mobile App**                | Termux (Android only)            | Termux + Neovim                  | Terminal-based, no iOS              |
| **Web Clipper**               | Not available                    | Manual markdown import           | Or build custom script              |
| **Version History** (plugin)  | Git log                          | `git log -- file.md`             | Full version control built-in       |
| **Folder Notes**              | Index notes                      | Create `index.md` in folder      | Manual organization                 |
| **Aliases**                   | Frontmatter `aliases: [...]`     | YAML frontmatter                 | IWE LSP supports alias linking      |
| **Metadata YAML**             | Frontmatter (same format)        | YAML frontmatter                 | 100% compatible                     |
| **Task Management** (plugin)  | Markdown checklists              | `- [ ]` syntax                   | No advanced task queries            |
| **Flashcards** (plugin)       | External (Anki)                  | Export to Anki                   | Not integrated                      |
| **Export to PDF**             | Pandoc                           | `pandoc file.md -o file.pdf`     | Command-line export                 |
| **Auto-linking**              | IWE LSP autocomplete             | Type `[[` for suggestions        | Smart title matching                |
| **Unlinked Mentions**         | Search + IWE backlinks           | `<leader>zg` + manual check      | Not automated                       |
| **Fold Headings**             | Neovim folding                   | `za` (toggle fold)               | Native Vim folding                  |
| **Code Syntax Highlighting**  | Treesitter                       | Automatic                        | Better than Obsidian for code       |
| **Mermaid Diagrams**          | External rendering               | Use mermaid-cli                  | Not in-editor                       |
| **Table Editor**              | Manual or markdown-table plugins | `Tabularize` plugin              | Less automated than Obsidian        |
| **Live Preview**              | MarkdownPreview plugin           | `:MarkdownPreview`               | Browser-based, not inline           |
| **Custom CSS**                | Terminal colorschemes            | `.config/nvim/colors/`           | Lua-based styling                   |
| **YAML Queries** (Dataview)   | Manual scripting                 | Write custom Lua                 | No query language                   |
| **Bookmarks**                 | Vim marks + harpoon              | `m[a-z]`, `:Harpoon`             | Local/global marks                  |
| **Properties Panel**          | Edit frontmatter manually        | YAML block at top                | No GUI editor                       |
| **Citations** (plugin)        | Pandoc-citeproc                  | `[@citation]` syntax             | Academic citation support           |
| **Slides** (plugin)           | Pandoc reveal.js                 | `pandoc -t revealjs`             | Export to slides                    |
| **Attachments Folder**        | `~/Zettelkasten/assets/`         | Configure in templates           | Manual organization                 |
| **Local REST API** (plugin)   | Not available                    | Build custom                     | No plugin API                       |
| **Customizable Ribbons**      | Status line / which-key          | Configure `lualine`, `which-key` | Terminal UI customization           |
| **File Recovery**             | Neovim swap files + git          | Automatic swap files             | Plus git history                    |
| **Smart Typography** (plugin) | Auto-format plugins              | SemBr (semantic line breaks)     | ML-based formatting                 |
| **Dictionary/Thesaurus**      | External tools                   | `:!dict word`                    | Command-line integration            |
| **Audio Recording**           | External (Audacity, etc.)        | Not integrated                   | Save to assets folder               |
| **Emoji Picker** (plugin)     | Insert mode completion           | Emoji autocomplete plugin        | Or type Unicode directly            |
| **Git Diff View** (plugin)    | Native git integration           | `git diff`, fugitive plugin      | Better than Obsidian plugin         |
| **Paste URL as Link**         | Manual formatting                | Write custom keymap              | No auto-detection                   |
| **Breadcrumbs**               | Not available                    | Use Outline or file path         | No breadcrumb UI                    |
| **Multi-cursor** (plugin)     | Vim multi-cursor                 | `<C-n>` (visual multi)           | Native Vim capability               |
| **Vim Mode** (plugin)         | Native Neovim                    | Everything                       | Full Vim, not emulation             |

### Missing Features (Honest Assessment)

**Not Available in PercyBrain**:

01. **Interactive Graph View**: Text-based graph only, no GUI exploration
02. **Canvas/Whiteboard**: No infinite canvas for visual organization
03. **Mobile Apps**: No iOS, limited Android (Termux)
04. **Dataview Dynamic Queries**: No embedded code blocks generating tables
05. **Drag-and-Drop**: All file operations via keyboard/commands
06. **Plugin Marketplace**: No centralized plugin discovery
07. **WYSIWYG Editing**: Markdown source only, no live preview rendering
08. **Collaboration**: No real-time co-editing (use git for async)
09. **Web Clipper**: No browser extension for quick capture
10. **Spaced Repetition**: No built-in SRS (use Anki separately)

**Workarounds Available**:

- **Graph View**: Use `graphviz` to render IWE graph as PNG
- **Mobile**: Termux on Android, SSH to desktop, or parallel Obsidian vault
- **Dataview**: Write custom Lua scripts for dynamic content
- **Plugin Discovery**: Browse GitHub Neovim plugin repos
- **Collaboration**: Git-based async collaboration works well

## Migration Workflow

### Phase 1: Copy Your Vault (30 minutes)

**Goal**: Get your notes into PercyBrain's expected directory structure.

#### Step 1: Create Zettelkasten Directory

```bash
# Create PercyBrain directory structure
mkdir -p ~/Zettelkasten/{inbox,daily,permanent,templates,assets,archive}

# Verify structure
tree -L 1 ~/Zettelkasten
```

#### Step 2: Analyze Obsidian Vault Structure

```bash
# Navigate to your Obsidian vault
cd ~/Documents/ObsidianVault

# Count files by type
find . -name "*.md" | wc -l       # Total markdown files
find . -name "*.png" | wc -l      # Images
find . -name "*.pdf" | wc -l      # PDFs

# List top-level folders
ls -1d */
```

**Example Obsidian Vault**:

```
ObsidianVault/
├── 00-Inbox/         (fleeting notes)
├── 10-Daily/         (daily notes)
├── 20-Areas/         (topic folders)
├── 30-Projects/      (active projects)
├── 40-Archive/       (completed work)
├── _attachments/     (images, PDFs)
└── _templates/       (note templates)
```

#### Step 3: Map Folders to PercyBrain Structure

**Folder Mapping Strategy**:

| Obsidian Folder      | PercyBrain Destination      | Rationale                          |
| -------------------- | --------------------------- | ---------------------------------- |
| `00-Inbox/`          | `~/Zettelkasten/inbox/`     | Direct mapping (fleeting notes)    |
| `10-Daily/`          | `~/Zettelkasten/daily/`     | Direct mapping (daily notes)       |
| `20-Areas/` (mature) | `~/Zettelkasten/permanent/` | Processed, permanent notes         |
| `20-Areas/` (WIP)    | `~/Zettelkasten/inbox/`     | Work-in-progress notes             |
| `30-Projects/`       | `~/Zettelkasten/permanent/` | Move to root (tag with `#project`) |
| `40-Archive/`        | `~/Zettelkasten/archive/`   | Direct mapping (completed work)    |
| `_attachments/`      | `~/Zettelkasten/assets/`    | Images, PDFs, media                |
| `_templates/`        | `~/Zettelkasten/templates/` | Note templates                     |

**Adaptation Note**: Obsidian's folder-first structure → PercyBrain's tag-and-link structure. You'll flatten hierarchy, add tags.

#### Step 4: Copy Files

```bash
# Copy vault to PercyBrain (preserving structure temporarily)
rsync -av ~/Documents/ObsidianVault/ ~/Zettelkasten-migration/

# Move files to correct PercyBrain locations
cd ~/Zettelkasten-migration

# Inbox notes
mv 00-Inbox/*.md ~/Zettelkasten/inbox/ 2>/dev/null || true

# Daily notes
mv 10-Daily/*.md ~/Zettelkasten/daily/ 2>/dev/null || true

# Permanent notes (from Areas and Projects)
find 20-Areas 30-Projects -name "*.md" -exec mv {} ~/Zettelkasten/permanent/ \; 2>/dev/null || true

# Archive
mv 40-Archive/*.md ~/Zettelkasten/archive/ 2>/dev/null || true

# Assets (images, PDFs, etc.)
mv _attachments/* ~/Zettelkasten/assets/ 2>/dev/null || true

# Templates
mv _templates/*.md ~/Zettelkasten/templates/ 2>/dev/null || true
```

**Verify Copy**:

```bash
# Compare file counts
find ~/Documents/ObsidianVault -name "*.md" | wc -l
find ~/Zettelkasten -name "*.md" | wc -l

# Should match (or Zettelkasten slightly more if you had nested folders)
```

#### Step 5: Handle Special Cases

**Nested Folders** (Obsidian supports, PercyBrain flat):

```bash
# Find deeply nested notes
find ~/Zettelkasten-migration -name "*.md" -type f

# Flatten to permanent/
find ~/Zettelkasten-migration -name "*.md" -exec mv {} ~/Zettelkasten/permanent/ \;

# Add folder context to frontmatter later (see Link Conversion)
```

**Duplicate Filenames**:

```bash
# Find duplicates
find ~/Zettelkasten -name "*.md" | xargs basename -a | sort | uniq -d

# Rename manually with unique identifiers:
mv ~/Zettelkasten/permanent/notes.md ~/Zettelkasten/permanent/notes-topic-a.md
```

### Phase 2: Link Conversion (45 minutes)

**Goal**: Ensure Obsidian wiki-links work in PercyBrain's IWE LSP.

**Good News**: Both use `[[wiki-link]]` syntax! Most links work unchanged.

**Exceptions to Convert**:

#### 1. Folder Paths in Links

**Obsidian** (supports folder paths):

```markdown
[[20-Areas/Cognitive Science/Distributed Cognition]]
```

**PercyBrain** (flat namespace, use unique titles):

```markdown
[[Distributed Cognition]]
```

**Conversion Script**:

```bash
#!/bin/bash
# remove-folder-paths-from-links.sh

# Find all markdown files
find ~/Zettelkasten -name "*.md" -type f | while read file; do
  # Remove folder paths from wiki links
  sed -i.bak 's|\[\[\([^]]*\)/\([^]]*\)\]\]|[[\2]]|g' "$file"
  # Example: [[Folder/Note]] → [[Note]]
done

echo "Converted links. Backups in *.bak files"
```

**Run Conversion**:

```bash
chmod +x remove-folder-paths-from-links.sh
./remove-folder-paths-from-links.sh

# Verify changes
diff ~/Zettelkasten/permanent/some-note.md.bak ~/Zettelkasten/permanent/some-note.md
```

#### 2. Block References

**Obsidian** (block references):

```markdown
[[Note#^block-id]]
```

**PercyBrain**: Not supported by IWE LSP.

**Workaround**: Link to note, add context:

```markdown
See [[Note]] (specifically the section on distributed cognition)
```

**Find Block References**:

```bash
# Find files with block references
grep -r '\[\[[^]]*#\^' ~/Zettelkasten

# Convert manually (no automated solution)
```

#### 3. Heading Links

**Obsidian** (heading links):

```markdown
[[Note#Heading]]
```

**PercyBrain**: IWE LSP supports heading links!

```markdown
[[Note#Heading]]  # Works in PercyBrain
```

**No conversion needed** for heading links.

#### 4. Aliases

**Obsidian**:

```markdown
[[Note|Display Text]]
```

**PercyBrain**: IWE LSP supports pipe syntax.

```markdown
[[Note|Display Text]]  # Works in PercyBrain
```

**No conversion needed** for aliases.

#### 5. Embeds

**Obsidian** (transclusion):

```markdown
![[Note]]
![[Image.png]]
```

**PercyBrain**: Embeds not rendered in terminal, but syntax preserved.

**Behavior**:

- `![[Note]]` → Shows as link (content not embedded)
- `![[Image.png]]` → Shows as link (image not displayed inline)

**Workaround**: Images render in `:MarkdownPreview` (browser preview).

**No conversion needed**, but note functionality difference.

### Phase 3: Frontmatter Normalization (30 minutes)

**Goal**: Ensure YAML frontmatter is PercyBrain-compatible.

**Good News**: PercyBrain uses same YAML format as Obsidian!

**Check Frontmatter**:

```bash
# View frontmatter from random note
head -20 ~/Zettelkasten/permanent/*.md | grep -A 10 "^---$"
```

#### Obsidian → PercyBrain Frontmatter Mapping

| Obsidian Field | PercyBrain Equivalent | Status        | Notes                        |
| -------------- | --------------------- | ------------- | ---------------------------- |
| `title`        | `title`               | ✅ Compatible | Same                         |
| `tags`         | `tags`                | ✅ Compatible | Same YAML array format       |
| `aliases`      | `aliases`             | ✅ Compatible | IWE LSP supports             |
| `cssclass`     | N/A                   | ❌ Ignored    | Remove or keep (no effect)   |
| `publish`      | N/A                   | ❌ Ignored    | Use Hugo frontmatter instead |
| `date`         | `date`                | ✅ Compatible | ISO format: YYYY-MM-DD HH:MM |
| `created`      | `date`                | ✅ Convert    | Rename to `date`             |
| `modified`     | N/A                   | ❌ Ignored    | Git tracks modification      |
| Custom fields  | Custom fields         | ✅ Compatible | All valid YAML preserved     |

#### Recommended PercyBrain Frontmatter

**Minimal Required**:

```yaml
---
title: Note Title
date: 2025-10-19
tags: [topic, concept]
---
```

**Enhanced (Optional)**:

```yaml
---
title: Note Title
date: 2025-10-19 14:30
tags: [topic, concept, question]
source: Book/Paper/Conversation
status: developing  # seedling, developing, stable, evergreen
confidence: medium  # low, medium, high
---
```

#### Bulk Frontmatter Cleanup

**Remove Obsidian-Specific Fields**:

```bash
#!/bin/bash
# cleanup-frontmatter.sh

find ~/Zettelkasten -name "*.md" -type f | while read file; do
  # Remove cssclass, publish, modified fields
  sed -i.bak '/^cssclass:/d; /^publish:/d; /^modified:/d' "$file"

  # Rename 'created' to 'date' if present
  sed -i 's/^created:/date:/' "$file"
done

echo "Cleaned frontmatter. Backups in *.bak"
```

**Run Cleanup**:

```bash
chmod +x cleanup-frontmatter.sh
./cleanup-frontmatter.sh

# Review changes
diff ~/Zettelkasten/permanent/note.md.bak ~/Zettelkasten/permanent/note.md
```

### Phase 4: Git Initialization (15 minutes)

**Goal**: Version control your Zettelkasten for backup and history.

**Obsidian Git Plugin** → **Native Git**

```bash
# Navigate to Zettelkasten
cd ~/Zettelkasten

# Initialize repository
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Neovim swap files
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.bak

# Large binary files (optional, keep images if small)
# *.png
# *.jpg
# *.pdf
EOF

# Initial commit
git add -A
git commit -m "Initial migration from Obsidian - $(date +%Y-%m-%d)"

# Tag migration point
git tag obsidian-migration

# View status
git status
git log --oneline
```

**Remote Backup** (optional):

```bash
# Create private GitHub repo, then:
git remote add origin git@github.com:yourusername/zettelkasten.git
git branch -M main
git push -u origin main --tags

# Future syncs
git push   # Upload changes
git pull   # Download changes
```

**Git Workflow**:

```bash
# Daily commits (manual or cron job)
cd ~/Zettelkasten
git add -A
git commit -m "Daily backup: $(date +%Y-%m-%d)"
git push

# Weekly review commits
git commit -m "Weekly review: strengthened connections in cognitive systems"

# Monthly snapshot
git tag monthly-$(date +%Y-%m)
git push --tags
```

### Phase 5: Workflow Adaptation (1-2 weeks)

**Goal**: Learn PercyBrain keybindings and adapt your Obsidian habits.

#### Day 1-2: Basic Navigation

**Practice Tasks**:

```vim
" Open Neovim
nvim ~/Zettelkasten

" Learn essential keymaps (in any .md file):
<leader>zf    " Find notes (like Obsidian Quick Switcher)
<leader>zg    " Search content (like Obsidian Search)
<leader>zb    " Backlinks (like Obsidian Backlinks pane)
<leader>zn    " New note (like Obsidian Cmd+N)
<leader>zd    " Daily note (like Obsidian Daily Note)
<leader>zi    " Quick inbox capture

" Basic Vim navigation (if new to Vim):
h j k l       " Left, Down, Up, Right
w b           " Next word, previous word
gg G          " Top of file, bottom of file
/ <search>    " Search forward
? <search>    " Search backward
n N           " Next match, previous match
:q            " Quit
:w            " Save
:wq           " Save and quit
```

**Goal**: Navigate notes without mouse.

#### Day 3-4: Link Creation

**Practice Tasks**:

```markdown
1. Open permanent note:
   <leader>zf → select note → Enter

2. Add link:
   Type: [[
   IWE LSP autocompletes note titles
   Select from list, press Enter

3. Follow link:
   Cursor on [[note-title]]
   Press: <leader>zl (or gd)
   Opens linked note

4. Jump back:
   Press: <C-o> (Ctrl+O)
   Returns to previous location

5. View backlinks:
   <leader>zb
   See all notes linking to current note

6. Create new linked note:
   Type: [[New Note Title]]
   IWE LSP creates note when you follow link
```

**Goal**: Comfortable with wiki-link workflow.

#### Day 5-7: Capture and Process

**Morning Routine**:

```vim
" 1. Open daily note
<leader>zd

" 2. Write intentions
# 2025-10-19
## Intentions
Exploring distributed cognition today...

" 3. Save
:w
```

**During Day** (quick captures):

```vim
" From any buffer
<leader>zi

" Types inbox note, writes thought, saves
:w

" Back to work
<C-o>
```

**Evening Processing**:

```vim
" 1. List inbox notes
<leader>zf → type: inbox/ → browse

" 2. For each fleeting note:
"    - Read content
"    - Decide: keep or delete
"    - If keep: <leader>zn → create permanent note
"    - Add links to related notes: [[
"    - Delete fleeting note

" 3. Review today's daily note
<leader>zd

" 4. Commit changes
:!git add -A && git commit -m "Evening processing: $(date +%Y-%m-%d)"
```

**Goal**: Establish daily capture → process rhythm.

#### Week 2: Advanced Features

**AI Integration**:

```vim
" Open literature note with dense text
nvim ~/Zettelkasten/permanent/literature-note.md

" Select paragraph (visual mode)
V   (shift-v for line-visual)
j j j   (extend selection)

" Summarize
<leader>as
" Floating window shows summary

" Explain jargon
<leader>ae
" Floating window shows explanation

" Suggest connections
<leader>al
" AI suggests related topics

" Interactive Q&A
<leader>aq
" Type question, AI answers
```

**Publishing Setup**:

```bash
# Create Hugo site (one-time setup)
cd ~/blog
hugo new site . --force

# Add theme
git submodule add https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
echo "theme = 'PaperMod'" >> config.toml

# Test publish from Neovim
nvim ~/Zettelkasten/permanent/note-to-publish.md
# Add to frontmatter: publish: true
<leader>zp   # Publish workflow

# Preview site
<leader>zP   # Opens localhost:1313
```

**Goal**: Use AI and publishing workflows.

### Phase 6: Parallel Operation (Optional, 2-4 weeks)

**Goal**: Run Obsidian and PercyBrain in parallel during transition.

**Strategy**:

1. **Obsidian**: Mobile access, GUI tasks, familiar workflows
2. **PercyBrain**: Desktop writing, terminal integration, AI features

**Sync Strategy**:

```bash
# Obsidian vault: ~/Documents/ObsidianVault (synced via Obsidian Sync/iCloud)
# PercyBrain vault: ~/Zettelkasten (synced via git)

# One-way sync: PercyBrain → Obsidian (manual)
rsync -av --exclude='.git' ~/Zettelkasten/ ~/Documents/ObsidianVault/

# Or: Two-way sync (advanced, requires conflict resolution)
# Use git + Obsidian Git plugin, same repository
```

**Gradual Transition**:

- **Week 1-2**: 80% Obsidian, 20% PercyBrain (learning phase)
- **Week 3-4**: 50/50 split (adapting workflows)
- **Week 5-6**: 20% Obsidian (mobile only), 80% PercyBrain
- **Week 7+**: 100% PercyBrain, Obsidian for mobile if needed

## Customization Guide

### Keybindings (Match Obsidian Habits)

**Edit Keymaps** (`~/.config/nvim/lua/config/keymaps.lua`):

```lua
-- Example: Map Cmd+N to new note (Mac users with Karabiner)
vim.keymap.set('n', '<D-n>', '<leader>zn', { desc = "New note" })

-- Quick switcher (Cmd+O behavior)
vim.keymap.set('n', '<D-o>', '<leader>zf', { desc = "Quick switcher" })

-- Search (Cmd+Shift+F behavior)
vim.keymap.set('n', '<D-S-f>', '<leader>zg', { desc = "Search in vault" })

-- Bold (Cmd+B)
vim.keymap.set('v', '<D-b>', 'c**<C-r>"**<Esc>', { desc = "Bold selection" })

-- Italic (Cmd+I)
vim.keymap.set('v', '<D-i>', 'c*<C-r>"*<Esc>', { desc = "Italic selection" })
```

**Note**: Terminal Neovim may not receive Cmd/Alt keys. Use Karabiner (Mac) or similar key remapping.

### Templates

**Edit Templates** (`~/Zettelkasten/templates/`):

**Daily Note Template** (`daily.md`):

```markdown
---
title: Daily Note {{date}}
date: {{date}}
tags: [daily]
---

# {{date}}

## Intentions

What am I exploring today?

## Captures

## Reflections

What surprised me? What connections emerged?
```

**Permanent Note Template** (`note.md`):

```markdown
---
title: {{title}}
date: {{date}}
tags: []
source:
status: seedling
---

# {{title}}

## Context

Where does this idea come from?

## Main Idea

[Your synthesis in your own words]

## Connections

- [[related-note-1]]
- [[related-note-2]]

## Questions

What questions does this raise?

## References
```

**Use Templates**:

```vim
<leader>zn   " Prompts for template selection
" Select: permanent, daily, literature, etc.
```

### Directory Structure (Match Your Workflow)

**Customize** (`~/.config/nvim/lua/config/zettelkasten.lua`):

```lua
-- Default structure
M.config = {
  root = vim.fn.expand("~/Zettelkasten"),
  inbox = "inbox",
  daily = "daily",
  permanent = "permanent",
  templates = "templates",
  assets = "assets",
  archive = "archive",
}

-- Custom structure (e.g., Obsidian's numbering)
M.config = {
  root = vim.fn.expand("~/Zettelkasten"),
  inbox = "00-Inbox",
  daily = "10-Daily",
  permanent = "20-Permanent",
  templates = "_templates",
  assets = "_attachments",
  archive = "40-Archive",
}
```

**Reload Config**:

```vim
:source ~/.config/nvim/lua/config/zettelkasten.lua
```

## Troubleshooting

### "Links don't autocomplete"

**Symptoms**: Typing `[[` doesn't show note suggestions.

**Solutions**:

```bash
# Check IWE LSP is running
:LspInfo
# Should show "iwe" as active client

# Restart LSP
:LspRestart

# Check IWE installation
which iwe
iwe --version

# Reinitialize IWE workspace
cd ~/Zettelkasten
iwe init
```

### "Can't find notes with Quick Switcher"

**Symptoms**: `<leader>zf` shows no results or old notes.

**Solutions**:

```vim
" Check Telescope configuration
:checkhealth telescope

" Rebuild file index
:Telescope find_files

" Verify search path
:lua print(vim.fn.expand("~/Zettelkasten"))
" Should output your Zettelkasten directory
```

### "Images don't display"

**Reality**: Terminal Neovim doesn't render images inline (unlike Obsidian GUI).

**Workarounds**:

```vim
" 1. Markdown Preview (browser-based)
:MarkdownPreview
" Opens HTML preview with images

" 2. External image viewer
:!open ~/Zettelkasten/assets/image.png   " macOS
:!xdg-open ~/Zettelkasten/assets/image.png   " Linux

" 3. Terminal image viewer (limited support)
:!kitty +kitten icat ~/Zettelkasten/assets/image.png   " Kitty terminal
```

**Alternative**: Use Obsidian for image-heavy notes, PercyBrain for text.

### "Vim motions are confusing"

**Learning Curve**: Vim has steep initial learning curve.

**Resources**:

```bash
# Interactive Vim tutorial (built-in)
vimtutor

# Practice basic motions
nvim ~/practice.txt
# Spend 30 minutes/day for 1 week
```

**Quick Reference**:

```
Movement:  h j k l (left, down, up, right)
           w b (next word, back word)
           0 $ (start of line, end of line)
           gg G (top of file, bottom of file)

Editing:   i (insert before cursor)
           a (append after cursor)
           o (open new line below)
           O (open new line above)
           x (delete character)
           dd (delete line)
           yy (yank/copy line)
           p (paste)

Visual:    v (character visual)
           V (line visual)
           <C-v> (block visual)

Search:    / (search forward)
           ? (search backward)
           n N (next, previous match)

Save/Quit: :w (write/save)
           :q (quit)
           :wq (save and quit)
           :q! (quit without saving)
```

**Fallback**: If Vim too steep, use Obsidian until comfortable.

### "Git workflow unclear"

**Obsidian Git Plugin** provided GUI, PercyBrain uses command-line.

**Simple Workflow**:

```bash
# Daily backup
cd ~/Zettelkasten
git add -A
git commit -m "Daily backup: $(date +%Y-%m-%d)"
git push   # If using remote

# Review changes
git status   # What changed?
git diff     # Show changes

# View history
git log --oneline
git log --oneline --graph

# Undo last commit (if mistake)
git reset --soft HEAD~1
```

**Automation** (cron job for daily commits):

```bash
# Add to crontab
crontab -e

# Add line (runs daily at 11 PM)
0 23 * * * cd ~/Zettelkasten && git add -A && git commit -m "Auto backup: $(date +\%Y-\%m-\%d)" && git push
```

### "Mobile access needed"

**Reality**: No native mobile apps for PercyBrain.

**Options**:

1. **Termux (Android)**:

```bash
# Install Termux from F-Droid
# In Termux:
pkg install neovim git
git clone <your-zettelkasten-repo>
nvim ~/Zettelkasten/note.md
```

2. **SSH to Desktop**:

```bash
# From mobile terminal app (Termux, iSH)
ssh user@desktop-ip
cd ~/Zettelkasten
nvim note.md
```

3. **Parallel Obsidian Mobile**:

```bash
# Keep Obsidian for mobile captures
# Sync to PercyBrain periodically:
rsync -av ~/ObsidianVault/ ~/Zettelkasten/
```

4. **Gitea/GitHub Web Interface**:

```bash
# View/edit notes via git web UI
# Limited, but works for simple edits
```

**Recommendation**: If mobile crucial, keep Obsidian for mobile, PercyBrain for desktop.

## Success Checklist

### Week 1 Goals

- [ ] All notes copied to `~/Zettelkasten`
- [ ] Links work (test 10+ notes with `<leader>zl`)
- [ ] Backlinks show correctly (`<leader>zb`)
- [ ] IWE LSP autocomplete functional (type `[[`)
- [ ] Git initialized with initial commit
- [ ] Daily note workflow established (`<leader>zd`)
- [ ] Comfortable with basic Vim motions (h j k l, i, Esc, :wq)

### Week 2 Goals

- [ ] Inbox capture → process workflow (5+ notes processed)
- [ ] Created 3+ permanent notes from fleeting notes
- [ ] Linked 10+ notes with context (not bare links)
- [ ] Used search effectively (`<leader>zg`)
- [ ] Tried AI features (summarize, explain, suggest links)
- [ ] Git daily commits (7 days of commits)
- [ ] No need to open Obsidian for basic tasks

### Month 1 Goals

- [ ] Processed 50+ inbox notes → permanent notes
- [ ] Created 20+ new permanent notes
- [ ] Established weekly review habit (Sundays)
- [ ] Hub notes created for major topics
- [ ] Publishing workflow tested (if applicable)
- [ ] Comfortable with all essential keybindings
- [ ] Obsidian usage \<20% (mobile only or rare GUI tasks)

### Success Indicators

**You've Successfully Migrated When**:

- ✅ Thinking in PercyBrain keybindings (muscle memory)
- ✅ Notes feel more connected (backlinks revealing surprises)
- ✅ Writing faster (Vim motions + AI assist)
- ✅ Git provides confidence (version history safety)
- ✅ Terminal workflow integrated (notes + code in one place)
- ✅ Privacy feels good (local AI, no cloud)
- ✅ Don't miss Obsidian GUI (or only for mobile)

## Long-term Workflow Integration

### Git Best Practices

**Commit Message Strategy**:

```bash
# Daily commits
git commit -m "Daily work: 5 new notes on distributed cognition"

# Weekly reviews
git commit -m "Weekly review: linked 12 orphan notes, created cognitive-systems hub"

# Monthly snapshots
git commit -m "Monthly synthesis: October 2025 - focus on feedback loops"
git tag monthly-2025-10
```

**Branching for Experiments**:

```bash
# Try new organization strategy
git checkout -b experiment/tag-restructure

# Make changes, test for 1 week

# If successful:
git checkout main
git merge experiment/tag-restructure

# If failed:
git checkout main
git branch -D experiment/tag-restructure
```

### Terminal Integration

**PercyBrain in Tmux/Screen**:

```bash
# Create dedicated Zettelkasten session
tmux new-session -s zettel

# Window 1: Neovim editing
nvim ~/Zettelkasten

# Window 2: Git/command-line
# Ctrl+B C (create new window)
cd ~/Zettelkasten
git status

# Window 3: Ollama monitoring
# Ctrl+B C
ollama list

# Switch windows: Ctrl+B <number>
# Detach: Ctrl+B D
# Reattach: tmux attach -t zettel
```

**Aliases for Speed** (`~/.bashrc` or `~/.zshrc`):

```bash
# Zettelkasten shortcuts
alias zk='cd ~/Zettelkasten'
alias zkn='nvim ~/Zettelkasten'
alias zkd='nvim ~/Zettelkasten/daily/$(date +%Y-%m-%d).md'
alias zki='nvim ~/Zettelkasten/inbox/$(date +%Y%m%d%H%M%S).md'
alias zkg='cd ~/Zettelkasten && git add -A && git commit -m "Quick save: $(date)" && git push'
alias zks='cd ~/Zettelkasten && git status'
alias zkl='cd ~/Zettelkasten && git log --oneline --graph'
```

### Obsidian Feature Replacements

**Dataview Alternative** (dynamic note lists):

```bash
# Create Lua script: ~/Zettelkasten/scripts/list-by-tag.lua

#!/usr/bin/env lua
-- Usage: lua list-by-tag.lua cognition

local tag = arg[1] or "untagged"
local notes_dir = os.getenv("HOME") .. "/Zettelkasten/permanent"

for file in io.popen("find " .. notes_dir .. " -name '*.md'"):lines() do
  local f = io.open(file, "r")
  local content = f:read("*a")
  f:close()

  if content:match("tags:.*" .. tag) then
    local title = file:match("([^/]+)%.md$")
    print("- [[" .. title .. "]]")
  end
end
```

**Usage**:

```bash
# List all notes tagged "cognition"
lua ~/Zettelkasten/scripts/list-by-tag.lua cognition

# Or integrate into Neovim command
:!lua ~/Zettelkasten/scripts/list-by-tag.lua cognition
```

**Kanban Alternative**:

```markdown
# Project: Writing Paper

## Todo
- [ ] Outline introduction
- [ ] Research distributed cognition papers
- [ ] Draft methodology section

## In Progress
- [x] Literature review (started 2025-10-15)

## Done
- [x] Topic selection
- [x] Advisor approval
```

**Use Neovim for Task Management**:

```vim
" Toggle checkbox
:s/\[ \]/\[x\]/   " Mark complete
:s/\[x\]/\[ \]/   " Mark incomplete

" Or use plugin: bullets.vim
```

## Resources and Community

### Learning Neovim

- **Interactive Tutorial**: `vimtutor` (built-in, 30 minutes)
- **Neovim Docs**: `:help` (comprehensive built-in documentation)
- **Video**: "Vim Tutorial for Beginners" (YouTube, search for recent)
- **Book**: "Practical Vim" by Drew Neil
- **Website**: [neovim.io](https://neovim.io)

### PercyBrain Documentation

- **Getting Started**: `/home/percy/.config/nvim/docs/tutorials/GETTING_STARTED.md`
- **Zettelkasten Workflow**: `/home/percy/.config/nvim/docs/how-to/ZETTELKASTEN_WORKFLOW.md`
- **AI Usage Guide**: `/home/percy/.config/nvim/docs/how-to/AI_USAGE_GUIDE.md`
- **System Design**: `/home/percy/.config/nvim/PERCYBRAIN_DESIGN.md`
- **Quick Reference**: `/home/percy/.config/nvim/QUICK_REFERENCE.md`

### Zettelkasten Method

- **Book**: "How to Take Smart Notes" by Sönke Ahrens
- **Website**: [zettelkasten.de](https://zettelkasten.de)
- **Community**: r/Zettelkasten (Reddit)

### Git for Note-Taking

- **Git Basics**: [git-scm.com/book](https://git-scm.com/book)
- **Pro Git Book**: Free online
- **GitHub Learning Lab**: [lab.github.com](https://lab.github.com)

### Obsidian to Neovim Stories

- **Reddit**: r/neovim (search "obsidian migration")
- **Blog Posts**: Search "switching from obsidian to neovim" (personal experiences)
- **Discussions**: Neovim Discourse forums

## Next Steps

### After Migration Complete

**1. Deep Dive into Features**:

- Read `ZETTELKASTEN_WORKFLOW.md` for advanced techniques
- Explore AI commands (`AI_USAGE_GUIDE.md`)
- Set up publishing if desired

**2. Customize Your Setup**:

- Refine keybindings to match habits
- Create custom templates
- Write Lua scripts for repetitive tasks

**3. Optimize Workflow**:

- Track time savings vs Obsidian
- Identify remaining pain points
- Adapt workflow to strengths (terminal, git, AI)

**4. Share Experience**:

- Document your migration journey
- Contribute workflow improvements
- Help others migrate

### Keeping Perspective

**Migration Reality Check**:

- **Week 1**: Frustrating (everything's different)
- **Week 2**: Progress (muscle memory building)
- **Month 1**: Comfortable (workflow established)
- **Month 3**: Fluent (faster than Obsidian)

**It's OK If**:

- You use Obsidian mobile alongside PercyBrain desktop
- You miss Obsidian's graph view (use IWE graph as supplement)
- You keep a few notes in Obsidian for GUI tasks (images, etc.)

**The Goal**: Not 100% replacement, but **better fit for your needs**.

PercyBrain excels at:

- Terminal integration
- Privacy (local AI)
- Git versioning
- Speed and control

Obsidian excels at:

- Mobile apps
- GUI-first workflow
- Plugin ecosystem
- Beginner-friendliness

**Choose the right tool for each context.** There's no rule against using both.

## Final Migration Checklist

- [ ] Vault backup created
- [ ] PercyBrain installed and healthy (`:checkhealth`)
- [ ] Notes copied to `~/Zettelkasten`
- [ ] Links converted (folder paths removed)
- [ ] Frontmatter normalized
- [ ] Git initialized with initial commit
- [ ] IWE LSP working (autocomplete test)
- [ ] Basic keybindings memorized (zn, zd, zi, zf, zg, zb)
- [ ] Daily workflow established (capture → process)
- [ ] AI features tested (summarize, explain, links)
- [ ] Remote git backup configured (optional)
- [ ] Mobile strategy decided (Termux, SSH, or parallel Obsidian)
- [ ] Week 1 success criteria met
- [ ] Documentation bookmarked for reference

**You've got this.** The learning curve is steep, but the terminal-native, privacy-first workflow is worth it. Welcome to PercyBrain. 🧠⚡
