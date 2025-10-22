# Ollama Integration Implementation - 2025-10-21

## Overview

Implemented comprehensive Ollama auto-start integration with IWE LSP and GTD AI using OpenAI-compatible endpoints.

## Key Discovery

Ollama provides built-in OpenAI-compatible API at `http://localhost:11434/v1/` - no custom abstraction layer needed!

## Files Created

### Core Components

1. **`lua/percybrain/ollama-manager.lua`** (370 lines)

   - Auto-start Ollama server on Neovim launch
   - Model management (change, pull, configure)
   - Health checks and status monitoring
   - Commands: `:OllamaStart`, `:OllamaHealth`, `:OllamaModel <name>`

2. **`~/Zettelkasten/templates/.iwe/config-ollama.toml`** (140 lines)

   - IWE config using Ollama OpenAI-compatible endpoints
   - Actions: expand, rewrite, keywords, emoji
   - Base URL: `http://localhost:11434/v1`
   - API key: any value (Ollama ignores it)

3. **`lua/percybrain/gtd/iwe-bridge.lua`** (110 lines)

   - Task detection in extracted notes
   - Auto-decompose prompting
   - Commands: `:GtdDecomposeNote`, `:GtdToggleAutoDecompose`

### Integration Updates

4. **`lua/percybrain/gtd/ai.lua`** (MODIFIED)

   - Changed from `/api/generate` to `/v1/chat/completions`
   - Chat completion format (messages array)
   - Uses `vim.g.ollama_model` for model selection

5. **`lua/plugins/zettelkasten/sembr-integration.lua`** (ENHANCED)

   - IWE extract/inline hooks for auto-formatting
   - Task detection notifications
   - Autocmds: `IWEExtractComplete`, `IWEInlineComplete`

6. **`lua/config/keymaps/workflows/iwe.lua`** (ENHANCED)

   - `<leader>za*` namespace: IWE AI transformations (zae, zaw, zak, zam)
   - `<leader>zr*` extended: GTD AI operations (zrd, zrc, zrp, zra)

7. **`lua/config/init.lua`** (MODIFIED)

   - Ollama manager setup with config
   - GTD-IWE bridge initialization

### Testing

8. **`tests/contract/ollama_integration_spec.lua`** (673 lines, 34 tests)

   - Ollama manager contracts (22 tests)
   - GTD AI OpenAI compatibility (12 tests)
   - All following AAA pattern

9. **`tests/capability/ollama/workflow_spec.lua`** (695 lines, 30 tests)

   - Task decomposition, context, priority
   - GTD-IWE bridge workflows
   - Full extract → format → decompose integration

### Documentation

10. **`docs/how-to/OLLAMA_INTEGRATION_SETUP.md`** (Complete guide)
    - Installation steps
    - Configuration options
    - Usage examples
    - Troubleshooting

## Architecture

### OpenAI-Compatible API Pattern

```
IWE LSP → http://localhost:11434/v1/chat/completions
GTD AI  → http://localhost:11434/v1/chat/completions
          (Unified Ollama backend)
```

### Workflow Pipeline

1. User extracts section with IWE (`<leader>zrx`)
2. SemBr auto-formats (semantic line breaks)
3. Task detection triggers
4. GTD AI decomposes if user confirms
5. Result: Formatted note with decomposed tasks

## Keybindings

### IWE AI Transformations (`<leader>za*`)

- `<leader>zae` - Expand text
- `<leader>zaw` - Rewrite for clarity
- `<leader>zak` - Bold keywords
- `<leader>zam` - Add emojis

### GTD AI Operations (`<leader>zr*`)

- `<leader>zrd` - Decompose task
- `<leader>zrc` - Suggest context
- `<leader>zrp` - Infer priority
- `<leader>zra` - Auto-enhance (all-in-one)

### SemBr Formatting

- `<leader>zs` - Format buffer/selection
- `<leader>zt` - Toggle auto-format

## Configuration

### Default Setup (lua/config/init.lua)

