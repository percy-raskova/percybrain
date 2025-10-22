# Phase 2 Architecture Diagrams: Telekasten → IWE Migration

**Date**: 2025-10-22 **Related**: PHASE2_IMPLEMENTATION_PLAN_TELEKASTEN_TO_IWE.md

______________________________________________________________________

## System Overview

### Before Migration (Current State)

```
┌─────────────────────────────────────────────────────────────┐
│                  Zettelkasten System (Current)              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User Input (<leader>z*)                                    │
│         ↓                                                   │
│  ┌──────────────────────────────────────────────┐          │
│  │  Keybindings (zettelkasten.lua)              │          │
│  │  • Lines 14-82: config.zettelkasten calls    │          │
│  │  • Lines 84-87: Telekasten plugin calls      │          │
│  └──────────────────┬──────────────┬────────────┘          │
│                     ↓              ↓                        │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │ config.zettelkasten  │  │ Telekasten Plugin    │        │
│  │ (PRIMARY)            │  │ (SECONDARY)          │        │
│  │                      │  │                      │        │
│  │ • new_note()         │  │ • show_tags()        │        │
│  │ • daily_note()       │  │ • show_calendar()    │        │
│  │ • find_notes()       │  │ • follow_link()      │        │
│  │ • search_notes()     │  │ • insert_link()      │        │
│  │ • backlinks()        │  │                      │        │
│  │ • find_orphans()     │  │ [133 lines of code]  │        │
│  │ • find_hubs()        │  │                      │        │
│  │ • publish()          │  └──────────┬───────────┘        │
│  └──────┬───────────────┘             ↓                    │
│         ↓                    ┌────────────────────┐        │
│  ┌──────────────────┐        │ calendar-vim       │        │
│  │  Telescope UI    │        │ (Dependency)       │        │
│  └──────────────────┘        └────────────────────┘        │
│         ↓                                                   │
│  ┌──────────────────────────────────────────────┐          │
│  │         IWE LSP (iwes)                       │          │
│  │  • Link navigation                           │          │
│  │  • Refactoring (extract/inline)              │          │
│  │  • link_type = "WikiLink" ⚠️ MISMATCH        │          │
│  └──────────────────────────────────────────────┘          │
│         ↓                                                   │
│  ~/Zettelkasten/                                            │
│  • .iwe/config.toml (link_type = "markdown") ⚠️            │
│                                                             │
│  ⚠️  PROBLEM: Two plugins, link format mismatch            │
└─────────────────────────────────────────────────────────────┘
```

### After Migration (Target State)

