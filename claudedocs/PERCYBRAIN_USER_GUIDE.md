# PercyBrain User Guide

**Version**: 1.0 (Phase 1 Complete)
**Last Updated**: 2025-10-17
**Status**: Production Ready

---

## Table of Contents

1. [Introduction](#introduction)
2. [Quick Start](#quick-start)
3. [Core Workflows](#core-workflows)
4. [Keyboard Shortcuts Reference](#keyboard-shortcuts-reference)
5. [AI Assistant Features](#ai-assistant-features)
6. [Template System](#template-system)
7. [Knowledge Graph Analysis](#knowledge-graph-analysis)
8. [Publishing Workflow](#publishing-workflow)
9. [Tips & Best Practices](#tips--best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Introduction

### What is PercyBrain?

PercyBrain is an AI-powered Zettelkasten knowledge management system built directly into Neovim. It transforms your editor into a complete "second brain" with:

- 🧠 **Local AI Intelligence** - Ollama-powered assistance (explain, summarize, improve)
- 📝 **Smart Templates** - 5 structured note types for different use cases
- 🔗 **Wiki-Style Linking** - IWE LSP for intelligent markdown navigation
- 🌐 **Knowledge Graphs** - Visualize connections and find orphaned notes
- ✨ **Semantic Line Breaks** - ML-based formatting for better git diffs
- 📤 **Static Site Publishing** - Export to Hugo/Quartz/Jekyll

### System Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Core System** | Note management, search, publishing | Lua (zettelkasten.lua) |
| **IWE LSP** | Wiki-style linking, backlinks, navigation | Rust (iwe v0.0.54) |
| **SemBr** | Semantic line break formatting | Python ML (sembr v0.2.3) |
| **Ollama AI** | Local LLM for text intelligence | llama3.2:latest (2.0 GB) |

---

## Quick Start

### First-Time Setup

**Prerequisites**: Neovim, IWE LSP, SemBr, and Ollama must be installed.

**1. Verify Installation**
```vim
:checkhealth
```
Look for:
- ✅ IWE LSP at `/home/percy/.cargo/bin/iwe`
- ✅ SemBr at `/home/percy/.local/bin/sembr`
- ✅ Ollama service running

**2. Create Your First Note**
```vim
<leader>zn
```
- Enter note title
- Select template from picker (try "permanent")
- Start writing!

**3. Try AI Features**
```vim
<leader>aa
```
Opens AI command menu - try "Explain" on some text.

**4. Format with Semantic Breaks**
```vim
<leader>zs
```
Formats current buffer with ML-based line breaks.

### Daily Workflow

**Morning Routine**:
1. `<leader>zd` - Open today's daily note
2. Write your thoughts
3. `<leader>aa` → "Generate Ideas" - Get AI suggestions

**Note-Taking Session**:
1. `<leader>zi` - Quick capture to inbox
2. Write fleeting thoughts
3. Later: `<leader>zn` - Convert to permanent note with template

**Research/Reading**:
1. `<leader>zn` - New literature note
2. Select "literature" template
3. Fill in source, quotes, thoughts
4. `<leader>ae` - AI explain difficult concepts

---

## Core Workflows

### Workflow 1: Capture → Process → Connect

**Phase 1: Capture** (Fleeting Notes)
```vim
<leader>zi    " Quick inbox capture
```
- Write raw thoughts immediately
- No structure required
- Context: where did this come from?

**Phase 2: Process** (Permanent Notes)
```vim
<leader>zn    " Create permanent note
```
- Select "permanent" template
- Atomic idea: one concept per note
- Add connections: `[[link-to-related-note]]`

**Phase 3: Connect** (Link Building)
```vim
<leader>al    " AI: Suggest related links
<leader>zg    " Search for related content
<leader>zb    " Find who links here (backlinks)
```

### Workflow 2: Research → Literature Notes

**1. Start Literature Note**
```vim
<leader>zn
" Select 'literature' template
```

**2. Fill in Structure**
```markdown
## Bibliographic Information
- **Author**: Jane Doe
- **Title**: Understanding Knowledge Graphs
- **Source**: Academic Journal, 2024

## Key Points
- Main argument 1
- Main argument 2

## Notable Quotes
> "Knowledge emerges from connections" (p. 42)

## Personal Thoughts
This relates to my work on [[personal-knowledge-management]]

## Related Notes
- [[zettelkasten-method]]
- [[graph-theory]]
```

**3. AI Enhancement**
```vim
<leader>as    " AI: Summarize your notes
<leader>ae    " AI: Explain difficult quotes
```

### Workflow 3: Project Management

**1. Create Project Note**
```vim
<leader>zn
" Select 'project' template
```

**2. Track Progress**
```markdown
## Goals & Objectives
- [ ] Complete Phase 1 implementation
- [ ] Write user documentation
- [x] Deploy to production

## Milestones
- [x] Week 1: Setup (2025-10-01)
- [ ] Week 2: Development (2025-10-08)
- [ ] Week 3: Testing (2025-10-15)

## Status Updates
### 2025-10-17
- Completed Phase 1 ✅
- AI integration working
- Templates implemented
```

**3. Review & Improve**
```vim
<leader>aw    " AI: Improve writing clarity
<leader>ax    " AI: Generate new ideas
```

### Workflow 4: Meeting Notes

**1. Create Meeting Note**
```vim
<leader>zn
" Select 'meeting' template
```

**2. During Meeting**
```markdown
## Meeting Details
- **Date**: 2025-10-17 14:00
- **Duration**: 1 hour
- **Attendees**: Alice, Bob, Carol

## Discussion Points
### Topic 1: PercyBrain Release
- Decided to publish Phase 1
- Timeline: end of week

## Action Items
- [ ] **Alice**: Write release notes - Due: 2025-10-18
- [ ] **Bob**: Test AI features - Due: 2025-10-19
- [ ] **Carol**: Update documentation - Due: 2025-10-20
```

**3. Post-Meeting Processing**
```vim
<leader>as    " AI: Summarize meeting
<leader>al    " AI: Suggest related links to other notes
```

---

## Keyboard Shortcuts Reference

### Core Note Management (z = Zettelkasten)

| Shortcut | Command | Description |
|----------|---------|-------------|
| `<leader>zn` | `:PercyNew` | Create new note with template picker |
| `<leader>zd` | `:PercyDaily` | Open today's daily note |
| `<leader>zi` | `:PercyInbox` | Quick capture to inbox |
| `<leader>zf` | Find notes | Fuzzy search by filename |
| `<leader>zg` | Search notes | Live grep through content |
| `<leader>zb` | Backlinks | Find links to current note |
| `<leader>zp` | `:PercyPublish` | Export to static site |

### AI Assistant (a = AI)

| Shortcut | Command | Description |
|----------|---------|-------------|
| `<leader>aa` | `:PercyAI` | AI command menu (Telescope picker) |
| `<leader>ae` | `:PercyExplain` | AI: Explain selected text or context |
| `<leader>as` | `:PercySummarize` | AI: Summarize note or selection |
| `<leader>al` | `:PercyLinks` | AI: Suggest related concepts to link |
| `<leader>aw` | `:PercyImprove` | AI: Improve writing clarity |
| `<leader>aq` | `:PercyAsk` | AI: Answer question about note |
| `<leader>ax` | `:PercyIdeas` | AI: Generate ideas from content |

### Focus Modes (f = focus)

| Shortcut | Command | Description |
|----------|---------|-------------|
| `<leader>fz` | `:ZenMode` | Zen mode (distraction-free writing) |

### Semantic Line Breaks (SemBr)

| Shortcut | Command | Description |
|----------|---------|-------------|
| `<leader>zs` | `:SemBrFormat` | Format with ML-based semantic breaks |
| `<leader>zt` | `:SemBrToggle` | Toggle auto-format on save |

### LSP Navigation (IWE)

| Shortcut | Action | Description |
|----------|--------|-------------|
| `gd` | Go to definition | Follow wiki link |
| `K` | Hover | Show link preview |
| `<leader>zr` | LSP references | Find all backlinks |
| `<leader>rn` | Rename | Rename symbol across vault |

---

## AI Assistant Features

### Feature Overview

PercyBrain uses **Ollama with llama3.2:latest** (2.0 GB model) running locally on your machine. All AI processing happens on your device - no cloud, no privacy concerns.

### AI Commands in Detail

#### 1. Explain (`<leader>ae`)

**Use cases**:
- Understand complex concepts
- Break down technical jargon
- Clarify confusing paragraphs

**How to use**:
1. Select text (visual mode) OR place cursor in paragraph
2. Press `<leader>ae`
3. Wait 5-15 seconds
4. Read explanation in floating window
5. Press `q` or `Esc` to close

**Example**:
```
Input: "The categorical imperative posits universal maxims"
AI Explains: "This is Kant's principle that moral rules should
work universally - if everyone followed the rule, would it still
make sense? It's about finding ethical guidelines that apply to
all people in all situations..."
```

#### 2. Summarize (`<leader>as`)

**Use cases**:
- Condense long notes
- Create abstracts
- Extract key points from research

**How to use**:
1. Open note or select text
2. Press `<leader>as`
3. Get concise summary in floating window

**Example**:
```
Input: 3-page literature note
AI Summary: "Author argues knowledge management requires three
components: capture (inbox), process (structure), connect
(linking). Key insight: connections matter more than content."
```

#### 3. Suggest Links (`<leader>al`)

**Use cases**:
- Discover note connections
- Build knowledge graph
- Find related concepts

**How to use**:
1. In any note, press `<leader>al`
2. AI analyzes content
3. Suggests 5-7 related concepts
4. Create `[[wiki-links]]` manually

**Example**:
```
Input: Note about "Zettelkasten method"
AI Suggests:
- Personal knowledge management
- Atomic notes principle
- Luhmann's slip-box system
- Graph theory applications
- Note-taking workflows
- Knowledge graph visualization
```

#### 4. Improve Writing (`<leader>aw`)

**Use cases**:
- Enhance clarity
- Fix awkward phrasing
- Improve flow

**How to use**:
1. Select text to improve
2. Press `<leader>aw`
3. Review AI's improved version
4. Manually apply changes you like

**Example**:
```
Before: "The thing about notes is they're really good when you
connect them and stuff because that's how you make knowledge"

After: "Notes become valuable when interconnected. Knowledge
emerges from the relationships between concepts, not from
isolated information."
```

#### 5. Ask Question (`<leader>aq`)

**Use cases**:
- Query note content
- Clarify concepts
- Test understanding

**How to use**:
1. Open relevant note
2. Press `<leader>aq`
3. Type question
4. Get answer based on note context

**Example**:
```
Note: Project planning document
Question: "What are the main risks?"
AI Answer: "Based on your notes, three main risks: timeline
delays (mentioned in milestones), resource constraints (noted
in objectives), and technical dependencies (highlighted in
requirements)."
```

#### 6. Generate Ideas (`<leader>ax`)

**Use cases**:
- Brainstorm new angles
- Explore related topics
- Overcome writer's block

**How to use**:
1. In any note, press `<leader>ax`
2. AI generates 5 creative ideas
3. Use ideas as starting points for new notes

**Example**:
```
Input: Note about "Knowledge management"
AI Ideas:
1. How would a knowledge management system for teams differ
   from personal systems?
2. What role does forgetting play in effective knowledge
   management?
3. Can you map the evolution of your ideas over time?
4. How do physical and digital note-taking complement each other?
5. What's the relationship between knowledge management and
   decision-making?
```

### AI Performance Tips

**Optimize response time**:
- Shorter input → faster response (5-10 seconds)
- Longer input → slower response (15-30 seconds)
- First call after Ollama start: ~5 seconds extra

**Improve AI quality**:
- Provide context: select full paragraphs, not fragments
- Specific questions: "What are the three main arguments?" > "Explain this"
- Iterate: use AI results as input for follow-up queries

**Troubleshooting**:
- **"Ollama not running"**: AI will auto-start service (wait 2 seconds)
- **Slow responses**: Normal for large context (50+ lines)
- **Poor quality**: Try rephrasing or providing more context

---

## Template System

### Available Templates

PercyBrain includes 5 default templates in `~/Zettelkasten/templates/`:

#### 1. Permanent Note (`permanent.md`)

**Use for**: Atomic ideas, core concepts, main arguments

**Structure**:
```markdown
---
title: {{title}}
date: {{date}}
type: permanent
tags: [permanent]
---

# {{title}}

## Core Idea
[State the atomic concept in one sentence]

## Connections
- Related to: [[]]
- Builds on: [[]]
- Contradicts: [[]]

## Evidence/Support
[Supporting information, examples, data]

## Questions for Exploration
- [ ] Question 1?
- [ ] Question 2?

## References
- Source 1
- Source 2
```

**Best practices**:
- One idea per note (atomic principle)
- State idea clearly upfront
- Link liberally to related notes
- Use your own words (avoid copy-paste)

#### 2. Literature Note (`literature.md`)

**Use for**: Reading notes, research, source material

**Structure**:
```markdown
---
title: {{title}}
date: {{date}}
type: literature
tags: [literature, reading]
---

# {{title}}

## Bibliographic Information
- **Author**:
- **Title**:
- **Year**:
- **Source**:
- **URL/DOI**:

## Key Points
- Point 1
- Point 2

## Notable Quotes
> "Quote here" (p. XX)

> "Another quote" (p. YY)

## Personal Thoughts
[Your interpretation, connections, questions]

## Related Notes
- [[note-1]]
- [[note-2]]
```

**Best practices**:
- Capture complete citation info immediately
- Use quotes sparingly (paraphrase most content)
- Add personal thoughts while reading
- Link to related permanent notes

#### 3. Project Note (`project.md`)

**Use for**: Project tracking, goal management, timelines

**Structure**:
```markdown
---
title: {{title}}
date: {{date}}
type: project
tags: [project]
status: active
---

# {{title}}

## Goals & Objectives
- Goal 1
- Goal 2

## Milestones
- [ ] Milestone 1 (Date)
- [ ] Milestone 2 (Date)

## Resources
- Resource 1
- Resource 2

## Timeline
### Phase 1 (Dates)
- Task 1
- Task 2

## Status Updates
### {{date}}
[Current status, blockers, progress]

## Next Actions
- [ ] Action 1
- [ ] Action 2

## Related Projects
- [[project-1]]
- [[project-2]]
```

**Best practices**:
- Update status regularly (weekly minimum)
- Use checkboxes for trackable items
- Link to related project and literature notes
- Archive completed projects (change status to "archived")

#### 4. Meeting Note (`meeting.md`)

**Use for**: Meeting records, discussions, action items

**Structure**:
```markdown
---
title: {{title}}
date: {{date}}
type: meeting
tags: [meeting]
attendees: []
---

# {{title}}

## Meeting Details
- **Date**: {{date}}
- **Duration**:
- **Location**:
- **Attendees**:

## Agenda
1. Topic 1
2. Topic 2

## Discussion Points
### Topic 1
- Point A
- Point B

## Decisions Made
- Decision 1
- Decision 2

## Action Items
- [ ] **Person**: Task - Due date
- [ ] **Person**: Task - Due date

## Follow-up Required
- Item 1
- Item 2

## Next Meeting
- **Date**:
- **Topics**:

## Related Documents
- [[doc-1]]
- [[doc-2]]
```

**Best practices**:
- Fill during meeting (real-time)
- Assign owners to action items
- Link to related project notes
- Review action items before next meeting

#### 5. Fleeting Note (`fleeting.md`)

**Use for**: Quick captures, raw thoughts, inbox processing

**Structure**:
```markdown
---
title: {{title}}
date: {{date}}
type: fleeting
tags: [fleeting, inbox]
---

# {{title}}

## Quick Thoughts
[Capture your immediate thoughts - don't worry about structure]

## Context
[Where did this idea come from? What sparked it?]

## Possible Connections
- [[]]
- [[]]

## Next Steps
- [ ] Expand into permanent note?
- [ ] Research further?
- [ ] Link to existing notes?

---

*Note: Process this into permanent note when ready*
```

**Best practices**:
- Write immediately, structure later
- Capture context while fresh
- Process inbox regularly (daily/weekly)
- Convert valuable fleeting notes to permanent

### Template Variables

All templates support variable substitution:

| Variable | Replaced With | Example |
|----------|---------------|---------|
| `{{title}}` | Note title you entered | "Zettelkasten Method" |
| `{{date}}` | Current date/time | "2025-10-17 14:30" |
| `{{timestamp}}` | Timestamp ID | "202510171430" |

### Creating Custom Templates

**1. Create template file**:
```bash
$ nvim ~/Zettelkasten/templates/my-template.md
```

**2. Use template variables**:
```markdown
---
title: {{title}}
date: {{date}}
type: custom
---

# {{title}}

[Your custom structure here]
```

**3. Template automatically appears** in picker (`<leader>zn`)

**Custom template ideas**:
- Book reviews
- Code snippets
- Recipe notes
- Travel logs
- Decision journals
- Learning notes

---

## Knowledge Graph Analysis

### Understanding Your Knowledge Graph

Your notes form a **network** where:
- **Nodes** = Individual notes
- **Edges** = Wiki-style links `[[note-name]]`
- **Strength** = Number of connections (in + out)

### Graph Health Metrics

**Healthy knowledge base characteristics**:
- Few orphans (< 10% of notes)
- Multiple hubs (5-10 highly connected notes)
- Balanced graph (not one mega-hub)
- Regular linking (average 3-5 links per note)

### Finding Orphan Notes

**What are orphans?**
Notes with **zero connections** (no incoming or outgoing links)

**Why they matter**:
- Isolated knowledge = harder to recall
- Orphans suggest incomplete processing
- Finding orphans = opportunities to connect

**Command**:
```vim
:PercyOrphans
```

**Telescope picker shows**:
```
📄 202510171430-fleeting-idea
📄 202510161200-random-thought
📄 202510151800-quick-note
```

**What to do**:
1. Open orphan note
2. Read content
3. Ask: "What does this relate to?"
4. Add `[[links]]` to related notes
5. Consider: Worth keeping? Delete if not.

**Workflow**:
```vim
:PercyOrphans              " Find orphans
<Enter> on note            " Open it
<leader>al                 " AI: Suggest related links
" Manually add [[links]] based on suggestions
<leader>zb                 " Check if now has backlinks
```

### Finding Hub Notes

**What are hubs?**
Notes with **highest connection count** (incoming + outgoing)

**Why they matter**:
- Hubs = central concepts in your thinking
- Entry points for topic exploration
- Candidates for further development

**Command**:
```vim
:PercyHubs
```

**Telescope picker shows**:
```
🔗 zettelkasten-method (↓8 ↑12 = 20)
🔗 knowledge-management (↓5 ↑7 = 12)
🔗 personal-productivity (↓4 ↑6 = 10)
```

**Display format**: `NoteName (↓incoming ↑outgoing = total)`

**What to do**:
1. Review top hubs
2. Ensure hub content is well-developed
3. Consider: Should hub be split into smaller notes?
4. Use hubs as starting points for topic exploration

**Analysis questions**:
- Are your top hubs what you expected?
- Do hubs match your actual interests/work?
- Are some hubs over-centralized? (single mega-hub)
- Missing hubs? (Topics you work on but aren't connected)

### Graph Maintenance Routine

**Weekly**: Check orphans
```vim
:PercyOrphans
" Process 5-10 orphans: link or delete
```

**Monthly**: Analyze hubs
```vim
:PercyHubs
" Review top 10 hubs
" Expand under-developed hubs
" Split over-connected hubs
```

**Quarterly**: Full graph review
- Export graph statistics
- Identify emerging themes
- Reorganize major areas
- Archive completed projects

---

## Publishing Workflow

### Static Site Generation

PercyBrain can export your Zettelkasten to a static website (Hugo, Quartz, Jekyll).

### Basic Publishing

**Command**:
```vim
<leader>zp
" Or :PercyPublish
```

**What happens**:
1. Copies notes from `~/Zettelkasten/` to `~/blog/content/zettelkasten/`
2. Excludes inbox folder
3. Runs Hugo build: `hugo` command
4. Generates static site in `~/blog/public/`

**Configuration**:
Located in `lua/config/zettelkasten.lua`:
```lua
M.config = {
  home = vim.fn.expand("~/Zettelkasten"),
  export_path = vim.fn.expand("~/blog/content/zettelkasten"),
}
```

### Preview Before Publishing

**Command**:
```vim
:PercyPreview
```

**Result**:
- Starts Hugo dev server
- Opens at `http://localhost:1313`
- Hot-reload enabled
- Stop with `Ctrl+C` in terminal

### Publishing Checklist

**Before publishing**:
- [ ] Run `:PercyOrphans` - link important isolated notes
- [ ] Check frontmatter - ensure tags are meaningful
- [ ] Review note titles - make them web-friendly
- [ ] Test links - verify `[[wiki-links]]` work
- [ ] Preview locally - check formatting

**After publishing**:
- [ ] Verify live site loads
- [ ] Test navigation links
- [ ] Check mobile responsiveness
- [ ] Review any broken links
- [ ] Update site index/home page

### Advanced Publishing

**Selective publishing** (coming in Phase 2):
- Publish only tagged notes: `tags: [public]`
- Exclude draft notes: `draft: true`
- Transform wiki links to web links

**Multi-SSG support** (coming in Phase 2):
- Hugo (current default)
- Quartz (Obsidian-style)
- Jekyll (GitHub Pages)

---

## Tips & Best Practices

### Writing Tips

**Atomic Notes**:
- One idea per note
- Can be understood in isolation
- Self-contained but connected

**Linking Strategy**:
- Link generously (5+ links per note)
- Link when writing, not later
- Don't fear over-linking

**Title Conventions**:
- Descriptive, not clever
- Searchable keywords
- Avoid dates in titles (use timestamps)

### Workflow Tips

**Daily Routine**:
```
Morning:
<leader>zd  → Daily note
<leader>zi  → Capture ideas

Evening:
Process inbox
Link new notes
Run :PercyOrphans
```

**Weekly Review**:
```
Monday:
- Review last week's daily notes
- Extract permanent notes
- Run :PercyHubs - analyze main themes
```

**Monthly Maintenance**:
```
First weekend:
- Archive completed projects
- Expand hub notes
- Delete irrelevant fleeting notes
- Update templates if needed
```

### Search Strategies

**Find by filename**:
```vim
<leader>zf
" Type partial filename
```

**Search content**:
```vim
<leader>zg
" Type search term
" Live results as you type
```

**Find backlinks**:
```vim
" Open note
<leader>zb
" See who links here
```

**Use LSP navigation**:
```vim
" Place cursor on [[wiki-link]]
gd         " Follow link
<C-o>      " Go back
<leader>zr " Find all references
```

### AI Usage Patterns

**Exploratory phase**:
- `<leader>ae` - Understand new concepts
- `<leader>al` - Discover connections
- `<leader>ax` - Generate ideas

**Writing phase**:
- `<leader>aw` - Improve clarity
- `<leader>as` - Create summaries
- `<leader>aq` - Test understanding

**Processing phase**:
- `<leader>ae` - Explain complex literature
- `<leader>as` - Distill key points
- `<leader>al` - Build connections

---

## Troubleshooting

### Common Issues

#### Issue: AI commands not working

**Symptoms**: `<leader>aa` does nothing, or "Ollama not running" message

**Solutions**:
1. Check Ollama service:
   ```bash
   $ ollama list
   # Should show llama3.2:latest
   ```

2. Manually start Ollama:
   ```bash
   $ ollama serve
   # Keep terminal open
   ```

3. Verify model installed:
   ```bash
   $ ollama pull llama3.2
   ```

4. Check keybinding:
   ```vim
   :verbose map <leader>aa
   # Should show ollama.lua mapping
   ```

#### Issue: Templates not appearing

**Symptoms**: `:PercyNew` shows "No templates found"

**Solutions**:
1. Check templates directory:
   ```bash
   $ ls ~/Zettelkasten/templates/
   # Should show 5 .md files
   ```

2. Verify path in config:
   ```vim
   :lua print(require('config.zettelkasten').config.templates)
   # Should print: /home/percy/Zettelkasten/templates
   ```

3. Recreate templates:
   ```bash
   $ mkdir -p ~/Zettelkasten/templates
   # Copy templates from claudedocs/
   ```

#### Issue: Wiki links not working

**Symptoms**: `gd` doesn't follow links, no completion

**Solutions**:
1. Check IWE LSP running:
   ```vim
   :LspInfo
   # Should show iwe client attached
   ```

2. Verify IWE installed:
   ```bash
   $ iwe --version
   # Should show v0.0.54 or newer
   ```

3. Restart LSP:
   ```vim
   :LspRestart
   ```

4. Check workspace:
   ```vim
   :lua print(vim.lsp.get_active_clients()[1].config.settings.iwe.workspace)
   # Should show ~/Zettelkasten
   ```

#### Issue: Semantic line breaks not working

**Symptoms**: `<leader>zs` does nothing

**Solutions**:
1. Check SemBr installed:
   ```bash
   $ sembr --version
   # Should show v0.2.3 or newer
   ```

2. Verify Python environment:
   ```bash
   $ which sembr
   # Should show path in ~/.local/bin/
   ```

3. Check keybinding:
   ```vim
   :verbose map <leader>zs
   # Should show sembr.lua mapping
   ```

#### Issue: Publishing fails

**Symptoms**: `:PercyPublish` shows errors

**Solutions**:
1. Check export path exists:
   ```bash
   $ ls ~/blog/content/zettelkasten
   ```

2. Verify Hugo installed:
   ```bash
   $ hugo version
   ```

3. Check blog directory structure:
   ```bash
   $ cd ~/blog
   $ ls config.toml  # Hugo config should exist
   ```

### Performance Issues

#### AI responses too slow

**Normal**: 5-30 seconds depending on context size
**Too slow**: >60 seconds

**Solutions**:
- Reduce context: select smaller text portions
- Restart Ollama: `ollama serve` in terminal
- Check system resources: AI needs RAM (~4GB)

#### Graph analysis slow

**Normal**: <5 seconds for <500 notes
**Too slow**: >10 seconds

**Solutions**:
- Reduce note count: archive old notes
- Simplify note content: large files slow scanning
- Future: will add caching (Phase 2)

### Getting Help

**Diagnostic commands**:
```vim
:checkhealth            " Full system check
:LspInfo               " LSP server status
:Lazy health           " Plugin health
:messages              " Recent error messages
```

**Log locations**:
- Neovim: `~/.local/state/nvim/log`
- IWE LSP: Check `:LspLog`
- Ollama: Check terminal where `ollama serve` runs

**Documentation files**:
- `PERCYBRAIN_DESIGN.md` - System architecture
- `PERCYBRAIN_ANALYSIS.md` - Feature status
- `PERCYBRAIN_PHASE1_COMPLETE.md` - Implementation report
- `KEYBINDING_REORGANIZATION.md` - Shortcut reference

---

## Appendix: File Structure

### Zettelkasten Directory Layout

```
~/Zettelkasten/
├── inbox/                     # Quick captures (fleeting notes)
│   └── 202510171430.md
├── daily/                     # Daily journal entries
│   ├── 2025-10-17.md
│   └── 2025-10-18.md
├── templates/                 # Note templates
│   ├── permanent.md
│   ├── literature.md
│   ├── project.md
│   ├── meeting.md
│   └── fleeting.md
├── .iwe/                      # IWE LSP index (auto-generated)
│   └── index.db
└── [your-notes].md            # Permanent notes
    ├── 202510171430-zettelkasten-method.md
    ├── 202510161200-knowledge-management.md
    └── 202510151800-note-taking-systems.md
```

### Configuration Files

```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   └── zettelkasten.lua   # Core PercyBrain module
│   └── plugins/
│       ├── ollama.lua          # AI integration
│       ├── sembr.lua           # Semantic line breaks
│       └── lsp/
│           └── lspconfig.lua   # IWE LSP config
└── claudedocs/                 # Documentation
    ├── PERCYBRAIN_DESIGN.md
    ├── PERCYBRAIN_USER_GUIDE.md  # This file
    └── ...
```

---

**End of User Guide**

Version 1.0 | Phase 1 Complete | 2025-10-17