```lua
require("percybrain.ollama-manager").setup({
  enabled = true,
  model = "llama3.2",
  auto_pull = false,
  timeout = 30,
})

require("percybrain.gtd.iwe-bridge").setup({
  auto_decompose = false,
})
```

### User Overrides

```lua
-- Disable auto-start
vim.g.ollama_config = { enabled = false }

-- Change model
vim.g.ollama_config = { model = "mistral" }

-- Auto-decompose without prompting
vim.g.gtd_iwe_auto_decompose = true
```

## Testing Results

### Contract Tests (34 total)

- Ollama manager: 22 tests (installation, server lifecycle, health, commands)
- GTD AI: 12 tests (OpenAI endpoints, chat format, model selection)

### Capability Tests (30 total)

- Task decomposition: 8 tests
- Context suggestion: 6 tests
- Priority inference: 6 tests
- GTD-IWE bridge: 6 tests
- Full workflow: 4 tests

### Test Execution

```bash
mise tc    # Contract tests
mise tcap  # Capability tests
mise test  # All tests
```

## Benefits

✅ **Zero Custom Code** - IWE works with Ollama's OpenAI mode directly ✅ **Unified Backend** - Single Ollama instance for IWE + GTD AI ✅ **100% Local** - No external API calls, complete privacy ✅ **Auto-Start** - Ollama starts automatically with Neovim ✅ **Model Flexibility** - Easy model switching via `:OllamaModel` ✅ **Workflow Integration** - Extract → Format → Decompose pipeline ✅ **Comprehensive Tests** - 64 tests with proper mocking

## Installation

### Prerequisites

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull model
ollama pull llama3.2

# Set env var
export OLLAMA_API_KEY="ollama"  # pragma: allowlist secret
```

### Setup

```bash
# Copy IWE config
cp ~/Zettelkasten/templates/.iwe/config-ollama.toml \
   ~/Zettelkasten/.iwe/config.toml
```

### Verify

```vim
:OllamaHealth
```

## Commands Reference

### Ollama Manager

- `:OllamaStart` - Start server manually
- `:OllamaHealth` - Show health status
- `:OllamaModel <name>` - Change active model

### GTD-IWE Bridge

- `:GtdDecomposeNote` - Decompose all tasks in note
- `:GtdToggleAutoDecompose` - Toggle auto-decompose

### SemBr

- `:SemBrFormat` - Format with semantic line breaks
- `:SemBrToggle` - Toggle auto-format on save

## Technical Details

### OpenAI Endpoint Format

```json
{
  "model": "llama3.2",
  "messages": [
    {"role": "user", "content": "prompt"}
  ],
  "stream": false
}
```

### Response Format

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "response text"
      }
    }
  ]
}
```

### IWE Integration

- Triggers: `User` autocmds (`IWEExtractComplete`, `IWEInlineComplete`)
- Hooks: Post-extract formatting, task detection
- Actions: expand, rewrite, keywords, emoji (all Ollama-powered)

### GTD AI Migration

- Old: `/api/generate` with `prompt` field
- New: `/v1/chat/completions` with `messages` array
- Model: Uses `vim.g.ollama_model` or defaults to "llama3.2"

## Future Enhancements

- [ ] Add model auto-download option (`auto_pull = true`)
- [ ] Implement streaming responses for long text
- [ ] Add temperature/top_p configuration per action
- [ ] Create preset prompt templates library
- [ ] Add token usage tracking and metrics
- [ ] Integrate with PercyBrain dashboard for AI analytics

## Related Memories

- `gtd_ai_implementation_2025-10-20` - Original GTD AI design
- `iwe_integration_2025-10-21` - IWE LSP setup
- `sembr_integration_2025-10-21` - Semantic formatting

## Related Documentation

- `docs/how-to/OLLAMA_INTEGRATION_SETUP.md` - User guide
- `claudedocs/OLLAMA_INTEGRATION_TESTS_2025-10-21.md` - Test documentation
- `docs/reference/KEYBINDINGS_REFERENCE.md` - Complete keymap catalog
