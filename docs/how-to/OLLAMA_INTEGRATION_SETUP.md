# Ollama Integration Setup Guide

**Updated**: 2025-10-21 **Component**: Ollama Auto-Start + IWE + GTD AI Integration **Type**: How-To Guide (Task-Oriented)

## Overview

PercyBrain now features **automatic Ollama integration** for local AI-powered note-taking and task management. Ollama starts automatically with Neovim and provides:

- **IWE AI Transformations**: Expand, rewrite, add keywords, emojify notes
- **GTD AI Operations**: Decompose tasks, suggest contexts, infer priorities
- **SemBr Integration**: Automatic semantic formatting after note operations
- **Privacy-First**: 100% local AI, no external API calls

## Prerequisites

### 1. Install Ollama

```bash
# Linux/macOS
curl -fsSL https://ollama.com/install.sh | sh

# Or via package manager
# macOS: brew install ollama
# Linux: see https://ollama.com/download
```

Verify installation:

```bash
ollama --version
```

### 2. Pull Default Model

```bash
# Pull llama3.2 (default model, ~2GB)
ollama pull llama3.2

# Alternative models:
# ollama pull llama3.1      # Larger, more capable
# ollama pull mistral       # Fast, efficient
# ollama pull codellama     # Code-focused
```

Verify model:

```bash
ollama list | grep llama3.2
```

### 3. Install IWE LSP (If Not Already Installed)

```bash
# Install IWE (Incremental Writing Environment)
cargo install iwe

# Verify
which iwe
```

### 4. Set Environment Variable

Add to `~/.bashrc`, `~/.zshrc`, or equivalent:

```bash
# Required for IWE OpenAI compatibility
export OLLAMA_API_KEY="ollama"  # pragma: allowlist secret
```

Reload shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

## Installation

### 1. Configure IWE for Ollama

The template is already created at `~/Zettelkasten/templates/.iwe/config-ollama.toml`.

**Copy to active Zettelkasten**:

```bash
# Create IWE config directory
mkdir -p ~/Zettelkasten/.iwe

# Copy Ollama-enabled config
cp ~/Zettelkasten/templates/.iwe/config-ollama.toml ~/Zettelkasten/.iwe/config.toml
```

**Verify configuration**:

```bash
cat ~/Zettelkasten/.iwe/config.toml | grep -A 2 "\[models.default\]"
```

Expected output:

```toml
[models.default]
api_key_env = "OLLAMA_API_KEY"  # pragma: allowlist secret
base_url = "http://localhost:11434/v1"  # pragma: allowlist secret
name = "llama3.2"
```

### 2. Verify Neovim Configuration

The Ollama manager is automatically initialized in `lua/config/init.lua`:

```lua
require("percybrain.ollama-manager").setup({
  enabled = true,              -- Auto-start enabled
  model = "llama3.2",          -- Default model
  auto_pull = false,           -- Don't auto-download
  timeout = 30,                -- 30s startup timeout
})
```

**To disable auto-start** (add to your personal init):

```lua
vim.g.ollama_config = {
  enabled = false,  -- Disable auto-start
}
```

### 3. Test Integration

**Start Neovim**:

```bash
nvim
```

You should see:

- ✅ "Starting Ollama server..."
- ✅ "Ollama server ready (took Xs)"

**Check health**:

```vim
:OllamaHealth
```

Expected output:

```
# Ollama Integration Health

✓ Ollama installed: Yes
✓ Server running: Yes
✓ Model available: Yes (llama3.2)
✓ OpenAI compatible: Yes
```

**Test OpenAI API**:

```bash
curl http://localhost:11434/v1/models
```

Expected: JSON response with model list.

## Usage

### IWE AI Transformations

**Keybindings** (`<leader>za*` namespace):

| Key           | Action              | Description                          |
| ------------- | ------------------- | ------------------------------------ |
| `<leader>zae` | Expand text         | Generate paragraphs from brief notes |
| `<leader>zaw` | Rewrite for clarity | Improve readability                  |
| `<leader>zak` | Bold keywords       | Mark important terms with `**text**` |
| `<leader>zam` | Add emojis          | Add relevant emojis to headers/lists |

**Example Workflow**:

1. Visual select text: `vip` (select paragraph)
2. Press `<leader>zae` to expand
3. Ollama processes locally → expanded text inserted

### GTD AI Operations

**Keybindings** (`<leader>zr*` namespace):

| Key           | Action                    | Description                         |
| ------------- | ------------------------- | ----------------------------------- |
| `<leader>zrd` | Decompose task            | Break down into actionable subtasks |
| `<leader>zrc` | Suggest context tag       | Add @home, @work, @computer, etc.   |
| `<leader>zrp` | Infer priority            | Assign HIGH/MEDIUM/LOW priority     |
| `<leader>zra` | Auto-enhance (all-in-one) | Decompose + context + priority      |

**Example Workflow**:

1. Cursor on task line: `- [ ] Build website for client`
2. Press `<leader>zrd` to decompose
3. Ollama generates subtasks:
   ```markdown
   - [ ] Build website for client
     - [ ] Research client requirements
     - [ ] Design mockups and wireframes
     - [ ] Develop frontend with HTML/CSS
     - [ ] Add backend functionality
     - [ ] Deploy to hosting service
   ```

### SemBr Formatting

