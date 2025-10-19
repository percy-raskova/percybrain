---
title: Academic Writing Tutorial - Your First Paper in PercyBrain
category: tutorial
tags:
  - academic-writing
  - latex
  - bibtex
  - zettelkasten
  - tutorial
  - getting-started
last_reviewed: '2025-10-19'
time_commitment: 60-90 minutes
prerequisites:
  - Neovim installed with PercyBrain config
  - latexmk, zathura, pandoc installed
  - Basic familiarity with Zettelkasten (see Zettelkasten tutorial first)
learning_outcomes:
  - Compile your first LaTeX academic paper
  - Manage citations with BibTeX
  - Convert research notes to paper sections
  - Use productivity features for efficient writing
---

# Academic Writing Tutorial - Your First Paper in PercyBrain

**Goal**: Write and compile your first academic paper using PercyBrain's integrated research → writing workflow.

**Time**: 60-90 minutes hands-on practice

**What You'll Build**: A complete academic paper with citations, bibliography, and sections derived from research notes.

## Prerequisites Check

Before starting, verify required tools:

```bash
# Required for LaTeX compilation
which latexmk   # ✅ Should show path
which zathura   # ✅ PDF viewer

# Required for conversions
which pandoc    # ✅ Document converter

# Optional but recommended
which biber     # ✅ Better bibliography processor than bibtex
```

**Missing tools?**

```bash
# Debian/Ubuntu
sudo apt install texlive-full latexmk zathura pandoc biber

# macOS
brew install --cask mactex
brew install pandoc biber
brew install zathura  # or use Skim
```

**Start Neovim**:

```bash
cd ~
nvim
```

**Verify PercyBrain loaded**:

```vim
:checkhealth percybrain
```

✅ All checks should pass. If not → see `TROUBLESHOOTING_GUIDE.md`

______________________________________________________________________

## Part 1: Your First LaTeX Document (20 min)

### Learning Goal

Compile a minimal LaTeX paper and understand the compilation workflow.

### Step 1: Create Paper Directory

```bash
# In terminal (or :!mkdir in Neovim)
mkdir -p ~/papers/my-first-paper
cd ~/papers/my-first-paper
```

### Step 2: Create LaTeX File

Open Neovim and create your first paper:

```bash
nvim paper.tex
```

**Type this minimal example** (copy-paste ready):

```latex
\documentclass{article}

% Metadata
\title{The Benefits of Plain Text Research}
\author{Your Name}
\date{\today}

\begin{document}

\maketitle

\section{Introduction}

This is my first academic paper using PercyBrain. Plain text workflows offer several advantages for researchers:

\begin{itemize}
  \item Version control with Git
  \item Long-term accessibility
  \item Tool independence
  \item Separation of content from formatting
\end{itemize}

\section{Conclusion}

PercyBrain makes academic writing efficient and reproducible.

\end{document}
```

**Save**: `:w`

### Step 3: Compile and View

**Start continuous compilation**:

```vim
:VimtexCompile
```

✅ **Expected**: Status line shows `vimtex: Compiling...` → `vimtex: Success`

**View PDF**:

```vim
:VimtexView
```

✅ **Expected**: Zathura opens showing your paper

### Step 4: Test Live Updates

1. **Keep Zathura open**
2. **In Neovim**, add text to Introduction section
3. **Save** (`:w`)
4. **Watch**: PDF auto-updates in Zathura

✅ **Success Checkpoint**: Changes in Neovim appear in PDF within 1-2 seconds

### Step 5: Navigate with Table of Contents

**Open TOC**:

```vim
:VimtexToc
```

✅ **Expected**: Split window shows sections/subsections

**Navigate**:

- Press `Enter` on section → cursor jumps to that section
- Press `q` → close TOC window

### Troubleshooting Part 1