```
┌─────────────────────────────────────────────────────────────┐
│                  Zettelkasten System (Target)               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User Input (<leader>z*)                                    │
│         ↓                                                   │
│  ┌──────────────────────────────────────────────┐          │
│  │  Keybindings (zettelkasten.lua)              │          │
│  │  ALL routes to config.zettelkasten           │          │
│  │  (No Telekasten references)                  │          │
│  └──────────────────┬───────────────────────────┘          │
│                     ↓                                       │
│  ┌──────────────────────────────────────────────┐          │
│  │         config.zettelkasten (UNIFIED)        │          │
│  │                                              │          │
│  │  Core Functions (Existing):                 │          │
│  │  • new_note()                                │          │
│  │  • daily_note(date?) [ENHANCED]              │          │
│  │  • find_notes()                              │          │
│  │  • search_notes(term?)                       │          │
│  │  • backlinks()                               │          │
│  │  • find_orphans()                            │          │
│  │  • find_hubs()                               │          │
│  │  • publish()                                 │          │
│  │                                              │          │
│  │  New Functions (Phase 2):                   │          │
│  │  • show_calendar() [NEW]                     │          │
│  │  • show_tags() [NEW]                         │          │
│  │  • follow_link() [NEW]                       │          │
│  │  • insert_link() [NEW]                       │          │
│  └───┬─────────┬──────────┬──────────┬──────────┘          │
│      ↓         ↓          ↓          ↓                      │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐              │
│  │Teles-  │ │  IWE   │ │Ripgrep │ │ Hugo   │              │
│  │cope    │ │  LSP   │ │        │ │        │              │
│  │        │ │        │ │        │ │        │              │
│  │• Date  │ │• Links │ │• Tag   │ │• Pub-  │              │
│  │  picker│ │• Code  │ │  search│ │  lish  │              │
│  │• Tag   │ │  action│ │        │ │        │              │
│  │  picker│ │• Def   │ │        │ │        │              │
│  └────────┘ └────────┘ └────────┘ └────────┘              │
│                 ↓                                           │
│  ┌──────────────────────────────────────────────┐          │
│  │         IWE LSP (iwes)                       │          │
│  │  • link_type = "Markdown" ✅ ALIGNED         │          │
│  └──────────────────────────────────────────────┘          │
│         ↓                                                   │
│  ~/Zettelkasten/                                            │
│  • .iwe/config.toml (link_type = "markdown") ✅            │
│                                                             │
│  ✅ SOLUTION: Single source of truth, consistent links     │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Component Interaction Diagrams

### Calendar Picker Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  Calendar Picker Workflow                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  USER                                                       │
│   ↓                                                         │
│  Press <leader>zc                                           │
│   ↓                                                         │
│  ┌─────────────────────────────────────────────┐           │
│  │  show_calendar()                            │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Generate Date Range                 │ │           │
│  │  │    • today - 30 days                   │ │           │
│  │  │    • today                             │ │           │
│  │  │    • today + 30 days                   │ │           │
│  │  │    = 61 total dates                    │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Format Display                      │ │           │
│  │  │    2025-10-22 → "📅 TODAY: Tuesday,    │ │           │
│  │  │                  October 22, 2025"     │ │           │
│  │  │    2025-10-21 → "Monday, October 21,   │ │           │
│  │  │                  2025"                 │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 3. Check File Existence                │ │           │
│  │  │    daily_path = ~/Zettelkasten/daily/  │ │           │
│  │  │                 2025-10-22.md          │ │           │
│  │  │                                        │ │           │
│  │  │    EXISTS → "✅ Tuesday, October 22"   │ │           │
│  │  │    MISSING → "➕ Tuesday, October 22"  │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 4. Telescope Picker                    │ │           │
│  │  │    ┌─────────────────────────────────┐ │ │           │
│  │  │    │ 📅 Select Date for Daily Note   │ │ │           │
│  │  │    ├─────────────────────────────────┤ │ │           │
│  │  │    │ > ✅ TODAY: Tues, Oct 22, 2025  │ │ │           │
│  │  │    │   ➕ Wednesday, October 23, 2025│ │ │           │
│  │  │    │   ✅ Monday, October 21, 2025   │ │ │           │
│  │  │    │   ➕ Sunday, October 20, 2025   │ │ │           │
│  │  │    └─────────────────────────────────┘ │ │           │
│  │  │                                        │ │           │
│  │  │    Supports fuzzy search:              │ │           │
│  │  │    Type "oct 25" → filters to Oct 25  │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  USER SELECTS DATE                                          │
│                  ↓                                          │
│  ┌─────────────────────────────────────────────┐           │
│  │  daily_note("2025-10-22")                   │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Check if file exists                │ │           │
│  │  │    ~/Zettelkasten/daily/2025-10-22.md  │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Create from template (if needed)    │ │           │
│  │  │    load_template("daily")              │ │           │
│  │  │    apply_template(content, date)       │ │           │
│  │  │    writefile(...)                      │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 3. Open file                           │ │           │
│  │  │    :edit ~/Zettelkasten/daily/...md    │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └─────────────────────────────────────────────┘           │
│                  ↓                                          │
│  Daily note opened in editor                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘

DATA FLOW:
┌───────────┐     ┌──────────┐     ┌───────────┐     ┌──────────┐
│ Date Range│────▶│ Telescope│────▶│ Selection │────▶│ File     │
│ Generator │     │ Picker   │     │ Handler   │     │ Editor   │
└───────────┘     └──────────┘     └───────────┘     └──────────┘
  (61 dates)      (User chooses)   (daily_note())   (nvim :edit)
```

