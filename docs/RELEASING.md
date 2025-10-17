# PercyBrain Release Process

**Philosophy**: Simple, automated releases that maintain quality without bureaucracy.

**For Solo Dev**: You control when releases happen via git tags.
**For Contributors**: Automation handles the rest after tag push.

---

## Quick Release Guide (TL;DR)

```bash
# 1. Ensure your changes are committed and tests pass
git status  # Should be clean
cd tests && ./simple-test.sh  # Verify quality

# 2. Tag the release (follows semantic versioning)
git tag v1.2.3 -m "Release 1.2.3: Brief summary of changes"

# 3. Push the tag to trigger automation
git push origin v1.2.3

# 4. Watch GitHub Actions create the release
# Visit: https://github.com/yourusername/percybrain/actions
```

That's it! CI/CD handles the rest automatically.

---

## Semantic Versioning Strategy

PercyBrain follows [Semantic Versioning 2.0.0](https://semver.org/):

**Format**: `MAJOR.MINOR.PATCH` (e.g., v1.2.3)

### When to Bump Each Component

#### MAJOR version (v1.x.x → v2.0.0)
**Breaking changes** that require user action:
- Plugin configuration API changes
- Removed features or commands
- Changed default keybindings that users rely on
- Incompatible lazy.nvim specification changes

**Example**: Renaming `require('config')` to `require('percybrain.config')`

#### MINOR version (v1.2.x → v1.3.0)
**New features** that don't break existing functionality:
- New plugins added (e.g., new markdown preview tool)
- New commands or keybindings
- Enhanced PercyBrain features
- New writing modes or themes

**Example**: Adding AI-powered summarization to PercyBrain

#### PATCH version (v1.2.3 → v1.2.4)
**Bug fixes** and non-functional changes:
- Fix startup errors
- Correct plugin configuration issues
- Documentation updates
- Performance improvements without API changes
- Dependency updates (if non-breaking)

**Example**: Fixing LaTeX preview not loading correctly

### Decision Tree

```
Does it break existing user configs? → YES → MAJOR
  ↓ NO
Does it add new features? → YES → MINOR
  ↓ NO
Is it a bug fix or small improvement? → YES → PATCH
```

---

## Detailed Release Workflow

### Phase 1: Pre-Release (Manual)

#### 1. Verify Work is Complete

```bash
# Check current branch
git branch
# Should be on main, not a feature branch

# Verify all changes committed
git status
# Should show "working tree clean"

# Review recent commits
git log --oneline -10
# Ensure commit messages are clear for changelog
```

#### 2. Run Tests Locally

```bash
# Full test suite
cd tests
./simple-test.sh

# Lint and format
stylua lua/
selene lua/
```

**💡 Tip**: Fix any issues before tagging. Releases should always be clean.

#### 3. Choose Version Number

Review changes since last release:

```bash
# See last release tag
git describe --tags --abbrev=0

# See commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Count commits since last tag
git rev-list $(git describe --tags --abbrev=0)..HEAD --count
```

Apply semantic versioning rules (see above) to choose `vX.Y.Z`.

#### 4. Create Annotated Tag

```bash
# Create tag with message
git tag v1.2.3 -m "Release 1.2.3: Add PercyBrain AI features"

# Verify tag created
git tag -l -n1 v1.2.3
```

**⚠️ Important**: Use annotated tags (`-m`), not lightweight tags. GitHub Actions only triggers on annotated tags.

#### 5. Push Tag to GitHub

```bash
# Push the tag
git push origin v1.2.3

# Verify push succeeded
git ls-remote --tags origin | grep v1.2.3
```

🚀 **Automation starts now!**

---

### Phase 2: Automated Release (CI/CD)

GitHub Actions (`.github/workflows/release.yml`) automatically:

#### Step 1: Validate Release

- ✅ Extract version from tag
- ✅ Validate semantic version format
- ✅ Run full test suite (simple-test.sh)
- ✅ Ensure code quality (StyLua, Selene)

**If tests fail**: Release is aborted. Fix issues, delete bad tag, create new tag.

#### Step 2: Generate Artifacts

- 📝 **version.lua**: Queryable version info in Lua
- 📋 **CHANGELOG**: Auto-generated from git commits
- 📖 **Installation Guide**: Complete setup instructions

#### Step 3: Create GitHub Release

- 🏷️ Tag marked as release
- 📄 Release notes populated from changelog
- 📦 Artifacts attached for download
- 🔗 Links to full changelog and installation guide

#### Step 4: Publish

- ✅ Release visible at: `https://github.com/yourusername/percybrain/releases`
- ✅ Users can install via lazy.nvim using tag: `tag = "v1.2.3"`
- ✅ GitHub notifies watchers of new release

**Typical Duration**: 3-5 minutes from tag push to published release.

---

## Advanced Workflows

### Dry Run (Test Without Publishing)

**Option A**: Use workflow_dispatch (manual trigger)

```bash
# 1. Create tag locally but don't push
git tag v1.2.3-rc1 -m "Release candidate for testing"

# 2. Go to GitHub Actions → Release workflow → Run workflow
# 3. Enter tag: v1.2.3-rc1
# 4. Review artifacts without publishing
```

**Option B**: Create a feature branch

```bash
# Test release workflow on feature branch
git checkout -b test-release-v1.2.3
git tag v1.2.3-test
git push origin v1.2.3-test

# Workflow runs but doesn't create official release
# Review workflow logs, then delete tag
git tag -d v1.2.3-test
git push origin :refs/tags/v1.2.3-test
```

### Fix a Bad Release

If you pushed a tag but need to fix it:

```bash
# 1. Delete local tag
git tag -d v1.2.3

# 2. Delete remote tag (removes GitHub release)
git push origin :refs/tags/v1.2.3

# 3. Fix the issues
git commit -m "fix: resolve issue in v1.2.3"

# 4. Create new tag
git tag v1.2.3 -m "Release 1.2.3: Fixed version"

# 5. Push corrected tag
git push origin v1.2.3
```

**⚠️ Warning**: Only do this for recent releases (<1 hour old). Users may have already installed.

### Hotfix Release Process

For urgent bug fixes:

```bash
# 1. Create hotfix branch from tagged release
git checkout -b hotfix/v1.2.4 v1.2.3

# 2. Fix the bug
git commit -m "fix: urgent bug in feature X"

# 3. Merge back to main
git checkout main
git merge hotfix/v1.2.4

# 4. Tag patch release
git tag v1.2.4 -m "Release 1.2.4: Hotfix for critical bug"

# 5. Push everything
git push origin main
git push origin v1.2.4
```

---

## What Gets Automated

### ✅ Fully Automated

- Version number extraction and validation
- Test suite execution
- version.lua generation with version API
- CHANGELOG generation from commit history
- Installation guide creation
- GitHub Release creation
- Artifact packaging and upload

### 🔧 Manual (Your Control)

- Deciding when to release
- Choosing version number (semantic versioning)
- Creating git tag
- Pushing tag to trigger release
- Announcing release to users

---

## Release Checklist

Use this checklist for every release:

### Pre-Release
- [ ] All changes committed to main branch
- [ ] Tests pass locally (`./tests/simple-test.sh`)
- [ ] Code formatted (`stylua lua/`)
- [ ] No linting errors (`selene lua/`)
- [ ] Commit messages are clear (they become changelog)
- [ ] Version number chosen using semantic versioning
- [ ] Feature branch merged (if applicable)

### Tagging
- [ ] Created annotated tag: `git tag vX.Y.Z -m "Release X.Y.Z: Summary"`
- [ ] Tag follows format: `v` + `MAJOR.MINOR.PATCH`
- [ ] Tag pushed to GitHub: `git push origin vX.Y.Z`

### Post-Release
- [ ] GitHub Actions workflow completed successfully
- [ ] Release visible at: https://github.com/yourusername/oviwrite/releases
- [ ] Release notes look correct
- [ ] Artifacts attached (version.lua, installation guide)
- [ ] Announcement to users (optional: Discord, Reddit, etc.)
- [ ] Close related GitHub issues/milestones

---

## Troubleshooting

### "Workflow didn't trigger after tag push"

**Cause**: Lightweight tag instead of annotated tag.

**Solution**:
```bash
# Delete lightweight tag
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3

# Create annotated tag
git tag v1.2.3 -m "Release 1.2.3: Summary"
git push origin v1.2.3
```

### "Tests failed during release"

**Cause**: Code quality issues not caught locally.

**Solution**:
```bash
# Review workflow logs on GitHub Actions
# Fix issues locally
git commit -m "fix: resolve test failures"

# Delete failed release tag
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3

# Re-tag after fix
git tag v1.2.3 -m "Release 1.2.3: Fixed version"
git push origin v1.2.3
```

### "Version format invalid"

**Cause**: Tag doesn't match `v#.#.#` format.

**Solution**:
```bash
# Wrong: v1.2, 1.2.3, release-1.2.3
# Right: v1.2.3

git tag -d <bad-tag>
git tag v1.2.3 -m "Release 1.2.3"
git push origin v1.2.3
```

### "Want to skip tests for urgent hotfix"

**Don't do this!** Tests exist to prevent shipping broken code.

If absolutely necessary:
1. Go to `.github/workflows/release.yml`
2. Comment out test steps temporarily
3. Commit and push
4. Create release
5. **Immediately** uncomment tests and commit

**Better approach**: Fix code so tests pass, even for hotfixes.

---

## Example: First Release

Let's walk through releasing v1.0.0 (your first release):

```bash
# 1. Verify everything works
git status  # Clean working tree
cd tests && ./simple-test.sh  # Tests pass

# 2. This is the first stable release
# All core features work, documentation complete
# Version: 1.0.0 (first major version)

# 3. Create tag
git tag v1.0.0 -m "Release 1.0.0: First stable release of PercyBrain"

# 4. Push tag
git push origin v1.0.0

# 5. Wait 3-5 minutes, check GitHub Actions
# Visit: https://github.com/yourusername/percybrain/actions

# 6. Verify release
# Visit: https://github.com/yourusername/percybrain/releases/tag/v1.0.0

# 7. Announce to users! 🎉
```

---

## For Contributors

If someone opens a PR and it gets merged:

1. **Maintainer** (you) decides when to release
2. Merge PR to main branch
3. Follow standard release process above
4. Contributor's changes included in next release automatically
5. Contributor credited in GitHub release (automatic)

**Contributors don't create releases** - only maintainers with push access to main.

---

## Philosophy & Design Decisions

### Why Manual Tags?

- **Control**: You decide release timing, not robots
- **Quality**: Time to batch fixes before releasing
- **Simplicity**: No complex commit message rules
- **Flexibility**: Release when ready, not on every commit

### Why Auto-Generated CHANGELOG?

- **Zero Maintenance**: No manual changelog editing
- **Always Accurate**: Reflects actual commits
- **Easy for Solo Dev**: No extra work during development
- **Transparent**: Users see exactly what changed

### Why Version.lua?

- **Runtime Queries**: Plugins can check PercyBrain version
- **Compatibility**: Future features can require minimum version
- **Debugging**: Users can report exact version easily
- **Professional**: Shows maturity and stability

---

## Future Enhancements (Not Implemented Yet)

Ideas for when the project grows:

### Conventional Commits (Team Phase)
- Enforce commit format: `feat:`, `fix:`, `BREAKING CHANGE:`
- Auto-calculate version bumps from commits
- Requires: Pre-commit hooks, contributor education

### Release Branches (Multi-Version Support)
- Maintain v1.x.x and v2.x.x simultaneously
- Backport critical fixes to older versions
- Requires: More complex branching strategy

### Beta/RC Releases (Advanced Testing)
- Pre-release tags: v1.2.3-beta.1, v1.2.3-rc.1
- Allow early testers to try features
- Requires: Tag format extension, separate workflow

### Automated Announcements (Marketing)
- Post to Discord, Reddit, Twitter automatically
- Requires: API tokens, announcement templates

**For now**: Keep it simple. Add complexity only when needed.

---

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [lazy.nvim Installation](https://github.com/folke/lazy.nvim)

---

**Questions?** Open a GitHub Issue or check the [GitHub Discussions](https://github.com/yourusername/percybrain/discussions).

**Want to contribute?** See [CONTRIBUTING.md](./CONTRIBUTING.md) (if it exists).