| Problem                | Solution                                                    |
| ---------------------- | ----------------------------------------------------------- |
| ❌ `latexmk not found` | Install: `sudo apt install latexmk`                         |
| ❌ PDF doesn't open    | Check: `:echo g:vimtex_view_method` → should be `'zathura'` |
| ❌ Compilation errors  | Check: `:VimtexLog` for details                             |
| ⚠️ PDF doesn't update  | Stop/restart: `:VimtexStop` → `:VimtexCompile`              |

**✅ Part 1 Complete**: You've compiled your first LaTeX paper!

______________________________________________________________________

## Part 2: Citations and Bibliography (25 min)

### Learning Goal

Add citations to your paper using BibTeX and PercyBrain's citation browser.

### Step 1: Create Bibliography File

```bash
# Create bibliography in Zettelkasten directory
nvim ~/Zettelkasten/bibliography.bib
```

**Add sample entries**:

```bibtex
@article{knuth1984literate,
  title = {Literate Programming},
  author = {Knuth, Donald E.},
  journal = {The Computer Journal},
  volume = {27},
  number = {2},
  pages = {97--111},
  year = {1984}
}

@book{ahrens2017how,
  title = {How to Take Smart Notes},
  author = {Ahrens, S{\"o}nke},
  publisher = {CreateSpace},
  year = {2017}
}

@article{wilson2014best,
  title = {Best Practices for Scientific Computing},
  author = {Wilson, Greg and Aruliah, D. A. and others},
  journal = {PLOS Biology},
  volume = {12},
  number = {1},
  year = {2014}
}
```

**Save**: `:w`

### Step 2: Browse Citations in Neovim

**Open your paper** (`nvim ~/papers/my-first-paper/paper.tex`)

**Launch citation browser**:

```vim
:lua require('percybrain.bibtex').browse()
```

✅ **Expected**: Telescope fuzzy finder opens with bibliography entries

**Try it**:

1. Type `knuth` → entry highlights
2. Press `Ctrl+p` → preview window shows full BibTeX
3. Press `Enter` → inserts `[@knuth1984literate]` (Pandoc markdown format)

⚠️ **Note**: `[@key]` is Pandoc markdown syntax. For LaTeX, we'll use `\cite{key}` (see Step 3).

### Step 3: Add Citations to LaTeX

**Update paper.tex** to use citations:

```latex
\documentclass{article}

% Bibliography package
\usepackage[style=apa,backend=biber]{biblatex}
\addbibresource{/home/percy/Zettelkasten/bibliography.bib}

\title{The Benefits of Plain Text Research}
\author{Your Name}
\date{\today}

\begin{document}

\maketitle

\section{Introduction}

Plain text workflows offer advantages for researchers \cite{wilson2014best}. The Zettelkasten method, popularized by \textcite{ahrens2017how}, emphasizes atomic notes and connections.

Knuth's literate programming \cite{knuth1984literate} demonstrates the value of combining narrative with code.

\section{Conclusion}

PercyBrain integrates these principles into a cohesive writing environment.

\printbibliography

\end{document}
```

**Key changes**:

- `\usepackage{biblatex}` → bibliography support
- `\addbibresource{path}` → links to your .bib file (use absolute path)
- `\cite{key}` → standard citation
- `\textcite{key}` → narrative citation (Ahrens (2017) says...)
- `\printbibliography` → bibliography section

**Save and compile**:

```vim
:w
:VimtexCompile
```

✅ **Expected**: PDF shows citations with \[Author, Year\] format

### Step 4: Add Citation from Research Note

**Create a literature note**:

```bash
nvim ~/Zettelkasten/permanent/lit-note-version-control.md
```

**Add frontmatter**:

```yaml
---
title: "Version Control for Research"
author: "Wilson, Greg"
source: "PLOS Biology"
year: 2014
tags:
  - research-methods
  - version-control
  - reproducibility
---

# Version Control for Research

Key findings:
- Version control prevents data loss
- Git enables collaboration
- Reproducible workflows essential for science
```

**Save** (`:w`)

**Generate BibTeX entry from note**:

```vim
:lua require('percybrain.bibtex').add_from_note()
```

✅ **Expected**:

1. BibTeX entry generated from frontmatter
2. Citation key copied to clipboard (e.g., `wilson2014version`)
3. Entry appended to `bibliography.bib`

**Verify**:

```bash
nvim ~/Zettelkasten/bibliography.bib
# Should see new entry at end of file
```

### Troubleshooting Part 2

| Problem                    | Solution                                                   |
| -------------------------- | ---------------------------------------------------------- |
| ❌ Citations show `[?]`    | Check: bibliography path is absolute, biber installed      |
| ❌ Browser doesn't open    | Verify: `~/Zettelkasten/bibliography.bib` exists           |
| ⚠️ Bibliography not found  | Run: `:VimtexClean` then `:VimtexCompile`                  |
| ❌ `add_from_note()` fails | Check: note has required frontmatter (title, author, year) |

**✅ Part 2 Complete**: You can browse, insert, and create citations!

______________________________________________________________________

## Part 3: Zettelkasten → Paper Workflow (25 min)

### Learning Goal

Transform research notes into structured paper sections.

### Step 1: Create Research Notes

**Create multiple interconnected notes**:

```bash
cd ~/Zettelkasten/permanent
nvim plain-text-benefits.md
```

**Note 1** (`plain-text-benefits.md`):

```markdown
---
title: "Benefits of Plain Text for Research"
tags:
  - research-methods
  - tools
  - productivity
---

# Benefits of Plain Text for Research

Plain text formats offer key advantages:

## Version Control
- Git tracks every change [@wilson2014best]
- Branching for experimental writing
- Collaboration via pull requests

## Longevity
- Readable in 50+ years
- No proprietary lock-in
- Simple migration between tools

## Interoperability
- Convert to any format (PDF, DOCX, HTML)
- Combine notes across projects
- Integrate with scripts and automation

See also: [[version-control-research]], [[markdown-latex-comparison]]
```

**Note 2** (`version-control-research.md`):

```markdown
---
title: "Version Control in Academic Writing"
tags:
  - version-control
  - git
  - collaboration
---

# Version Control in Academic Writing

Git provides:
- Atomic commits for each idea
- Revert to previous drafts
- Track contribution in co-authored papers [@wilson2014best]

Zettelkasten + Git = versioned knowledge graph

See also: [[plain-text-benefits]]
```

**Save both**: `:w`

### Step 2: Convert Notes to LaTeX with Pandoc

**Open first note**:

```bash
nvim ~/Zettelkasten/permanent/plain-text-benefits.md
```

**Convert to LaTeX**:

```vim
:Pandoc latex -o ~/papers/my-first-paper/sections/benefits.tex
```

✅ **Expected**: LaTeX file created in sections directory

**Review generated LaTeX**:

```bash
nvim ~/papers/my-first-paper/sections/benefits.tex
```

**Observe**:

- Markdown headers → `\section{}`, `\subsection{}`
- Lists → `\begin{itemize}`
- Citations → `\cite{key}` (if using `[@key]` syntax)
- Wiki links removed (manual cleanup needed)

### Step 3: Organize Paper Structure

**Create section files**:

```bash
mkdir -p ~/papers/my-first-paper/sections
cd ~/papers/my-first-paper
```

**File structure**:

```
~/papers/my-first-paper/
├── paper.tex              # Main document
├── sections/
│   ├── introduction.tex   # Converted from notes
│   ├── methods.tex
│   └── benefits.tex       # From Step 2
└── build/                 # Compiled outputs (auto-created)
```

**Update paper.tex** to use sections:

```latex
\documentclass{article}

\usepackage[style=apa,backend=biber]{biblatex}
\addbibresource{/home/percy/Zettelkasten/bibliography.bib}

\title{The Benefits of Plain Text Research}
\author{Your Name}
\date{\today}

\begin{document}

\maketitle

\tableofcontents

\input{sections/introduction.tex}
\input{sections/benefits.tex}
\input{sections/methods.tex}

\section{Conclusion}

Plain text workflows enable reproducible, version-controlled research.

\printbibliography

\end{document}
```