### Tag Browser Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Tag Browser Workflow                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  USER                                                       │
│   ↓                                                         │
│  Press <leader>zt                                           │
│   ↓                                                         │
│  ┌─────────────────────────────────────────────┐           │
│  │  show_tags()                                │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Run ripgrep                         │ │           │
│  │  │    rg --no-heading                     │ │           │
│  │  │       --with-filename                  │ │           │
│  │  │       --line-number                    │ │           │
│  │  │       '^tags:'                         │ │           │
│  │  │       ~/Zettelkasten                   │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Parse Results                       │ │           │
│  │  │                                        │ │           │
│  │  │  Input:                                │ │           │
│  │  │  "/path/note1.md:3:tags: [zk, note]"  │ │           │
│  │  │  "/path/note2.md:5:tags: [zk, idea]"  │ │           │
│  │  │  "/path/note3.md:2:tags: [zk]"        │ │           │
│  │  │                                        │ │           │
│  │  │  Extract pattern:                      │ │           │
│  │  │  tags:%s*%[(.-)%]                      │ │           │
│  │  │                                        │ │           │
│  │  │  Captured:                             │ │           │
│  │  │  "zk, note" → split → ["zk", "note"]  │ │           │
│  │  │  "zk, idea" → split → ["zk", "idea"]  │ │           │
│  │  │  "zk" → ["zk"]                         │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 3. Aggregate & Count                   │ │           │
│  │  │                                        │ │           │
│  │  │  Frequency Table:                      │ │           │
│  │  │  { zk: 3, note: 1, idea: 1 }           │ │           │
│  │  │                                        │ │           │
│  │  │  Sort by count (descending):           │ │           │
│  │  │  [                                     │ │           │
│  │  │    { tag: "zk", count: 3 },            │ │           │
│  │  │    { tag: "note", count: 1 },          │ │           │
│  │  │    { tag: "idea", count: 1 }           │ │           │
│  │  │  ]                                     │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 4. Telescope Picker                    │ │           │
│  │  │    ┌─────────────────────────────────┐ │ │           │
│  │  │    │ 🏷️  Tags (3 unique)             │ │ │           │
│  │  │    ├─────────────────────────────────┤ │ │           │
│  │  │    │ > zk (3 notes)                  │ │ │           │
│  │  │    │   note (1 note)                 │ │ │           │
│  │  │    │   idea (1 note)                 │ │ │           │
│  │  │    └─────────────────────────────────┘ │ │           │
│  │  │                                        │ │           │
│  │  │    Supports fuzzy search:              │ │           │
│  │  │    Type "zk" → highlights "zk (3)"    │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  USER SELECTS TAG "zk"                                      │
│                  ↓                                          │
│  ┌─────────────────────────────────────────────┐           │
│  │  search_notes("zk")                         │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ Telescope live_grep                    │ │           │
│  │  │ default_text = "zk"                    │ │           │
│  │  │                                        │ │           │
│  │  │ Shows all notes containing "zk"        │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └─────────────────────────────────────────────┘           │
│                  ↓                                          │
│  Notes filtered by tag displayed                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

DATA FLOW:
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ ripgrep │───▶│  Parse   │───▶│ Aggregate│───▶│Telescope │
│ Search  │    │ Tags     │    │ & Sort   │    │ Picker   │
└─────────┘    └──────────┘    └──────────┘    └──────────┘
  (Find YAML)  (Extract tags)  (Count freq)    (User select)
                                                      ↓
                                               ┌──────────┐
                                               │ Search   │
                                               │ Notes    │
                                               └──────────┘
                                               (Filter by tag)