**Keybindings**:

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>zs` | Format with semantic line breaks |
| `<leader>zt` | Toggle auto-format on save       |

**Automatic Integration**:

- After IWE extract → Auto-format with SemBr
- After IWE inline → Re-format to preserve semantic structure
- Task detected → Notify user with decomposition option

### Full Workflow Example

**Scenario**: Extract section, format, decompose tasks

1. **Extract section with IWE**:

   - Visual select: `V` + arrow keys
   - Extract: `<leader>zrx`
   - New note created with WikiLink

2. **Auto-format with SemBr** (happens automatically):

   - Semantic line breaks applied
   - Clean git diffs enabled

3. **Decompose detected tasks**:

   - Prompt: "Task detected. Decompose with GTD AI?"
   - Select: "Yes" or press `<leader>zrd` manually
   - Subtasks generated and formatted

4. **Result**:

   - New note with semantic formatting
   - Tasks broken down into actionable subtasks
   - Context tags and priorities suggested
   - All processing done locally with Ollama

## Configuration

### Change Default Model

**In Neovim**:

```vim
:OllamaModel mistral
```

**Permanently** (add to your init):

```lua
vim.g.ollama_config = {
  model = "mistral",  -- Change default model
}
```

### Disable Auto-Decompose Prompt

**Always auto-decompose** (add to your init):

```lua
vim.g.gtd_iwe_auto_decompose = true
```

### Adjust Startup Timeout

```lua
vim.g.ollama_config = {
  timeout = 60,  -- Increase to 60 seconds
}
```

### Disable Auto-Start

**Option 1**: Environment variable (temporary):

```bash
OLLAMA_ENABLED=false nvim
```

**Option 2**: Configuration (permanent):

```lua
vim.g.ollama_config = {
  enabled = false,
}
```

## Commands

### Ollama Manager Commands

| Command               | Description                          |
| --------------------- | ------------------------------------ |
| `:OllamaStart`        | Manually start Ollama server         |
| `:OllamaHealth`       | Show health status and configuration |
| `:OllamaModel <name>` | Change active model                  |

### GTD-IWE Bridge Commands

| Command                   | Description                         |
| ------------------------- | ----------------------------------- |
| `:GtdDecomposeNote`       | Decompose all tasks in current note |
| `:GtdToggleAutoDecompose` | Toggle automatic task decomposition |

### SemBr Commands

| Command        | Description                        |
| -------------- | ---------------------------------- |
| `:SemBrFormat` | Format buffer/selection with SemBr |
| `:SemBrToggle` | Toggle auto-format on save         |

## Troubleshooting

### Ollama Not Starting

**Symptom**: "Ollama server failed to start within 30s"

**Solutions**:

1. Check Ollama installation: `ollama --version`
2. Check if already running: `curl http://localhost:11434/api/tags`
3. Start manually: `ollama serve` (in separate terminal)
4. Increase timeout: `vim.g.ollama_config = { timeout = 60 }`

### Model Not Found

**Symptom**: "Model 'llama3.2' not found"

**Solution**:

```bash
ollama pull llama3.2
```

### IWE Actions Not Working

**Symptom**: AI actions don't appear in code actions menu

**Solutions**:

1. Verify IWE LSP running: `:LspInfo`
2. Check IWE config exists: `ls ~/Zettelkasten/.iwe/config.toml`
3. Verify OLLAMA_API_KEY set: `echo $OLLAMA_API_KEY`
4. Restart IWE LSP: `:LspRestart`

### GTD AI Not Responding

**Symptom**: "Failed to connect to Ollama"

**Solutions**:

1. Check Ollama server: `curl http://localhost:11434/v1/models`
2. Verify OpenAI endpoint: `curl http://localhost:11434/v1/chat/completions -H "Content-Type: application/json" -d '{"model":"llama3.2","messages":[{"role":"user","content":"test"}]}'`
3. Check logs: `:messages` in Neovim

### Slow Response Times

**Symptom**: AI operations take >10 seconds

**Solutions**:

1. Use faster model: `:OllamaModel llama3.2` (smaller than llama3.1)
2. Check system resources: `htop` or `top`
3. Reduce prompt complexity (edit IWE config prompts)
4. Increase timeout if needed

## Testing

**Run integration tests**:

```bash
# Contract tests (specifications)
mise tc

# Capability tests (workflows)
mise tcap

# All tests
mise test
```

**Expected**:

- Contract tests: 34/34 passing
- Capability tests: 30/30 passing
- Integration tests: All passing

## Performance Notes

**Startup Time**:

- Ollama cold start: 2-5 seconds
- Neovim + Ollama: +2-5s total startup time
- Auto-start can be disabled if startup speed critical

**AI Response Times** (llama3.2 on typical hardware):

- Text expansion: 2-4 seconds
- Task decomposition: 3-5 seconds
- Context suggestion: 1-2 seconds
- Priority inference: 1-2 seconds

**Resource Usage**:

- RAM: +1-2GB (Ollama + model)
- CPU: Minimal when idle, spikes during inference
- Disk: ~2GB per model

## Security and Privacy

✅ **100% Local**: All AI processing happens on your machine ✅ **No Network Calls**: IWE and GTD AI use local Ollama only ✅ **No Data Collection**: Your notes never leave your computer ✅ **OpenAI Compatible**: Easy migration if you want cloud AI later

## Next Steps

- **Customize Prompts**: Edit `~/Zettelkasten/.iwe/config.toml` actions
- **Try Different Models**: `:OllamaModel mistral` or `:OllamaModel codellama`
- **Create Workflows**: Combine IWE + SemBr + GTD AI for your use case
- **Read Philosophy**: See `docs/explanation/LOCAL_AI_RATIONALE.md`

## Related Documentation

- **IWE LSP Reference**: `docs/reference/LSP_REFERENCE.md`
- **GTD System Guide**: `docs/how-to/GTD_USAGE.md`
- **SemBr Integration**: `docs/how-to/SEMBR_USAGE.md`
- **Keybindings Reference**: `docs/reference/KEYBINDINGS_REFERENCE.md`
- **Test Documentation**: `claudedocs/OLLAMA_INTEGRATION_TESTS_2025-10-21.md`
