---
title: Publishing Zettelkasten with Quartz
category: how-to
tags:
  - publishing
  - quartz
  - zettelkasten
  - workflow
last_reviewed: 2025-10-23
---

# Publishing Zettelkasten with Quartz

**Category**: How-to Guide (Diataxis) **Audience**: PercyBrain users who want to publish their Zettelkasten online **Time**: 10 minutes setup, 2 minutes per publish

## Overview

This guide shows you how to publish your PercyBrain Zettelkasten as a static website using Quartz.

**What you get**:

- Beautiful static website of your notes
- Automatic backlinks and graph view
- Full-text search
- Tag pages
- RSS feed
- Mobile-friendly responsive design

## Prerequisites

- PercyBrain configured with `~/Zettelkasten/`
- Node.js installed (for `npx`)
- Quartz project cloned to `~/projects/quartz/`

## Phase 1: MVP Setup (Completed)

### 1. Create Symlink

The Quartz `content/` directory is a symlink to your Zettelkasten:

```bash
cd ~/projects/quartz
rm -rf content  # Remove default content
ln -s ~/Zettelkasten content  # Symlink to your notes
```

**Benefits**:

- Single source of truth
- No duplication
- Edits in Neovim appear immediately in builds

### 2. Configure Quartz

File: `~/projects/quartz/quartz.config.ts`

Key settings:

```typescript
configuration: {
  pageTitle: "PercyBrain Knowledge Base",
  enableSPA: true,
  enablePopovers: true,
  analytics: null,  // No tracking
  ignorePatterns: [".iwe", ".git", "private", "ai"],  // Don't publish these
}
```

**Important**: The `.iwe` directory must be in `ignorePatterns` to avoid publishing LSP metadata.

### 3. Frontmatter Compatibility

IWE's frontmatter template works as-is with Quartz:

```yaml
---
title: Note Title
date: 2025-10-23
tags:
  - tag1
  - tag2
---
```

**Critical**: Use spaces, not tabs, for YAML indentation. The IWE template (as of 2025-10-23) correctly uses spaces.

### 4. Fix Existing Notes (One-time)

If you have older notes with tabs in frontmatter:

```bash
cd ~/Zettelkasten
for file in *.md; do
  [ -f "$file" ] && sed -i 's/\t/  /g' "$file"
done
```

### 5. Create Index Page

File: `~/Zettelkasten/index.md`

```markdown
---
title: PercyBrain Knowledge Base
date: 2025-10-23
tags:
  - index
---

# PercyBrain Knowledge Base

Welcome to my knowledge base!

## Navigation

- Browse by [Tags](tags)
- Explore the knowledge graph
```

## Common Workflows

### Build Locally

```bash
cd ~/projects/quartz
npx quartz build
```

**Output**: `public/` directory with HTML files

### Preview Locally

```bash
cd ~/projects/quartz
npx quartz build --serve
```

Visit: http://localhost:8080

**Features**:

- Hot reload (rebuilds on file changes)
- Incremental builds (fast)
- WebSocket live refresh

### Publish to GitHub Pages

```bash
cd ~/projects/quartz
npx quartz sync
```

**What it does**:

1. Builds the site
2. Commits to `gh-pages` branch
3. Pushes to GitHub
4. GitHub Pages deploys automatically

## File Workflow

### Writing Flow

1. **Edit in Neovim**: Use IWE LSP as normal

   - `gd` - Go to definition (follow link)
   - `gb` - Show backlinks
   - Create notes with frontmatter

2. **Quartz processes automatically**:

   - Symlink means Quartz sees changes immediately
   - No manual sync needed

3. **Preview when ready**:

   ```bash
   cd ~/projects/quartz
   npx quartz build --serve
   ```

4. **Publish when satisfied**:

   ```bash
   cd ~/projects/quartz
   npx quartz sync
   ```

### Link Format

**PercyBrain uses standard Markdown links**:

```markdown
I love Astras [arepas](arepas.md)
See also [this note](another-note.md)
```

Quartz handles these natively with the `CrawlLinks` plugin.

## Troubleshooting

### Build fails with "tab characters must not be used"

**Cause**: YAML frontmatter has tabs instead of spaces

**Fix**:

```bash
cd ~/Zettelkasten
sed -i 's/\t/  /g' FILENAME.md
```

Or fix all files:

```bash
for file in *.md; do sed -i 's/\t/  /g' "$file"; done
```

### Missing backlinks

**Check**: Is `Component.Backlinks()` in `quartz.layout.ts`?

```typescript
right: [
  Component.Graph(),
  Component.Backlinks(),  // Must be here
]
```

### `.iwe` directory appears in published site

**Fix**: Add to `ignorePatterns` in `quartz.config.ts`:

```typescript
ignorePatterns: [".iwe", ".git", "private"],
```

### Links don't resolve

**Check**: Are you using standard Markdown links `[text](file.md)`?

Quartz configuration includes:

```typescript
Plugin.GitHubFlavoredMarkdown(),
Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
```

This handles standard Markdown links.

## Directory Structure

```
~/Zettelkasten/              # Source (PercyBrain)
  ├── .iwe/                  # IWE metadata (ignored by Quartz)
  ├── *.md                   # Your notes
  ├── index.md               # Homepage
  └── .git/                  # Version control

~/projects/quartz/
  ├── content -> ~/Zettelkasten/  # SYMLINK (read-only)
  ├── quartz.config.ts       # Configuration
  ├── quartz.layout.ts       # Layout components
  └── public/                # Build output (gitignored)
```

## Phase 2: Mise Integration (Optional)

For easier workflow, add Quartz tasks to `~/.config/nvim/.mise.toml`:

```toml
[tasks.quartz-preview]
description = "Preview Zettelkasten with Quartz"
run = "cd ~/projects/quartz && npx quartz build --serve"

[tasks.quartz-build]
description = "Build Zettelkasten site"
run = "cd ~/projects/quartz && npx quartz build"

[tasks.quartz-publish]
description = "Publish to GitHub Pages"
run = "cd ~/projects/quartz && npx quartz sync"
```

Then use:

```bash
mise quartz-preview    # Local preview
mise quartz-build      # Test build
mise quartz-publish    # Deploy
```

## Performance Notes

**Build times**:

- \<128 files: ~5-10 seconds (single thread)
- > 128 files: ~15-30 seconds (worker pool)
- Incremental: 250ms debounce

**Your Zettelkasten** (24 notes):

- Build: ~6 seconds
- Incremental: \<1 second

## Next Steps

**Immediate**:

- Test preview locally: `npx quartz build --serve`
- Verify links and backlinks work
- Check graph view shows connections

**Short-term**:

- Setup GitHub repository for publishing
- Configure GitHub Pages
- Add Mise integration

**Long-term**:

- Customize Quartz theme
- Add custom components
- Explore advanced features (graph view customization, search)

## References

- [Quartz Documentation](https://quartz.jzhao.xyz/)
- [Quartz Configuration](https://quartz.jzhao.xyz/configuration)
- [PercyBrain IWE Integration](IWE_GETTING_STARTED.md)
- [Integration Analysis](~/projects/quartz/docs/PERCYBRAIN_INTEGRATION_ANALYSIS.json)