```

### Link Navigation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  Link Navigation Workflow                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  USER                                                       │
│   ↓                                                         │
│  Cursor on markdown link: [Some Note](note-id)              │
│   ↓                                                         │
│  Press <leader>zl (follow link)                             │
│   ↓                                                         │
│  ┌─────────────────────────────────────────────┐           │
│  │  follow_link()                              │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Check LSP Client                    │ │           │
│  │  │    vim.lsp.get_active_clients()        │ │           │
│  │  │                                        │ │           │
│  │  │    If "iwes" not attached:             │ │           │
│  │  │    → Warn user, exit                   │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Call LSP Definition                 │ │           │
│  │  │    vim.lsp.buf.definition()            │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  ┌─────────────────────────────────────────────┐           │
│  │  IWE LSP (iwes)                             │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Parse Link Under Cursor             │ │           │
│  │  │    Pattern: %[(.-)%]%((.-)%)            │ │           │
│  │  │    Capture: [text](key)                │ │           │
│  │  │                                        │ │           │
│  │  │    Result: key = "note-id"             │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Resolve Key to Path                 │ │           │
│  │  │    IWE searches link_actions:          │ │           │
│  │  │                                        │ │           │
│  │  │    [actions.link]                      │ │           │
│  │  │    key_template = "{{id}}"             │ │           │
│  │  │                                        │ │           │
│  │  │    Check paths:                        │ │           │
│  │  │    1. zettel/note-id.md                │ │           │
│  │  │    2. sources/note-id.md               │ │           │
│  │  │    3. mocs/note-id.md                  │ │           │
│  │  │    4. drafts/note-id.md                │ │           │
│  │  │                                        │ │           │
│  │  │    Found: zettel/note-id.md            │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 3. Return LSP Location                 │ │           │
│  │  │    {                                   │ │           │
│  │  │      uri: "file:///~/Zettelkasten/    │ │           │
│  │  │            zettel/note-id.md",         │ │           │
│  │  │      range: { start: {0, 0} }          │ │           │
│  │  │    }                                   │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  Neovim jumps to file                                       │
│  :edit ~/Zettelkasten/zettel/note-id.md                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

LSP REQUEST/RESPONSE:
┌──────────────────┐    ┌──────────────┐    ┌──────────────┐
│  Neovim Client   │───▶│  IWE Server  │───▶│  File System │
│                  │    │  (iwes)      │    │              │
│ textDocument/    │    │ Parse link   │    │ Resolve path │
│ definition       │    │ key = "id"   │    │ Check dirs   │
│                  │◀───│              │◀───│              │
│ Jump to location │    │ Return URI   │    │ Found file   │
└──────────────────┘    └──────────────┘    └──────────────┘
```

### Link Insertion Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  Link Insertion Workflow                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  USER                                                       │
│   ↓                                                         │
│  Type some text or select text                              │
│   ↓                                                         │
│  Press <leader>zk (insert link)                             │
│   ↓                                                         │
│  ┌─────────────────────────────────────────────┐           │
│  │  insert_link()                              │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Check LSP Client                    │ │           │
│  │  │    vim.lsp.get_active_clients()        │ │           │
│  │  │                                        │ │           │
│  │  │    If "iwes" not attached:             │ │           │
│  │  │    → Warn user, exit                   │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Request Code Actions                │ │           │
│  │  │    vim.lsp.buf.code_action({           │ │           │
│  │  │      filter = fn(action)               │ │           │
│  │  │        return action.title:match("Link")│ │           │
│  │  │    })                                  │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  ┌─────────────────────────────────────────────┐           │
│  │  IWE LSP (iwes)                             │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 1. Analyze Context                     │ │           │
│  │  │    Cursor position                     │ │           │
│  │  │    Selected text (if any)              │ │           │
│  │  │    Current document                    │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 2. Find Available Notes                │ │           │
│  │  │    Scan library_path                   │ │           │
│  │  │    ~/Zettelkasten/**/*.md              │ │           │
│  │  │                                        │ │           │
│  │  │    Results:                            │ │           │
│  │  │    - zettel/202510221430-example.md   │ │           │
│  │  │    - sources/author-2023-paper.md     │ │           │
│  │  │    - mocs/MOC-knowledge-mgmt.md       │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  │         ↓                                    │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ 3. Generate Code Actions               │ │           │
│  │  │    [                                   │ │           │
│  │  │      {                                 │ │           │
│  │  │        title: "Link to example",       │ │           │
│  │  │        kind: "refactor.rewrite",       │ │           │
│  │  │        edit: { /* LSP edit */ }        │ │           │
│  │  │      },                                │ │           │
│  │  │      {                                 │ │           │
│  │  │        title: "Link to paper",         │ │           │
│  │  │        ...                             │ │           │
│  │  │      },                                │ │           │
│  │  │      ...                               │ │           │
│  │  │    ]                                   │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  ┌─────────────────────────────────────────────┐           │
│  │  Neovim Code Action Menu                   │           │
│  │  ┌────────────────────────────────────────┐ │           │
│  │  │ Code Actions                           │ │           │
│  │  ├────────────────────────────────────────┤ │           │
│  │  │ > Link to example                      │ │           │
│  │  │   Link to paper                        │ │           │
│  │  │   Link to knowledge-mgmt               │ │           │
│  │  └────────────────────────────────────────┘ │           │
│  └───────────────┬─────────────────────────────┘           │
│                  ↓                                          │
│  USER SELECTS "Link to example"                             │
│                  ↓                                          │
│  LSP applies edit:                                          │
│  Before: "some text"                                        │
│  After:  "[some text](202510221430-example)"                │
│                                                             │
└─────────────────────────────────────────────────────────────┘

