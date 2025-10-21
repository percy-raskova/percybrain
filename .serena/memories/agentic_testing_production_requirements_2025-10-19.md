# Agentic Testing Framework - Production Requirements

**Date**: 2025-10-19 **Context**: Critical production considerations for CI/CD agentic testing

## 6 Critical Requirements

### 1. Hugo Testing - Local Server Only

**Requirement**: Never publish to real site, test locally with browser automation

**Implementation**:

```yaml
- name: Build Hugo Site Locally
  run: |
    cd ~/blog
    hugo server --port 1313 --bind 0.0.0.0 --baseURL http://localhost:1313 &
    HUGO_PID=$!
    sleep 2  # Wait for server startup

- name: Test with Playwright
  run: |
    # Agent uses Playwright MCP to interact with http://localhost:1313
    # Validates: Published page renders, navigation works, frontmatter correct

- name: Cleanup Hugo Server
  run: kill $HUGO_PID
```

**Why**: Safe, fast, no accidental publication, validates full rendering pipeline

### 2. Act Compatibility

**Requirement**: Tests must run locally with Act before pushing to GitHub

**Implementation**:

```bash
# Install Act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run specific workflow locally
act -j agentic-test-suite --container-architecture linux/amd64

# Run with secrets
act -j agentic-test-suite --secret-file .secrets
```

**GitHub Action Compatibility**:

```yaml
# Use Act-compatible syntax
runs-on: ubuntu-latest  # Act uses ubuntu-latest by default

# Check if running in Act
- name: Detect Act
  run: |
    if [ -n "$ACT" ]; then
      echo "Running in Act (local)"
    else
      echo "Running in GitHub Actions (cloud)"
    fi
```

**Why**: Catch issues locally before burning GitHub Action minutes

### 3. Custom Docker Image with Strategic Caching

**Requirement**: Pre-built image with all dependencies, cached aggressively

**Dockerfile**:

```dockerfile
# .github/agentic-tests/Dockerfile
FROM ubuntu:22.04

# Layer 1: Base system (rarely changes)
RUN apt-get update && apt-get install -y \
    curl wget git build-essential \
    python3 python3-pip nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Fonts and display (rarely changes)
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip \
    && unzip FiraCode.zip -d /usr/share/fonts/truetype/ \
    && fc-cache -fv

# Layer 3: Neovim stable (changes monthly)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
    && tar -C /opt -xzf nvim-linux64.tar.gz \
    && ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

# Layer 4: Hugo (changes occasionally)
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.120.0/hugo_extended_0.120.0_linux-amd64.deb \
    && dpkg -i hugo_extended_0.120.0_linux-amd64.deb

# Layer 5: Ollama (changes occasionally)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Layer 6: Claude Code CLI (changes frequently - separate layer)
RUN npm install -g @anthropic-ai/claude-code

# Layer 7: Playwright (changes frequently - separate layer)
RUN npx playwright install --with-deps chromium

# Working directory
WORKDIR /workspace

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**Caching Strategy**:

```yaml
# .github/workflows/agentic-testing.yml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ hashFiles('.github/agentic-tests/Dockerfile') }}
    restore-keys: |
      ${{ runner.os }}-buildx-

- name: Build and cache Docker image
  uses: docker/build-push-action@v5
  with:
    context: .github/agentic-tests
    cache-from: type=local,src=/tmp/.buildx-cache
    cache-to: type=local,dest=/tmp/.buildx-cache-new
    tags: percybrain-agentic-test:latest
```

**Why**: Avoid 10+ minute rebuilds, layers cache independently, faster iteration

### 4. Manual Trigger Only (Not Commit Blocker)

**Requirement**: Expensive tests run on-demand, never block commits

**GitHub Action Trigger**:

```yaml
name: Agentic UX Testing

on:
  # Manual trigger only
  workflow_dispatch:
    inputs:
      workflow_filter:
        description: 'Run specific workflow (or "all")'
        required: false
        default: 'all'
        type: choice
        options:
          - all
          - first-note-creation
          - linking-notes
          - ai-assisted-writing
          - hugo-publishing
          - bulk-operations

      model:
        description: 'Claude model to use'
        required: false
        default: 'claude-sonnet-4'
        type: choice
        options:
          - claude-sonnet-4
          - claude-sonnet-3.5

      max_cost:
        description: 'Maximum API cost (USD)'
        required: false
        default: '2.00'
        type: string

  # Optional: Scheduled run
  schedule:
    - cron: '0 3 * * 0'  # Sundays at 3am (optional, can disable)
