# Documentation Strategy - PercyBrain AI Context Management

**Purpose**: Comprehensive strategy for maintaining efficient, accurate, and navigable documentation **Principles**: Token efficiency, Diataxis framework, single source of truth, systematic validation

## 1. Diataxis Framework (Document Type Classification)

### Four Document Types

**Tutorials** (learning-oriented):

- **Purpose**: Hands-on practice for first-time learners
- **Structure**: Sequential exercises with progressive complexity
- **Features**: Day-by-day progression, success checkpoints, common mistakes
- **Example**: ZETTELKASTEN_TUTORIAL.md (7-day journey, first 20 notes)
- **Duration**: 30 min to 7 days depending on scope
- **Quality Check**: Beginner can complete without prior knowledge

**How-To Guides** (task-oriented):

- **Purpose**: Solve specific problems, achieve concrete goals
- **Structure**: Goal-focused, can be read in any order
- **Features**: Step-by-step workflows, quick reference checklists
- **Example**: ZETTELKASTEN_DAILY_PRACTICE.md (5-min morning routine)
- **Duration**: Single session (5-90 min)
- **Quality Check**: User can quickly find and apply solution

**Reference** (information-oriented):

- **Purpose**: Lookup facts, comprehensive catalogs
- **Structure**: Tables, indexes, complete inventories
- **Features**: Searchable, complete, no task instructions
- **Example**: KEYBINDINGS_REFERENCE.md (100+ bindings in tables)
- **Duration**: Quick lookup (seconds to minutes)
- **Quality Check**: Information is findable and accurate

**Explanation** (understanding-oriented):

- **Purpose**: Deepen conceptual understanding
- **Structure**: Conceptual depth, architectural reasoning
- **Features**: Why questions, design rationale, philosophy
- **Example**: COGNITIVE_ARCHITECTURE.md (distributed cognition theory)
- **Duration**: Extended reading (15-45 min)
- **Quality Check**: User understands "why" not just "how"

### Diataxis Compliance Rules

1. **No Mixed Types**: Each document belongs to exactly one category
2. **Clear Separation**: Tutorial ≠ How-to (hands-on learning vs. task completion)
3. **Consistent Voice**: Tutorials use "you will learn", How-tos use "to do X"
4. **Cross-Reference**: Link between types ("Tutorial → How-to for ongoing practice")

### Tutorial vs. How-to Distinction (Critical)

**Tutorial**: "Day 1 Exercise 1.1: Create your first atomic note" **How-to**: "Morning routine checklist: 5-minute daily note + review"

**Tutorial Conversion Pattern** (How-to → Tutorial):

1. Workflows → Day-by-day progression
2. "How to do X" → "Exercise: Do X and observe Y"
3. Add goals, checkpoints, common mistakes
4. Progressive complexity (simple → advanced over time)
5. Assume no prior knowledge (beginner-friendly)

## 2. Token Optimization Patterns

### Symbol-Enhanced Communication

**Technical Symbols**:

- `→` leads to, implies (auth.js:45 → 🛡️ security risk)
- `✅` completed, passed
- `❌` failed, error
- `⏳` pending, waiting
- `🔄` in progress
- `≥` greater than or equal
- `|` separator for grouped items

**Domain Symbols**:

- `⚡` performance
- `🔍` analysis
- `🔧` configuration
- `🛡️` security
- `📦` deployment
- `🎨` design/UI
- `📚` tutorials
- `📖` reference
- `💡` explanation

### Information Grouping Syntax

**Pattern**: `{item1(count1)|item2(count2)|...}`

**Example**:

```
Before (15 lines):
lua/plugins/
├── zettelkasten/      # 6 plugins
├── ai-sembr/          # 3 plugins
├── prose-writing/     # 14 plugins

After (2 lines):
lua/plugins/{zettelkasten(6)|ai-sembr(3)|prose-writing(14)|
academic(4)|publishing(3)|org-mode(3)|lsp(3)|completion(5)}
```

**Savings**: 60% space reduction for lists

### Table Compression

**Before (verbose - 12 lines)**:

```markdown
| Command | Action |
|---------|--------|
| :PercyNew | Create new note |
| :PercyDaily | Open daily note |
| :PercyInbox | Quick capture |
```

**After (compressed - 3 lines)**:

```markdown
Commands: `:PercyNew` (new note) | `:PercyDaily` (daily) |
`:PercyInbox` (capture) | `:PercyPublish` (export)
```

**When NOT to compress**: User-facing tutorials (clarity > compression)

### Reference Model (Anti-Duplication)

**Anti-Pattern**: Duplicating information across multiple docs **Pattern**: Create single source of truth, reference elsewhere

**Example**:

```markdown
# CLAUDE.md (index)
Keyboard shortcuts → lua/config/keymaps.lua
Plugin architecture → PERCYBRAIN_DESIGN.md:458-612

# Not this:
[200 lines of duplicated keyboard shortcuts]
[154 lines of duplicated architecture explanation]
```

### Hierarchical Information Density

**Level 1**: High-level overview with symbols **Level 2**: Mid-level detail with grouping **Level 3**: Deep detail by reference only

**Example**:

```markdown
# Level 1: Overview
PercyBrain = Zettelkasten(PRIMARY) + AI-Writing(SECONDARY)

# Level 2: Components
Core: {IWE-LSP|SemBr|AI-Draft} → Details in PERCYBRAIN_DESIGN.md

# Level 3: Reference (not duplicated)
Full specs → docs/specs/*.md
```

### Token Efficiency Metrics

**Target**: ≥2.0x compression ratio **Formula**: `Token_Efficiency = (Information_Density × Symbol_Usage) / Character_Count`

**CLAUDE.md Example**:

- Before: 621 lines, ~15K tokens
- After: 124 lines, ~3K tokens
- Reduction: 80% token savings
- Information Preserved: ~95%

### When to Apply Token Optimization

- ✅ AI context files (CLAUDE.md, project instructions)
- ✅ Completion reports (claudedocs/\*.md)
- ✅ Architecture overviews (high-level design docs)
- ❌ User-facing tutorials (clarity > compression)
- ❌ API documentation (precision > brevity)

## 3. PROJECT_INDEX.json Management

### Purpose and Structure

**Machine-Readable Index**: Systematic project structure documentation **Use Cases**: AI navigation, architecture validation, cross-reference verification **Location**: Project root (version controlled) **Format**: JSON with metadata, architecture, documentation sections

### Key Sections

```json
{
  "metadata": {
    "version": "1.1.0",
    "generated": "2025-10-21T...",
    "branch": "workflow/zettelkasten-wiki-ai-pipeline"
  },
  "architecture": {
    "workflows": 14,
    "workflow_imports": 17,
    "plugins": 68,
    "distinction": "14 directories → 17 lazy.nvim imports (prose-writing subdirs)"
  },
  "documentation_map": {
    "tutorials": [...],
    "how_to": [...],
    "reference": [...],
    "explanation": [...]
  }
}
```

### Critical Accuracy Requirements

1. **Verify Before Update**: Always validate counts against actual codebase
2. **Distinguish Concepts**: Directory structure ≠ import statements (lazy.nvim architecture)
3. **Git Synchronization**: Keep metadata current with branch and commit context
4. **File Existence**: Validate all documented paths exist

### Architecture Clarity Pattern

**Before**: "18 workflows" (ambiguous) **After**: "14 workflows (17 imports)" (precise)

**Why**: lazy.nvim `{ import = "plugins.X" }` statements ≠ directory count when subdirectories exist (prose-writing has 4 subdirs that each get separate import).

### Update Workflow

1. **Systematic Validation**: Run `/sc:index --update` for accuracy checks
2. **Cross-Reference Validation**: Verify all documented files exist
3. **Architecture Verification**: Count workflows, imports, plugins against codebase
4. **Metadata Synchronization**: Update git branch, commits, working tree status
5. **Version Bump**: Increment version on structural changes

### Quality Metrics

- Architecture Counts: Verified against actual codebase (not assumptions)
- File Existence: 100% validation of all documented paths
- Git Synchronization: Current branch, commits, working tree status
- Metadata Currency: Generation date, version, branch tracking

## 4. CLAUDE.md Best Practices

### Purpose and Scope

**Target Audience**: AI assistants (Claude, GPT, etc.) **Purpose**: Efficient context loading for AI-assisted development **Length**: 124-200 lines (target \<3K tokens) **Updates**: After major refactors, new workflows, architecture changes

### Required Sections