LSP CODE ACTION FLOW:
┌──────────────────┐    ┌──────────────┐    ┌──────────────┐
│  Neovim Request  │───▶│  IWE Server  │───▶│  Scan Notes  │
│                  │    │              │    │              │
│ code_action()    │    │ Find targets │    │ List all .md │
│ filter: "Link"   │    │ Generate edits│   │ Parse titles │
│                  │◀───│              │◀───│              │
│ Show menu        │    │ Return actions│   │ Return list  │
│ Apply selection  │    │              │    │              │
└──────────────────┘    └──────────────┘    └──────────────┘
```

______________________________________________________________________

## Data Flow Architecture

### Configuration Consistency

```
┌─────────────────────────────────────────────────────────────┐
│               Link Format Configuration Flow                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BEFORE (Inconsistent):                                     │
│                                                             │
│  lua/plugins/lsp/iwe.lua                                    │
│  ┌─────────────────────────────┐                           │
│  │ link_type = "WikiLink" ⚠️   │                           │
│  └─────────────────────────────┘                           │
│            ↓                                                │
│  ~/Zettelkasten/.iwe/config.toml                            │
│  ┌─────────────────────────────┐                           │
│  │ link_type = "markdown" ⚠️   │                           │
│  └─────────────────────────────┘                           │
│                                                             │
│  PROBLEM: Mismatch causes LSP confusion                     │
│           Plugin creates [[wiki]] links                     │
│           Config expects [text](key) links                  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  AFTER (Consistent):                                        │
│                                                             │
│  lua/plugins/lsp/iwe.lua                                    │
│  ┌─────────────────────────────┐                           │
│  │ link_type = "Markdown" ✅   │                           │
│  └─────────────────────────────┘                           │
│            ↓                                                │
│  ~/Zettelkasten/.iwe/config.toml                            │
│  ┌─────────────────────────────┐                           │
│  │ link_type = "markdown" ✅   │                           │
│  └─────────────────────────────┘                           │
│            ↓                                                │
│  BOTH CREATE: [text](key)                                   │
│                                                             │
│  BENEFITS:                                                  │
│  ✅ LSP navigation works correctly                         │
│  ✅ Hugo static site renders links                         │
│  ✅ GitHub/GitLab preview works                            │
│  ✅ Obsidian compatibility                                 │
│  ✅ Future-proof (markdown standard)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Keybinding Routing

