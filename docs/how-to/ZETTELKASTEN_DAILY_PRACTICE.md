---
title: Zettelkasten Daily Practice - Quick Reference
category: how-to
tags:
  - zettelkasten
  - workflow
  - daily-practice
  - quick-reference
last_reviewed: '2025-10-19'
difficulty: beginner
prerequisites:
  - Completed ZETTELKASTEN_TUTORIAL
time_commitment: 30-45 minutes daily
---

# Zettelkasten Daily Practice - Quick Reference

**Type**: How-to Guide (Diataxis Framework) **Goal**: Quick reference for daily Zettelkasten maintenance **Audience**: Users who completed the tutorial and need a daily checklist

## Overview

This guide provides quick reference for your daily Zettelkasten practice. For the full learning experience, see `docs/tutorials/ZETTELKASTEN_TUTORIAL.md`.

**Prerequisites**: You've completed the tutorial and understand:

- Atomic note principle
- Contextual linking
- Inbox processing workflow
- Weekly review rhythm

______________________________________________________________________

## Morning Routine (5 minutes)

### Open Daily Note

```vim
<leader>zd
```

### Template

```markdown
---
title: Daily Note 2025-10-19
date: 2025-10-19
tags: [daily]
---

# 2025-10-19

## Intentions

What am I exploring today?

## Captures

<!-- Fleeting thoughts throughout the day -->

## Evening Reflection

<!-- Added at end of day -->
```

### Quick Review

```vim
<leader>zf
```

Type: `daily/` and select yesterday's note

Ask: Did any ideas from yesterday deserve permanent notes?

______________________________________________________________________

## Throughout the Day: Capture (10-20 minutes total)

### Quick Capture to Inbox

```vim
<leader>zi
```

**What to capture**:

- ✅ Interesting ideas from reading
- ✅ Questions that emerge
- ✅ Connections you notice
- ✅ Personal insights
- ❌ Don't capture: Facts Google knows, tasks (use task manager)

**Capture quality**:

```markdown
❌ Bad: "Interesting productivity idea"

✅ Good: "Newport's Deep Work argues context switching creates cognitive residue—attention fragments stay on previous task. Explains why my best work happens after 90+ uninterrupted minutes. Related to flow state research?"
```

**Flow**: Idea strikes → `<leader>zi` → Write 2-5 sentences → `:w` → `<C-o>` (return to work)

______________________________________________________________________

## Evening Routine (30 minutes)

### Process Inbox

**Goal**: Transform fleeting captures into permanent notes

```vim
<leader>zf
```

Type: `inbox/`

### Decision Tree

For each inbox note:

```
Is this still relevant?
├─ No → Delete (70-80% should be deleted!)
└─ Yes → Continue

What type is this?
├─ Personal journal → Move to daily note
├─ Quick fact → Delete (Google exists)
└─ Unique insight → Make permanent note

Can it connect to existing notes?
├─ Yes → Add 2-3 contextual links
└─ No → Might be too broad (split it)
```

### Create Permanent Note

```vim
<leader>zn
```

**Title**: One idea, descriptive

```markdown
---
title: [Atomic idea, not broad topic]
date: 2025-10-19 18:30
tags: [2-4 relevant tags]
---

# [Title]

[3-10 sentences in YOUR words]

This connects to [[related-note]] because [explain relationship].

**Question**: [Open question for future exploration]
```

### Link to Existing Notes

**Find connections**:

```vim
<leader>zg    " Search for related concepts
<leader>zb    " View backlinks to current note
<leader>zt    " Browse by tag
```

**Add contextual links**:

❌ Weak: `See [[other-note]]`

✅ Strong: `This relates to [[other-note]] because both approaches externalize mental processes to reduce cognitive load.`

______________________________________________________________________

## Weekly Review (Sunday, 1 hour)

### Review Stats

```vim
:PercyHubs      " Most connected notes
:PercyOrphans   " Unlinked notes
```

### Orphan Management

For each orphan note:

```
Still interesting?
├─ No → Delete
└─ Yes → Find 2-3 connections and link
```

### Tag Cleanup

```vim
<leader>zt
```

**Consolidate duplicates**:

- `#productivity` + `#getting-things-done` → Choose one
- Tags used once → Too specific, delete or merge

### Update Index Notes

```vim
'L    " Jump to bookmarked index (if you set marks)
```

Add new notes to appropriate sections.

### Create Weekly Reflection

```vim
<leader>zn
```

Title: `Weekly Review YYYY-MM-DD`

```markdown
---
title: "Weekly Review 2025-10-19"
date: 2025-10-19
tags: [weekly, reflection]
---

# Weekly Review 2025-10-19

## Stats

- Permanent notes created: ___
- Orphans: ___ (target: <10%)
- Top hub: [[___]] (___ connections)

## Strongest Connection

[Unexpected connection discovered this week]

## Emerging Themes

[Patterns noticed across notes]

## Next Week Focus

[Questions to explore]
```