1. **Header**: Project overview + Testing status + Architecture counts
2. **Documentation Map**: Diataxis-organized navigation (tutorials/how-to/reference/explanation)
3. **Architecture Essentials**: Bootstrap sequence, plugin structure, critical patterns
4. **Key Workflows**: Zettelkasten (PRIMARY), Dev Workflow, Test Architecture
5. **Critical Patterns**: lazy.nvim detection, environment variables, plugin specs
6. **Dependencies**: Required tools with verification commands
7. **Troubleshooting**: Common issues with quick solutions
8. **Status**: Active development, testing metrics, philosophy shifts

### Header Format

```markdown
# CLAUDE.md - PercyBrain AI Context Index

**Project**: Neovim Zettelkasten + AI Writing Environment
**Testing**: 44/44 passing, 6/6 standards
**Arch**: 68 plugins/14 workflows (17 imports)
```

**Why**: Immediate context for AI assistants (project type, quality status, architecture)

### Documentation Map Organization

**Follow Diataxis Strictly**:

```markdown
## Documentation Map

**🎓 Tutorials** (learning-oriented):
- `docs/tutorials/GETTING_STARTED.md` → Zero to first linked note (30 min)

**📖 How-To Guides** (task-oriented):
- `docs/how-to/ZETTELKASTEN_DAILY_PRACTICE.md` → Quick reference

**📋 Reference** (information-oriented):
- `docs/reference/KEYBINDINGS_REFERENCE.md` → Complete keymap catalog

**💡 Explanation** (understanding-oriented):
- `docs/explanation/WHY_PERCYBRAIN.md` → Problems solved, philosophy
```

**Navigation Quality**: ≤3 clicks to any document from CLAUDE.md

### Architecture Essentials

**Bootstrap Sequence**: Critical for debugging blank screen issues

```markdown
**Bootstrap**: `init.lua` → `require('config')` →
`lua/config/init.lua` → lazy.nvim → `lua/plugins/init.lua` → 14 workflows
```

**Plugin Structure**: Compressed syntax with counts

```markdown
lua/plugins/{zettelkasten(6)|ai-sembr(3)|prose-writing(14)|
academic(4)|publishing(3)|org-mode(3)|lsp(3)|completion(5)}
```

**Critical Warnings**: MUST include for common failures

````markdown
**⚠️ CRITICAL**: `lua/plugins/init.lua` MUST have explicit imports:
```lua
return {
  { import = "plugins.zettelkasten" },
  -- ... all 14 workflows
}
````

Without imports → blank screen (lazy.nvim stops auto-scan)

````

### Key Workflows

**Zettelkasten (PRIMARY)**: Most important for project identity
**Dev Workflow**: Testing, quality checks, setup commands
**Test Architecture**: Philosophy, structure, execution commands

### Token Efficiency Applied

- Symbol shortcuts: ✅/❌/⏳/🔄
- Grouped information: {workflow(count)|...}
- Reference model: Link to detailed docs, no duplication
- Hierarchical density: Overview → Details → Deep dive

### Cross-Reference Validation

**Before Committing**: Validate all file paths exist
**Command**: `/sc:index --update` for systematic validation
**Result**: 100% documentation integrity (no broken links)

## 5. Completion Reports (claudedocs/)

### Purpose

**Session Documentation**: Post-operation completion reports
**Retention**: Session outcomes, metrics, lessons learned
**Location**: `claudedocs/COMPLETION_[task-name]_[date].md`
**Archival**: Git history (permanent session record)

### Required Sections

```markdown
# [Task Name] - Completion Report

**Date**: YYYY-MM-DD
**Branch**: branch-name
**Duration**: Estimate
**Status**: Complete/Partial/Blocked

## Session Overview
[High-level summary of work completed]

## Work Completed
[Detailed breakdown with commits]

## Key Patterns & Learnings
[Reusable patterns for future sessions]

## Success Metrics Achieved
[Quantitative results against goals]

## Next Session Recommendations
[Clear roadmap for remaining work]

## Commands Used
[Git, validation, documentation commands]

## Key Takeaway
[Single most important lesson from session]
````

### Token Efficiency for Reports

**Apply Consolidation Patterns**:

- Symbol shortcuts for status tracking
- Grouped information for lists
- Reference model for detailed context
- Hierarchical density for readability

**Example**:

```markdown
## Work Completed

**Phase 5: Important Tier + Reference** (5 docs):
1. TROUBLESHOOTING_GUIDE.md (823 lines) ✅
2. KEYBINDINGS_REFERENCE.md (463 lines) ✅
3. MIGRATION_FROM_OBSIDIAN.md (1536 lines) ✅

**Commits**: 4e1edba (Phase 5), 2625d1c (Academic tutorial)
```

### Evidence-Based Documentation Pattern

**Git Archaeology**:

1. Analyze commit history for recurring issues
2. Identify patterns (blank screen fixes, plugin conflicts, LSP failures)
3. Document solutions with commit references
4. Cross-reference in completion reports

**Example**:

```markdown
**Evidence-based**: Commits af3ae06, b488692, f221e35 (recurring fixes)
```

## 6. Document Type Classification System

### Serena Memories (Cross-Session Learning)

**Purpose**: Permanent project knowledge, reusable patterns **Location**: `.serena/memories/` **Retention**: Permanent (core knowledge base) **Naming**: `pattern_name_YYYY-MM-DD.md` or descriptive name **Content**: Architecture patterns, testing strategies, lessons learned

**Examples**:

- `documentation_strategy` (this document)
- `percy_development_patterns` (quality-first principles)
- `testing_best_practices` (Kent Beck framework)

### Claudedocs Reports (Session Outcomes)

**Purpose**: Post-operation completion reports **Location**: `claudedocs/` **Retention**: Session-specific, archivable via git history **Naming**: `COMPLETION_[task]_YYYY-MM-DD.md` **Content**: Session metrics, work completed, lessons, next steps

### Scratch Journal (AI Exploration)

**Purpose**: AI exploration and experimentation **Location**: `claudedocs/scratches/` **Retention**: Session-specific, can be archived or deleted **Naming**: `[experiment]_[date].md` **Content**: Prototypes, experiments, exploratory work

### Project Docs (User-Facing)

**Purpose**: User-facing documentation **Location**: `ROOT` or `docs/` **Retention**: Permanent, version controlled **Naming**: Diataxis-based organization (tutorials/, how-to/, reference/, explanation/) **Content**: Tutorials, guides, references, explanations

## 7. Documentation Consolidation Workflow

### Phase-Based Approach

**Phase 1**: ✅ Quality baseline (all hooks passing) **Phase 2**: ✅ Extract lessons → Serena memories **Phase 3**: ✅ Consolidate structure (Diataxis organization) **Phase 4**: ✅ Update cross-references (validate links) **Phase 5**: ✅ Validate completeness (systematic checks) **Phase 6**: ✅ Delete redundant files (preserve via git)

### Anti-Duplication Strategy

1. **Identify**: Find overlapping content across docs
2. **Classify**: Determine canonical source for each topic
3. **Extract**: Create single source of truth
4. **Reference**: Replace duplicates with links
5. **Validate**: Ensure no broken references

**Example Consolidation**:

```
BEFORE:
- CLAUDE.md: 200 lines of keyboard shortcuts
- README.md: 150 lines of keyboard shortcuts
- keymaps.lua: Source of truth

AFTER:
- CLAUDE.md: "Shortcuts → lua/config/keymaps.lua"
- README.md: "Complete reference → CLAUDE.md"
- keymaps.lua: Single source of truth
```

### Quality Gates

**Before Consolidation**:

1. All tests passing (quality baseline)
2. Git commit created (rollback point)
3. Reference validation (no broken links)
4. Symbol legend added (user comprehension)

**After Consolidation**:

1. Information preserved ≥90%
2. Token efficiency ≥2.0x
3. Cross-references validated
4. User feedback incorporated

## 8. Validation Workflows

### Cross-Reference Validation

**Systematic Check**: `/sc:index --update` **Process**:

1. Extract all file paths from CLAUDE.md, README.md
2. Validate each path exists in filesystem
3. Report broken links for immediate fixing
4. Update metadata (generation date, git state)

**Target**: 100% documentation integrity (no broken links)

### Architecture Accuracy Verification

**Critical Checks**:

1. Count workflows (directories in lua/plugins/)
2. Count imports (lazy.nvim imports in init.lua)
3. Count plugins (files excluding init.lua)
4. Verify bootstrap sequence accuracy
5. Validate environment variables

**Why**: Previous errors (18 workflows vs. 14 actual) caused confusion

### Git Synchronization

