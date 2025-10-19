---
title: LSP Reference Guide
category: reference
tags:
  - lsp
  - language-server
  - markdown-oxide
  - ltex
  - lua-language-server
  - configuration
last_reviewed: '2025-10-19'
---

# LSP Reference Guide

**Document Type**: Reference (information-oriented) **Audience**: Developers customizing PercyBrain, users troubleshooting LSP issues **Purpose**: Comprehensive reference for all Language Server Protocol configurations in PercyBrain

## Table of Contents

- [Overview](#overview)
- [LSP Inventory](#lsp-inventory)
- [Detailed LSP Specifications](#detailed-lsp-specifications)
  - [markdown_oxide (IWE LSP)](#markdown_oxide-iwe-lsp)
  - [ltex](#ltex)
  - [lua_ls](#lua_ls)
  - [Web Development LSPs](#web-development-lsps)
  - [Python LSP](#python-lsp)
- [Common LSP Commands](#common-lsp-commands)
- [Troubleshooting](#troubleshooting)
- [External Resources](#external-resources)

## Overview

### What are Language Server Protocols?

Language Server Protocol (LSP) is a standardized protocol that provides language-specific intelligence to editors. LSPs enable:

- **Code completion**: Intelligent suggestions based on context
- **Go to definition**: Jump to symbol definitions
- **Find references**: Locate all usages of a symbol
- **Diagnostics**: Real-time error and warning detection
- **Code actions**: Refactoring, quick fixes, and transformations
- **Hover documentation**: Inline documentation on hover

### Why PercyBrain Uses LSPs

PercyBrain leverages LSPs to provide:

1. **Intelligent Markdown Navigation**: Via markdown_oxide (IWE LSP) for wiki-style linking and knowledge graphs
2. **Grammar and Spell Checking**: Via ltex for prose writing quality
3. **Lua Development**: Via lua_ls for Neovim configuration development
4. **Web Development Support**: For Hugo static site generation and web publishing

## LSP Inventory

| LSP Name                     | Purpose                                   | Languages                  | Installation                                                        | Status                               |
| ---------------------------- | ----------------------------------------- | -------------------------- | ------------------------------------------------------------------- | ------------------------------------ |
| **markdown_oxide**           | Wiki-linking, backlinks, knowledge graphs | Markdown                   | `cargo install --git https://github.com/Feel-ix-343/markdown-oxide` | **Required** (Core Zettelkasten)     |
| **ltex**                     | Grammar, spell checking, style            | Markdown, Text, LaTeX, Org | Mason auto-install                                                  | **Recommended** (Writing quality)    |
| **lua_ls**                   | Lua language intelligence                 | Lua                        | Mason auto-install                                                  | **Recommended** (Config development) |
| **tsserver**                 | TypeScript/JavaScript support             | TS, JS                     | Mason auto-install                                                  | Optional (Web dev)                   |
| **html**                     | HTML language support                     | HTML                       | Mason auto-install                                                  | Optional (Web dev)                   |
| **cssls**                    | CSS language support                      | CSS                        | Mason auto-install                                                  | Optional (Web dev)                   |
| **tailwindcss**              | Tailwind CSS support                      | CSS                        | Mason auto-install                                                  | Optional (Web dev)                   |
| **pyright**                  | Python language support                   | Python                     | Mason auto-install                                                  | Optional (Scripting)                 |
| **texlab**                   | LaTeX language support                    | LaTeX                      | Mason auto-install                                                  | Optional (Academic writing)          |
| **emmet_ls**                 | HTML/CSS expansion                        | HTML, CSS, JSX             | Mason auto-install                                                  | Optional (Web dev)                   |
| **graphql**                  | GraphQL schema/queries                    | GraphQL                    | Mason auto-install                                                  | Optional (Web dev)                   |
| **grammarly-languageserver** | Grammarly integration                     | Markdown, Text             | External install                                                    | Optional (Advanced grammar)          |

**Configuration Location**: `/home/percy/.config/nvim/lua/plugins/lsp/lspconfig.lua`

## Detailed LSP Specifications

### markdown_oxide (IWE LSP)

**Critical component for PercyBrain's Zettelkasten functionality.**

#### Purpose

markdown_oxide (also known as IWE LSP) provides Obsidian-like features for markdown:

- **Wiki-link autocomplete**: Type `[[` to autocomplete note titles
- **Backlink navigation**: Find all notes linking to current note
- **Go to definition**: Jump to linked notes with `gd`
- **Document symbols**: Table of contents navigation
- **Workspace symbols**: Global note search
- **Code actions**: Extract/inline sections, refactoring

#### Installation

```bash
# Install via cargo (requires Rust toolchain)
cargo install --git https://github.com/Feel-ix-343/markdown-oxide
```

**Verify installation**:

```bash
which markdown-oxide
# Should output: /home/percy/.cargo/bin/markdown-oxide (or similar)
```

#### Configuration

**File**: `lua/plugins/lsp/lspconfig.lua` (lines 188-217)

```lua
-- configure IWE markdown server (PercyBrain Zettelkasten)
-- IWE is installed via cargo: cargo install --git https://github.com/Feel-ix-343/markdown-oxide
lspconfig["markdown_oxide"].setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- IWE-specific keymaps for Zettelkasten workflow
    local iwe_opts = { noremap = true, silent = true, buffer = bufnr }

    -- Navigate links with gd (already mapped in on_attach)
    -- Find backlinks with <leader>zr (references)
    iwe_opts.desc = "Find backlinks (references)"
    keymap.set("n", "<leader>zr", vim.lsp.buf.references, iwe_opts)

    -- Extract/inline sections with code actions
    iwe_opts.desc = "Extract/Inline section"
    keymap.set({ "n", "v" }, "<leader>za", vim.lsp.buf.code_action, iwe_opts)

    -- Document symbols (table of contents)
    iwe_opts.desc = "Document outline (TOC)"
    keymap.set("n", "<leader>zo", vim.lsp.buf.document_symbol, iwe_opts)

    -- Workspace symbols (global search)
    iwe_opts.desc = "Global note search"
    keymap.set("n", "<leader>zf", vim.lsp.buf.workspace_symbol, iwe_opts)
  end,
  filetypes = { "markdown" },
  root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
})
```

#### Key Capabilities

| Feature               | Command                            | Description                        |
| --------------------- | ---------------------------------- | ---------------------------------- |
| **Link autocomplete** | Type `[[`                          | Auto-suggests existing note titles |
| **Go to definition**  | `gd`                               | Jump to linked note                |
| **Find backlinks**    | `<leader>zr`                       | Show all notes linking to current  |
| **Code actions**      | `<leader>za`                       | Extract section, inline reference  |
| **Document outline**  | `<leader>zo`                       | Navigate headings in current note  |
| **Global search**     | `<leader>zf`                       | Search across all notes            |
| **Workspace symbols** | `:Telescope lsp_workspace_symbols` | Symbol-based search                |

#### Workspace Configuration

markdown_oxide detects workspace root via:

1. `.git` directory (Git repository root)
2. `.iwe` directory (explicit workspace marker)

**Recommended**: Use Git repository root for automatic detection.

#### Troubleshooting

**LSP not starting**:

```bash
# 1. Check markdown-oxide is installed
which markdown-oxide

# 2. Verify it runs
markdown-oxide --version

# 3. Check LSP logs
:LspLog

# 4. Restart LSP
:LspRestart
```

**No autocomplete**:

- Ensure you're in a markdown file (`:set ft?` should show `markdown`)
- Check LSP is attached: `:LspInfo` (should show `markdown_oxide`)
- Verify root directory detected: `:LspInfo` shows `Root directory`

**Performance issues** (large vaults):

- markdown_oxide indexes on startup (may take 5-10s for 1000+ notes)
- Check indexing complete: `:LspInfo` shows `ready`
- Consider excluding large directories via workspace configuration

### ltex

**Grammar and spell checking for prose writing.**

#### Purpose

ltex provides:

- **Grammar checking**: Advanced grammar rules via LanguageTool
- **Spell checking**: Multi-language spell checking
- **Style suggestions**: Writing style improvements
- **Picky rules**: Optional detailed style enforcement

#### Installation

Automatically installed via Mason (no manual installation needed).

#### Configuration

**File**: `lua/plugins/lsp/lspconfig.lua` (lines 114-127)

```lua
-- configure LanguageTool grammar checker (ltex-ls)
lspconfig["ltex"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "markdown", "text", "tex", "org" },
  settings = {
    ltex = {
      language = "en-US",
      additionalRules = {
        enablePickyRules = true,
      },
    },
  },
})
```

#### Key Capabilities

| Feature          | Behavior                       | Configuration             |
| ---------------- | ------------------------------ | ------------------------- |
| **Language**     | Default: en-US                 | `settings.ltex.language`  |
| **Picky rules**  | Detailed style checks          | `enablePickyRules = true` |
| **Diagnostics**  | Real-time grammar/spell errors | Shown as LSP diagnostics  |
| **Code actions** | Quick fixes for errors         | `<leader>ca`              |
| **File types**   | Markdown, Text, LaTeX, Org     | `filetypes` array         |

#### Supported Languages

- English: `en-US`, `en-GB`, `en-CA`, `en-AU`
- German: `de-DE`, `de-AT`, `de-CH`
- French: `fr-FR`
- Spanish: `es-ES`
- And 20+ more (see [LanguageTool documentation](https://languagetool.org/))

#### Troubleshooting

**ltex not starting**:

```vim
" Check Mason installation
:Mason
" Search for 'ltex' in the UI
" Should show as installed

" Reinstall if needed
:MasonUninstall ltex
:MasonInstall ltex
```

**High memory usage**:

- ltex uses Java runtime (can consume 500MB-1GB)
- Disable picky rules if performance is critical: `enablePickyRules = false`

**False positives**:

Add words to user dictionary:

```vim
" Use code action on flagged word
<leader>ca
" Select 'Add to dictionary'
```

### lua_ls

**Lua language intelligence for Neovim configuration development.**

#### Purpose

lua_ls provides:

- **Neovim API awareness**: Autocomplete for `vim.*` APIs
- **Diagnostics**: Type checking and error detection
- **Signature help**: Function parameter hints
- **Workspace library**: Recognition of Neovim runtime files

#### Installation

Automatically installed via Mason.

#### Configuration

**File**: `lua/plugins/lsp/lspconfig.lua` (lines 167-186)

```lua
-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize "vim" global
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})
```

#### Key Features

| Feature              | Benefit                        | Example                            |
| -------------------- | ------------------------------ | ---------------------------------- |
| **Neovim globals**   | Recognizes `vim` API           | No warnings on `vim.keymap.set()`  |
| **Runtime library**  | Autocomplete for Neovim APIs   | `vim.api.nvim_<autocomplete>`      |
| **Config awareness** | Autocomplete for local modules | `require('config.<tab>')`          |
| **Type checking**    | Catches type errors            | Warns on incorrect parameter types |

#### Troubleshooting

**`vim` undefined warnings**:

- Ensure `globals = { "vim" }` is set in diagnostics
- Restart LSP: `:LspRestart`

**No autocomplete for Neovim APIs**:

- Verify workspace library includes `$VIMRUNTIME/lua`
- Check `:LspInfo` shows workspace library configured

### Web Development LSPs

PercyBrain includes LSPs for Hugo static site generation and web publishing.

#### html

**HTML language support**

```lua
lspconfig["html"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Features**: Tag completion, validation, formatting

#### tsserver

**TypeScript/JavaScript support**

```lua
lspconfig["tsserver"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Features**: Type checking, imports, refactoring

#### cssls

**CSS language support**

```lua
lspconfig["cssls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Features**: Property completion, color preview, validation

#### tailwindcss

**Tailwind CSS IntelliSense**

```lua
lspconfig["tailwindcss"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Features**: Class autocomplete, variant suggestions, color preview

#### emmet_ls

**HTML/CSS expansion engine**

```lua
lspconfig["emmet_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})
```

**Features**: Abbreviation expansion (`div.class>ul>li*3`)

#### graphql

**GraphQL schema and query support**

```lua
lspconfig["graphql"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
})
```

**Features**: Schema validation, autocomplete, diagnostics

### Python LSP

#### pyright

**Python type checking and IntelliSense**

```lua
lspconfig["pyright"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Features**:

- Type inference
- Import resolution
- Refactoring
- Code navigation

**Use case**: Python scripting for automation (SemBr integration)

## Common LSP Commands

### Navigation

| Command              | Keybinding | Description                     |
| -------------------- | ---------- | ------------------------------- |
| Go to definition     | `gd`       | Jump to symbol definition       |
| Go to declaration    | `gD`       | Jump to symbol declaration      |
| Find references      | `gR`       | Show all references (Telescope) |
| Find implementations | `gi`       | Show implementations            |
| Find type definition | `gt`       | Show type definition            |

### Diagnostics

| Command                 | Keybinding  | Description                        |
| ----------------------- | ----------- | ---------------------------------- |
| Show line diagnostics   | `<leader>d` | Floating window with error details |
| Show buffer diagnostics | `<leader>D` | All diagnostics in current file    |
| Next diagnostic         | `]d`        | Jump to next error/warning         |
| Previous diagnostic     | `[d`        | Jump to previous error/warning     |

### Actions

| Command             | Keybinding   | Description                                |
| ------------------- | ------------ | ------------------------------------------ |
| Code actions        | `<leader>ca` | Show available quick fixes/refactors       |
| Rename symbol       | `<leader>rn` | Smart rename across project                |
| Hover documentation | `K`          | Show documentation for symbol under cursor |
| Restart LSP         | `<leader>rs` | Restart language server                    |

### Management

| Command       | Description                          |
| ------------- | ------------------------------------ |
| `:LspInfo`    | Show attached LSP clients and status |
| `:LspStart`   | Start LSP client                     |
| `:LspStop`    | Stop LSP client                      |
| `:LspRestart` | Restart LSP client                   |
| `:LspLog`     | Open LSP log file (for debugging)    |
| `:Mason`      | Open Mason package manager UI        |

## Troubleshooting

### General LSP Issues

#### LSP Not Attaching

**Symptoms**: No autocomplete, diagnostics, or LSP features

**Diagnosis**:

```vim
" 1. Check if LSP is attached
:LspInfo
" Should show active clients for current buffer

" 2. Check file type is correct
:set ft?
" Should match LSP filetypes (e.g., 'markdown' for markdown_oxide)

" 3. Check Mason installation (for Mason-managed LSPs)
:Mason
```

**Solutions**:

1. **Wrong file type**: Set manually: `:set ft=markdown`
2. **LSP not installed**: Install via Mason (`:Mason` → search → press `i`)
3. **Configuration error**: Check `:LspLog` for errors
4. **Restart LSP**: `:LspRestart`

#### LSP Performance Issues

**Symptoms**: Slow autocomplete, high CPU usage, lag

**Diagnosis**:

```vim
" Check LSP status
:LspInfo
" Look for 'indexing' or high memory usage warnings
```

**Solutions**:

1. **Large workspace**: Exclude directories (configure root_dir patterns)
2. **ltex memory**: Disable picky rules or switch to lighter grammar checker
3. **Multiple LSPs**: Disable unused LSPs for current file type
4. **Restart**: `:LspRestart` to clear cache

#### No Autocomplete

**Symptoms**: Typing doesn't trigger suggestions

**Diagnosis**:

```vim
" 1. Check LSP attached
:LspInfo

" 2. Check completion plugin loaded
:lua print(vim.inspect(require('cmp').get_config()))

" 3. Check cmp-nvim-lsp capabilities
:lua print(vim.inspect(require('cmp_nvim_lsp').default_capabilities()))
```

**Solutions**:

1. **LSP not attached**: See "LSP Not Attaching" above
2. **Completion plugin issue**: Restart Neovim
3. **Trigger manually**: `<C-Space>` to force completion

### markdown_oxide Specific Issues

#### Wiki Links Not Autocompleting

**Diagnosis**:

```vim
" 1. Verify LSP attached
:LspInfo
" Should show 'markdown_oxide' as active client

" 2. Check you're typing in markdown file
:set ft?
" Should output: filetype=markdown

" 3. Verify markdown-oxide binary exists
:!which markdown-oxide
```

**Solutions**:

1. **LSP not attached**: Ensure in `.md` file, restart LSP
2. **Binary not found**: Install via `cargo install --git https://github.com/Feel-ix-343/markdown-oxide`
3. **Root directory not detected**: Create `.git` or `.iwe` in workspace root

#### Backlinks Not Working

**Symptoms**: `<leader>zr` shows no results or errors

**Solutions**:

1. **No backlinks exist**: Verify other notes link to current note with `[[note-name]]`
2. **Index not built**: Wait for markdown_oxide to complete initial indexing
3. **Wrong workspace**: Ensure all notes are in same Git repository or `.iwe` workspace

### ltex Specific Issues

#### Grammar Checker Not Running

**Diagnosis**:

```vim
" Check ltex installed
:Mason
" Search for 'ltex'

" Check LSP attached
:LspInfo
```

**Solutions**:

1. **Not installed**: `:MasonInstall ltex`
2. **Wrong file type**: Ensure file is `.md`, `.txt`, `.tex`, or `.org`
3. **Java not installed**: ltex requires Java runtime (install OpenJDK)

#### Too Many False Positives

**Solutions**:

1. **Disable picky rules**: Set `enablePickyRules = false` in config
2. **Add to dictionary**: Use `<leader>ca` on flagged word → "Add to dictionary"
3. **Disable for section**: Use ltex code actions to disable specific rules

### lua_ls Specific Issues

#### `vim` Global Not Recognized

**Symptoms**: Warning: "Undefined global `vim`"

**Solution**:

Ensure diagnostics.globals includes `"vim"`:

```lua
settings = {
  Lua = {
    diagnostics = {
      globals = { "vim" },
    },
  },
}
```

Restart LSP: `:LspRestart`

#### No Neovim API Autocomplete

**Solution**:

Verify workspace library includes runtime:

```lua
workspace = {
  library = {
    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
    [vim.fn.stdpath("config") .. "/lua"] = true,
  },
}
```

### Cross-References

For additional troubleshooting:

- **Installation issues**: See [PERCYBRAIN_SETUP.md](../../PERCYBRAIN_SETUP.md)
- **General errors**: See [docs/troubleshooting/TROUBLESHOOTING_GUIDE.md](../troubleshooting/TROUBLESHOOTING_GUIDE.md)
- **Zettelkasten workflow**: See [docs/how-to/ZETTELKASTEN_WORKFLOW.md](../how-to/ZETTELKASTEN_WORKFLOW.md)

## External Resources

### Official Documentation

- **markdown_oxide (IWE)**: <https://github.com/Feel-ix-343/markdown-oxide>
- **ltex**: <https://valentjn.github.io/ltex/>
- **lua_ls**: <https://luals.github.io/>
- **LSP Specification**: <https://microsoft.github.io/language-server-protocol/>
- **nvim-lspconfig**: <https://github.com/neovim/nvim-lspconfig>

### PercyBrain Resources

- **Setup Guide**: [PERCYBRAIN_SETUP.md](../../PERCYBRAIN_SETUP.md) - Installation instructions
- **Design Document**: [PERCYBRAIN_DESIGN.md](../../PERCYBRAIN_DESIGN.md) - LSP integration architecture
- **Keybindings**: [KEYBINDINGS_REFERENCE.md](./KEYBINDINGS_REFERENCE.md) - All LSP keybindings
- **How-to Guide**: [how-to/ZETTELKASTEN_WORKFLOW.md](../how-to/ZETTELKASTEN_WORKFLOW.md) - LSP in practice

### Community

- **PercyBrain Issues**: Report bugs and request features
- **Neovim LSP Docs**: `:help lsp` in Neovim
- **Mason Registry**: <https://github.com/williamboman/mason.nvim> - Browse available LSPs