```

**Local Act Trigger**:

```bash
# Run manually with Act
act workflow_dispatch \
  -j agentic-test-suite \
  --input workflow_filter=first-note-creation \
  --input max_cost=1.00
```

**Why**:

- Developers control when to spend money/time
- Not in critical path (commits never blocked)
- Can run before major releases
- Useful for experimentation

### 5. Timeout and Hang Prevention

**Requirement**: No runaway processes, strict resource limits, automatic termination

**Multi-Layer Timeout Strategy**:

```yaml
jobs:
  agentic-test-suite:
    runs-on: ubuntu-latest
    timeout-minutes: 30  # Job-level timeout (hard limit)

    steps:
      - name: Individual Workflow Test
        timeout-minutes: 5  # Step-level timeout
        run: |
          # Timeout at command level
          timeout 240 claude-code run-workflow test.yaml
```

**Watchdog Script** (`.github/agentic-tests/watchdog.sh`):

```bash
#!/bin/bash
# Kills processes that exceed time/cost limits

MAX_RUNTIME_SECONDS=300  # 5 minutes
MAX_API_COST_USD=2.00
POLL_INTERVAL=10

start_time=$(date +%s)
total_cost=0

while true; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))

  # Check runtime limit
  if [ $elapsed -gt $MAX_RUNTIME_SECONDS ]; then
    echo "❌ TIMEOUT: Exceeded $MAX_RUNTIME_SECONDS seconds"
    pkill -9 -f "claude-code"
    pkill -9 -f "nvim"
    exit 124  # Standard timeout exit code
  fi

  # Check cost limit (parse from logs)
  current_cost=$(grep "API_COST:" /tmp/claude-cost.log | tail -1 | cut -d: -f2)
  if (( $(echo "$current_cost > $MAX_API_COST_USD" | bc -l) )); then
    echo "❌ COST LIMIT: Exceeded \$$MAX_API_COST_USD"
    pkill -9 -f "claude-code"
    exit 125  # Custom cost limit exit code
  fi

  # Check for hung processes
  if pgrep -f "nvim.*--headless" > /dev/null; then
    nvim_runtime=$(ps -o etimes= -p $(pgrep -f "nvim.*--headless") | awk '{print $1}')
    if [ "$nvim_runtime" -gt 120 ]; then
      echo "⚠️  Neovim hung for ${nvim_runtime}s, killing..."
      pkill -9 -f "nvim"
    fi
  fi

  sleep $POLL_INTERVAL
done
```

**Agent Instruction Safety**:

```yaml
# In workflow YAML
safety_constraints:
  max_attempts_per_step: 3
  max_retries_on_failure: 2
  timeout_per_step: 30
  abort_on_repeated_errors: true

  termination_triggers:
    - "No progress for 60 seconds"
    - "Same error 3 times in a row"
    - "Cost exceeds $2.00"
    - "Runtime exceeds 5 minutes"
```

**Why**: Prevents runaway costs, protects GitHub Action quota, fails gracefully

### 6. Structured Determinism (80% Predictable)

**Requirement**: AI stays on-script, limited creativity, high reproducibility

**Structured Agent Instructions**:

```yaml
# Each workflow step has explicit constraints
- step: "Create new note"
  action: "Press <leader>zn"

  # Deterministic path
  required_sequence:
    1. "Wait for title prompt"
    2. "Type exact title: 'Test Note'"
    3. "Press Enter"
    4. "Wait for buffer to open"
    5. "Verify template loaded"

  # Constrain agent creativity
  constraints:
    allowed_deviations: ["retry on error", "wait for UI"]
    forbidden_actions: ["explore other commands", "experiment with settings"]
    max_exploration_steps: 0  # Zero exploration allowed

  # Clear success/failure
  success_condition: "Buffer contains '# Test Note' header"
  failure_condition: "Timeout OR error message"

  # No ambiguity
  on_success: "Proceed to next step"
  on_failure: "Abort workflow, report error"