**Update on Every Major Change**:

- Current branch name
- Recent commits (last 3-5)
- Working tree status
- Generation timestamp

**Why**: AI assistants need current context, not stale metadata

## 9. Integration with Development Workflow

### Serena Memory Usage

**Session Start**: `list_memories()` → Review relevant patterns **During Work**: Reference memories for established patterns **Session End**: Update memories with new learnings

**Key Memories**:

- `documentation_strategy` (this document)
- `percy_development_patterns` (quality principles)
- `testing_best_practices` (test architecture)
- `codebase_structure` (architecture understanding)

### Git Integration

**Branch Strategy**: Feature branches for major consolidation **Commit Pattern**: Conventional commits with scope **Pre-commit Hooks**: All 14 passing before consolidation commits **Merge Strategy**: Squash merge for consolidation branches

### Testing Integration

**Quality Baseline**: All tests passing before documentation updates **Post-Update Validation**: Run `mise test:quick` after major changes **Pre-commit Validation**: mdformat, yamllint, validate-links hooks

## 10. Common Patterns and Anti-Patterns

### Patterns to Follow

✅ **Diataxis Compliance**: Strict category separation (tutorial/how-to/reference/explanation) ✅ **Token Efficiency**: Symbol shortcuts, grouping, reference model ✅ **Single Source of Truth**: No content duplication across docs ✅ **Systematic Validation**: Cross-reference checks, architecture verification ✅ **Evidence-Based**: Git archaeology for troubleshooting guides ✅ **Progressive Complexity**: Tutorials build from simple → advanced ✅ **Cross-Reference**: Link between doc types (tutorial → how-to for practice)

### Anti-Patterns to Avoid

❌ **Mixed Document Types**: Tutorial with reference material embedded ❌ **Over-Compression**: Symbols without context confuse readers ❌ **Duplication**: Same content in multiple locations ❌ **Broken References**: Links to non-existent files ❌ **Stale Metadata**: Outdated git branch, commits, architecture counts ❌ **Assumption-Based Counts**: Architecture metrics without verification ❌ **Verbose Tables**: When inline compression would work

## 11. Success Metrics

### Documentation Quality

- **Diataxis Compliance**: 100% (all docs properly categorized)
- **Cross-Reference Integrity**: 100% (no broken links)
- **Architecture Accuracy**: 100% (counts verified against codebase)
- **Metadata Currency**: 100% (git state synchronized)
- **Token Efficiency**: ≥2.0x compression ratio for AI context
- **Information Preservation**: ≥90% unique content retained
- **Navigation Quality**: ≤3 clicks to any document

### Maintainability Improvements

- **File Reduction**: 70+ scattered docs → 21 organized files (70% reduction)
- **Update Efficiency**: Single source of truth reduces maintenance burden
- **Onboarding Speed**: Clear tutorial progression (30 min → 7 days learning paths)
- **AI Context Loading**: \<3K tokens for complete project context

### User Experience

- **Findability**: Diataxis structure enables quick navigation
- **Clarity**: Proper categorization matches user intent (learn vs. solve vs. lookup)
- **Completeness**: Tutorial → How-to → Reference progression supports full journey
- **Troubleshooting**: Evidence-based solutions address real user pain points

## 12. Future Maintenance

### Regular Updates

**Quarterly**: `/sc:index --update` for systematic validation **After Major Refactors**: Update CLAUDE.md, PROJECT_INDEX.json **New Workflows**: Add to appropriate Diataxis category **Deprecations**: Remove or archive obsolete documentation

### Version Control

**PROJECT_INDEX.json**: Semantic versioning (major.minor.patch)

- Major: Structural changes (new workflows, architecture shifts)
- Minor: Content additions (new docs, features)
- Patch: Metadata updates (git sync, cross-reference fixes)

**CLAUDE.md**: Update header metrics on significant changes **Completion Reports**: Archive in git history, don't delete

### Quality Monitoring

**Pre-commit Hooks**: Enforce quality gates automatically **Cross-Reference Checks**: Run validation before major commits **Token Efficiency**: Monitor CLAUDE.md size (\<3K tokens target) **User Feedback**: Incorporate into next documentation iteration

______________________________________________________________________

**Key Takeaway**: Documentation is a product, not a byproduct. Apply the same engineering rigor (testing, validation, versioning) to documentation as to code.
