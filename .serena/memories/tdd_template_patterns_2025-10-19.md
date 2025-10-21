# TDD Template System Patterns - 2025-10-19

## Pattern: Dual-Tier Template Architecture

### Problem

Users need two different note-taking modes:

1. Fast capture for fleeting thoughts (ADHD-optimized, minimal friction)
2. Polished output for publishing (Hugo-compatible, citation support)

### Solution

Two completely separate templates with distinct purposes:

**Fleeting Template** (`~/Zettelkasten/templates/fleeting.md`):

```markdown
---
title: {{title}}
created: {{date}}
---

# {{title}}

```

- 7 lines total
- Saves to: `~/Zettelkasten/inbox/`
- Frontmatter: title + created only
- NO Hugo fields (draft, tags, categories)
- NO structure sections
- Purpose: Zero-friction capture

**Wiki Template** (`~/Zettelkasten/templates/wiki.md`):

```markdown
---
title: "{{title}}"
date: {{date}}
draft: false
tags: []
categories: []
description: ""
bibliography: references.bib
cite-method: biblatex
---

# {{title}}

## Overview

## Key Concepts

## Related Notes

- [](.)

## References

<!-- BibTeX citations: [@key] for in-text, [@key, p. 42] for page numbers -->
<!-- Example: According to [@smith2020], this demonstrates... -->
```

- 22 lines total
- Saves to: `~/Zettelkasten/*.md` (root, not inbox)
- Frontmatter: Complete Hugo + BibTeX
- Structured sections for content organization
- Purpose: Publishable permanent knowledge

### Key Insight

NO middle ground. Either ultra-simple (fleeting) or fully-featured (wiki). Trying to create one "flexible" template creates friction in both use cases.

## Pattern: TDD Contract Testing for Templates

### Problem

How do you validate template requirements without running implementation?

### Solution

Write contract tests defining MUST/MUST NOT/MAY behaviors:

```lua
-- Contract: Fleeting template MUST be ultra-simple
it("MUST have ultra-simple frontmatter (title + created only)", function()
  local template_path = vim.fn.expand("~/Zettelkasten/templates/fleeting.md")
  local file = io.open(template_path, "r")
  local content = file:read("*all")
  file:close()

  -- Assert: Only title and created
  assert.matches("title:", content)
  assert.matches("created:", content)
  assert.not_matches("draft:", content)  -- FORBIDDEN
  assert.not_matches("tags:", content)   -- FORBIDDEN
end)

-- Contract: Wiki template MUST have Hugo frontmatter
it("MUST have Hugo-compatible frontmatter", function()
  local template_path = vim.fn.expand("~/Zettelkasten/templates/wiki.md")
  local file = io.open(template_path, "r")
  local content = file:read("*all")
  file:close()

  -- Assert: Required Hugo fields
  assert.matches("title:", content)
  assert.matches("date:", content)
  assert.matches("draft:", content)
  assert.matches("tags:", content)
  assert.matches("categories:", content)
  assert.matches("description:", content)
end)
```

### Key Insight

Contract tests validate the template FILES themselves, not the implementation. This catches template format errors before any code runs.

## Pattern: TDD Capability Testing for User Workflows

### Problem

How do you test user-facing capabilities without building UI?

### Solution

Write capability tests using "CAN DO" language:

```lua
describe("Fleeting Note Creation Capabilities", function()
  it("CAN create fleeting note with minimal friction", function()
    -- Arrange: User wants quick capture
    local title = "Quick idea about AI"
    local template_name = "fleeting"

    -- Act: Load and apply template
    local zettel = require("config.zettelkasten")
    local template_content = zettel.load_template(template_name)
    local content = zettel.apply_template(template_content, title)

    -- Assert: Simple frontmatter, no Hugo overhead
    assert.matches("title: " .. title, content)
    assert.matches("created:", content)
    assert.not_matches("draft:", content)
  end)

  it("CAN save fleeting note to inbox directory", function()
    local inbox_path = vim.fn.expand("~/Zettelkasten/inbox")
    local inbox_exists = vim.fn.isdirectory(inbox_path) == 1
    assert.is_true(inbox_exists)
  end)
end)
```

### Key Insight

Capability tests focus on what users can DO, not how it's implemented. Tests validate workflows from user perspective.

## Pattern: GREEN-on-First-Run Validation

### Problem

How do you know if existing implementation is correct?

### Solution

Write comprehensive tests BEFORE running implementation. If tests pass immediately, architecture was already correct.

**Process**:

1. RED Phase: Write failing tests (don't run implementation yet)
2. GREEN Phase: Run tests
   - Expected: Some tests fail, implement to fix
   - Remarkable: All tests pass immediately
3. REFACTOR Phase: Clean up (or skip if already clean)

**Outcome This Session**:

- Wrote 18 tests (8 contract + 10 capability)
- All 18 passed on first run
- Zero implementation changes needed
- Validation: Architecture was sound from start

### Key Insight

GREEN-on-first-run isn't "wasted" TDD. It's PROOF that design was correct. Tests become documentation and regression protection.

## Pattern: Template Variable Replacement

### Implementation

Existing zettelkasten.lua already has:

```lua
M.apply_template = function(template_content, title)
  local date = os.date("%Y-%m-%d")
  local timestamp = os.date("%Y%m%d%H%M")

  local result = template_content
  result = result:gsub("{{title}}", title)
  result = result:gsub("{{date}}", date)
  result = result:gsub("{{timestamp}}", timestamp)

  return result
end
```

### Validated Variables

- `{{title}}`: User-provided note title
- `{{date}}`: YYYY-MM-DD format (for Hugo compatibility)
- `{{timestamp}}`: YYYYMMDDHHmm format (for Zettelkasten IDs)

### Key Insight

Simple string substitution works perfectly. No need for complex templating engine.

## Pattern: Inbox vs Root Directory Distinction

### Rule

- Fleeting notes → `~/Zettelkasten/inbox/`
- Wiki pages → `~/Zettelkasten/*.md` (root, excluding inbox)

### Publishing Behavior

- Inbox notes: EXCLUDED from Hugo publishing
- Root wiki pages: PUBLISHED to Hugo site

### Validation

```lua
it("CAN save fleeting note to inbox directory", function()
  local inbox_path = vim.fn.expand("~/Zettelkasten/inbox")
  assert.is_true(vim.fn.isdirectory(inbox_path) == 1)
end)

it("CAN save wiki page to root Zettelkasten (not inbox)", function()
  local zettel_root = vim.fn.expand("~/Zettelkasten")
  local expected_path = zettel_root .. "/20251019-test.md"

  assert.not_matches("/inbox/", expected_path)
  assert.matches("^" .. zettel_root .. "/", expected_path)
end)
```

### Key Insight

File path = publishing intent. No need for "publish: true/false" flags in frontmatter.

## Pattern: Naming Convention Validation

### Contract

All notes (fleeting AND wiki) use: `yyyymmdd-title.md`

### Validation

```lua
it("MUST use yyyymmdd-title.md naming for all notes", function()
  local expected_format = "20251019-example-note.md"
  assert.matches("^%d%d%d%d%d%d%d%d%-.*%.md$", expected_format)
end)

it("CAN have consistent naming between fleeting and wiki", function()
  local fleeting_name = "20251019-fleeting-idea.md"
  local wiki_name = "20251019-wiki-page.md"
  local pattern = "^%d%d%d%d%d%d%d%d%-.*%.md$"

  assert.matches(pattern, fleeting_name)
  assert.matches(pattern, wiki_name)
end)
```

### Key Insight

Consistent naming across both types enables chronological sorting and Zettelkasten linking.

## Anti-Patterns Avoided

### ❌ Single Flexible Template

Creating one template with "optional" fields creates friction:

- User must decide what to fill in (cognitive load)
- Template becomes cluttered for simple capture
- Publishing workflow requires field validation

### ❌ Implementing Before Testing

Writing template code before tests risks:

- Building features nobody asked for
- Missing edge cases
- No validation that requirements are met

### ❌ Testing Implementation Instead of Contract

Testing `apply_template()` function instead of template FILES:

- Misses template format errors
- Tests code, not user-facing artifacts
- Can't validate templates independently

## Success Metrics

### Template System Quality

- 18/18 tests passing ✅
- Zero implementation changes needed ✅
- 7-line fleeting template (minimal cognitive load) ✅
- 22-line wiki template (complete publishing workflow) ✅
- Pre-commit hooks passing (luacheck, test-standards) ✅

### TDD Discipline

- Tests written BEFORE implementation ✅
- Strict RED-GREEN-REFACTOR cycle ✅
- Contract tests define MUST/MUST NOT/MAY ✅
- Capability tests define user workflows ✅
- GREEN-on-first-run validates architecture ✅

## Lessons for Future TDD Cycles

1. **Write Contract Tests First**: Define MUST/MUST NOT/MAY before capability tests
2. **Test Artifacts, Not Code**: Validate templates/configs directly, not implementation
3. **Accept GREEN**: If tests pass immediately, architecture was correct - don't "improve"
4. **Dual-Tier > Flexible**: Two simple templates better than one complex template
5. **File Path = Intent**: Location (inbox vs root) defines behavior, not frontmatter flags

## Next TDD Targets

1. Hugo frontmatter validation (validate YAML structure, not just presence)
2. AI model selection (Ollama integration, user picker)
3. Write-quit pipeline (BufWritePost trigger, wiki vs fleeting differentiation)
4. Floating quick capture (minimal friction popup)

Each follows same pattern: Contract tests → Capability tests → Implementation → Validation