______________________________________________________________________

## Monthly Review (Last Sunday, 2 hours)

### Deep Synthesis

Review hub notes:

```vim
:PercyHubs
```

**Ask**: What patterns connect these hubs?

### Create Synthesis Note

```vim
<leader>zn
```

Title: `[Higher-order pattern]`

```markdown
---
title: [Synthesis across multiple notes]
date: 2025-10-31
tags: [synthesis, meta]
status: developing
---

# [Title]

**Synthesis**: [What pattern emerged from reviewing connections]

## Evidence from Notes

- [[note-1]] shows [aspect 1]
- [[note-2]] demonstrates [aspect 2]
- [[note-3]] reveals [aspect 3]

## Underlying Principle

[Your interpretation]

## Questions This Raises

- [[question-1]]
- [[question-2]]
```

### System Maintenance

**Archive completed projects**:

```bash
cd ~/Zettelkasten
mkdir -p archive/2025-10-project-name
mv *project-name* archive/2025-10-project-name/
```

**Git backup**:

```bash
git add -A
git commit -m "Monthly backup: October 2025 - [X] notes, focus on [theme]"
git tag monthly-2025-10
git push origin main --tags
```

**Update templates** (based on what worked):

```vim
:e ~/Zettelkasten/templates/note.md
:e ~/Zettelkasten/templates/daily.md
```

______________________________________________________________________

## Quick Keybinding Reference

```vim
" === CORE ===
<leader>zn    📝 New note
<leader>zd    📅 Daily note
<leader>zi    📥 Inbox capture

" === NAVIGATION ===
<leader>zf    🔍 Find notes
<leader>zg    📖 Search content
<leader>zb    🔗 View backlinks

" === ORGANIZE ===
<leader>zt    🏷️  Browse tags
<leader>zl    🔗 Insert link
<leader>zr    ✏️  Rename note

" === ADVANCED ===
:PercyOrphans    Find unlinked notes
:PercyHubs       Find hub notes
<leader>zp       📤 Publish to site
<leader>fz       🎯 Focus mode
```

______________________________________________________________________

## Health Check Metrics

Run these monthly to assess system health:

```vim
:PercyOrphans    " Should be <10% of total notes
:PercyHubs       " Top note should have 10+ connections
<leader>zt       " Should have 20-50 active tags
```

**Healthy System**:

- ✅ Orphan rate: \<10%
- ✅ Processing lag: \<20 inbox notes
- ✅ Hub connections: Top note has 15+
- ✅ Weekly creation: 5-10 permanent notes
- ✅ Synthesis frequency: 1-2 per month
- ✅ Rediscovery rate: 2-3 surprises per week

**Warning Signs**:

- ⚠️ Orphan rate >20%
- ⚠️ Inbox >50 unprocessed notes
- ⚠️ No notes with >5 connections
- ⚠️ Haven't created notes in 2+ weeks
- ⚠️ Notes feel like obligation, not tool

______________________________________________________________________

## Common Issues and Solutions

### "Too many inbox notes"

**Solution**: Daily 30-min processing, ruthless deletion (70-80% should be deleted)

### "Can't find old notes"

**Solution**: Create index notes, improve tag discipline, use full-text search (`<leader>zg`)

### "Notes feel disconnected"

**Solution**: Weekly link strengthening—add context to bare links, use backlinks for discovery

### "Writing notes feels like work"

**Solution**: Write for yourself (not publication), use conversational tone, lower the bar

### "No patterns emerging"

**Solution**: Be patient (need 30+ notes), do weekly reviews, create synthesis notes

______________________________________________________________________

## Time Investment

**Daily**: 30-45 minutes

```
Morning prep:     5 min
Capture:         10-20 min (on-demand)
Evening process: 30 min
```

**Weekly**: 1 hour (Sunday review)

**Monthly**: 2 hours (synthesis + maintenance)

**Annual**: ~312 hours (6 hours/week)

**ROI**: Faster writing, deeper thinking, compounding knowledge network

______________________________________________________________________

## Next Steps

**For deeper understanding**:

- `docs/explanation/COGNITIVE_ARCHITECTURE.md` - Why this works
- `docs/how-to/AI_USAGE_GUIDE.md` - Integrate AI assistance
- `docs/how-to/PUBLISHING_TUTORIAL.md` - Share publicly

**For learning the method**:

- `docs/tutorials/ZETTELKASTEN_TUTORIAL.md` - 7-day hands-on tutorial

**For reference**:

- `docs/reference/ZETTELKASTEN_COMMANDS.md` - Complete command reference
- `PERCYBRAIN_DESIGN.md` - Full system architecture

______________________________________________________________________

## Remember

Your Zettelkasten is a **cognitive prosthetic**, not a filing cabinet.

- Write in complete sentences for future you
- Link with context (explain relationships)
- Review weekly (patterns emerge from reflection)
- Be patient (value compounds over time)
- Consistency beats perfection

Happy note-taking! 🧠✨
