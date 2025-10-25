# IWE Architecture and Concepts

**Category**: Explanation **Audience**: Users wanting to understand how IWE works **Purpose**: Conceptual understanding of IWE's design and architecture

______________________________________________________________________

## Table of Contents

1. [What is IWE?](#what-is-iwe)
2. [Architectural Overview](#architectural-overview)
3. [The LSP Protocol](#the-lsp-protocol)
4. [Project Detection](#project-detection)
5. [Link Resolution](#link-resolution)
6. [Graph-Based Knowledge](#graph-based-knowledge)
7. [Integration Strategy](#integration-strategy)
8. [Design Philosophy](#design-philosophy)

______________________________________________________________________

## What is IWE?

**IWE (Interactive Writing Environment)** is a Language Server Protocol implementation for markdown-based knowledge management.

### The Problem It Solves

Traditional markdown editors treat notes as isolated files. IWE treats them as an **interconnected knowledge graph**.

**Without IWE:**

```markdown
# Programming

See [[Rust]] notes.
```

- Link is just text
- No navigation
- Breaking changes when renaming files
- No discovery of connections

**With IWE:**

```markdown
# Programming

See [[Rust]] notes.
     ^^^^^^ ← Interactive link
```

- `gd` to follow link
- `gr` to find who links here
- `<leader>rn` to rename (updates all references)
- Graph visualization of connections

______________________________________________________________________

## Architectural Overview

### Component Stack

```
┌─────────────────────────────────────┐
│         Neovim (Editor)             │
│  ┌──────────────────────────────┐   │
│  │   iwe.nvim (Plugin)          │   │
│  │  - Keybindings               │   │
│  │  - Telescope integration     │   │
│  │  - Configuration             │   │
│  └──────────┬───────────────────┘   │
│             │ LSP Client            │
└─────────────┼─────────────────────────┘
              │
         LSP Protocol (JSON-RPC)
              │
┌─────────────▼─────────────────────────┐
│       iwes (LSP Server)               │
│  - Markdown parsing                   │
│  - Link resolution                    │
│  - Graph analysis                     │
│  - Refactoring operations             │
└───────────────────────────────────────┘
              │
┌─────────────▼─────────────────────────┐
│    Markdown Files (.md)               │
│  - Wiki-style links: [[Target]]       │
│  - YAML frontmatter                   │
│  - Standard markdown syntax           │
└───────────────────────────────────────┘
```

### Key Components

1. **iwes (LSP Server)**

   - Rust binary
   - Runs as separate process
   - Analyzes markdown files
   - Provides LSP capabilities

2. **iwe.nvim (Neovim Plugin)**

   - Lua plugin
   - Manages LSP client
   - Provides keybindings
   - Integrates with Telescope

3. **LSP Protocol**

   - Standard communication protocol
   - Editor-agnostic
   - JSON-RPC over stdio/sockets

______________________________________________________________________

## The LSP Protocol

### Why LSP?

**Language Server Protocol** (developed by Microsoft) separates language intelligence from editors.

**Traditional Approach:**

```
Editor 1 → Language X support (built-in)
Editor 2 → Language X support (built-in)
Editor 3 → Language X support (built-in)
```

**LSP Approach:**

```
Editor 1 ──┐
Editor 2 ──┼→ Language Server ← Single implementation
Editor 3 ──┘
```

### LSP for Markdown?

IWE treats **markdown files as a programming language** with:

- **Symbols**: Files, sections, links
- **References**: Backlinks, cross-references
- **Refactoring**: Extract section, inline reference
- **Completion**: Link suggestions
- **Diagnostics**: Broken links, orphan files

______________________________________________________________________

## Project Detection

### The `.iwe` Marker

IWE needs to know the **project root**—where your knowledge base begins.

**Why?**

- Link resolution is relative to project root
- Graph analysis scans from root
- Prevents mixing multiple projects

**How it works:**

1. Open markdown file: `~/Notes/programming/rust.md`
2. LSP client walks up directory tree:
   ```
   ~/Notes/programming/rust.md
   ~/Notes/programming/     ← Check for .iwe
   ~/Notes/                 ← Check for .iwe (FOUND!)
   ~/                       ← Stop
   ```
3. Project root: `~/Notes/`
4. LSP server activates for this project

### Multi-Project Support

You can have multiple independent knowledge bases:

```
~/Work/notes/.iwe       ← Work project
~/Personal/notes/.iwe   ← Personal project
~/Archive/notes/.iwe    ← Archive project
```

Each has independent:

- Link resolution
- Graph analysis
- LSP server instance

______________________________________________________________________

## Link Resolution

### Wiki-Style Links

IWE uses `[[Target]]` syntax (popularized by Obsidian, Roam, Notion).

**Example:**

```markdown
See [[Programming]] for details.
```

**Resolution Algorithm:**

1. **Parse link text**: `Programming`
2. **Search for file**:
   ```
   programming.md                 ← Exact match (lowercase)
   Programming.md                 ← Case-sensitive match
   notes/programming.md          ← Recursive search
   ```
3. **If found**: Open file
4. **If not found**: Create file with frontmatter

### Ambiguous Links

If multiple files match:

```
notes/programming.md
archive/programming.md
```

IWE uses **distance heuristic**:

- Prefer files in same directory
- Then parent directory
- Then search depth-first

### Relative Path Links

You can use paths directly:

```markdown
See [Code Style](./code-style.md)
```

LSP resolves relative to current file.

______________________________________________________________________

## Graph-Based Knowledge

### The Knowledge Graph

IWE models your notes as a **directed graph**:

**Nodes**: Files (markdown documents) **Edges**: Links (`[[Target]]` creates edge from source to target)

**Example:**

```
index.md ───→ programming.md ───→ rust.md
    │                                 │
    └─────→ philosophy.md ←───────────┘
```

### Graph Operations

#### Finding Paths

"How do I get from `index.md` to `rust.md`?"

```
index.md → programming.md → rust.md
index.md → rust.md (if direct link exists)
```

#### Finding Connections

"What connects `programming.md` and `philosophy.md`?"

```
Common ancestor: index.md
Shared references: [rust.md]
```

#### Identifying Clusters

"Which notes form communities?"

```
Programming cluster:
  - programming.md
  - rust.md
  - typescript.md

Philosophy cluster:
  - philosophy.md
  - ethics.md
  - stoicism.md
```

### Graph Visualization

`:IWE preview export-workspace` generates SVG:

```
     ┌─────────┐
     │ index   │
     └────┬────┘
          │
    ┌─────┴─────┐
    │           │
┌───▼──┐    ┌──▼────┐
│ prog │    │ phil  │
└───┬──┘    └───────┘
    │
┌───▼──┐
│ rust │
└──────┘
```

______________________________________________________________________

## Integration Strategy

### PercyBrain Integration

PercyBrain uses **IWE as primary** with custom augmentations:

```
┌─────────────────────────────────────┐
│         Core Knowledge              │
│            (IWE LSP)                │
│                                     │
│  - Link navigation (gd)             │
│  - Backlinks (gb)                   │
│  - Refactoring (<leader>ca)         │
│  - File rename (<leader>rn)         │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Custom Extensions              │
│                                     │
│  - Frontmatter autocmd              │
│  - Telescope pickers                │
│  - Blood Moon theme                 │
│  - Calendar views (separate)        │
│  - Tag navigation (separate)        │
└─────────────────────────────────────┘
```

### Why Not Telekasten?

Telekasten was **removed** because:

1. **Feature Overlap**: Both IWE and Telekasten provide link navigation
2. **Conflicts**: Competing keybindings and LSP features
3. **LSP is Superior**: Native LSP support beats plugin-based hacks
4. **Maintenance**: Fewer dependencies, simpler stack

**Migration Path:**

- Telekasten `<leader>zf` → IWE `gf`
- Telekasten `<leader>zb` → IWE `gb`
- Telekasten templates → Frontmatter autocmd

______________________________________________________________________

## Design Philosophy

### 1. Editor Agnostic (LSP-First)

IWE doesn't care if you use Neovim, VSCode, or Emacs.

**Why?**

- Write features once
- Work everywhere
- Standards-based

**Example:** Same `iwes` binary works in:

- Neovim (via iwe.nvim)
- VSCode (via vscode-iwe extension)
- Emacs (via eglot)

______________________________________________________________________

### 2. Markdown as Code

Treat markdown like a programming language.

**Traditional View:**

```
Markdown = text files
```

**IWE View:**

```
Markdown = structured documents with:
  - Symbols (files, sections)
  - References (links, backlinks)
  - Refactorings (extract, inline)
  - Types (headers, lists, code)
```

**Benefits:**

- Use existing LSP infrastructure
- Leverage editor LSP features
- Apply programming tools (git, CI/CD)

______________________________________________________________________

### 3. Local-First, Privacy-Respecting

Your notes never leave your machine.

**No Cloud:**

- No sync service
- No API calls
- No telemetry

**Full Control:**

- Git for version control
- Rsync for sync
- Your encryption

______________________________________________________________________

### 4. Plain Text Portability

Notes are just markdown files.

**Exit Strategy:**

```markdown
---
title: My Note
tags:
  - example
---

# My Note

Some content with [[links]].
```

**You can:**

- Read in any editor
- Parse with scripts
- Convert to other formats (pandoc)
- Archive for decades

______________________________________________________________________

### 5. Graph-Based Thinking

Knowledge is a network, not a hierarchy.

**Hierarchical (Traditional):**

```
Folder: Programming
  ├─ Folder: Languages
  │   ├─ Rust.md
  │   └─ Python.md
  └─ Folder: Paradigms
      ├─ FP.md
      └─ OOP.md
```

**Problem**: Where does "Rust for FP" go?

**Graph-Based (IWE):**

```
Rust.md ──────→ FP.md
  ↓                ↑
  └──→ Languages ──┘
```

**Benefits:**

- Multiple contexts
- Emergent structure
- Natural connections

______________________________________________________________________

## Advanced Concepts

### Bidirectional Links

Some systems (Obsidian, Roam) show **automatic backlinks**.

IWE provides this via LSP `textDocument/references`:

**In `rust.md`:**

```markdown
See [[Ownership Concept]]
```

**In `ownership-concept.md`, press `gb`:**

```
rust.md:5: See [[Ownership Concept]]
systems-programming.md:12: Related: [[Ownership Concept]]
```

**Implementation:**

- LSP server indexes all links on startup
- Maintains reverse index: `target → [sources]`
- Updates on file changes

______________________________________________________________________

### Inlay Hints

Show **metadata inline** without modifying files.

**File: `rust.md`**

**Without Inlay Hints:**

```markdown
# Rust

Programming language.
```

**With Inlay Hints:**

```markdown
# Rust ← 3 references

Programming language.
```

**Powered by:**

- LSP `textDocument/inlayHint`
- Neovim 0.10+ inlay hint API

______________________________________________________________________

### Lazy Loading

IWE is **lazy loaded** in PercyBrain:

```lua
{
  "iwe-org/iwe.nvim",
  ft = "markdown",     -- Load on markdown files
  cmd = "IWE",         -- Or when using :IWE command
}
```

**Why?**

- Faster Neovim startup
- Only active when needed
- No overhead for non-markdown files

**Lazy Load Triggers:**

1. Open `.md` file → Plugin loads → LSP starts
2. Run `:IWE` command → Plugin loads → Command executes

______________________________________________________________________

## Performance Considerations

### Indexing Strategy

**On Startup:**

1. LSP server scans project
2. Builds symbol index (files, links)
3. Creates graph structure

**Time Complexity:**

- O(n) where n = number of files
- Large projects (1000+ files): 2-5 seconds

**Incremental Updates:**

- File changes → Update index for that file only
- O(1) for single file changes

### Debouncing

Text changes are debounced (default: 500ms):

```
User types: "See [[Ru"
            ↓ (wait 500ms)
LSP server: "Complete: [[Rust]], [[Ruby]], [[Rust Book]]"
```

**Why?**

- Reduce LSP requests
- Prevent UI jank
- Balance responsiveness vs load

______________________________________________________________________

## Security Model

### Filesystem Access

IWE LSP server can:

- ✅ Read markdown files in project
- ✅ Write markdown files in project
- ❌ Access outside project root
- ❌ Execute arbitrary code
- ❌ Network access

### Sandboxing

LSP runs as separate process:

- Crash doesn't kill Neovim
- Restart with `:IWE lsp restart`
- Isolated from editor memory

______________________________________________________________________

## Future Directions

### Planned Features

1. **AI Integration**: Code actions for AI-powered text generation
2. **Collaborative Editing**: Real-time multi-user editing
3. **Semantic Search**: Vector similarity search
4. **Template System**: Configurable note templates

### Community Plugins

- `vscode-iwe` - VSCode extension
- `iwe-cli` - Command-line tools
- `iwe-web` - Web-based viewer

______________________________________________________________________

## Comparison with Alternatives

### vs Obsidian

| Feature     | IWE            | Obsidian              |
| ----------- | -------------- | --------------------- |
| Editor      | Any (LSP)      | Obsidian only         |
| Open Source | ✅ Yes         | ❌ No (closed source) |
| Local-First | ✅ Yes         | ✅ Yes                |
| Graph View  | ✅ Via CLI     | ✅ Built-in           |
| Plugins     | Editor plugins | Obsidian plugins      |
| Price       | Free           | Free (sync paid)      |

### vs Org-Mode

| Feature        | IWE      | Org-Mode          |
| -------------- | -------- | ----------------- |
| Format         | Markdown | Org syntax        |
| Portability    | ✅ High  | ❌ Emacs-specific |
| Learning Curve | Low      | High              |
| Features       | Focused  | Extensive         |

### vs Foam

| Feature     | IWE         | Foam        |
| ----------- | ----------- | ----------- |
| Editor      | Any (LSP)   | VSCode only |
| Server      | iwes (Rust) | TypeScript  |
| Performance | ✅ Fast     | Moderate    |
| Maturity    | Newer       | Established |

______________________________________________________________________

## Learning Resources

### Recommended Reading

1. **LSP Specification**: https://microsoft.github.io/language-server-protocol/
2. **Zettelkasten Method**: https://zettelkasten.de/
3. **Graph Theory Basics**: For understanding knowledge graphs

### Related Concepts

- **PKM (Personal Knowledge Management)**: IWE is a PKM tool
- **Digital Garden**: IWE supports digital gardening workflows
- **Second Brain**: Building an external memory system
- **Evergreen Notes**: Andy Matuschak's note-taking principles

______________________________________________________________________

## See Also

- [IWE Getting Started](../tutorials/IWE_GETTING_STARTED.md) - Hands-on tutorial
- [IWE Daily Workflow](../how-to/IWE_DAILY_WORKFLOW.md) - Practical usage patterns
- [IWE Reference](../reference/IWE_REFERENCE.md) - Complete API documentation
- [Official IWE Repo](https://github.com/iwe-org/iwe) - Source code and issues

______________________________________________________________________

## Glossary

**LSP (Language Server Protocol)**: Standard protocol for editor-language server communication

**Knowledge Graph**: Network representation of interconnected notes

**Backlink**: Reverse reference (B links to A → A has backlink from B)

**Project Root**: Directory containing `.iwe` marker

**Wiki Link**: `[[Target]]` style link popularized by wikis

**Frontmatter**: YAML metadata at top of markdown files

**Inlay Hint**: Inline metadata displayed without modifying file

**Code Action**: LSP refactoring operation (extract, inline, etc.)

**Document Symbol**: Structural element (header, section) in document

**Workspace Symbol**: File or symbol across entire project
