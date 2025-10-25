# Issue #18: Quartz Custom Plugins - Phase 4 (Optional)

## Description

Develop custom Quartz plugins to enhance PercyBrain-specific publishing features. This is Phase 4 of the Quartz integration and should **wait for user feedback** after Phases 1-3 are complete and in production use.

## Context

- **Phase 1**: ✅ Complete - Symlink publishing working
- **Phase 2**: 🔜 Issue #15 - Mise integration + GitHub Pages
- **Phase 3**: 🔜 Issue #15 - Public deployment
- **Phase 4**: ⏸️ **THIS ISSUE** - Custom plugins (deferred)

**Rationale for Deferral**: Let the base system run in production first. Gather real-world usage data and user pain points before investing in custom development.

## Value

- **IWEFrontmatterEnhancer**: Auto-generate descriptions from note content
- **IWEPrivateFilter**: Advanced privacy filtering beyond basic patterns
- **IWEZettelkastenGraph**: Enhanced graph view with PercyBrain aesthetics

**User Impact**: Improved publishing workflow, better privacy controls, Blood Moon themed visualizations

## Tasks

### Task 1: User Feedback Collection (REQUIRED FIRST)

**Duration**: 2-4 weeks of production use **Estimated**: N/A - passive data gathering **Context Window**: N/A

**Requirements**:

- Deploy Phases 1-3 to production
- Use publishing workflow for 2-4 weeks minimum
- Document pain points, missing features, frustrations
- Prioritize plugin ideas based on actual need

**Data to Collect**:

- How often is frontmatter manually written?
- Do `.iwe` ignore patterns catch everything needed?
- Is the default Quartz graph sufficient?
- What Blood Moon aesthetic elements are most important?

**Acceptance Criteria**:

- [ ] Minimum 2 weeks production usage
- [ ] At least 10 publishing sessions completed
- [ ] Pain points documented
- [ ] User explicitly requests custom plugin development

**⚠️ BLOCKER**: Do NOT proceed to Task 2+ without completing this task

______________________________________________________________________

### Task 2: IWEFrontmatterEnhancer Plugin Design

**File**: `~/projects/quartz/quartz/plugins/transformers/iwe-frontmatter.ts` (future) **Estimated**: 1 hour (design only, not implementation) **Context Window**: Medium - plugin architecture research

**Requirements**:

- Research Quartz transformer plugin API
- Design auto-description generation algorithm
- Define configuration options
- Plan integration with existing frontmatter

**Design Considerations**:

**Input**: Markdown note without `description` field

```markdown
---
title: "Arepas Recipe"
date: 2025-10-20
tags:
  - cooking
  - venezuelan
---

Arepas are delicious cornmeal cakes from Venezuela...
```

**Output**: Same note with auto-generated description

```markdown
---
title: "Arepas Recipe"
date: 2025-10-20
description: "Arepas are delicious cornmeal cakes from Venezuela..."
tags:
  - cooking
  - venezuelan
---
```

**Algorithm Options**:

1. **First Sentence**: Use first complete sentence as description
2. **First N Characters**: Truncate first paragraph to 150 chars
3. **Summary Extraction**: Use common summarization patterns
4. **AI-Assisted**: Integrate with Ollama for smart summaries (advanced)

**Configuration**:

```typescript
interface IWEFrontmatterConfig {
  maxDescriptionLength: number;
  strategy: 'first-sentence' | 'first-paragraph' | 'truncate';
  skipIfExists: boolean;
  fallbackText: string;
}
```

**Acceptance Criteria**:

- [ ] Quartz transformer API documented
- [ ] Algorithm chosen based on user needs
- [ ] Configuration options defined
- [ ] Integration plan created
- [ ] No implementation code written yet (design only)

______________________________________________________________________

### Task 3: IWEPrivateFilter Plugin Design

**File**: `~/projects/quartz/quartz/plugins/filters/iwe-private.ts` (future) **Estimated**: 1 hour (design only) **Context Window**: Medium - privacy pattern analysis

**Requirements**:

- Analyze current `ignorePatterns` limitations
- Design advanced privacy filtering rules
- Define per-note privacy markers
- Plan integration with `.iwe/config.toml`

**Design Considerations**:

**Current Filtering** (basic glob patterns):

```typescript
ignorePatterns: [".iwe", ".git", "private", "ai"]
```

**Enhanced Filtering**:

```typescript
interface IWEPrivateFilterConfig {
  // Directory-based
  privateDirs: string[];

  // Tag-based filtering
  privateTags: string[];

  // Frontmatter-based
  checkDraftField: boolean;
  checkPublishField: boolean;

  // Content markers
  privateMarkers: string[];  // e.g., "PRIVATE:", "TODO:"

  // Advanced patterns
  regexPatterns: RegExp[];
}
```

**Example Usage**:

```markdown
---
title: "Secret Project Notes"
tags:
  - private  # ← Would be filtered
publish: false  # ← Would be filtered
---

PRIVATE: Don't publish this section...
```

**Acceptance Criteria**:

- [ ] Privacy requirements documented
- [ ] Filtering rules defined
- [ ] Configuration schema created
- [ ] Integration with IWE patterns planned
- [ ] No implementation code written yet

______________________________________________________________________

### Task 4: IWEZettelkastenGraph Plugin Design

**File**: `~/projects/quartz/quartz/components/IWEGraph.tsx` (future) **Estimated**: 2 hours (design only) **Context Window**: Large - graph visualization research

**Requirements**:

- Research Quartz graph component customization
- Design Blood Moon aesthetic styling
- Plan link weight visualization
- Define interaction enhancements

**Design Considerations**:

**Blood Moon Aesthetic**:

```typescript
interface IWEGraphTheme {
  backgroundColor: '#1a0000';  // Deep red background
  nodeColors: {
    default: '#ffd700',        // Gold nodes
    active: '#dc143c',         // Crimson active
    hover: '#ff4500',          // Orange-red hover
  };
  linkColors: {
    default: '#8b0000',        // Dark red links
    strong: '#ff0000',         // Bright red strong links
    weak: '#4a0000',           // Darker weak links
  };
  fontSize: number;
  nodeSize: {
    min: number;
    max: number;
    scaleFactor: 'backlinks' | 'tags' | 'recency';
  };
}
```

**Enhanced Features**:

- Link weight based on backlink count
- Node sizing based on connection importance
- Tag-based clustering
- Time-based coloring (recent notes brighter)
- Hover previews with note snippets

**Interaction Design**:

- Click node → navigate to note
- Hover node → show preview tooltip
- Double-click → open in new tab
- Drag nodes → rearrange layout (persistent?)

**Acceptance Criteria**:

- [ ] Blood Moon theme colors defined
- [ ] Graph enhancement features listed
- [ ] Interaction patterns documented
- [ ] Performance considerations noted
- [ ] No implementation code written yet

______________________________________________________________________

### Task 5: Plugin Implementation Plan & Prioritization

**File**: `claudedocs/QUARTZ_PLUGINS_IMPLEMENTATION_PLAN.md` (NEW) **Estimated**: 30 minutes **Context Window**: Medium - consolidation document

**Requirements**:

- Consolidate all plugin designs
- Prioritize based on user feedback
- Estimate implementation effort for each
- Create phased rollout plan

**Document Structure**:

```markdown
# Quartz Custom Plugins - Implementation Plan

## User Feedback Summary
[Summarize production usage data from Task 1]

## Plugin Prioritization

### Priority 1: [Plugin Name]
**Justification**: [Why this is most important based on feedback]
**Estimated Effort**: [hours]
**Dependencies**: [Quartz version, other plugins]

### Priority 2: [Plugin Name]
...

## Implementation Phases

### Phase 4.1: [Plugin Name] (2-4 hours)
- [ ] Setup plugin boilerplate
- [ ] Implement core functionality
- [ ] Add configuration options
- [ ] Write tests
- [ ] Document usage

### Phase 4.2: [Plugin Name] (2-4 hours)
...

## Testing Strategy
- Unit tests for transformers
- Integration tests with Quartz build
- Manual testing with real Zettelkasten
- Performance benchmarks

## Rollout Plan
1. Develop in feature branch
2. Test with subset of notes
3. Deploy to production
4. Monitor for issues
5. Iterate based on feedback
```

**Acceptance Criteria**:

- [ ] All plugin designs consolidated
- [ ] Priority order justified with user data
- [ ] Implementation phases defined
- [ ] Testing strategy documented
- [ ] Rollout plan created

______________________________________________________________________

## Dependencies

- **BLOCKER**: Issue #15 (Phases 2-3) must be complete
- **BLOCKER**: 2-4 weeks production usage required
- **BLOCKER**: User explicitly requests custom plugins
- **Requires**: Node.js, TypeScript, Quartz v4 plugin API knowledge
- **Optional**: Ollama integration (for AI-assisted descriptions)

## Estimated Effort

**Design Phase** (Tasks 1-5): 5-6 hours

- Task 1: 2-4 weeks passive + documentation
- Task 2: 1 hour (Frontmatter design)
- Task 3: 1 hour (Privacy filter design)
- Task 4: 2 hours (Graph design)
- Task 5: 30 min (Consolidation)

**Implementation Phase** (if approved): 6-12 hours

- IWEFrontmatterEnhancer: 2-3 hours
- IWEPrivateFilter: 2-3 hours
- IWEZettelkastenGraph: 3-6 hours (most complex)

**Total**: 11-18 hours (design + implementation)

## Success Criteria

**Design Phase**:

- [ ] All 5 design tasks completed
- [ ] User feedback collected and analyzed
- [ ] Plugins prioritized based on real needs
- [ ] Implementation plan approved by user

**Implementation Phase** (if user approves):

- [ ] Chosen plugin(s) implemented and tested
- [ ] Integration with Quartz build validated
- [ ] Documentation updated
- [ ] Production deployment successful

## Related Files

- `~/projects/quartz/quartz.config.ts` - Plugin registration
- `~/projects/quartz/quartz/plugins/` - Plugin directory
- `docs/how-to/QUARTZ_PUBLISHING.md` - User documentation
- `claudedocs/QUARTZ_PHASE1_COMPLETION_2025-10-23.md` - Phase 1 reference
- `claudedocs/QUARTZ_PLUGINS_IMPLEMENTATION_PLAN.md` - This plan (NEW)

## Notes

**⚠️ IMPORTANT**: This is an **OPTIONAL** issue marked for **DEFERRAL**

**DO NOT START** until:

1. Phases 1-3 are complete (Issue #15)
2. System has been used in production for 2-4 weeks
3. User has explicitly requested custom plugin development
4. Specific pain points are documented

**Rationale**: Premature optimization. Let the system prove itself first. Custom plugins are significant development effort and should only be undertaken if there's clear user need demonstrated through real-world usage.

**Alternative**: If basic Quartz works well enough, this entire issue can be **CLOSED AS WONTFIX** with no work done. That's a perfectly valid outcome.
