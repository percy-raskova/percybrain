# Debugging GitHub Actions with Act

Guide for testing GitHub Actions workflows locally using Act.

## What is Act?

Act is a tool that runs your GitHub Actions locally in Docker containers. It helps you:

- Test workflows before pushing to GitHub
- Debug failing CI tests quickly
- Iterate faster on workflow changes

## Installation

### Linux (Debian/Ubuntu)

```bash
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### macOS

```bash
brew install act
```

### Verify Installation

```bash
act --version
```

## Basic Usage

### List Available Workflows

```bash
# From project root (/home/percy/.config/nvim)
act -l
```

Expected output:

```
Stage  Job ID  Job name       Workflow name              Workflow file
0      test    test           PercyBrain Simple Tests    percybrain-tests.yml
0      format-and-lint        Lua Quality Checks         lua-quality.yml
```

### Run Main Test Workflow

```bash
# Run the full test suite
act push --job test

# Run with verbose output (see more details)
act push --job test --verbose

# Run with debug logging
act push --job test --verbose --debug
```

### Run Quality Workflow

```bash
act push --job format-and-lint
```

## Common Issues & Solutions

### Issue: "Docker not running"

**Error**: Cannot connect to Docker daemon

**Solution**:

```bash
# Start Docker service
sudo systemctl start docker

# Or for Docker Desktop
# Open Docker Desktop application
```

### Issue: "Container architecture mismatch"

**Error**: Platform mismatch warnings

**Solution**: Create `.actrc` in project root:

```bash
cat > .actrc << 'ACTRC'
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--container-architecture linux/amd64
ACTRC
```

### Issue: "Cache not working"

**Note**: Act doesn't perfectly replicate GitHub Actions cache behavior

**Workaround**: Run without cache or manually test tool installation:

```bash
# Test tool installation step
act push --job test -s GITHUB_ACTIONS=true
```

### Issue: "Tests hang on Selene"

**Symptom**: Tests stop responding during linting phase

**Debug Steps**:

1. Check if issue is in Act or the script:

```bash
# Run tests locally (outside Act)
cd tests/
./simple-test.sh
```

2. Check Act container:

```bash
# Run interactive shell in Act container
act push --job test -b

# Then inside container, manually run:
cd /home/runner/work/neovim-iwe/neovim-iwe/tests
./simple-test.sh
```

3. Check tool versions in container:

```bash
act push --job test --verbose | grep -A5 "Tool Verification"
```

### Issue: "PATH not set correctly"

**Symptom**: Tools not found even after installation

**Debug**: Add verification step to workflow (already included):

```yaml
- name: Verify tool installation
  run: |
    echo "=== PATH ==="
    echo "$PATH"
    which stylua
    which selene
```

## Debugging Techniques

### 1. Interactive Container Shell

Drop into a shell to manually test:

```bash
act push --job test -b
```

Then run commands interactively.

### 2. Dry Run (No Execution)

See what Act would do:

```bash
act push --job test --dryrun
```

### 3. Reuse Containers

Speed up debugging by reusing containers:

```bash
act push --job test --reuse
```

### 4. Verbose Output

See all steps and output:

```bash
act push --job test --verbose 2>&1 | tee act-debug.log
```

### 5. Specific Step Testing

Test just one step by commenting out others in workflow, then:

```bash
act push --job test
```

## Comparing Act vs GitHub Actions

### Differences to Be Aware Of

| Feature     | Act                      | GitHub Actions       |
| ----------- | ------------------------ | -------------------- |
| Cache       | Limited/unreliable       | Full cache support   |
| Secrets     | Manual setup needed      | Automatic from repo  |
| Environment | Docker container         | GitHub-hosted runner |
| Performance | Depends on local machine | Consistent cloud VMs |
| Network     | Local network/DNS        | GitHub network       |

### When to Use Act

✅ **Good for:**

- Testing workflow syntax
- Debugging failing tests
- Iterating on workflow logic
- Checking tool installation

❌ **Not reliable for:**

- Cache behavior testing
- Performance benchmarks
- Network-dependent operations
- GitHub-specific features (PR comments, etc.)

## Quick Testing Workflow

When you make changes:

1. **Test locally first** (fastest):

```bash
cd tests/
./simple-test.sh
```

2. **Test with Act** (if workflow changes):

```bash
act push --job test
```

3. **Push to GitHub** (final verification):

```bash
git add .
git commit -m "Fix: description"
git push
```

## Troubleshooting Checklist

When tests fail in Act:

- [ ] Do tests pass locally? (`cd tests/ && ./simple-test.sh`)
- [ ] Is Docker running? (`docker ps`)
- [ ] Are tools installed in container? (Check workflow logs)
- [ ] Is PATH set correctly? (Check verification step)
- [ ] Is Selene finding `selene.toml`? (Check working directory)
- [ ] Are timeouts appropriate? (30s for StyLua, 60s for Selene)
- [ ] Is cache causing issues? (Try without cache)

## Example Debug Session

```bash
# 1. Run tests locally to verify they work
cd /home/percy/.config/nvim/tests
./simple-test.sh
# ✓ All pass

# 2. Test with Act
cd /home/percy/.config/nvim
act push --job test --verbose
# ✗ Hangs on Selene

# 3. Debug interactively
act push --job test -b
# In container:
cd tests
./simple-test.sh
# Identify issue: Selene can't find selene.toml

# 4. Fix: Run Selene from project root (already fixed in script)

# 5. Verify fix
act push --job test
# ✓ All pass

# 6. Push to GitHub
git add .
git commit -m "fix: ensure Selene runs from project root"
git push
```

## Resources

- **Act Documentation**: https://github.com/nektos/act
- **Act Runner Images**: https://github.com/catthehacker/docker_images
- **GitHub Actions Docs**: https://docs.github.com/en/actions

## Getting Help

If Act behaves unexpectedly:

1. Check Act issues: https://github.com/nektos/act/issues
2. Compare with GitHub Actions results
3. Test outside Act to isolate issue
4. Use `--verbose` for detailed logs
5. Try `--reuse` to speed up iterations
