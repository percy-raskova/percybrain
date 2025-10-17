# PercyBrain Testing Suite

Simple, local testing for all PercyBrain components. No complex frameworks - just Bash scripts that verify everything works.

## Quick Start

### Daily Health Check (30 seconds)

```bash
cd ~/.config/nvim/tests
./quick-check.sh
```

**Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PercyBrain Quick Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Neovim installed
✓ IWE LSP installed
✓ SemBr installed
✓ Ollama installed
✓ Core config exists
✓ Ollama plugin exists
✓ Zettelkasten directory
✓ Templates directory
✓ All 5 templates present
✓ llama3.2 model installed
⊘ Ollama service not running (will auto-start when needed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 PercyBrain is healthy!
```

### Full Test Suite (2-3 minutes)

```bash
cd ~/.config/nvim/tests
./percybrain-test.sh
```

## Test Components

### 1. Core Configuration Files
- `init.lua` exists and is valid
- `config/zettelkasten.lua` loads correctly
- `plugins/ollama.lua` is configured
- `plugins/sembr.lua` is present
- LSP configuration includes IWE

### 2. External Dependencies
- **Neovim** - Editor
- **IWE LSP** - Wiki-style linking (`iwe` command)
- **SemBr** - Semantic line breaks (`sembr` command)
- **Ollama** - Local AI (`ollama` command)

### 3. Zettelkasten Structure
- `~/Zettelkasten/` directory exists
- `inbox/` subdirectory (fleeting notes)
- `daily/` subdirectory (daily journals)
- `templates/` subdirectory (note templates)

### 4. Template System
- 5 templates present: permanent, literature, project, meeting, fleeting
- Template variables `{{title}}`, `{{date}}`, `{{timestamp}}`
- Valid markdown structure

### 5. Lua Module Loading
- Zettelkasten module loads without errors
- SemBr plugin loads correctly
- Ollama plugin file is valid Lua

### 6. Ollama AI Integration
- Ollama service status (optional - auto-starts)
- llama3.2 model installed
- API endpoint responding (if service running)

### 7. Keybinding Configuration
- No conflicts between components
- Proper prefix separation (z = Zettelkasten, a = AI, f = focus)
- No duplicate bindings

### 8. LSP Integration
- IWE LSP configured in lspconfig.lua
- Workspace set to `~/Zettelkasten`
- Link style set to wiki-style

### 9. Documentation
- CLAUDE.md exists
- All PERCYBRAIN_*.md docs present
- User guide up to date with keybindings

## Usage Examples

### Run All Tests (Default)

```bash
./percybrain-test.sh
```

Output shows pass/fail for each test with color-coded results:
- ✓ Green = Passed
- ✗ Red = Failed
- ⊘ Yellow = Skipped (optional component not present)

### Verbose Mode

```bash
./percybrain-test.sh --verbose
```

Shows detailed information during test execution:
- Neovim version
- IWE version
- SemBr version
- File paths checked
- Module loading details

### Test Single Component

```bash
./percybrain-test.sh --component ollama
./percybrain-test.sh -c templates
./percybrain-test.sh -c keys --verbose
```

Available components:
- `core` - Core configuration files
- `deps` - External dependencies
- `zettel` - Zettelkasten structure
- `templates` - Template system
- `lua` - Lua module loading
- `ollama` - AI integration
- `keys` - Keybinding configuration
- `lsp` - LSP integration
- `docs` - Documentation

### View Test Reports

Test reports are saved to `tests/output/` with timestamps:

```bash
ls -lh tests/output/
cat tests/output/test-report-20251017_143022.txt
```

## Continuous Integration

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
cd ~/.config/nvim/tests
./percybrain-test.sh --component lua
if [ $? -ne 0 ]; then
    echo "❌ PercyBrain tests failed - fix before committing"
    exit 1
fi
```

### Weekly Cron Job

```bash
# Run full test suite every Monday at 9am
0 9 * * 1 cd ~/.config/nvim/tests && ./percybrain-test.sh > ~/percybrain-test.log 2>&1
```

## Troubleshooting Tests

### Test Fails: "Neovim not installed"

```bash
# Verify Neovim in PATH
which nvim

# If not found, install or add to PATH
export PATH="/path/to/neovim/bin:$PATH"
```

### Test Fails: "Module load error"

```bash
# Check Lua syntax manually
nvim --headless -c "lua require('config.zettelkasten')" -c "qall"

# Review error messages
nvim --headless -c "messages" -c "qall"
```

### Test Fails: "Ollama API not responding"

```bash
# Start Ollama manually
ollama serve

# Test API directly
curl http://localhost:11434/api/tags
```

### Test Skipped: "Templates directory doesn't exist"

This is OK on first run. Create templates:

```bash
mkdir -p ~/Zettelkasten/templates
# Copy templates from backup or docs
```

### Test Fails: "Keybinding conflict"

Check for duplicate keybindings:

```bash
grep -rn "'<leader>" ~/.config/nvim/lua/config/
grep -rn '"<leader>' ~/.config/nvim/lua/plugins/
```

## Test Development

### Adding New Tests

**1. Create test function** in `percybrain-test.sh`:

```bash
test_my_feature() {
    print_section "Testing My Feature"

    assert_file_exists "/path/to/file" "My file exists"
    assert_command_exists "mycommand" "My command installed"
}
```

**2. Add to test runner**:

```bash
# In run_all_tests()
test_my_feature
```

### Helper Functions Available

- `assert_file_exists <file> <description>` - File existence
- `assert_command_exists <cmd> <description>` - Command in PATH
- `assert_process_running <process> <description>` - Process check
- `assert_lua_module_loads <module> <description>` - Lua syntax
- `assert_contains <haystack> <needle> <description>` - String match

### Test Output Functions

- `print_header <title>` - Major section header
- `print_section <title>` - Subsection header
- `log_verbose <message>` - Verbose-only output

## CI/CD Integration

### GitHub Actions (Example)

```yaml
name: PercyBrain Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          # Install Neovim, IWE, SemBr, Ollama
          # ... installation commands ...

      - name: Run tests
        run: |
          cd tests
          ./percybrain-test.sh
```

### GitLab CI (Example)

```yaml
test:
  script:
    - cd ~/.config/nvim/tests
    - ./percybrain-test.sh
  artifacts:
    paths:
      - tests/output/
```

## Test Results Interpretation

### Success Rate Thresholds

- **100%** - Perfect, all tests passed
- **90-99%** - Good, minor skipped tests (optional components)
- **80-89%** - Acceptable, some features not configured
- **<80%** - Needs attention, core functionality broken

### Common Skip Reasons

- **"Ollama service not running"** - Normal, starts on demand
- **"Templates directory doesn't exist"** - Creates on first use
- **"llama3.2 model not installed"** - Run `ollama pull llama3.2`

### Critical Failures

These should never fail:
- Core configuration files missing
- Lua syntax errors in modules
- Keybinding conflicts
- Neovim not installed

## Performance Benchmarks

**Quick Health Check**: 1-2 seconds
**Full Test Suite**: 30-60 seconds (without AI tests)
**Full Test Suite with AI**: 2-3 minutes (includes Ollama startup)

## Test Coverage

Current coverage by component:

| Component | Tests | Coverage |
|-----------|-------|----------|
| Core Files | 6 | 100% |
| Dependencies | 4 | 100% |
| Zettelkasten Structure | 4 | 100% |
| Templates | 6 | 100% |
| Lua Modules | 3 | 100% |
| Ollama Integration | 3 | 80% |
| Keybindings | 2 | 100% |
| LSP Integration | 2 | 100% |
| Documentation | 6 | 100% |

**Total**: 36 tests covering all major components

## Future Enhancements

### Planned Test Additions

- [ ] End-to-end workflow tests (create note → AI → publish)
- [ ] Performance benchmarks (search speed, AI response time)
- [ ] Integration tests (LSP + SemBr + AI together)
- [ ] Stress tests (1000+ notes, large knowledge graph)
- [ ] Network tests (publishing workflow, API calls)

### Test Framework Evolution

Currently: Simple Bash scripts
Future: May migrate to:
- Lua-based tests using Plenary.nvim
- Neovim integration tests
- Automated UI testing with expect/pexpect

## Credits

**Test Suite Design**: Simple, practical, local-first testing
**Testing Philosophy**: Fast feedback, clear results, no dependencies
**Inspired By**: Unix philosophy - do one thing well

---

**Last Updated**: 2025-10-17
**Version**: 1.0
**Maintainer**: PercyBrain Development Team
