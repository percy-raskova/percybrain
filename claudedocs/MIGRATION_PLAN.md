# OVIWrite Testing & CI/CD Migration Plan

**Version**: 1.0
**Date**: 2025-10-16
**Status**: Ready for Implementation

## Executive Summary

This document outlines the phased migration plan to implement comprehensive testing and CI/CD infrastructure for OVIWrite. The plan prioritizes safety, maintainability, and minimal disruption to current development.

**Timeline**: 4 weeks (1 week per phase)
**Effort**: Medium complexity (~15-20K tokens implementation)
**Risk**: Low (validation is additive, doesn't modify existing code)

## Prerequisites

Before starting Phase 1:

- [ ] Review [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for full context
- [ ] Ensure Git repository is clean (`git status`)
- [ ] Create backup branch: `git checkout -b backup-pre-validation`
- [ ] Document any known issues in baseline report

## Phase 1: Foundation (Week 1)

**Goal**: Core validation scripts operational and tested

### Tasks

#### 1.1: Create Scripts Infrastructure (Day 1)

- [ ] Create `scripts/` directory structure
- [ ] Copy validation scripts from deliverables
- [ ] Make scripts executable: `chmod +x scripts/*.sh scripts/*.lua`
- [ ] Create `scripts/deprecated-patterns.txt` with known API deprecations

**Acceptance Criteria**:
- All 7 scripts present and executable
- Scripts run without immediate errors

#### 1.2: Implement Layer 1 Validation (Day 2)

**Script**: `scripts/validate-layer1.sh`

- [ ] Test duplicate plugin detection
- [ ] Test Lua syntax validation
- [ ] Test deprecated API scanning
- [ ] Test file organization rules

**Test Commands**:
```bash
./scripts/validate-layer1.sh
./scripts/validate-layer1.sh --only-duplicates
./scripts/validate-layer1.sh --only-deprecated
```

**Expected Results**:
- Detects known duplicate: `nvim-orgmode.lua` + `nvimorgmode.lua` (already fixed)
- Scans all `.lua` files without crashing
- Reports any deprecated API usage with file:line context

#### 1.3: Implement Layer 2 Validation (Day 3)

**Script**: `scripts/validate-layer2.lua`

- [ ] Test plugin spec structure validation
- [ ] Test lazy.nvim field validation
- [ ] Test keymap conflict detection
- [ ] Test dependency validation

**Test Commands**:
```bash
nvim --headless -l scripts/validate-layer2.lua
```

**Expected Results**:
- Validates all plugin specs in `lua/plugins/*.lua`
- Reports invalid structures with clear error messages
- Exits with appropriate exit codes (0 = pass, 1 = fail)

#### 1.4: Create Baseline Report (Day 4)

**Document**: `claudedocs/BASELINE_REPORT.md`

```markdown
# OVIWrite Validation Baseline Report

**Date**: [Today]
**Neovim Version**: [nvim --version]
**Total Plugins**: [Count from lua/plugins/]

## Layer 1 Results
- Syntax errors: X files
- Duplicates: X pairs
- Deprecated APIs: X instances
- File organization: X violations

## Layer 2 Results
- Invalid plugin specs: X files
- Keymap conflicts: X duplicates
- Dependency issues: X plugins

## Known Issues (Not Blocking)
1. [List issues that are acceptable for now]
2. [e.g., "vim-wiki uses deprecated API, upstream issue"]

## Action Items
- [ ] Fix critical errors (syntax, duplicates)
- [ ] Document acceptable warnings
- [ ] Update deprecated-patterns.txt with findings
```

**Deliverables**:
- Baseline report documenting current validation state
- List of issues to fix vs. acceptable warnings
- Updated `deprecated-patterns.txt` with discovered patterns

#### 1.5: Setup GitHub Actions (Day 5)

- [ ] Create `.github/workflows/` directory
- [ ] Copy `quick-validation.yml` workflow
- [ ] Test workflow on feature branch
- [ ] Verify cache configuration works

**Test Process**:
```bash
git checkout -b test/validation-ci
git add .github/workflows/quick-validation.yml
git commit -m "test: add quick validation workflow"
git push origin test/validation-ci
# Observe GitHub Actions run
```

**Acceptance Criteria**:
- Workflow runs on push
- Layer 1-2 validation executes
- Results visible in GitHub Actions UI
- Cache speeds up subsequent runs

### Phase 1 Deliverables

- [x] All validation scripts operational
- [x] Baseline report documenting current state
- [x] GitHub Actions quick validation workflow running
- [x] Documentation of known issues and action items

### Phase 1 Success Criteria

- Scripts run without crashes
- Validation detects actual issues (test with intentional errors)
- CI workflow completes successfully
- Baseline report approved by maintainers

---

## Phase 2: Local Development Workflow (Week 2)

**Goal**: Developer-friendly local testing with git hooks

### Tasks

#### 2.1: Create Setup Script (Day 1)

**Script**: `scripts/setup-dev-env.sh`

- [ ] Dependency checking (Neovim, Git, optional tools)
- [ ] Git hook installation with backup
- [ ] Test directory creation
- [ ] Script executable permissions
- [ ] Initial validation test

**Test Process**:
```bash
# On a fresh clone
git clone https://github.com/MiragianCycle/OVIWrite.git test-clone
cd test-clone
./scripts/setup-dev-env.sh
```

**Acceptance Criteria**:
- Script runs without errors
- Git hooks installed and working
- Clear output showing what was done
- Help text explaining next steps

#### 2.2: Implement Git Hooks (Day 2)

**Files**: `scripts/pre-commit`, `scripts/pre-push`

- [ ] Pre-commit hook (Layer 1-2 validation)
- [ ] Pre-push hook (Layer 1-3 validation)
- [ ] SKIP_VALIDATION environment variable support
- [ ] Clear error messages with skip instructions

**Test Process**:
```bash
# Test pre-commit
echo "syntax error" >> lua/plugins/test.lua
git add lua/plugins/test.lua
git commit -m "test: should fail"
# Should block commit with clear error

# Test skip
SKIP_VALIDATION=1 git commit -m "test: should succeed"
# Should allow commit with skip message
```

**Acceptance Criteria**:
- Pre-commit blocks bad commits
- Pre-push runs full validation
- Skip mechanism works
- Error messages are clear and actionable

#### 2.3: Create Master Validation Script (Day 3)

**Script**: `scripts/validate.sh`

- [ ] Implements `--full` flag (Layer 1-4)
- [ ] Implements `--check <name>` for specific checks
- [ ] Implements `--help` with usage instructions
- [ ] Beautiful colored output
- [ ] Clear progress indicators

**Test Process**:
```bash
./scripts/validate.sh --help
./scripts/validate.sh              # Quick (Layer 1-2)
./scripts/validate.sh --full       # Full (Layer 1-4)
./scripts/validate.sh --check duplicates
./scripts/validate.sh --check startup
```

**Acceptance Criteria**:
- All flags work correctly
- Output is clear and informative
- Exit codes are correct (0 = pass, 1 = fail)
- Performance meets targets (<5s for quick, <3min for full)

#### 2.4: Write CONTRIBUTING.md (Day 4)

**Document**: `CONTRIBUTING.md`

Sections:
- [ ] Quick start guide
- [ ] Development workflow
- [ ] Validation system explanation
- [ ] Common tasks (adding plugins, fixing errors)
- [ ] Troubleshooting guide
- [ ] Coding standards
- [ ] Pull request process

**Acceptance Criteria**:
- New contributor can follow guide successfully
- All common scenarios documented
- Troubleshooting covers known issues
- Examples are clear and tested

#### 2.5: Test with Sample Contributions (Day 5)

Create test scenarios simulating real contributions:

**Test Scenario 1: Add New Plugin**
```bash
git checkout -b test/add-plugin
# Create lua/plugins/test-plugin.lua with valid spec
git add lua/plugins/test-plugin.lua
git commit -m "feat: add test plugin"
# Should pass validation
```

**Test Scenario 2: Invalid Plugin Spec**
```bash
git checkout -b test/invalid-spec
# Create plugin file returning wrong structure
git commit -m "feat: invalid plugin"
# Should fail Layer 2 validation
```

**Test Scenario 3: Duplicate Plugin**
```bash
git checkout -b test/duplicate
# Create nvim-tree.lua (duplicate of nvimtree.lua)
git commit -m "feat: duplicate plugin"
# Should fail Layer 1 validation
```

**Acceptance Criteria**:
- All test scenarios behave as expected
- Error messages guide user to fix
- Skip mechanism works when needed
- Workflow is smooth and not frustrating

### Phase 2 Deliverables

- [ ] `setup-dev-env.sh` script working
- [ ] Git hooks installed and tested
- [ ] Master `validate.sh` script operational
- [ ] CONTRIBUTING.md complete
- [ ] Test scenarios validated

### Phase 2 Success Criteria

- New contributors can set up environment in <5 minutes
- Validation provides fast feedback (<5s for common edits)
- Git hooks catch issues before CI
- Documentation is clear and comprehensive

---

## Phase 3: CI/CD Enhancement (Week 3)

**Goal**: Comprehensive CI coverage across platforms and Neovim versions

### Tasks

#### 3.1: Implement Layer 3 Scripts (Day 1-2)

**Scripts**:
- `scripts/validate-startup.sh` - Neovim startup test
- `scripts/validate-health.sh` - Health check automation
- `scripts/validate-plugin-loading.lua` - Individual plugin loading

**Test Process**:
```bash
./scripts/validate-startup.sh
./scripts/validate-health.sh
nvim --headless -l scripts/validate-plugin-loading.lua
```

**Acceptance Criteria**:
- Startup test detects configuration errors
- Health check parses output correctly
- Plugin loading identifies broken plugins
- All scripts work in isolated environments

#### 3.2: Create Full Validation Workflow (Day 3)

**File**: `.github/workflows/full-validation.yml`

Features:
- [ ] Matrix testing (Linux, macOS, Windows)
- [ ] Matrix testing (Neovim stable, nightly)
- [ ] All 4 validation layers
- [ ] Plugin caching
- [ ] PR commenting with results
- [ ] Artifact upload on failure

**Test Process**:
```bash
git checkout -b test/full-validation
git push origin test/full-validation
# Create PR to main
# Observe full validation run
```

**Acceptance Criteria**:
- Workflow runs on PR to main
- Tests all OS + Neovim combinations (6 total)
- Completes in <5 minutes per matrix job
- Comments on PR with results
- Artifacts available for debugging

#### 3.3: Optimize CI Performance (Day 4)

Optimizations:
- [ ] Plugin caching (restore previous lazy.nvim state)
- [ ] Parallel job execution (matrix strategy)
- [ ] Conditional job execution (only run full on main PRs)
- [ ] Artifact retention policies (7 days for quick, 14 for full)

**Benchmark Targets**:
- Quick validation: <1 minute
- Full validation per matrix job: <3 minutes
- Total CI time (all jobs): <5 minutes with parallelization

**Acceptance Criteria**:
- Cache hit rate >80% on subsequent runs
- Performance meets benchmark targets
- No unnecessary job executions
- Artifact storage within GitHub free tier limits

#### 3.4: PR Comment Bot (Day 5)

**Feature**: Automated PR comments with validation results

Implements:
- [ ] Summary comment with pass/fail per layer
- [ ] Matrix results table (OS x Neovim version)
- [ ] Link to full logs and artifacts
- [ ] Actionable next steps on failure

**Example Comment**:
```markdown
## ✅ Validation Results - ubuntu-latest / stable

**Layers tested**: All (1-4)

| Layer | Result | Time |
|-------|--------|------|
| Layer 1: Static | ✅ Pass | 3s |
| Layer 2: Structural | ✅ Pass | 8s |
| Layer 3: Startup | ✅ Pass | 45s |
| Layer 3: Health | ✅ Pass | 30s |
| Layer 4: Documentation | ⚠️ Warning | 10s |

**Warnings**: 2 plugins missing from CLAUDE.md

[View full logs](#) | [Download artifacts](#)
```

**Acceptance Criteria**:
- Comments appear on all PRs
- Results are accurate and actionable
- Links work correctly
- Comment is clear and not overwhelming

### Phase 3 Deliverables

- [ ] Layer 3 validation scripts working
- [ ] Full validation workflow operational
- [ ] CI performance optimized
- [ ] PR comment bot functional

### Phase 3 Success Criteria

- Matrix testing covers all target platforms
- CI completes in <5 minutes total
- Failures are clearly communicated
- Contributors understand how to fix issues

---

## Phase 4: Documentation Sync (Week 4)

**Goal**: Prevent documentation drift automatically

### Tasks

#### 4.1: Implement Documentation Validation (Day 1)

**Script**: `scripts/validate-documentation.lua`

Features:
- [ ] Extract installed plugins from `lua/plugins/*.lua`
- [ ] Parse CLAUDE.md for documented plugins
- [ ] Compare lists and calculate accuracy score
- [ ] Report missing plugins
- [ ] Report removed plugins (documented but not installed)

**Test Process**:
```bash
nvim --headless -l scripts/validate-documentation.lua
```

**Expected Output**:
```
📚 Layer 4: Documentation Sync Validation
========================================
🔍 Scanning installed plugins...
   Found 62 plugin files
📖 Parsing CLAUDE.md...
   Found 58 documented plugins
🔄 Comparing plugin lists...

Documentation Sync Results:
--------------------
  Total installed:  62
  Total documented: 58
  Matched:          56
  Accuracy score:   90%

⚠️  Plugins missing from CLAUDE.md (6):
  - new-plugin.lua
  - another-plugin.lua
  ...
```

**Acceptance Criteria**:
- Accurately detects installed plugins
- Parses CLAUDE.md correctly
- Calculates meaningful accuracy score
- Reports are actionable

#### 4.2: Implement Keymap Extraction (Day 2)

**Script**: `scripts/extract-keymaps.lua`

Features:
- [ ] Parse `lua/config/keymaps.lua` for `vim.keymap.set()` calls
- [ ] Extract mode, key, description
- [ ] Generate markdown table
- [ ] Filter to leader key shortcuts
- [ ] Sort by key for consistency

**Test Process**:
```bash
nvim --headless -l scripts/extract-keymaps.lua
# Should output markdown table
```

**Acceptance Criteria**:
- Extracts all leader keymaps
- Includes descriptions from `desc` field
- Generates valid markdown table
- Output is ready to copy-paste to CLAUDE.md

#### 4.3: Manual Documentation Sync (Day 3)

**One-time synchronization**:

1. **Run plugin list validation**
```bash
./scripts/validate.sh --check docs
```

2. **Identify discrepancies**
- Missing plugins from CLAUDE.md
- Removed plugins still documented
- Miscategorized plugins

3. **Update CLAUDE.md**
- Add missing plugins to appropriate sections
- Remove outdated plugins
- Verify plugin descriptions are current
- Update categories if needed

4. **Run keymap extraction**
```bash
./scripts/extract-keymaps.lua > /tmp/keymaps.md
```

5. **Update keyboard shortcuts section**
- Copy generated table to CLAUDE.md
- Verify all shortcuts are correct
- Add any missing shortcuts not detected

6. **Verify accuracy**
```bash
./scripts/validate.sh --check docs
# Should show 90%+ accuracy
```

**Acceptance Criteria**:
- CLAUDE.md plugin list is 100% accurate
- Keyboard shortcuts section is current
- All plugin descriptions are helpful
- Validation reports >95% accuracy

#### 4.4: Enable Documentation Validation in CI (Day 4)

**Integration**:
- [ ] Add Layer 4 validation to full-validation.yml
- [ ] Configure as warning-only (doesn't block merge)
- [ ] Add doc drift report to PR comments
- [ ] Document in CONTRIBUTING.md how to update docs

**CI Workflow Update**:
```yaml
- name: Run Layer 4 validation (documentation)
  id: layer4
  run: |
    echo "::group::Layer 4: Documentation Sync"
    nvim --headless -l scripts/validate-documentation.lua
    echo "::endgroup::"
```

**Acceptance Criteria**:
- Layer 4 runs in CI (warnings only)
- PR comments include doc drift warnings
- Doesn't block merges
- Clear instructions on how to fix

#### 4.5: Create Documentation Helper Script (Day 5)

**Script**: `scripts/update-docs.sh`

Interactive helper for maintaining documentation:

```bash
#!/bin/bash
# OVIWrite Documentation Update Helper

echo "📚 Documentation Update Helper"
echo ""

# 1. Check current sync status
echo "Current documentation status:"
./scripts/validate.sh --check docs

# 2. Generate updated plugin list
echo ""
echo "Generating plugin list..."
# [Extract and format plugin list]

# 3. Generate keymap table
echo ""
echo "Generating keymap table..."
./scripts/extract-keymaps.lua

# 4. Offer to open CLAUDE.md for editing
echo ""
read -p "Open CLAUDE.md for editing? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  nvim CLAUDE.md
fi

# 5. Validate after updates
echo ""
echo "Validating updates..."
./scripts/validate.sh --check docs
```

**Acceptance Criteria**:
- Helper guides user through doc update process
- Generates all necessary content
- Makes documentation maintenance easy
- Reduces friction for contributors

### Phase 4 Deliverables

- [ ] Documentation validation script working
- [ ] Keymap extraction script working
- [ ] CLAUDE.md fully synchronized
- [ ] Layer 4 enabled in CI (warnings)
- [ ] Documentation helper script operational

### Phase 4 Success Criteria

- Documentation accuracy >95%
- Contributors know how to maintain docs
- Drift is detected automatically
- Process is low-friction

---

## Phase 5: Refinement & Long-term Maintenance

**Goal**: Continuous improvement based on real-world usage

### Ongoing Tasks

#### 5.1: Collect Contributor Feedback

**Methods**:
- GitHub Issues template for validation problems
- Survey in CONTRIBUTING.md
- Monitor PR comments for frustration points
- Track how often validation is skipped

**Action Items**:
- Improve error messages based on confusion
- Add FAQ section to CONTRIBUTING.md
- Optimize slow validation checks
- Add more patterns to deprecated-patterns.txt

#### 5.2: Maintain Deprecated Patterns

**Process**:
1. Monitor Neovim releases for API changes
2. Update `deprecated-patterns.txt` with new deprecations
3. Test patterns against codebase
4. Document in CI/CD strategy

**Frequency**: Check quarterly or on major Neovim releases

#### 5.3: Monitor CI Performance

**Metrics to track**:
- Average CI run time per layer
- Cache hit rate (target: >80%)
- False positive rate (target: <5%)
- Validation skip frequency

**Optimization opportunities**:
- Parallelize more operations
- Improve caching strategies
- Reduce unnecessary file scanning
- Optimize Lua script performance

#### 5.4: Expand Validation Coverage

**Future enhancements** (based on issues discovered):
- Colorscheme conflict detection
- LSP configuration validation
- Plugin version compatibility checking
- Performance regression testing
- Visual regression testing (screenshots)

#### 5.5: Documentation Maintenance

**Quarterly tasks**:
- Review CONTRIBUTING.md for outdated information
- Update TESTING_STRATEGY.md with lessons learned
- Refresh validation script examples
- Update troubleshooting section

### Phase 5 Success Metrics

- Contributor satisfaction with validation system
- Low false positive rate (<5%)
- Fast validation times maintained
- Documentation accuracy >95%
- Validation rarely skipped (<10% of commits)

---

## Rollback Plan

If validation causes significant problems:

### Emergency Disable

```bash
# Disable git hooks temporarily
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
```

### Disable CI Workflows

```yaml
# Add to workflow file
on:
  # Temporarily disabled - validation issues
  # push:
  #   branches: ['**']
  workflow_dispatch:  # Manual trigger only
```

### Gradual Rollback

1. **Phase 4 → Phase 3**: Disable documentation sync (Layer 4)
2. **Phase 3 → Phase 2**: Disable CI, keep local hooks
3. **Phase 2 → Phase 1**: Remove git hooks, keep scripts available
4. **Phase 1 → Phase 0**: Remove all validation infrastructure

### Rollback Decision Criteria

- Validation blocks >50% of legitimate commits
- False positive rate >20%
- CI times exceed 10 minutes regularly
- Contributors consistently skip validation
- Maintainers cannot keep up with validation issues

---

## Success Metrics

### Quantitative Metrics

**Phase 1**:
- [x] Validation scripts run without crashes: 100%
- [x] Known issues detected: 100%
- [x] CI workflow success rate: >95%

**Phase 2**:
- [ ] Setup time for new contributors: <5 minutes
- [ ] Local validation time: <5 seconds (Layer 1-2)
- [ ] Git hook adoption rate: 100% (automatic)

**Phase 3**:
- [ ] CI run time per job: <3 minutes
- [ ] Total CI time: <5 minutes (parallelized)
- [ ] False positive rate: <5%

**Phase 4**:
- [ ] Documentation accuracy: >95%
- [ ] Doc drift detection: <24 hours
- [ ] Doc update friction: Low (helper script usage >50%)

**Phase 5 (Ongoing)**:
- [ ] Validation skip frequency: <10%
- [ ] Contributor satisfaction: >80% positive
- [ ] Issue prevention rate: 100% of targeted issues

### Qualitative Metrics

- Contributors report validation is helpful, not burdensome
- Maintainers spend less time reviewing common issues
- New contributors successfully navigate validation system
- Documentation stays current without manual tracking

---

## Risk Assessment

### Low Risk

- Validation is additive (doesn't modify existing code)
- Can be skipped for emergencies
- Rollback plan available
- Tested incrementally

### Medium Risk

- Learning curve for contributors
- CI costs (mitigated by free tier)
- Initial time investment

### High Risk

- None identified

### Mitigation Strategies

- Clear documentation and examples
- Graceful degradation (warnings vs errors)
- Skip mechanisms for edge cases
- Phased rollout with testing

---

## Conclusion

This migration plan provides a structured, low-risk approach to implementing comprehensive testing and CI/CD for OVIWrite. Each phase builds on the previous, allowing for incremental adoption and continuous feedback.

**Next Steps**:
1. Review and approve this migration plan
2. Create tracking issues for each phase
3. Begin Phase 1 implementation
4. Schedule weekly check-ins to review progress

**Estimated Timeline**: 4 weeks for core implementation, ongoing refinement

**Expected Outcome**: Robust validation system preventing common issues while maintaining developer productivity and project maintainability.