**Compile**:

```vim
:VimtexCompile
```

✅ **Expected**: Multi-section paper with table of contents

### Step 4: Iterative Writing Workflow

**Best practice loop**:

1. **Research** → Create Zettelkasten notes with citations
2. **Link** → Connect related notes (`[[wiki-links]]`)
3. **Convert** → `:Pandoc latex` on key notes
4. **Refine** → Clean up converted LaTeX, add details
5. **Integrate** → `\input{section.tex}` in main paper
6. **Review** → Continuous compilation updates PDF

**Pro tip**: Split windows for efficient workflow

```vim
:vsplit ~/Zettelkasten/permanent/my-note.md
# Edit note on left, paper.tex on right
# Convert → copy → refine → integrate
```

### Troubleshooting Part 3

| Problem                     | Solution                                                  |
| --------------------------- | --------------------------------------------------------- |
| ❌ Pandoc conversion fails  | Check: markdown syntax is valid                           |
| ⚠️ Wiki links in LaTeX      | Manual cleanup: remove `[[links]]` or convert to `\ref{}` |
| ❌ `\input` file not found  | Use relative paths: `sections/file.tex`                   |
| ⚠️ Duplicate bibliographies | Only one `\printbibliography` in main paper               |

**✅ Part 3 Complete**: You've built a paper from research notes!

______________________________________________________________________

## Part 4: Productivity Features (20 min)

### Learning Goal

Use advanced features for faster, more efficient writing.

### Feature 1: Concealment (Readable LaTeX)

**Default**: Already enabled (`conceallevel=2`)

**What it does**:

- `\alpha` displays as `α`
- `\sum` displays as `∑`
- `\rightarrow` displays as `→`

**Try it**:

```latex
\section{Mathematics}

The integral $\int_0^\infty e^{-x} dx = 1$ is fundamental.

Greek letters: $\alpha, \beta, \gamma, \delta$

Logic: $\forall x \in \mathbb{R}, \exists y : x \rightarrow y$
```

**Toggle concealment**:

```vim
:set conceallevel=0   " Show raw LaTeX
:set conceallevel=2   " Show concealed symbols (default)
```

✅ **Benefit**: Read LaTeX like rendered math

### Feature 2: Folding (Manage Large Documents)

**Folds automatically created for**:

- Sections (`\section{}`, `\subsection{}`)
- Environments (`\begin{...} \end{...}`)

**Navigation**:

```vim
zc    " Close fold under cursor
zo    " Open fold
za    " Toggle fold
zR    " Open all folds
zM    " Close all folds

]z    " Next fold
[z    " Previous fold
```

**Try it**: Open large paper, press `zM` → only section headers visible

✅ **Benefit**: Navigate 50+ page documents efficiently

### Feature 3: Grammar Checking (ltex-ls LSP)

**Check status**:

```vim
:LspInfo
```

✅ **Expected**: `ltex` attached to `.tex` buffers

**Grammar diagnostics**:

- Underlines grammar errors (blue squiggly)
- Spelling mistakes (red underline)
- Style suggestions (yellow underline)

**Navigate diagnostics**:

```vim
]d    " Next diagnostic
[d    " Previous diagnostic
gl    " Show diagnostic details (float window)
```

**Try it**: Write intentionally bad grammar

```latex
\section{Introduction}

This are a test of grammer checking. Their is errors here.
```

✅ **Expected**: Underlines on "are" (should be "is"), "grammer" (spelling), "Their" (wrong word)

**Accept suggestion**:

```vim
:lua vim.lsp.buf.code_action()
" Select correction from menu
```

### Feature 4: SyncTeX (Source ↔ PDF Navigation)

**Forward search** (Neovim → PDF):

```vim
:VimtexView
```