```

**Agent System Prompt Constraints**:

```
You are executing a rigorously defined test workflow. Your job is to:

1. Follow the exact sequence of steps provided
2. Do NOT deviate from the script
3. Do NOT explore alternative approaches
4. Do NOT experiment with different commands
5. Report ONLY what the workflow asks for

If a step fails:
- Retry exactly ONCE using the same approach
- If retry fails, STOP and report the failure
- Do NOT try creative solutions
- Do NOT continue to next step

Your responses must be:
- Structured (follow exact output format)
- Deterministic (same input = same output)
- Brief (no commentary beyond requested)
- Factual (report what happened, not opinions)

Think of yourself as a QA robot, not a creative problem-solver.
```

**Output Format Enforcement**:

```json
{
  "workflow": "first-note-creation",
  "step": 3,
  "step_name": "Enter note title",
  "status": "success|failure|timeout",
  "duration_ms": 1234,
  "observations": [
    "Prompt appeared after 0.5s",
    "Typed 'Test Note' successfully",
    "Template loaded with frontmatter"
  ],
  "friction_detected": [
    {
      "type": "missing_feedback",
      "severity": "medium",
      "description": "No visual confirmation after save"
    }
  ],
  "next_action": "proceed|retry|abort"
}
```

**Limited Reasoning Budget**:

```yaml
agent_config:
  temperature: 0.1  # Low creativity
  max_thinking_tokens: 500  # Brief reasoning
  response_format: "structured_json"  # No free-form text
  allowed_tools: ["nvim_command", "bash_verify"]  # Limited toolset
  forbidden_tools: ["web_search", "code_generation"]  # No exploration
```

**Why**:

- Predictable behavior
- Reproducible results
- Fast execution (no wasted thinking)
- Cost-efficient (minimal token usage)
- Easy to debug (deterministic failures)

## Integration Example

```yaml
# .github/workflows/agentic-testing.yml (production-ready)
name: Agentic UX Testing

on:
  workflow_dispatch:
    inputs:
      workflow_filter:
        description: 'Workflow to test'
        required: true
        default: 'all'
      max_cost:
        description: 'Max cost (USD)'
        required: false
        default: '2.00'

jobs:
  agentic-test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    container:
      image: ghcr.io/${{ github.repository }}/percybrain-agentic-test:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Start Watchdog
        run: |
          .github/agentic-tests/watchdog.sh &
          echo $! > /tmp/watchdog.pid

      - name: Run Hugo Server (Background)
        run: |
          hugo server --port 1313 &
          echo $! > /tmp/hugo.pid
          sleep 2

      - name: Execute Workflow Tests
        timeout-minutes: 5
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          MAX_COST: ${{ inputs.max_cost }}
        run: |
          claude-code \
            --max-cost $MAX_COST \
            --config .github/agentic-tests/agent-config.json \
            run-workflow .github/agentic-tests/workflows/${{ inputs.workflow_filter }}.yaml

      - name: Cleanup
        if: always()
        run: |
          kill $(cat /tmp/hugo.pid) || true
          kill $(cat /tmp/watchdog.pid) || true

      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ux-test-report
          path: reports/*.md
```

## Cost Analysis

**Per Workflow Estimates**:

- Simple workflow (first-note): ~5K tokens = $0.15
- Complex workflow (hugo-publishing): ~15K tokens = $0.45
- Full suite (5 workflows): ~40K tokens = $1.20

**Safety Limits**:

- Hard cap: $2.00 per run
- Watchdog terminates at $2.01
- Budget alerts at $1.50

**GitHub Action Minutes**:

- With cached Docker image: ~8 minutes total
- Without cache: ~15 minutes (first run)
- Act local run: Free (uses local compute)

## Success Criteria

Framework is production-ready when: ✅ Runs successfully in Act locally ✅ Docker image cached efficiently (\<2min cold start) ✅ No workflow exceeds 5 minutes ✅ No run exceeds $2.00 cost ✅ Zero hangs or runaway processes ✅ 95%+ reproducible results ✅ Clear, actionable failure reports
