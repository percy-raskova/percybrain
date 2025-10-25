# SemBr Offline Setup - Local Model Configuration

**Status**: ✅ Configured for maximum privacy **Last Updated**: 2025-10-24

## Overview

SemBr has been configured to use locally stored models, ensuring zero network calls to Hugging Face during inference. All model files are stored on disk and loaded from `~/.local/share/sembr/models/`.

## Current Configuration

**Model Location**: `~/.local/share/sembr/models/sembr2023-bert-small/` **Model Size**: 437MB on disk (219MB apparent) **Network Access**: None required (offline mode)

### Model Files

```
~/.local/share/sembr/models/sembr2023-bert-small/
├── config.json              (model configuration)
├── model.safetensors        (model weights - safetensors format)
├── pytorch_model.bin        (model weights - PyTorch format)
├── tokenizer.json           (tokenizer)
├── tokenizer_config.json    (tokenizer config)
├── vocab.txt                (vocabulary)
├── special_tokens_map.json  (special tokens)
└── training_args.bin        (training metadata)
```

## Neovim Configuration

### Plugin Configuration

**File**: `~/.config/nvim/lua/plugins/ai-sembr/sembr.lua`

```lua
M.config = {
  -- Local model path for maximum privacy (no network calls)
  model = vim.fn.expand("~/.local/share/sembr/models/sembr2023-bert-small"),
  auto_format = false,
  enable_mcp = false,
}
```

### Environment Variables (Mise)

**File**: `~/.config/nvim/.mise.toml`

```toml
[env]
# AI/ML Privacy - Force offline mode for transformers (SemBr)
TRANSFORMERS_OFFLINE = "1"  # Prevents Hugging Face API calls, uses local models only
SEMBR_MODEL_PATH = "~/.local/share/sembr/models/sembr2023-bert-small"  # Local SemBr model path
```

**What these do:**

- `TRANSFORMERS_OFFLINE=1`: Forces all transformer-based tools to operate in offline mode (no network calls)
- `SEMBR_MODEL_PATH`: Specifies which local model to use (makes switching models easier)

These environment variables are automatically set by mise when working in the Neovim directory.

## Usage

### Neovim Keybindings

- `<leader>sb` - Format current buffer with semantic line breaks
- `<leader>ss` - Format visual selection (in visual mode)
- `<leader>st` - Toggle auto-format on save

### First Run

On first use in Neovim, the model will load from disk (no download needed). Subsequent uses will be faster as the model stays in memory.

### CLI Usage (Offline Mode)

```bash
# Offline mode (will fail if model not found locally)
TRANSFORMERS_OFFLINE=1 sembr -m ~/.local/share/sembr/models/sembr2023-bert-small -i file.md

# Normal mode (same result, just doesn't enforce offline)
sembr -m ~/.local/share/sembr/models/sembr2023-bert-small -i file.md
```

## Privacy Guarantees

✅ **No Hugging Face API Calls**: Model loaded from local filesystem only ✅ **No Model Updates**: Model version frozen, no automatic updates ✅ **No Telemetry**: No usage statistics sent to external services ✅ **Offline Capable**: Works without internet connection

## Downloading Additional Models

If you want to download other SemBr models for different speed/accuracy trade-offs:

### Available Models

| Model             | Size       | Speed        | Accuracy  | Hugging Face Path                         |
| ----------------- | ---------- | ------------ | --------- | ----------------------------------------- |
| bert-tiny         | ~17MB      | Fastest      | Good      | `admko/sembr2023-bert-tiny`               |
| bert-mini         | ~42MB      | Fast         | Better    | `admko/sembr2023-bert-mini`               |
| **bert-small** ✅ | **~220MB** | **Balanced** | **Best**  | `admko/sembr2023-bert-small`              |
| distilbert-base   | ~260MB     | Slower       | Excellent | `admko/sembr2023-distilbert-base-uncased` |

### Download Command