✅ **Expected**: PDF scrolls to location matching cursor in Neovim

**Inverse search** (PDF → Neovim):

1. **In Zathura**: `Ctrl+Click` on text
2. **Neovim**: Cursor jumps to source line

✅ **Benefit**: Review PDF → instantly jump to source to edit

### Feature 5: Quick Commands Reference

| Command          | Action                                    |
| ---------------- | ----------------------------------------- |
| `:VimtexCompile` | Start continuous compilation              |
| `:VimtexStop`    | Stop compilation                          |
| `:VimtexView`    | Open/sync PDF viewer                      |
| `:VimtexToc`     | Table of contents browser                 |
| `:VimtexClean`   | Remove auxiliary files (.aux, .log, etc.) |
| `:VimtexErrors`  | Show compilation errors                   |
| `:VimtexLog`     | View compilation log                      |
| `:VimtexInfo`    | Show vimtex status                        |

### Troubleshooting Part 4

| Problem                    | Solution                                                 |
| -------------------------- | -------------------------------------------------------- |
| ❌ ltex not starting       | Check: `:Mason`, ensure `ltex-ls` installed              |
| ⚠️ Concealment not working | Verify: `:set conceallevel?` → should be `2`             |
| ❌ SyncTeX not working     | Ensure: Zathura installed, `synctex=1` in LaTeX compiler |
| ⚠️ Folding disabled        | Check: `:set foldmethod?` → should be `expr`             |

**✅ Part 4 Complete**: You're using productivity features like a pro!

______________________________________________________________________

## Part 5: Complete Example Workflow (10 min)

### End-to-End Demonstration

**Scenario**: Write a short research paper on "The Pomodoro Technique for Academic Writing"

### Phase 1: Research (Zettelkasten)

```bash
cd ~/Zettelkasten/permanent
nvim pomodoro-research.md
```

**Create literature note**:

```yaml
---
title: "The Pomodoro Technique"
author: "Cirillo, Francesco"
year: 2006
source: "Time Management Method"
tags:
  - productivity
  - time-management
  - focus
---

# The Pomodoro Technique

Core principles:
- 25-minute focused work sessions
- 5-minute breaks between pomodoros
- Track completed pomodoros
- Avoid interruptions during sessions

Benefits for academic writing [@cirillo2006pomodoro]:
- Maintains focus during literature review
- Prevents burnout on long papers
- Measurable daily progress

See also: [[deep-work-research]], [[writing-productivity]]
```

**Add citation**:

```vim
:lua require('percybrain.bibtex').add_from_note()
```

✅ Citation added to bibliography

### Phase 2: Draft (LaTeX)

```bash
mkdir -p ~/papers/pomodoro-paper
cd ~/papers/pomodoro-paper
nvim paper.tex
```

**Start with template**:

```latex
\documentclass{article}
\usepackage[style=apa,backend=biber]{biblatex}
\addbibresource{/home/percy/Zettelkasten/bibliography.bib}

\title{The Pomodoro Technique for Academic Writing}
\author{Your Name}
\date{\today}

\begin{document}
\maketitle

\section{Introduction}

Time management is critical for productive academic writing. The Pomodoro Technique \cite{cirillo2006pomodoro} offers a structured approach to focused work.

\section{Methodology}

This study applies the Pomodoro Technique to academic writing workflows:

\begin{itemize}
  \item 25-minute writing sprints
  \item 5-minute breaks for reflection
  \item Track completed sections per pomodoro
\end{itemize}

\section{Results}

Preliminary findings suggest increased daily word count and reduced procrastination.

\section{Conclusion}

The Pomodoro Technique integrates well with PercyBrain's academic writing environment.

\printbibliography
\end{document}
```

**Start compilation**:

```vim
:VimtexCompile
```

### Phase 3: Review (PDF + Grammar)

**View PDF**:

```vim
:VimtexView
```

**Check grammar** (ltex-ls runs automatically):

```vim
]d    " Navigate to next diagnostic
gl    " View suggestion
```

