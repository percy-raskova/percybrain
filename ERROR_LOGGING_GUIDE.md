# PercyBrain Error Logging Guide

## 🔍 Quick Error Checking Commands

Using Neovim's **built-in** error tracking features:

### Inside Neovim

| Command        | Keybinding   | Description                                   |
| -------------- | ------------ | --------------------------------------------- |
| `:messages`    | -            | Show all messages/errors from current session |
| `:PercyErrors` | `<leader>pe` | Show all errors in a new split window         |
| `:PercyRecent` | -            | Show only recent errors from this session     |
| `:PercyHealth` | `<leader>ph` | Run full health check                         |
| `:checkhealth` | -            | Native Neovim health check                    |
| `:Lazy log`    | -            | Show lazy.nvim plugin loading errors          |

### From Terminal

```bash
# Run Neovim with verbose logging
nvim -V10/tmp/nvim-debug.log

# Check for startup errors
nvim --headless -c 'messages' -c 'qall' 2>&1

# Run health check
nvim --headless -c 'checkhealth' -c 'qall'

# Check specific plugin health
nvim --headless -c 'checkhealth lazy' -c 'qall'
```

## 🎯 Most Common PercyBrain Errors to Check

1. **LSP Errors**: `:LspInfo` - Check if IWE/markdown_oxide is running
2. **Plugin Load Errors**: `:Lazy log` - See which plugins failed
3. **Keybinding Conflicts**: `:verbose map <leader>` - See all leader mappings
4. **Lua Errors**: `:messages` - Shows any Lua runtime errors

## 📝 Error Locations

Neovim stores logs in these locations:

- **Message log**: `:messages` (in-memory, current session only)
- **Neovim log**: `~/.local/state/nvim/log`
- **LSP log**: `:LspLog`
- **Lazy.nvim log**: `:Lazy log`

## 🚀 Quick Troubleshooting

```vim
" In Neovim, run these commands:

" 1. Check recent errors
:PercyRecent

" 2. See all messages
:messages

" 3. Check plugin status
:Lazy

" 4. Check LSP status (for IWE)
:LspInfo

" 5. Full health check
:checkhealth
```

## 💡 Pro Tips

1. **Clear old messages**: `:messages clear`
2. **Redirect output**: `:redir > errors.txt | messages | redir END`
3. **Debug specific file**: `nvim -V10debug.log problematic_file.lua`
4. **Check startup time**: `nvim --startuptime startup.log`

## 🔧 If You See Lots of Errors

Most common causes:

1. **Missing external tools** - Run `:checkhealth` to see what's missing
2. **Plugin conflicts** - Check `:Lazy` for failed plugins
3. **LSP not installed** - Verify `cargo install iwe` completed
4. **Old plugin cache** - Try `:Lazy clean` then `:Lazy sync`

______________________________________________________________________

*Error logger loaded in: `lua/percybrain/error-logger.lua`*
