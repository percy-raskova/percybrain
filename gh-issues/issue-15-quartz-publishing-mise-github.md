# Issue #15: Quartz Publishing Integration - Mise Tasks & GitHub Pages

## Description

Complete Quartz publishing workflow integration by adding Mise task automation (Phase 2) and GitHub Pages deployment (Phase 3). This builds on Phase 1 (symlink setup) which is already complete.

## Context

- **Phase 1**: ✅ Complete - Symlink strategy working, builds succeed
- **Phase 2**: ⏳ Mise task integration (30 min)
- **Phase 3**: ⏳ GitHub Pages setup (1 hour)
- **Phase 4**: 🔜 Deferred - Custom plugins (wait for user feedback)

## Value

- Streamlined publishing workflow via `mise quartz-preview`, `mise quartz-build`, `mise quartz-publish`
- Automated public knowledge sharing via GitHub Pages
- Zero-friction Zettelkasten publishing

## Tasks

### Task 1: Add Quartz Mise Tasks Configuration

**File**: `.mise.toml` **Estimated**: 10 minutes **Context Window**: Small - single file, ~30 lines to add

**Requirements**:

- Add three new tasks to `.mise.toml` under `[tasks]` section
- Tasks: `quartz-preview`, `quartz-build`, `quartz-publish`
- Each task should have `description` and `run` fields
- Working directory: `~/projects/quartz`

**Implementation**:

```toml
[tasks.quartz-preview]
description = "Preview Zettelkasten with Quartz local server"
run = "cd ~/projects/quartz && npx quartz build --serve"

[tasks.quartz-build]
description = "Build static site from Zettelkasten"
run = "cd ~/projects/quartz && npx quartz build"

[tasks.quartz-publish]
description = "Publish Zettelkasten to GitHub Pages"
run = "cd ~/projects/quartz && npx quartz sync"
```

**Validation**:

```bash
# Test tasks are registered
mise tasks | grep quartz

# Should show:
# quartz-preview  Preview Zettelkasten with Quartz local server
# quartz-build    Build static site from Zettelkasten
# quartz-publish  Publish Zettelkasten to GitHub Pages
```

**Acceptance Criteria**:

- [ ] Tasks added to `.mise.toml` in alphabetical order within tasks section
- [ ] `mise tasks` shows all three quartz tasks
- [ ] `mise quartz-preview` starts local server at http://localhost:8080
- [ ] `mise quartz-build` completes successfully
- [ ] Descriptions are user-friendly and descriptive

______________________________________________________________________

### Task 2: Update Documentation for Mise Integration

**File**: `docs/how-to/QUARTZ_PUBLISHING.md` **Estimated**: 15 minutes **Context Window**: Small - documentation update, ~50 lines

**Requirements**:

- Add new section: "## Workflow Commands (Mise)"
- Update existing workflow examples to use Mise tasks
- Add troubleshooting section for common Mise issues

**Implementation**: Add after line ~100 in existing file:

````markdown
## Workflow Commands (Mise)

PercyBrain integrates Quartz publishing via Mise task runner for streamlined workflows.

### Preview Locally