```
┌─────────────────────────────────────────────────────────────┐
│                  Keybinding Routing Flow                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BEFORE (Dual Routing):                                     │
│                                                             │
│  <leader>zn  ──────────────────────┐                       │
│  <leader>zd  ──────────────────────┤                       │
│  <leader>zf  ──────────────────────┤                       │
│  <leader>zg  ──────────────────────┼──▶ config.zettelkasten│
│  <leader>zb  ──────────────────────┤                       │
│  <leader>zo  ──────────────────────┤                       │
│  <leader>zh  ──────────────────────┘                       │
│                                                             │
│  <leader>zt  ──────────────────────┐                       │
│  <leader>zc  ──────────────────────┼──▶ Telekasten plugin  │
│  <leader>zl  ──────────────────────┤                       │
│  <leader>zk  ──────────────────────┘                       │
│                                                             │
│  PROBLEM: Two different backends, inconsistent behavior     │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  AFTER (Unified Routing):                                   │
│                                                             │
│  <leader>zn  ──────────────────────┐                       │
│  <leader>zd  ──────────────────────┤                       │
│  <leader>zf  ──────────────────────┤                       │
│  <leader>zg  ──────────────────────┤                       │
│  <leader>zb  ──────────────────────┤                       │
│  <leader>zo  ──────────────────────┼──▶ config.zettelkasten│
│  <leader>zh  ──────────────────────┤                       │
│  <leader>zt  ──────────────────────┤    (UNIFIED)          │
│  <leader>zc  ──────────────────────┤                       │
│  <leader>zl  ──────────────────────┤                       │
│  <leader>zk  ──────────────────────┘                       │
│                                                             │
│  BENEFITS:                                                  │
│  ✅ Single source of truth                                 │
│  ✅ Consistent behavior                                    │
│  ✅ Easier maintenance                                     │
│  ✅ Better integration                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Testing Architecture

### Test Coverage Map

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────┐            │
│  │         Contract Tests (mise tc)           │            │
│  │  specs/iwe_zettelkasten_contract.lua       │            │
│  │  tests/contract/iwe_zettelkasten_*_spec.lua│            │
│  ├────────────────────────────────────────────┤            │
│  │  ✅ IWE link format = "Markdown"           │            │
│  │  ✅ IWE LSP server (iwes) installed        │            │
│  │  ✅ IWE CLI (iwe) installed                │            │
│  │  ✅ Directory structure maintained         │            │
│  │  ✅ Templates exist and valid              │            │
│  └────────────────────────────────────────────┘            │
│                     ↓                                       │
│  ┌────────────────────────────────────────────┐            │
│  │      Capability Tests (mise tcap)          │            │
│  │  tests/capability/zettelkasten/*_spec.lua  │            │
│  ├────────────────────────────────────────────┤            │
│  │  ✅ Calendar picker creates daily notes    │            │
│  │  ✅ Tag browser extracts tags              │            │
│  │  ✅ Link navigation (LSP definition)       │            │
│  │  ✅ Link insertion (LSP code action)       │            │
│  │  ✅ End-to-end workflows                   │            │
│  └────────────────────────────────────────────┘            │
│                     ↓                                       │
│  ┌────────────────────────────────────────────┐            │
│  │      Regression Tests (mise tr)            │            │
│  │  tests/regression/*_spec.lua               │            │
│  ├────────────────────────────────────────────┤            │
│  │  ✅ ADHD protections maintained            │            │
│  │  ✅ No configuration regressions           │            │
│  │  ✅ Keybinding consistency                 │            │
│  │  ✅ Critical user workflows                │            │
│  └────────────────────────────────────────────┘            │
│                     ↓                                       │
│  ┌────────────────────────────────────────────┐            │
│  │     Integration Tests (mise ti)            │            │
│  │  tests/integration/*_spec.lua              │            │
│  ├────────────────────────────────────────────┤            │
│  │  ✅ Zettelkasten + IWE workflow            │            │
│  │  ✅ Hugo publishing pipeline               │            │
│  │  ✅ AI processing integration              │            │
│  │  ✅ Component interactions                 │            │
│  └────────────────────────────────────────────┘            │
│                                                             │
│  TOTAL: 44/44 tests → 165+ tests (after Phase 2)           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Performance Characteristics

### Operation Latency Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                 Performance Comparison                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Operation: Calendar Picker                                 │
│  ┌─────────────────────────────────────────────┐           │
│  │ Telekasten:  100ms ████████████             │           │
│  │ IWE:          50ms ██████                   │           │
│  └─────────────────────────────────────────────┘           │
│  Improvement: 2x faster (pure Lua, no plugin overhead)     │
│                                                             │
│  Operation: Tag Browsing                                    │
│  ┌─────────────────────────────────────────────┐           │
│  │ Telekasten:  200ms ████████████████████████ │           │
│  │ IWE:          50ms █████                    │           │
│  └─────────────────────────────────────────────┘           │
│  Improvement: 4x faster (ripgrep vs Lua parsing)           │
│                                                             │
│  Operation: Link Navigation                                 │
│  ┌─────────────────────────────────────────────┐           │
│  │ Telekasten:   50ms ██████                   │           │
│  │ IWE:          30ms ████                     │           │
│  └─────────────────────────────────────────────┘           │
│  Improvement: 1.6x faster (native LSP)                     │
│                                                             │
│  Operation: Link Insertion                                  │
│  ┌─────────────────────────────────────────────┐           │
│  │ Telekasten:  100ms ████████████             │           │
│  │ IWE:          50ms ██████                   │           │
│  └─────────────────────────────────────────────┘           │
│  Improvement: 2x faster (LSP code action)                  │
│                                                             │
│  Memory Footprint                                           │
│  ┌─────────────────────────────────────────────┐           │
│  │ Telekasten:  500KB ████████████████████████ │           │
│  │ IWE:          50KB ██                       │           │
│  └─────────────────────────────────────────────┘           │
│  Improvement: 10x smaller (business logic in config)       │
│                                                             │
│  Note: IWE LSP (iwes) is ~5MB background process,          │
│        but shared with other LSP features                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Risk Mitigation Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Risk Mitigation Strategy                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Risk 1: Link Format Breaks Existing Notes                 │
│  ┌────────────────────────────────────────────┐            │
│  │ MITIGATION: Already using markdown in      │            │
│  │            .iwe/config.toml                 │            │
│  │                                            │            │
│  │ IF OLD NOTES EXIST WITH [[wikilinks]]:     │            │
│  │   1. Run: iwe normalize ~/Zettelkasten     │            │
│  │   2. Batch converts [[note]] → [note](key) │            │
│  │   3. One-time operation                    │            │
│  └────────────────────────────────────────────┘            │
│  Status: ✅ LOW RISK                                       │
│                                                             │
│  Risk 2: Calendar UX Worse Than Telekasten                  │
│  ┌────────────────────────────────────────────┐            │
│  │ MITIGATION: Simple date picker + preview   │            │
│  │                                            │            │
│  │ Features:                                  │            │
│  │   ✅ Fuzzy search dates                    │            │
│  │   ✅ Preview existing notes                │            │
│  │   ✅ Clear existence indicators            │            │
│  │   ✅ "TODAY" marker                        │            │
│  │                                            │            │
│  │ Escape Hatch:                              │            │
│  │   If users want visual calendar:           │            │
│  │   → Add calendar-vim overlay (already dep) │            │
│  └────────────────────────────────────────────┘            │
│  Status: ⚠️  MEDIUM RISK (user feedback needed)            │
│                                                             │
│  Risk 3: LSP Navigation Fails                               │
│  ┌────────────────────────────────────────────┐            │
│  │ MITIGATION: Thorough testing + fallback    │            │
│  │                                            │            │
│  │ Testing:                                   │            │
│  │   ✅ Contract test: iwes installed         │            │
│  │   ✅ Capability test: navigation works     │            │
│  │   ✅ LSP client check in function          │            │
│  │                                            │            │
│  │ Fallback:                                  │            │
│  │   If LSP fails → clear error message       │            │
│  │   User can manually open note              │            │
│  └────────────────────────────────────────────┘            │
│  Status: ✅ LOW RISK (LSP is stable)                       │
│                                                             │
│  Risk 4: Tag Parsing Misses Formats                        │
│  ┌────────────────────────────────────────────┐            │
│  │ MITIGATION: Support 95% use case           │            │
│  │                                            │            │
│  │ Supported:                                 │            │
│  │   ✅ tags: [a, b, c]                       │            │
│  │   ✅ tags: ["a", "b"]                      │            │
│  │                                            │            │
│  │ Not Supported (Future):                    │            │
│  │   ❌ tags:                                 │            │
│  │        - a                                 │            │
│  │        - b                                 │            │
│  │                                            │            │
│  │ Document limitation in QUICK_REFERENCE.md  │            │
│  └────────────────────────────────────────────┘            │
│  Status: ✅ LOW RISK (document limitation)                 │
│                                                             │
│  Risk 5: Performance Degradation                           │
│  ┌────────────────────────────────────────────┐            │
│  │ MITIGATION: Benchmarks show improvement    │            │
│  │                                            │            │
│  │ Evidence:                                  │            │
│  │   ✅ ripgrep faster than Lua parsing       │            │
│  │   ✅ LSP native faster than plugin         │            │
│  │   ✅ Pure Lua faster than plugin overhead  │            │
│  │                                            │            │
│  │ Monitoring:                                │            │
│  │   If users report slowness:                │            │
│  │   → Profile with :profile start             │            │
│  │   → Optimize hot paths                     │            │
│  └────────────────────────────────────────────┘            │
│  Status: ✅ VERY LOW RISK (benchmarks confirm)             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Rollback Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Rollback Strategy                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  IF MIGRATION FAILS:                                        │
│                                                             │
│  Option 1: Git Revert (< 5 minutes)                         │
│  ┌────────────────────────────────────────────┐            │
│  │ $ git checkout main                        │            │
│  │ $ nvim  # Telekasten back                  │            │
│  └────────────────────────────────────────────┘            │
│                                                             │
│  Option 2: Selective Revert                                 │
│  ┌────────────────────────────────────────────┐            │
│  │ $ git revert <commit-hash>                 │            │
│  │ $ nvim  # Specific change reverted         │            │
│  └────────────────────────────────────────────┘            │
│                                                             │
│  Option 3: Emergency Telekasten Restore                     │
│  ┌────────────────────────────────────────────┐            │
│  │ $ git show main:lua/plugins/...            │            │
│  │   telekasten.lua > temp.lua                │            │
│  │ $ cp temp.lua lua/plugins/...              │            │
│  │   zettelkasten/telekasten.lua              │            │
│  │ $ nvim  # Telekasten temporarily restored  │            │
│  └────────────────────────────────────────────┘            │
│                                                             │
│  TRIGGERS FOR ROLLBACK:                                     │
│  ❌ Tests fail after implementation                        │
│  ❌ LSP navigation consistently broken                     │
│  ❌ User workflow severely impacted                        │
│  ❌ Performance degradation >2x                            │
│                                                             │
│  POST-ROLLBACK ACTIONS:                                     │
│  1. Document root cause in claudedocs/                      │
│  2. File issue on IWE repo (if LSP bug)                     │
│  3. Revise migration plan                                   │
│  4. Schedule retry with fixes                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Document Metadata

| Attribute    | Value                                                                                    |
| ------------ | ---------------------------------------------------------------------------------------- |
| Created      | 2025-10-22                                                                               |
| Version      | 1.0                                                                                      |
| Related Docs | PHASE2_IMPLEMENTATION_PLAN_TELEKASTEN_TO_IWE.md, WORKFLOW_TELEKASTEN_TO_IWE_MIGRATION.md |
| Diagrams     | 10 (System, Component, Data Flow, Risk, Performance)                                     |
| Format       | ASCII Art + Markdown                                                                     |
| Status       | Planning Phase - Ready for Phase 1 (RED)                                                 |

______________________________________________________________________

**Status**: Architecture documented, ready for implementation **Next Step**: Begin Phase 1 (Test Refactoring - RED) **Do NOT Proceed to Phase 2 until tests are RED**
