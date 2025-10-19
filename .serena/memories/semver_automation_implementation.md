# Semantic Versioning Automation - Implementation

**Date**: 2025-10-17 **Status**: ✅ Complete and tested

## Overview

Implemented automated semantic versioning system for PercyBrain with:

- Manual git tag control (solo-dev friendly)
- Auto-generated changelogs from commits
- GitHub Actions release automation
- Queryable version.lua API

## Key Files

### Workflows

- `.github/workflows/release.yml` - Release automation (triggers on tag push)

### Scripts

- `scripts/generate-version.sh` - Creates lua/oviwrite/version.lua
- `scripts/generate-changelog.sh` - Generates CHANGELOG from git log

### Documentation

- `docs/RELEASING.md` - Complete release process guide (491 lines)
- `docs/SEMVER_AUTOMATION_SUMMARY.md` - Implementation summary

### Configuration

- `.gitignore` - Excludes generated files (version.lua, CHANGELOG-release.md)

## Release Workflow

```bash
# 1. Solo dev creates tag
git tag v1.2.3 -m "Release 1.2.3: Summary"

# 2. Push tag triggers CI/CD
git push origin v1.2.3

# 3. Automation runs (~3-5 minutes):
#    - Validates version format
#    - Runs test suite
#    - Generates version.lua
#    - Generates CHANGELOG
#    - Creates GitHub Release
```

## Semantic Versioning Rules

**MAJOR**: Breaking changes (API changes, removed features) **MINOR**: New features (backward compatible) **PATCH**: Bug fixes (non-breaking)

Decision tree:

- Breaking? → MAJOR
- New features? → MINOR
- Bug fixes? → PATCH

## Version.lua API

```lua
local version = require('oviwrite.version')

version.version      -- "1.2.3"
version.major        -- 1
version.minor        -- 2
version.patch        -- 3
version.tag          -- "v1.2.3"
version.release_date -- "2025-10-17"

version.is_at_least("1.2.0")  -- boolean
version.get_info()             -- "PercyBrain v1.2.3 (released 2025-10-17)"
```

## Testing Results

✅ Local testing passed:

- Version generator: `./scripts/generate-version.sh 0.1.0` → Success
- Changelog generator: `./scripts/generate-changelog.sh v0.1.0` → Success
- Generated 255 commit changelog from full git history
- All files have correct format and syntax

⏳ CI/CD testing: Pending first real tag push

## Design Philosophy

1. **Manual Control**: Solo dev decides when to release via git tags
2. **Zero Maintenance**: Changelog auto-generated from commits
3. **Fail-Safe**: Tests must pass before release
4. **Extensible**: Room for conventional commits later

## Integration with Existing CI

- Reuses `tests/simple-test.sh` for validation
- Leverages existing Lua tools cache
- Works alongside `lua-quality.yml` and `percybrain-tests.yml`

## Next Steps

1. Test with `v0.1.0-test` tag (dry run)
2. Create first real release: `v0.1.0`
3. Replace `yourusername` placeholders with actual GitHub username
4. Update README.md with installation via tags

## References

- Full guide: `docs/RELEASING.md`
- Summary: `docs/SEMVER_AUTOMATION_SUMMARY.md`
- Workflow: `.github/workflows/release.yml`
