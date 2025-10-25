# Issue #10: External Files Deployment Structure (CI/CD Enhancement)

**Labels:** `infrastructure`, `ci-cd`, `deployment`, `medium-priority`

## Description

Create external files structure for zero-friction deployment to test runners, enabling CI/CD to automatically provision Zettelkasten templates, Hugo site structure, and configuration examples.

## Context

Current CI/CD Phase 1 complete (pre-commit hooks, test automation) **Gap**: Test runners require manual setup of external files (templates, Hugo configs) **Related**: Enhances Issue #5 (CI/CD Phase 2) but focused on external file deployment

## Requirements

### 1. Zettelkasten Template Deployment

Automated provisioning of Zettelkasten templates:

- Fleeting note template (`templates/fleeting.md`)
- Wiki page template (`templates/wiki.md`)
- Daily note template (`templates/daily.md`)
- Academic note template (`templates/academic.md`)
- Template validation during CI/CD

### 2. Hugo Site Structure

Complete Hugo site deployment:

- Hugo config file (`config.toml` or `config.yaml`)
- Theme configuration (Blood Moon theme)
- Content structure (`content/`, `static/`, `layouts/`)
- Frontmatter validation rules
- Publishing workflow scripts

### 3. Configuration Examples

Reference configurations for testing:

- Example Zettelkasten directory structure
- Sample notes with frontmatter
- Valid/invalid frontmatter examples for testing
- AI model configuration examples
- IWE LSP configuration examples

### 4. CI/CD Integration

Automated deployment to test environments:

- GitHub Actions workflow provisioning
- Test runner environment setup
- Temporary Zettelkasten directory creation
- Hugo site initialization for integration tests
- Cleanup after test completion

## Acceptance Criteria

- [ ] Template deployment: All 4 templates automatically provisioned
- [ ] Hugo structure: Complete Hugo site created in test environment
- [ ] Configuration examples: 10+ reference configs for testing
- [ ] CI/CD integration: Zero-friction test runner setup
- [ ] Validation: Automated checks for file structure completeness
- [ ] Documentation: Clear guide for local and CI/CD deployment
- [ ] Performance: Setup completes in \<10 seconds

## Implementation Tasks

### Phase 1: Template Structure (2-3 hours)

- [ ] Create `external-files/templates/` directory
- [ ] Document fleeting note template structure
- [ ] Document wiki page template structure
- [ ] Document daily note template structure
- [ ] Document academic note template structure
- [ ] Add template validation script

### Phase 2: Hugo Site Structure (3-4 hours)

- [ ] Create `external-files/hugo-site/` directory
- [ ] Document Hugo config file (config.yaml)
- [ ] Document Blood Moon theme configuration
- [ ] Document content structure (directories, layouts)
- [ ] Document frontmatter validation rules
- [ ] Add Hugo site validation script

### Phase 3: Configuration Examples (2-3 hours)

- [ ] Create `external-files/examples/` directory
- [ ] Document example Zettelkasten structure
- [ ] Document sample notes with frontmatter
- [ ] Document valid/invalid frontmatter cases
- [ ] Document AI model configuration
- [ ] Document IWE LSP configuration

### Phase 4: CI/CD Integration (2-3 hours)

- [ ] Update GitHub Actions workflow
- [ ] Add environment provisioning script
- [ ] Add temporary directory creation
- [ ] Add Hugo site initialization
- [ ] Add cleanup automation
- [ ] Test complete CI/CD pipeline

## Testing Strategy

- **Local Testing**: Script to deploy external files to local test environment
- **CI/CD Testing**: GitHub Actions workflow with provisioning validation
- **Validation Checks**: Automated verification of file structure completeness
- **Cleanup Testing**: Verify all temporary files removed after tests
- **Performance Testing**: Measure setup time (target: \<10 seconds)

## Success Metrics

- **Zero-Friction Setup**: Test runners auto-provision without manual intervention
- **Completeness**: 100% of required external files deployed
- **Performance**: Setup time \<10 seconds
- **Reliability**: 0% setup failures in CI/CD
- **Documentation Quality**: Clear local and CI/CD deployment guides

## Estimated Effort

8-10 hours

## Dependencies

- Hugo (for site structure validation)
- GitHub Actions (for CI/CD integration)
- Existing templates (fleeting.md, wiki.md in `/home/percy/Zettelkasten/templates/`)
- Issue #5 (CI/CD Phase 2) for workflow integration

## Related Files

- `external-files/templates/` (NEW - template deployment directory)
- `external-files/hugo-site/` (NEW - Hugo structure directory)
- `external-files/examples/` (NEW - configuration examples directory)
- `.github/workflows/ci.yml` (UPDATE - add provisioning steps)
- `scripts/provision-test-env.sh` (NEW - local provisioning script)
- `/home/percy/Zettelkasten/templates/` (SOURCE - existing templates)
- `lua/percybrain/hugo-menu.lua` (RELATED - Hugo integration)
