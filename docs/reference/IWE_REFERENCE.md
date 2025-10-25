# IWE Complete Reference

**Category**: Reference **Audience**: All users **Purpose**: Technical reference for all IWE features, commands, and configuration options

______________________________________________________________________

## Table of Contents

1. [Commands](#commands)
2. [Keybindings](#keybindings)
3. [Configuration](#configuration)
4. [Lua API](#lua-api)
5. [LSP Capabilities](#lsp-capabilities)
6. [Telescope Integration](#telescope-integration)
7. [Preview System](#preview-system)
8. [Health Checks](#health-checks)

______________________________________________________________________

## Commands

### `:IWE`

Main command with subcommands.

#### `:IWE init`

Initialize IWE project in current directory.

**Usage:**

```vim
:IWE init
```

**Effect:**

- Creates `.iwe/` marker directory
- Enables LSP server activation for markdown files in this tree

**Example:**

```vim
:cd ~/Notes
:IWE init
" Creates ~/Notes/.iwe/
```

______________________________________________________________________

#### `:IWE lsp {action}`

Control LSP server lifecycle.

**Actions:**

- `start` - Manually start LSP server
- `stop` - Stop LSP server
- `restart` - Restart LSP server
- `status` - Show LSP server status

**Usage:**

```vim
:IWE lsp status
:IWE lsp restart
```

**Example:**

```vim
" If LSP isn't auto-starting:
:IWE lsp start

" Check if it's running:
:IWE lsp status
```

______________________________________________________________________

#### `:IWE telescope {action}`

Launch Telescope pickers.

**Actions:**

- `find_files` - Find files (equivalent to `gf`)
- `paths` - Workspace symbols - paths (equivalent to `gs`)
- `roots` - Namespace symbols - roots (equivalent to `ga`)
- `grep` - Live grep search (equivalent to `g/`)
- `blockreferences` - LSP references - blockreferences (equivalent to `gb`)
- `backlinks` - LSP references - backlinks (equivalent to `gR`)
- `headers` - Document symbols - headers (equivalent to `go`)
- `setup` - Configure Telescope integration

**Usage:**

```vim
:IWE telescope find_files
:IWE telescope backlinks
```

______________________________________________________________________

#### `:IWE preview {action}`

Generate graph and document previews using IWE CLI.

**Actions:**

- `squash` - Generate single-file markdown export
- `export` - Generate basic DOT graph as SVG
- `export-headers` - Generate DOT graph with headers as SVG
- `export-workspace` - Generate full workspace graph as SVG

**Requirements:**

- `iwe` CLI in PATH
- `neato` (Graphviz) for graph exports

**Output Directory:**

- Default: `~/Zettelkasten/preview/`
- Configurable via `preview.output_dir`

**Usage:**

```vim
:IWE preview squash
" Creates: ~/Zettelkasten/preview/squash.md

:IWE preview export-workspace
" Creates: ~/Zettelkasten/preview/graph.svg
```

______________________________________________________________________

#### `:IWE info`

Show plugin configuration and status.

**Usage:**

```vim
:IWE info
```

**Displays:**

- Current configuration
- LSP server status
- Project root
- Enabled features

______________________________________________________________________

## Keybindings

### Markdown Editing

Available in markdown files when `enable_markdown_mappings = true`.

| Key     | Mode   | <Plug> Mapping                 | Description              |
| ------- | ------ | ------------------------------ | ------------------------ |
| `-`     | Normal | `<Plug>(iwe-checklist-format)` | Format line as checklist |
| `<C-n>` | Normal | `<Plug>(iwe-link-next)`        | Jump to next link        |
| `<C-p>` | Normal | `<Plug>(iwe-link-prev)`        | Jump to previous link    |
| `/d`    | Insert | `<Plug>(iwe-insert-date)`      | Insert current date      |
| `/w`    | Insert | `<Plug>(iwe-insert-week)`      | Insert current week      |

______________________________________________________________________

### Telescope Navigation

Available when `enable_telescope_keybindings = true`.

| Key  | <Plug> Mapping                          | Description                          |
| ---- | --------------------------------------- | ------------------------------------ |
| `gf` | `<Plug>(iwe-telescope-find-files)`      | Find files (fuzzy search)            |
| `gs` | `<Plug>(iwe-telescope-paths)`           | Workspace symbols - paths            |
| `ga` | `<Plug>(iwe-telescope-roots)`           | Namespace symbols - roots            |
| `g/` | `<Plug>(iwe-telescope-grep)`            | Live grep across notes               |
| `gb` | `<Plug>(iwe-telescope-blockreferences)` | LSP blockreferences                  |
| `gR` | `<Plug>(iwe-telescope-backlinks)`       | LSP backlinks (who links here?)      |
| `go` | `<Plug>(iwe-telescope-headers)`         | Document outline (table of contents) |

______________________________________________________________________

### LSP Refactoring

Available when `enable_lsp_keybindings = true`.

| Key         | <Plug> Mapping                         | Description                     |
| ----------- | -------------------------------------- | ------------------------------- |
| `<leader>h` | `<Plug>(iwe-lsp-rewrite-list-section)` | Convert list to section headers |
| `<leader>l` | `<Plug>(iwe-lsp-rewrite-section-list)` | Convert section to list         |

______________________________________________________________________

### Preview Generation

Available when `enable_preview_keybindings = true`.

| Key          | <Plug> Mapping                         | Description                 |
| ------------ | -------------------------------------- | --------------------------- |
| `<leader>ps` | `<Plug>(iwe-preview-squash)`           | Generate squash markdown    |
| `<leader>pe` | `<Plug>(iwe-preview-export)`           | Generate basic graph        |
| `<leader>ph` | `<Plug>(iwe-preview-export-headers)`   | Generate graph with headers |
| `<leader>pw` | `<Plug>(iwe-preview-export-workspace)` | Generate workspace graph    |

______________________________________________________________________

### Standard LSP Keybindings

These are standard Neovim LSP keybindings (active when LSP is running).

| Key          | Function                       | Description                     |
| ------------ | ------------------------------ | ------------------------------- |
| `gD`         | `vim.lsp.buf.declaration()`    | Go to declaration               |
| `gd`         | `vim.lsp.buf.definition()`     | Go to definition / Follow link  |
| `gi`         | `vim.lsp.buf.implementation()` | Go to implementation            |
| `gr`         | `vim.lsp.buf.references()`     | Show references                 |
| `K`          | `vim.lsp.buf.hover()`          | Hover documentation             |
| `<C-k>`      | `vim.lsp.buf.signature_help()` | Signature help (insert mode)    |
| `[d`         | `vim.diagnostic.goto_prev()`   | Previous diagnostic             |
| `]d`         | `vim.diagnostic.goto_next()`   | Next diagnostic                 |
| `<leader>ca` | `vim.lsp.buf.code_action()`    | Code actions (extract/inline)   |
| `<leader>rn` | `vim.lsp.buf.rename()`         | Rename (updates all references) |
| `<leader>f`  | `vim.lsp.buf.format()`         | Format document                 |

______________________________________________________________________

## Configuration

### Setup Function

```lua
require("iwe").setup({
  lsp = {...},
  mappings = {...},
  telescope = {...},
  preview = {...}
})
```

### LSP Options

```lua
lsp = {
  cmd = { "iwes" },                   -- LSP server command
  name = "iwes",                      -- LSP server name
  debounce_text_changes = 500,        -- Debounce time (ms)
  auto_format_on_save = true,         -- Auto-format on save
  enable_inlay_hints = true,          -- Show inlay hints
}
```

#### `lsp.cmd` (table)

Command to start LSP server.

**Type:** `string[]` **Default:** `{ "iwes" }`

**Example:**

```lua
cmd = { "/usr/local/bin/iwes", "--log-level", "debug" }
```

#### `lsp.name` (string)

LSP server name for identification.

**Type:** `string` **Default:** `"iwes"`

#### `lsp.debounce_text_changes` (number)

Delay before sending text changes to LSP (milliseconds).

**Type:** `number` **Default:** `500`

**Higher values:**

- Reduce LSP load
- Slower completion

**Lower values:**

- Faster completion
- More LSP requests

#### `lsp.auto_format_on_save` (boolean)

Automatically format buffer on save.

**Type:** `boolean` **Default:** `true`

**What it formats:**

- Header normalization
- List formatting
- Link title updates
- Whitespace cleanup

#### `lsp.enable_inlay_hints` (boolean)

Show inline type hints from LSP.

**Type:** `boolean` **Default:** `true`

**Shows:**

- Parent document references
- Link usage counts

______________________________________________________________________

### Mappings Options

```lua
mappings = {
  enable_markdown_mappings = true,       -- Core markdown editing keys
  enable_telescope_keybindings = true,   -- gf, gb, go, etc.
  enable_lsp_keybindings = true,         -- <leader>h, <leader>l
  enable_preview_keybindings = true,     -- <leader>ps, <leader>pe, etc.
  leader = "<leader>",                   -- Leader key
  localleader = "<localleader>",         -- Local leader key
}
```

#### `enable_markdown_mappings` (boolean)

Enable markdown editing keybindings.

**Type:** `boolean` **Default:** `true`

**Keybindings:**

- `-` = Format as checklist
- `<C-n>` = Next link
- `<C-p>` = Previous link
- `/d` = Insert date (insert mode)
- `/w` = Insert week (insert mode)

#### `enable_telescope_keybindings` (boolean)

Enable Telescope picker keybindings.

**Type:** `boolean` **Default:** `true`

**Keybindings:**

- `gf`, `gs`, `ga`, `g/`, `gb`, `gR`, `go`

#### `enable_lsp_keybindings` (boolean)

Enable IWE-specific LSP keybindings.

**Type:** `boolean` **Default:** `true`

**Keybindings:**

- `<leader>h` = Rewrite list section
- `<leader>l` = Rewrite section list

#### `enable_preview_keybindings` (boolean)

Enable preview generation keybindings.

**Type:** `boolean` **Default:** `true`

**Keybindings:**

- `<leader>ps`, `<leader>pe`, `<leader>ph`, `<leader>pw`

#### `leader` (string)

Leader key for mappings.

**Type:** `string` **Default:** `"<leader>"`

#### `localleader` (string)

Local leader key for buffer-local mappings.

**Type:** `string` **Default:** `"<localleader>"`

______________________________________________________________________

### Telescope Options

```lua
telescope = {
  enabled = true,                        -- Enable Telescope integration
  setup_config = true,                   -- Auto-configure Telescope
  load_extensions = { "ui-select", "emoji" }  -- Extensions to load
}
```

#### `enabled` (boolean)

Enable Telescope integration.

**Type:** `boolean` **Default:** `true`

**Required:** `nvim-telescope/telescope.nvim`

#### `setup_config` (boolean)

Automatically configure Telescope with IWE defaults.

**Type:** `boolean` **Default:** `true`

#### `load_extensions` (table)

Telescope extensions to auto-load.

**Type:** `string[]` **Default:** `{ "ui-select", "emoji" }`

**Optional Extensions:**

- `ui-select` - Enhanced UI picker
- `emoji` - Emoji picker

______________________________________________________________________

### Preview Options

```lua
preview = {
  output_dir = "~/Zettelkasten/preview",  -- Where to save previews
  temp_dir = "/tmp",                      -- Temp directory for processing
  auto_open = false,                      -- Auto-open previews after generation
}
```

#### `output_dir` (string)

Directory for preview output.

**Type:** `string` **Default:** `"~/Zettelkasten/preview"`

**Created files:**

- `squash.md` - Squashed markdown export
- `graph.svg` - Graph visualizations

#### `temp_dir` (string)

Temporary directory for preview processing.

**Type:** `string` **Default:** `"/tmp"`

#### `auto_open` (boolean)

Automatically open preview files after generation.

**Type:** `boolean` **Default:** `false`

______________________________________________________________________

## Lua API

### Core Functions

#### `require('iwe').setup(opts)`

Configure IWE plugin.

**Parameters:**

- `opts` (table): Configuration options

**Returns:** `nil`

**Example:**

```lua
require('iwe').setup({
  lsp = {
    debounce_text_changes = 300,
  },
  mappings = {
    enable_telescope_keybindings = true,
  }
})
```

______________________________________________________________________

#### `require('iwe').get_project_root()`

Get current IWE project root (containing `.iwe` marker).

**Parameters:** None

**Returns:** `string|nil` - Project root path or nil

**Example:**

```lua
local root = require('iwe').get_project_root()
print("Project root:", root)
-- Output: "Project root: /home/user/Notes"
```

______________________________________________________________________

#### `require('iwe').is_in_project()`

Check if current buffer is in an IWE project.

**Parameters:** None

**Returns:** `boolean`

**Example:**

```lua
if require('iwe').is_in_project() then
  print("Inside IWE project")
end
```

______________________________________________________________________

#### `require('iwe').start_lsp(bufnr)`

Manually start LSP server for buffer.

**Parameters:**

- `bufnr` (number, optional): Buffer number (default: current buffer)

**Returns:** `nil`

**Example:**

```lua
-- Start LSP for current buffer
require('iwe').start_lsp()

-- Start LSP for specific buffer
require('iwe').start_lsp(5)
```

______________________________________________________________________

#### `require('iwe').lsp_available()`

Check if `iwes` LSP server is available in PATH.

**Parameters:** None

**Returns:** `boolean`

**Example:**

```lua
if require('iwe').lsp_available() then
  print("iwes is installed")
else
  print("Please install iwes")
end
```

______________________________________________________________________

#### `require('iwe').get_config()`

Get current plugin configuration.

**Parameters:** None

**Returns:** `table` - Current configuration

**Example:**

```lua
local config = require('iwe').get_config()
print(vim.inspect(config.lsp))
```

______________________________________________________________________

### Telescope Functions

#### `require('iwe.telescope').pickers.find_files()`

Launch find files picker (equivalent to `gf`).

**Parameters:** None

**Returns:** `nil`

**Example:**

```lua
require('iwe.telescope').pickers.find_files()
```

______________________________________________________________________

#### `require('iwe.telescope').pickers.grep()`

Launch live grep picker (equivalent to `g/`).

**Parameters:** None

**Returns:** `nil`

**Example:**

```lua
require('iwe.telescope').pickers.grep()
```

______________________________________________________________________

#### `require('iwe.telescope').pickers.backlinks()`

Launch backlinks picker (equivalent to `gb`).

**Parameters:** None

**Returns:** `nil`

**Example:**

```lua
require('iwe.telescope').pickers.backlinks()
```

______________________________________________________________________

### Preview Functions

#### `require('iwe.preview').generate_squash_preview()`

Generate squashed markdown preview.

**Parameters:** None

**Returns:** `nil`

**Requires:** `iwe` CLI in PATH

**Output:** `~/Zettelkasten/preview/squash.md`

**Example:**

```lua
require('iwe.preview').generate_squash_preview()
```

______________________________________________________________________

#### `require('iwe.preview').generate_export_preview()`

Generate basic DOT graph as SVG.

**Parameters:** None

**Returns:** `nil`

**Requires:**

- `iwe` CLI in PATH
- `neato` (Graphviz) in PATH

**Output:** `~/Zettelkasten/preview/graph.svg`

**Example:**

```lua
require('iwe.preview').generate_export_preview()
```

______________________________________________________________________

## LSP Capabilities

IWE provides these LSP features:

### Document Formatting

**LSP Method:** `textDocument/formatting`

**Keybinding:** `<leader>f`

**Formats:**

- Headers (normalize levels)
- Lists (consistent formatting)
- Links (update titles)
- Whitespace (remove trailing)

______________________________________________________________________

### Go To Definition

**LSP Method:** `textDocument/definition`

**Keybinding:** `gd`

**Behavior:**

- Follow `[[wiki-links]]` to target file
- Create file with frontmatter if missing
- Support for relative paths

______________________________________________________________________

### Find References

**LSP Method:** `textDocument/references`

**Keybinding:** `gr`

**Shows:**

- All files linking to current file
- Line numbers and preview

______________________________________________________________________

### Code Actions

**LSP Method:** `textDocument/codeAction`

**Keybinding:** `<leader>ca`

**Available Actions:**

- Extract section to new file
- Inline reference
- Rewrite list section
- Rewrite section list
- AI text generation (if configured)

______________________________________________________________________

### Rename Symbol

**LSP Method:** `textDocument/rename`

**Keybinding:** `<leader>rn`

**Behavior:**

- Rename current file
- Update ALL references across project
- Safe refactoring

______________________________________________________________________

### Document Symbols

**LSP Method:** `textDocument/documentSymbol`

**Keybinding:** `go` (Telescope)

**Shows:**

- All headers in current document
- Jump to section

______________________________________________________________________

### Workspace Symbols

**LSP Method:** `workspace/symbol`

**Keybinding:** `gs` (Telescope)

**Shows:**

- All files in project
- Fuzzy search

______________________________________________________________________

### Completion

**LSP Method:** `textDocument/completion`

**Trigger:** Type `[[`

**Provides:**

- Link completion
- File name suggestions
- Real-time fuzzy matching

______________________________________________________________________

### Inlay Hints

**LSP Method:** `textDocument/inlayHint`

**Enabled by:** `lsp.enable_inlay_hints = true`

**Shows:**

- Parent document references
- Link usage counts

______________________________________________________________________

## Telescope Integration

IWE extends Telescope with custom pickers.

### File Picker (`gf`)

Fuzzy search all files in project.

**Respects:**

- `.gitignore`
- `.iwe` project boundaries

______________________________________________________________________

### Grep Picker (`g/`)

Search content across all notes.

**Features:**

- Live preview
- Multi-line context
- Regex support

______________________________________________________________________

### Backlinks Picker (`gb`)

Show all files linking to current file.

**Uses:** LSP `textDocument/references`

______________________________________________________________________

### Outline Picker (`go`)

Navigate current document structure.

**Uses:** LSP `textDocument/documentSymbol`

______________________________________________________________________

## Preview System

Generate graph visualizations and exports.

### Requirements

- `iwe` CLI (`cargo install --git https://github.com/iwe-org/iwe`)
- `neato` (Graphviz) for graphs (`apt install graphviz`)

### Preview Types

#### Squash (`squash.md`)

Single-file markdown export of entire knowledge base.

**Use case:** Publishing to static site generators

#### Basic Graph (`graph.svg`)

Simple node-edge graph of all notes and links.

**Use case:** Visualize knowledge structure

#### Graph with Headers (`graph-headers.svg`)

Graph showing document sections as nodes.

**Use case:** Detailed structure analysis

#### Workspace Graph (`workspace.svg`)

Full workspace visualization.

**Use case:** Overview of all projects

______________________________________________________________________

## Health Checks

Run diagnostics with `:checkhealth iwe`.

### Checks Performed

1. **IWE LSP Server**

   - ✅ iwes command found in PATH
   - ✅ iwes is executable

2. **Project Structure**

   - ⚠️ .iwe marker directory exists

3. **Configuration**

   - ✅ LSP settings valid
   - ✅ Mapping configuration valid

4. **Dependencies**

   - ✅ telescope.nvim detected
   - ℹ️ Optional extensions (ui-select, emoji)
   - ✅ render-markdown detected (optional)
   - ✅ gitsigns detected (optional)

5. **Preview System**

   - ✅ iwe CLI found
   - ✅ neato (Graphviz) found
   - ✅ Output directory writable

6. **LSP Status**

   - ✅ LSP server running
   - ✅ Active clients

______________________________________________________________________

## Global Variables

### `g:disable_iwe`

Disable IWE plugin entirely.

**Type:** `boolean` **Default:** `false`

**Example:**

```vim
let g:disable_iwe = 1
```

______________________________________________________________________

### `g:loaded_iwe`

Indicates plugin has been loaded (set by plugin).

**Type:** `boolean` **Default:** `false` (set to `true` after load)

______________________________________________________________________

## See Also

- [IWE Getting Started Tutorial](../tutorials/IWE_GETTING_STARTED.md)
- [IWE Daily Workflow](../how-to/IWE_DAILY_WORKFLOW.md)
- [IWE Architecture](../explanation/IWE_ARCHITECTURE.md)
- [Official IWE Documentation](https://github.com/iwe-org/iwe)
