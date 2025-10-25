# Issue #5: Implement CI/CD Phase 2 - Local Development Workflow

**Parent Epic:** Complete Testing & CI/CD Infrastructure

**Labels:** `infrastructure`, `ci-cd`, `phase-2`, `contributor-experience`

## Description

Create developer-friendly local testing workflow with git hooks, setup scripts, and contributor documentation.

## Requirements

1. Create `scripts/setup-dev-env.sh` for contributor onboarding
2. Implement `scripts/pre-commit` hook (Layer 1-2 validation)
3. Implement `scripts/pre-push` hook (Layer 1-3 validation)
4. Create master `scripts/validate.sh` with flags (`--full`, `--check`, `--help`)
5. Write comprehensive `CONTRIBUTING.md`
6. Test with sample contribution scenarios

## Acceptance Criteria

- [ ] Setup script runs in \<5 minutes, installs all dependencies
- [ ] Pre-commit blocks bad commits (syntax errors, duplicates)
- [ ] Pre-push runs full validation (startup, health checks)
- [ ] SKIP_VALIDATION environment variable works
- [ ] `validate.sh --full` completes in \<3 minutes
- [ ] CONTRIBUTING.md enables new contributors to contribute successfully
- [ ] Test scenarios validated (add plugin, invalid spec, duplicate)

## Implementation Checklist

- [ ] `scripts/setup-dev-env.sh` - dependency checking, hook installation
- [ ] `scripts/pre-commit` - fast validation (Layer 1-2)
- [ ] `scripts/pre-push` - comprehensive validation (Layer 1-3)
- [ ] `scripts/validate.sh` - master script with flag support
- [ ] `CONTRIBUTING.md` - sections: Quick Start, Workflow, Troubleshooting, Standards, PR Process
- [ ] Test scenarios documented and executed

## Validation Layers

**Layer 1: Static Analysis**

- Lua syntax validation (luac)
- Plugin spec validation (lazy.nvim)
- Duplicate detection
- Naming conventions

**Layer 2: Configuration Tests**

- Keymap registry validation
- Plugin dependency checks
- Configuration loading tests

**Layer 3: Functional Tests**

- Neovim startup test (headless)
- Plugin loading verification
- Health check validation

## Testing Strategy

- Fresh clone test: `git clone` → `setup-dev-env.sh` → verify hooks
- Negative tests: Intentional errors blocked by hooks
- Skip mechanism: `SKIP_VALIDATION=1` bypasses hooks
- Performance: Validate timing meets targets

## Estimated Effort

12-16 hours

## Related Files

- `scripts/setup-dev-env.sh` (NEW)
- `scripts/pre-commit` (NEW)
- `scripts/pre-push` (NEW)
- `scripts/validate.sh` (NEW)
- `CONTRIBUTING.md` (NEW)
- `claudedocs/MIGRATION_PLAN.md` (REFERENCE - archived)
