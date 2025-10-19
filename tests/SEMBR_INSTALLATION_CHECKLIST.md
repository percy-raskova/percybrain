# SemBr Installation Checklist

## Prerequisites

### Required Software

- [ ] Neovim >= 0.8.0
- [ ] Git >= 2.19.0
- [ ] Python >= 3.8 (for sembr tool)
- [ ] UV package manager (for installing sembr)

### Install SemBr Binary

```bash
# Install UV if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install SemBr formatter
uv tool install sembr

# Verify installation
sembr --version
```

## Neovim Plugin Installation

### 1. Core Git Plugins

These are automatically installed via lazy.nvim when you start Neovim:

- [ ] vim-fugitive (Git operations)
- [ ] gitsigns.nvim (Visual Git integration)
- [ ] diffview.nvim (optional, for advanced diffs)

### 2. SemBr Integration Layer

Already configured in your PercyBrain setup:

- [ ] `/lua/percybrain/sembr-git.lua` - Core integration
- [ ] `/lua/plugins/zettelkasten/sembr-integration.lua` - Plugin config
- [ ] `/lua/plugins/utilities/fugitive.lua` - Fugitive extensions
- [ ] `/lua/plugins/utilities/gitsigns.lua` - Gitsigns configuration

## Git Configuration

### Automatic Configuration

When you first use SemBr Git commands, the system will automatically configure Git:

```bash
# These are set automatically:
git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"
git config diff.algorithm patience
git config diff.wordDiff true
git config merge.tool vimdiff
git config merge.conflictstyle diff3
```

### Manual Configuration (Optional)

If you want to configure Git manually:

```bash
cd ~/Zettelkasten

# Configure word-level diff for markdown
git config diff.markdown.wordRegex "([^[:space:]]|([[:alnum:]]|/)+)"

# Use patience algorithm for better semantic diffs
git config diff.algorithm patience

# Enable word diff
git config diff.wordDiff true

# Set merge tool and style
git config merge.tool vimdiff
git config merge.conflictstyle diff3
```

### .gitattributes Setup

The system will automatically create `.gitattributes` in your Zettelkasten:

```gitattributes
# Semantic Line Breaks configuration for markdown
*.md diff=markdown
*.md merge=union
*.markdown diff=markdown
*.markdown merge=union

# Treat markdown as text for stats
*.md linguist-detectable=true
*.md linguist-documentation=false

# LFS for images in vault
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
```

## Testing the Installation

### 1. Start Neovim

```bash
cd ~/Zettelkasten
nvim
```

### 2. Check Plugin Installation

```vim
:Lazy
" Look for vim-fugitive and gitsigns.nvim in the list
" They should show as [loaded] or [lazy]
```

### 3. Test SemBr Formatter

```vim
" Open a markdown file
:e test.md

" Add some text
iThis is a very long sentence that contains multiple clauses and should be broken up into semantic line breaks for better version control and readability.<Esc>

" Format with SemBr
:SemBrFormat

" The text should now be broken into semantic lines
```

### 4. Test Git Integration

```vim
" Check Git status (fugitive)
:Git status

" View SemBr-enhanced diff
:GSemBrDiff

" View SemBr-aware blame
:GSemBrBlame

" Stage with SemBr preview
:GSemBrStage
```

### 5. Test Keymaps

| Keymap        | Command            | Expected Result                 |
| ------------- | ------------------ | ------------------------------- |
| `<leader>zs`  | Format with SemBr  | Text breaks into semantic lines |
| `<leader>zt`  | Toggle auto-format | Enable/disable format on save   |
| `<leader>gsd` | SemBr Git diff     | Diff with word wrap enabled     |
| `<leader>gsb` | SemBr Git blame    | Blame with line wrapping        |
| `<leader>gsc` | SemBr Git commit   | Commit with SemBr formatting    |

## Verification Commands

### Check SemBr Binary

```bash
# Should output version
sembr --version

# Test formatting
echo "This is a long sentence with multiple clauses that should be split." | sembr
```

### Check Git Configuration

```bash
cd ~/Zettelkasten
git config --list | grep -E "(diff|merge)"
```

### Check Neovim Integration

```vim
" Should list all SemBr commands
:command GSembr

" Should show SemBr keymaps
:map <leader>z
:map <leader>gs
```

## Troubleshooting

### SemBr Binary Not Found

```bash
# Ensure UV is in PATH
echo $PATH | grep -q ".local/bin" || export PATH="$HOME/.local/bin:$PATH"

# Reinstall sembr
uv tool install --force sembr
```

### Plugins Not Loading

```vim
" Force reload plugins
:Lazy reload vim-fugitive
:Lazy reload gitsigns.nvim

" Check for errors
:checkhealth
```

### Git Commands Not Working

```vim
" Ensure you're in a Git repository
:!git status

" Initialize if needed
:!git init
```

### Formatting Not Working

```vim
" Check if sembr is accessible from Neovim
:!which sembr

" Try manual formatting
:%!sembr
```

## Usage Tips

### Daily Workflow

1. Write your notes naturally in long paragraphs
2. Use `<leader>zs` to format with semantic line breaks before committing
3. Git diffs will show meaningful changes at the clause level
4. Hugo will render paragraphs correctly (ignoring line breaks)

### Auto-Format on Save

```vim
" Enable auto-format for current session
:SemBrToggle

" Or use keymap
<leader>zt
```

### Best Practices

- Format just before committing for cleaner diffs
- Use word-level diff view for reviewing changes
- Keep auto-format OFF during initial drafting
- Enable auto-format during editing/revision phase

## Integration with Hugo

Hugo automatically handles SemBr-formatted markdown:

- Line breaks within paragraphs are ignored
- Paragraphs are separated by blank lines
- Result: Clean rendering despite semantic line breaks

No special Hugo configuration needed!

## Success Indicators

✅ **You're ready when:**

- [ ] `sembr --version` shows output
- [ ] `:SemBrFormat` command exists in Neovim
- [ ] `<leader>zs` formats text into semantic lines
- [ ] `:GSemBrDiff` shows wrapped diff view
- [ ] Git commits show clause-level changes
- [ ] Hugo preview renders paragraphs correctly

## Support

If you encounter issues:

1. Check `:checkhealth` in Neovim
2. Review `~/.config/nvim/lua/percybrain/sembr-git.lua`
3. Verify Git version: `git --version` (need >= 2.19.0)
4. Check sembr installation: `uv tool list | grep sembr`

______________________________________________________________________

**Remember the Philosophy**: We extend existing tools (vim-fugitive, gitsigns) rather than reinventing. The SemBr layer is thin and maintainable - only ~300 lines of integration code!