**Use SyncTeX**: Click in PDF → jump to source → edit → auto-recompile

### Phase 4: Refine (Integrate Notes)

**Convert research note**:

```bash
nvim ~/Zettelkasten/permanent/pomodoro-research.md
```

```vim
:Pandoc latex -o ~/papers/pomodoro-paper/sections/literature.tex
```

**Add to paper**:

```latex
\section{Literature Review}
\input{sections/literature.tex}
```

### Phase 5: Finalize

**Clean build artifacts**:

```vim
:VimtexClean
```

**Final compilation**:

```vim
:VimtexCompile
```

**Result**: `~/papers/pomodoro-paper/paper.pdf`

✅ **Complete paper** with citations, bibliography, sections from research notes

______________________________________________________________________

## Next Steps

**You've learned**:

- ✅ LaTeX compilation with VimTeX
- ✅ Citation management with BibTeX
- ✅ Research notes → paper sections workflow
- ✅ Productivity features (folding, grammar, SyncTeX)

**Continue learning**:

1. **Advanced LaTeX**: Figures, tables, custom commands

   - Reference: `LATEX_REFERENCE.md`

2. **Zettelkasten workflows**: Permanent notes, fleeting notes, literature notes

   - Tutorial: `ZETTELKASTEN_TUTORIAL.md`

3. **Collaboration**: Git workflows for co-authored papers

   - How-to: `GIT_COLLABORATION_HOWTO.md`

4. **Publishing**: Journal submission, DOCX conversion

   - How-to: `PUBLISHING_HOWTO.md`

5. **Automation**: Custom snippets, templates, build scripts

   - Reference: `AUTOMATION_REFERENCE.md`

**Recommended next tutorial**: `ZETTELKASTEN_TUTORIAL.md` (if not completed)

______________________________________________________________________

## Troubleshooting

### Common Issues

**LaTeX won't compile**:

```vim
:VimtexErrors    " View errors
:VimtexLog       " Check full log
```

**Bibliography not showing**:

```bash
# Ensure biber installed
which biber

# Clean and rebuild
:VimtexClean
:VimtexCompile
```

**ltex-ls not providing suggestions**:

```vim
:LspInfo         " Check if ltex attached
:Mason           " Install ltex-ls if missing
```

**Zathura not opening**:

```vim
:echo g:vimtex_view_method    " Should be 'zathura'
# If not installed:
# sudo apt install zathura
```

**Citations show \[?\]**:

- Verify bibliography path is absolute
- Check citation keys match .bib file
- Run biber manually: `biber paper` (in paper directory)

### Get Help

**Documentation**:

- Reference: `LATEX_REFERENCE.md`
- Troubleshooting: `TROUBLESHOOTING_GUIDE.md`
- Keybindings: `KEYBINDINGS_REFERENCE.md`

**Community**:

- VimTeX wiki: https://github.com/lervag/vimtex/wiki
- PercyBrain discussions: GitHub issues

______________________________________________________________________

## Summary

**Workflow recap**:

```
Research (Zettelkasten notes)
  ↓
Add citations (BibTeX browser)
  ↓
Convert notes (Pandoc)
  ↓
Write paper (LaTeX in Neovim)
  ↓
Compile (VimTeX continuous mode)
  ↓
Review (Zathura with SyncTeX)
  ↓
Finalize (Grammar check, clean, export)
```

**Key commands**:

```vim
:VimtexCompile                        " Start compilation
:VimtexView                           " Open PDF
:lua require('percybrain.bibtex').browse()   " Browse citations
:Pandoc latex                         " Convert markdown
:VimtexToc                            " Table of contents
```

**✅ Congratulations!** You've completed your first academic paper in PercyBrain.

______________________________________________________________________

**Last reviewed**: 2025-10-19 **Estimated completion time**: 60-90 minutes **Difficulty**: Beginner **Prerequisites**: Neovim, PercyBrain, LaTeX installation