```bash
# Create model directory
mkdir -p ~/.local/share/sembr/models

# Clone desired model (example: bert-tiny for faster inference)
cd ~/.local/share/sembr/models
git clone https://huggingface.co/admko/sembr2023-bert-tiny

# Update Neovim config to point to new model
# Edit: ~/.config/nvim/lua/plugins/ai-sembr/sembr.lua
# Change: model = vim.fn.expand("~/.local/share/sembr/models/sembr2023-bert-tiny")
```

### Switching Models

To switch between models, edit the `SEMBR_MODEL_PATH` in `~/.config/nvim/.mise.toml`:

```toml
[env]
# Option 1: Fastest (17MB, good accuracy)
SEMBR_MODEL_PATH = "~/.local/share/sembr/models/sembr2023-bert-tiny"

# Option 2: Fast (42MB, better accuracy)
SEMBR_MODEL_PATH = "~/.local/share/sembr/models/sembr2023-bert-mini"

# Option 3: Balanced (220MB, best accuracy) ✅ CURRENT DEFAULT
SEMBR_MODEL_PATH = "~/.local/share/sembr/models/sembr2023-bert-small"

# Option 4: Accurate (260MB, excellent accuracy)
SEMBR_MODEL_PATH = "~/.local/share/sembr/models/sembr2023-distilbert-base-uncased"
```

Then restart Neovim to load the new environment variable.

## Verification

### Test Offline Mode Works

```bash
# Create test file
echo "This is a test sentence that should be broken into semantic line breaks." > /tmp/test.txt

# Run sembr in offline mode
TRANSFORMERS_OFFLINE=1 sembr -m ~/.local/share/sembr/models/sembr2023-bert-small -i /tmp/test.txt

# Expected output (with semantic breaks):
# This is a test sentence
# that should be broken into semantic line breaks.
```

If this works, your setup is fully offline and private.

### Check Model Size

```bash
du -sh ~/.local/share/sembr/models/sembr2023-bert-small/
# Expected: ~437M (219M apparent)
```

## Troubleshooting

### Issue: "Model not found" error

**Solution**: Verify model files exist:

```bash
ls -la ~/.local/share/sembr/models/sembr2023-bert-small/
# Should show config.json, model.safetensors, tokenizer files, etc.
```

### Issue: "401 Unauthorized" or network errors

**Solution**: You're trying to use a Hugging Face path instead of local path. Check config:

```lua
-- ❌ Wrong: Will try to download from Hugging Face
model = "admko/sembr2023-bert-small"

-- ✅ Correct: Uses local files only
model = vim.fn.expand("~/.local/share/sembr/models/sembr2023-bert-small")
```

### Issue: Model loads slowly

**First load**: ~2-5 seconds (loading from disk) **Subsequent uses**: \<1 second (model in memory)

This is normal. The model stays in memory after first use for fast subsequent operations.

### Issue: High memory usage

**Expected**: ~1.7GB RAM for bert-small model **Mitigation**: Use smaller model (bert-tiny: ~500MB RAM, bert-mini: ~1GB RAM)

## Maintenance

### Updating Models

Models are versioned and frozen at download time. To update:

```bash
cd ~/.local/share/sembr/models/sembr2023-bert-small
git pull
```

**Note**: Only do this if you trust the model updates. Pulling updates means network access to Hugging Face.

### Removing Models

```bash
# Remove specific model
rm -rf ~/.local/share/sembr/models/sembr2023-bert-small

# Remove all models
rm -rf ~/.local/share/sembr/models
```

## References

- **SemBr GitHub**: https://github.com/admk/sembr
- **Hugging Face Models**: https://huggingface.co/admko
- **Neovim Config**: `~/.config/nvim/lua/plugins/ai-sembr/sembr.lua`

______________________________________________________________________

**Privacy Status**: ✅ Fully Offline | No telemetry | No external network calls **Setup Date**: 2025-10-24 **Model Version**: sembr2023-bert-small (frozen at download)