```bash
mise quartz-preview
# Opens local server at http://localhost:8080
# Press Ctrl+C to stop
````

### Build Site

```bash
mise quartz-build
# Builds static site to public/ directory
# ~6 seconds for <50 notes, ~30 seconds for <1000 notes
```

### Publish to GitHub Pages

```bash
mise quartz-publish
# Runs quartz sync (requires GitHub setup - see Phase 3)
```

### Common Workflows

**Quick preview while writing**:

```bash
mise quartz-preview &
# Server runs in background, auto-rebuilds on changes
```

**Pre-publish validation**:

```bash
mise quartz-build && echo "Build successful ✅"
```

## Troubleshooting

### Mise task not found

**Problem**: `mise: task 'quartz-preview' not found` **Solution**: Ensure `.mise.toml` is in project root and contains task definitions

### Port already in use

**Problem**: `Error: Port 8080 already in use` **Solution**: Kill existing server: `pkill -f "quartz.*serve"` then retry

````

**Acceptance Criteria**:
- [ ] New section added with clear command examples
- [ ] Existing workflow examples updated to reference Mise
- [ ] Troubleshooting covers common issues
- [ ] Markdown formatting validated (mdformat passes)

---

### Task 3: Create GitHub Repository for Quartz Deployment
**File**: None (GitHub web interface)
**Estimated**: 15 minutes
**Context Window**: N/A - external service setup

**Requirements**:
- Create new public GitHub repository
- Name: `percybrain-knowledge-base` (or user preference)
- Initialize with README explaining it's auto-published from Quartz
- No .gitignore needed (Quartz handles this)

**Implementation Steps**:
1. Go to https://github.com/new
2. Repository name: `percybrain-knowledge-base`
3. Description: "PercyBrain Zettelkasten - Auto-published via Quartz"
4. Public repository
5. Initialize with README:
   ```markdown
   # PercyBrain Knowledge Base

   This site is automatically published from my Zettelkasten notes using [Quartz v4](https://quartz.jzhao.xyz/).

   The notes are managed in Neovim using the PercyBrain configuration with IWE (Integrated Writing Environment).

   **Note**: This repository contains only the published site. The source notes are in a private repository.
````

6. Create repository

**Acceptance Criteria**:

- [ ] Repository created and public
- [ ] README explains auto-publishing setup
- [ ] Repository URL noted for Task 4

______________________________________________________________________

### Task 4: Configure Quartz Sync for GitHub Pages

**File**: `~/projects/quartz/quartz.config.ts` **Estimated**: 20 minutes **Context Window**: Medium - config file + git setup

**Requirements**:

- Update `quartz.config.ts` with GitHub repository URL
- Configure GitHub Pages branch (gh-pages)
- Generate GitHub personal access token (if needed)
- Test sync workflow

**Implementation**:

1. **Update quartz.config.ts** (line ~15):

```typescript
const config: QuartzConfig = {
  configuration: {
    // ... existing config ...
    baseUrl: "username.github.io/percybrain-knowledge-base", // UPDATE
    ignorePatterns: [".iwe", ".git", "private", "ai"],
  },
}
```

2. **Initialize Quartz sync**:

```bash
cd ~/projects/quartz
npx quartz sync --setup

# Follow prompts:
# - Repository URL: https://github.com/username/percybrain-knowledge-base
# - Branch: gh-pages
# - Token: (paste GitHub PAT if prompted)
```

3. **First publish**:

```bash
mise quartz-publish
# Should push to gh-pages branch
```

4. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Source: Deploy from branch
   - Branch: gh-pages / (root)
   - Save

**Acceptance Criteria**:

- [ ] `baseUrl` updated in quartz.config.ts
- [ ] `quartz sync --setup` completed successfully
- [ ] First publish pushes to gh-pages branch
- [ ] GitHub Pages deployed and accessible
- [ ] Site loads at https://username.github.io/percybrain-knowledge-base

______________________________________________________________________

### Task 5: Update QUICK_REFERENCE.md with Publishing Workflow

**File**: `QUICK_REFERENCE.md` **Estimated**: 10 minutes **Context Window**: Small - documentation addition

**Requirements**:

- Add new section: "Publishing (Quartz)" under Workflows
- Document the three-command workflow
- Link to full documentation in `docs/how-to/QUARTZ_PUBLISHING.md`

**Implementation**: Add after Zettelkasten section (line ~80):

````markdown
### Publishing (Quartz)

| Command               | Description                    |
| --------------------- | ------------------------------ |
| `mise quartz-preview` | Preview site locally (port 8080) |
| `mise quartz-build`   | Build static site              |
| `mise quartz-publish` | Deploy to GitHub Pages         |

**Full documentation**: `docs/how-to/QUARTZ_PUBLISHING.md`

**Quick workflow**:
```bash
# Write notes in Neovim → Auto-synced via symlink
mise quartz-preview    # Preview changes
mise quartz-publish    # Publish when ready
````

```

**Acceptance Criteria**:
- [ ] Table added with three commands
- [ ] Link to full documentation included
- [ ] Quick workflow example clear and concise
- [ ] Formatting validated with mdformat

---

## Dependencies

- **Prerequisite**: Phase 1 (Quartz symlink) complete ✅
- **Requires**: Node.js, npm, git, GitHub account
- **Follows**: Issue #14 (Calendar plugin integration)

## Estimated Effort

- **Total**: 1.5 hours
- **Task 1**: 10 min (Mise config)
- **Task 2**: 15 min (Docs update)
- **Task 3**: 15 min (GitHub repo)
- **Task 4**: 20 min (Quartz sync)
- **Task 5**: 10 min (Quick ref)

## Success Criteria

- [ ] All 5 tasks completed
- [ ] `mise quartz-*` commands work correctly
- [ ] Site published to GitHub Pages and accessible
- [ ] Documentation updated and accurate
- [ ] User can publish with single command: `mise quartz-publish`

## Related Files

- `.mise.toml` - Task definitions
- `~/projects/quartz/quartz.config.ts` - Quartz configuration
- `docs/how-to/QUARTZ_PUBLISHING.md` - Publishing guide
- `QUICK_REFERENCE.md` - Quick command reference
- `claudedocs/QUARTZ_PHASE1_COMPLETION_2025-10-23.md` - Phase 1 completion report
```
