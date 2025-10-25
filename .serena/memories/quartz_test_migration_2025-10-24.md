# Hugo → Quartz Test Migration

**Date**: 2025-10-24 **Context**: PercyBrain switched from Hugo to Quartz v4 for static site generation

## Changes

- Created `lua/lib/quartz-frontmatter.lua` (161 lines) - Quartz v4 validation module
- Created `tests/contract/quartz_frontmatter_spec.lua` (18 tests, 100% passing)
- Deprecated `tests/contract/hugo_frontmatter_spec.lua` → `.deprecated`

## Key Differences: Hugo → Quartz

| Field         | Hugo                   | Quartz                               |
| ------------- | ---------------------- | ------------------------------------ |
| `draft`       | **Required** (boolean) | **Optional** (defaults to false)     |
| `categories`  | **Required** (array)   | **Not used**                         |
| `aliases`     | Not supported          | **Optional** (array)                 |
| `description` | Optional               | Optional (auto-generated if omitted) |

## Quartz Frontmatter Spec

- **Required**: `title` (string), `date` (YYYY-MM-DD)
- **Optional**: `draft`, `tags`, `aliases`, `description`, `permalink`

## Test Coverage (18 tests)

- Format validation (date, tags, title, draft, aliases, description)
- Validation contract (detect invalid types, missing fields)
- Publishing safety (exclude inbox, private, templates)
- Extraction contract (parse frontmatter, handle missing)

## Spirit Preserved from Hugo Tests

✅ Frontmatter format validation with strict type checking ✅ Publishing safety (block invalid frontmatter) ✅ Directory exclusions (inbox, private) ✅ Robust YAML parsing and extraction

## Integration

- Mise tasks: `quartz-preview`, `quartz-build`, `quartz-publish`
- Validation: `require("lib.quartz-frontmatter").validate_frontmatter(content)`
- Compatible with existing IWE frontmatter (title/date/tags work as-is)
