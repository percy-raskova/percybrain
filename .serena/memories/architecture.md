# OVIWrite Architecture

## File Structure

```
~/.config/nvim/
├── init.lua                        # Entry point: NeoVide config + requires('config')
├── lua/
│   ├── config/                     # Core configuration
│   │   ├── init.lua               # Bootstrap: lazy.nvim setup + loads globals/keymaps/options
│   │   ├── globals.lua            # Global variables and settings
│   │   ├── keymaps.lua            # Leader key mappings (<space> is <leader>)
│   │   └── options.lua            # Vim options (spell, search, appearance, behavior)
│   ├── plugins/                    # Plugin specifications (auto-loaded by lazy.nvim)
│   │   ├── init.lua               # Minimal plugin loader (neoconf, neodev)
│   │   ├── [plugin-name].lua      # Individual plugin configs (lazy-loaded)
│   │   └── lsp/                   # LSP configurations (mason, lspconfig, none-ls)
│   └── utils/                      # Utility modules (NOT auto-loaded)
│       ├── lsp.lua
│       ├── writer_templates.lua
│       └── keymapper.lua
├── scripts/                        # Validation and development scripts
├── spell/                          # Spell check dictionaries
├── assets/                         # Screenshots and images
└── lazy-lock.json                  # Plugin version lockfile
```

## Loading Sequence

1. `init.lua` → Sets NeoVide GUI config
2. `require('config')` → Calls `lua/config/init.lua`
3. `lua/config/init.lua`:
   - Bootstraps lazy.nvim (auto-installs if missing)
   - Loads `config.globals`, `config.keymaps`, `config.options`
   - Calls `require("lazy").setup('plugins', opts)`
4. lazy.nvim auto-loads all `lua/plugins/*.lua` files
5. Plugins lazy-load based on triggers (event, cmd, keys, ft)

## Plugin Architecture

- **One plugin per file**: `lua/plugins/plugin-name.lua`
- **lazy.nvim spec format**: Each file returns `{ "author/repo", ... }` table
- **Lazy loading by default**: Plugins load on trigger (VeryLazy, BufReadPre, cmd, keys, ft)
- **Auto-discovery**: lazy.nvim scans `lua/plugins/` and loads all `.lua` files

## Core Configuration Files

### lua/config/options.lua

Writer-focused defaults:

- `opt.spell = true` - Spell checking ON by default
- `opt.spelllang = 'en'` - English spell check
- `opt.wrap = true` - Line wrapping for prose
- `opt.number = true` - Line numbers
- `opt.relativenumber = true` - Relative line numbers
- `opt.scrolloff = 10` - Keep 10 lines visible above/below cursor
- `opt.clipboard:append("unnamedplus")` - System clipboard integration

### lua/config/keymaps.lua

Leader key: `<space>` (spacebar) Core shortcuts: File tree, save, quit, splits, terminal, LazyGit, writing modes

### lua/config/globals.lua

Global variables and theme settings

## Plugin Categories

- **Long-form writing**: vimtex, vim-pencil, fountain, nvim-orgmode
- **Spell/Grammar**: LanguageTool, vim-grammarous, vale
- **Note-taking**: vim-wiki, vim-zettel, obsidianNvim
- **Distraction-free**: zen-mode, goyo, limelight, twilight, centerpad, typewriter
- **Utilities**: telescope, fzf-lua, nvim-tree, lazygit, translate, img-clip
- **Color schemes**: catppuccin, gruvbox, nightfox

## NeoVide Support

GUI-specific settings in `init.lua`:

- Custom font: Hack Nerd Font Mono 18pt
- Transparency and blur effects
- macOS-style keyboard shortcuts (Cmd+S, Cmd+C, Cmd+V)
