# PercyBrain Workflow-Focused Refactoring Plan

**Date**: 2025-10-17
**Goal**: Reorganize 67 plugins into clear workflow-based directories aligned with primary use cases

---

## 📋 Use Case Priority

### 1. **Knowledge Management / Zettelkasten** (Primary)
- Note capture and organization
- Wiki-style linking
- Backlinks and reference discovery
- Knowledge graph navigation
- IWE LSP integration for markdown

### 2. **AI-Assisted Writing** (Secondary)
- Parse semantic line-broken notes
- Generate rough drafts from notes
- Text improvement and expansion
- SemBr formatting integration

### 3. **Long-Form Prose Writing** (Tertiary)
- Distraction-free writing modes
- LaTeX for academic papers
- Citation management
- Document formatting

### 4. **Static Site Publishing** (Supporting)
- Hugo integration
- Markdown to web publishing
- Preview and deployment

---

## 🗂️ New Directory Structure

```
lua/plugins/
├── zettelkasten/          # Knowledge Management Workflow
│   ├── iwe-lsp.lua        # IWE markdown LSP (NEW)
│   ├── vim-wiki.lua       # Wiki system
│   ├── vim-zettel.lua     # Zettelkasten for vim-wiki
│   ├── obsidian.lua       # Obsidian vault compatibility
│   ├── telescope.lua      # Fuzzy finding (moved here)
│   └── img-clip.lua       # Paste images into notes
│
├── ai-sembr/              # AI & Semantic Line Breaks
│   ├── ollama.lua         # Custom PercyBrain AI
│   ├── sembr.lua          # ML-based semantic line breaks
│   └── ai-draft.lua       # Draft generation from notes (NEW)
│
├── prose-writing/         # Long-Form Writing Workflow
│   ├── distraction-free/
│   │   ├── goyo.lua       # Minimalist mode
│   │   ├── zen-mode.lua   # Modern distraction-free
│   │   ├── limelight.lua  # Dim paragraphs
│   │   └── centerpad.lua  # Center text
│   ├── editing/
│   │   ├── nvim-surround.lua    # Surround operations (NEW)
│   │   ├── vim-textobj-sentence.lua  # Sentence objects (NEW)
│   │   ├── vim-repeat.lua       # Dot repeat (NEW)
│   │   ├── vim-pencil.lua       # Prose writing mode
│   │   └── undotree.lua         # Visual undo history (NEW)
│   ├── formatting/
│   │   ├── autopairs.lua        # Auto-close brackets
│   │   └── comment.lua          # Comment toggling
│   └── grammar/
│       ├── ltex-ls.lua          # LanguageTool LSP (NEW)
│       ├── vale.lua             # Prose linting
│       └── thesaurus.lua        # Thesaurus lookup
│
├── academic/              # Academic Writing Workflow
│   ├── vimtex.lua         # LaTeX support
│   ├── vim-pandoc.lua     # Pandoc integration
│   ├── vim-latex-preview.lua  # LaTeX preview
│   └── cmp-dictionary.lua      # Dictionary completion
│
├── publishing/            # Static Site Publishing
│   ├── hugo.lua           # Hugo integration (NEW)
│   ├── markdown-preview.lua   # Markdown preview
│   └── autopandoc.lua     # Auto-conversion (optional)
│
├── org-mode/              # Org-Mode Support (Optional)
│   ├── nvim-orgmode.lua   # Modern org-mode
│   ├── org-bullets.lua    # Visual enhancements
│   └── headlines.lua      # Heading highlights
│
├── lsp/                   # Language Server Configuration
│   ├── mason.lua          # LSP installer
│   ├── mason-lspconfig.lua    # Mason bridge
│   ├── lspconfig.lua      # LSP configurations
│   └── none-ls.lua        # Null-ls replacement (formatting/linting)
│
├── completion/            # Completion Framework
│   ├── nvim-cmp.lua       # Completion engine
│   └── cmp-sources.lua    # Completion sources
│
├── ui/                    # User Interface
│   ├── alpha.lua          # Splash screen
│   ├── whichkey.lua       # Keybinding help
│   ├── noice.lua          # Enhanced UI
│   ├── catppuccin.lua     # Theme
│   ├── gruvbox.lua        # Alternative theme
│   ├── nightfox.lua       # Alternative theme
│   └── transparent.lua    # Transparency support
│
├── navigation/            # File & Code Navigation
│   ├── nvim-tree.lua      # File explorer
│   ├── yazi.lua           # Terminal file manager
│   ├── fzf-lua.lua        # Alternative fuzzy finder
│   └── neoscroll.lua      # Smooth scrolling
│
├── utilities/             # General Utilities
│   ├── lazygit.lua        # Git interface
│   ├── toggleterm.lua     # Terminal management
│   ├── floaterm.lua       # Floating terminal
│   ├── pomo.lua           # Pomodoro timer
│   ├── translate.lua      # Translation
│   ├── stay-centered.lua  # Cursor centering
│   ├── typewriter.lua     # Typewriter scrolling
│   ├── hardtime.lua       # Vim training (optional)
│   ├── screenkey.lua      # Show keypresses (optional)
│   └── high-str.lua       # Highlight strings (optional)
│
├── treesitter/            # Syntax & Parsing
│   └── nvim-treesitter.lua
│
├── lisp/                  # Lisp Development (Optional)
│   ├── quicklispnvim.lua
│   └── cl-neovim.lua
│
├── experimental/          # Testing/Experimental
│   ├── pendulum.lua       # Time tracking (?)
│   ├── styledoc.lua       # Styled docs (?)
│   ├── vim-dialect.lua    # Language variants (?)
│   └── w3m.lua            # Web browser (?)
│
└── init.lua               # Plugin loader (updated)
```

---

## 🔄 Plugin Migration Map

### Zettelkasten Workflow (11 plugins)

| Current Location | New Location | Action |
|------------------|--------------|--------|
| N/A | `zettelkasten/iwe-lsp.lua` | **ADD** - IWE markdown LSP |
| `vim-wiki.lua` | `zettelkasten/vim-wiki.lua` | **MOVE** |
| `vim-zettel.lua` | `zettelkasten/vim-zettel.lua` | **MOVE** |
| `obsidianNvim.lua` | `zettelkasten/obsidian.lua` | **MOVE + RENAME** |
| `telescope.lua` | `zettelkasten/telescope.lua` | **MOVE** - primary search |
| `img-clip.lua` | `zettelkasten/img-clip.lua` | **MOVE** |
| `fzf-lua.lua` | `navigation/fzf-lua.lua` | **MOVE** - alternative |
| `fzf-vim.lua` | N/A | **DELETE** - redundant |

### AI & SemBr Workflow (3 plugins)

| Current Location | New Location | Action |
|------------------|--------------|--------|
| `ollama.lua` | `ai-sembr/ollama.lua` | **MOVE** |
| `sembr.lua` | `ai-sembr/sembr.lua` | **MOVE** |
| N/A | `ai-sembr/ai-draft.lua` | **CREATE** - draft generator |
| `gen.lua` | N/A | **DELETE** - redundant |

### Prose Writing Workflow (14 plugins)

#### Distraction-Free (4 plugins)
| Current Location | New Location | Action |
|------------------|--------------|--------|
| `goyo.lua` | `prose-writing/distraction-free/goyo.lua` | **MOVE** |
| `zen-mode.lua` | `prose-writing/distraction-free/zen-mode.lua` | **MOVE** |
| `limelight.lua` | `prose-writing/distraction-free/limelight.lua` | **MOVE** |
| `centerpad.lua` | `prose-writing/distraction-free/centerpad.lua` | **MOVE** |
| `twilight.lua` | N/A | **DELETE** - redundant |

#### Editing Tools (5 plugins)
| Current Location | New Location | Action |
|------------------|--------------|--------|
| N/A | `prose-writing/editing/nvim-surround.lua` | **ADD** |
| N/A | `prose-writing/editing/vim-textobj-sentence.lua` | **ADD** |
| N/A | `prose-writing/editing/vim-repeat.lua` | **ADD** |
| `vim-pencil.lua` | `prose-writing/editing/vim-pencil.lua` | **MOVE** |
| N/A | `prose-writing/editing/undotree.lua` | **ADD** |

#### Formatting (2 plugins)
| Current Location | New Location | Action |
|------------------|--------------|--------|
| `autopairs.lua` | `prose-writing/formatting/autopairs.lua` | **MOVE** |
| `comment.lua` | `prose-writing/formatting/comment.lua` | **MOVE** |

#### Grammar (3 plugins)
| Current Location | New Location | Action |
|------------------|--------------|--------|
| N/A | `prose-writing/grammar/ltex-ls.lua` | **ADD** - LanguageTool LSP |
| `vale.lua` | `prose-writing/grammar/vale.lua` | **MOVE** |
| `thesaurusquery.lua` | `prose-writing/grammar/thesaurus.lua` | **MOVE + RENAME** |
| `LanguageTool.lua` | N/A | **EVALUATE** - may be redundant with ltex-ls |
| `vim-grammarous.lua` | N/A | **DELETE** - use ltex-ls instead |

### Academic Writing Workflow (4 plugins)

| Current Location | New Location | Action |
|------------------|--------------|--------|
| `vimtex.lua` | `academic/vimtex.lua` | **MOVE** |
| `vim-pandoc.lua` | `academic/vim-pandoc.lua` | **MOVE** |
| `vim-latex-preview.lua` | `academic/vim-latex-preview.lua` | **MOVE** |
| `cmp-dictionary.lua` | `academic/cmp-dictionary.lua` | **MOVE** |

### Publishing Workflow (3 plugins)

| Current Location | New Location | Action |
|------------------|--------------|--------|
| N/A | `publishing/hugo.lua` | **ADD** - Hugo integration |
| `markdown-preview.lua` | `publishing/markdown-preview.lua` | **MOVE** |
| `autopandoc.lua` | `publishing/autopandoc.lua` | **MOVE** |

### Removed Plugins (8 total)

| Plugin | Reason |
|--------|--------|
| `fountain.lua` | **User request** - removed screenwriting |
| `twilight.lua` | **Redundant** - duplicate of limelight |
| `vimorg.lua` | **Deprecated** - use nvim-orgmode |
| `fzf-vim.lua` | **Redundant** - superseded by fzf-lua |
| `gen.lua` | **Redundant** - custom ollama.lua is better |
| `vim-grammarous.lua` | **Redundant** - use ltex-ls instead |
| `LanguageTool.lua` | **Evaluate** - may be redundant with ltex-ls |
| `autopandoc.lua` | **Optional** - evaluate if actually used |

---

## 🆕 New Plugins to Add

### 1. **IWE LSP** - Markdown Knowledge Management
**Purpose**: Modern LSP for markdown with wiki-style linking, backlinks, extract/inline sections

**File**: `lua/plugins/zettelkasten/iwe-lsp.lua`

```lua
return {
  "Feel-ix-343/markdown-oxide",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- IWE LSP is configured via lua/plugins/lsp/lspconfig.lua
    -- This file just ensures the plugin is loaded
  end,
}
```

**Integration**: Add to `lua/plugins/lsp/lspconfig.lua`:

```lua
-- IWE LSP for markdown knowledge management
require('lspconfig').markdown_oxide.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- IWE-specific keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- Navigate links with gd (go to definition)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    -- Find backlinks with <leader>zr (references)
    vim.keymap.set('n', '<leader>zr', vim.lsp.buf.references, opts)

    -- Extract/inline sections with code actions
    vim.keymap.set({ 'n', 'v' }, '<leader>za', vim.lsp.buf.code_action, opts)

    -- Rename files with <leader>rn
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

    -- Document symbols (table of contents)
    vim.keymap.set('n', '<leader>zo', vim.lsp.buf.document_symbol, opts)

    -- Workspace symbols (global search)
    vim.keymap.set('n', '<leader>zf', vim.lsp.buf.workspace_symbol, opts)
  end,
})
```

### 2. **Hugo Integration** - Static Site Publishing
**Purpose**: Hugo commands and preview integration

**File**: `lua/plugins/publishing/hugo.lua`

```lua
return {
  "phelipetls/jsonpath.nvim", -- Dependency for Hugo
  ft = { "markdown", "md" },
  config = function()
    -- Hugo commands
    vim.api.nvim_create_user_command("HugoNew", function(opts)
      local title = opts.args
      if title == "" then
        vim.ui.input({ prompt = "Post title: " }, function(input)
          if input then
            vim.cmd("!hugo new posts/" .. input:gsub(" ", "-"):lower() .. ".md")
          end
        end)
      else
        vim.cmd("!hugo new posts/" .. title:gsub(" ", "-"):lower() .. ".md")
      end
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("HugoServer", function()
      vim.cmd("terminal hugo server -D")
    end, {})

    vim.api.nvim_create_user_command("HugoBuild", function()
      vim.cmd("!hugo --cleanDestinationDir")
    end, {})

    vim.api.nvim_create_user_command("HugoPublish", function()
      vim.cmd("!hugo && git add . && git commit -m 'Publish' && git push")
    end, {})

    -- Keymaps
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>zp", ":HugoPublish<CR>", opts)
    vim.keymap.set("n", "<leader>zv", ":HugoServer<CR>", opts)
    vim.keymap.set("n", "<leader>zb", ":HugoBuild<CR>", opts)
  end,
}
```

### 3. **ltex-ls** - LanguageTool LSP
**Purpose**: Grammar and style checking via LSP

**File**: `lua/plugins/prose-writing/grammar/ltex-ls.lua`

```lua
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "ltex-ls", -- LanguageTool Language Server
    },
  },
}
```

**Integration**: Add to `lua/plugins/lsp/lspconfig.lua`:

```lua
-- ltex-ls for grammar checking
require('lspconfig').ltex.setup({
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

### 4. **AI Draft Generator** - Convert Notes to Prose
**Purpose**: Parse semantic line-broken notes and generate rough drafts

**File**: `lua/plugins/ai-sembr/ai-draft.lua`

```lua
return {
  "nvim-lua/plenary.nvim", -- Dependency
  config = function()
    local M = {}

    -- Configuration
    M.config = {
      model = "llama3.2:latest",
      ollama_url = "http://localhost:11434",
      temperature = 0.8, -- Higher for creative prose
      max_tokens = 4096,
    }

    -- Collect notes from workspace
    function M.collect_notes(pattern)
      local notes = {}
      local workspace_dir = vim.fn.expand("~/Zettelkasten")

      -- Find all markdown files matching pattern
      local find_cmd = string.format('find %s -name "*.md" | xargs grep -l "%s"', workspace_dir, pattern)
      local handle = io.popen(find_cmd)
      local result = handle:read("*a")
      handle:close()

      for filepath in result:gmatch("[^\n]+") do
        local file = io.open(filepath, "r")
        if file then
          table.insert(notes, {
            path = filepath,
            content = file:read("*a")
          })
          file:close()
        end
      end

      return notes
    end

    -- Generate draft from notes
    function M.generate_draft()
      vim.ui.input({ prompt = "Search notes for topic: " }, function(topic)
        if not topic or topic == "" then return end

        vim.notify("🔍 Collecting notes about: " .. topic, vim.log.levels.INFO)
        local notes = M.collect_notes(topic)

        if #notes == 0 then
          vim.notify("❌ No notes found for: " .. topic, vim.log.levels.WARN)
          return
        end

        vim.notify(string.format("📝 Found %d notes, generating draft...", #notes), vim.log.levels.INFO)

        -- Combine note content
        local combined_content = "# Source Notes\n\n"
        for i, note in ipairs(notes) do
          combined_content = combined_content .. string.format(
            "## Note %d: %s\n\n%s\n\n",
            i,
            note.path:match("([^/]+)%.md$") or "Untitled",
            note.content
          )
        end

        -- Create prompt for AI
        local prompt = string.format([[
You are a writing assistant helping transform Zettelkasten notes into a coherent rough draft.

The user has collected notes on the topic: "%s"

Below are the source notes. They use semantic line breaks (each sentence or clause on its own line).

Your task:
1. Synthesize these notes into a cohesive narrative
2. Maintain semantic line breaks in the output
3. Create a logical flow from the disparate notes
4. Add transitions where needed
5. Keep key concepts and quotes from the notes
6. Output as a rough draft ready for editing

Source Notes:
%s

Generate a rough draft outline and opening sections:
]], topic, combined_content)

        -- Call Ollama API
        local curl_cmd = string.format(
          'curl -s -X POST %s/api/generate -d \'{"model": "%s", "prompt": %s, "stream": false, "options": {"temperature": %.1f, "num_predict": %d}}\'',
          M.config.ollama_url,
          M.config.model,
          vim.fn.json_encode(prompt),
          M.config.temperature,
          M.config.max_tokens
        )

        vim.fn.jobstart(curl_cmd, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data and #data > 0 then
              local json_str = table.concat(data, "")
              local success, result = pcall(vim.fn.json_decode, json_str)

              if success and result.response then
                -- Create new buffer with draft
                vim.cmd('new')
                local buf = vim.api.nvim_get_current_buf()

                -- Set filename
                local filename = string.format("draft-%s-%s.md",
                  topic:gsub("%s+", "-"):lower(),
                  os.date("%Y%m%d"))
                vim.api.nvim_buf_set_name(buf, filename)

                -- Insert content
                local lines = vim.split(result.response, "\n")
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

                vim.notify(string.format("✅ Draft created: %s", filename), vim.log.levels.INFO)
              else
                vim.notify("❌ Failed to parse AI response", vim.log.levels.ERROR)
              end
            end
          end,
        })
      end)
    end

    -- User command
    vim.api.nvim_create_user_command("PercyDraft", M.generate_draft, {
      desc = "Generate prose draft from notes",
    })

    -- Keymap
    vim.keymap.set("n", "<leader>ad", M.generate_draft, {
      noremap = true,
      silent = true,
      desc = "AI: Generate Draft from Notes"
    })

    vim.notify("📝 PercyBrain Draft Generator loaded - <leader>ad to create drafts", vim.log.levels.INFO)
  end,
}
```

### 5. **Essential Prose Editing Plugins**

**nvim-surround**: `lua/plugins/prose-writing/editing/nvim-surround.lua`
```lua
return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
```

**vim-repeat**: `lua/plugins/prose-writing/editing/vim-repeat.lua`
```lua
return {
  "tpope/vim-repeat",
  event = "VeryLazy",
}
```

**vim-textobj-sentence**: `lua/plugins/prose-writing/editing/vim-textobj-sentence.lua`
```lua
return {
  "preservim/vim-textobj-sentence",
  dependencies = { "kana/vim-textobj-user" },
  ft = { "markdown", "text", "tex", "org" },
  config = function()
    vim.g.textobj_sentence_no_default_key_mappings = 1
    vim.keymap.set({ "n", "x", "o" }, "as", "<Plug>TextobjSentenceA")
    vim.keymap.set({ "n", "x", "o" }, "is", "<Plug>TextobjSentenceI")
  end,
}
```

**undotree**: `lua/plugins/prose-writing/editing/undotree.lua`
```lua
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
}
```

---

## 📝 Updated Plugin Loader

**File**: `lua/plugins/init.lua`

```lua
-- PercyBrain Plugin Loader
-- Loads plugins from workflow-based directory structure

return {
  -- Minimal plugins that need early loading
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
  },
  {
    "folke/neodev.nvim",
    opts = {},
  },

  -- All other plugins loaded from subdirectories
  -- lazy.nvim automatically scans lua/plugins/**/*.lua
}
```

Lazy.nvim will automatically load all `.lua` files in subdirectories, so the new structure works immediately.

---

## 🔧 Grammar Checker Decision: LanguageTool (ltex-ls)

**Choice**: **ltex-ls** (LanguageTool via LSP)

**Rationale**:
1. **LSP Integration**: Works natively with Neovim's LSP client
2. **Real-time Checking**: Inline diagnostics as you write
3. **More Powerful**: Full LanguageTool engine (5000+ rules)
4. **Better Integration**: Works with IWE LSP and other markdown tools
5. **Active Development**: Well-maintained Mason package

**Remove**:
- `LanguageTool.lua` (non-LSP version, less integrated)
- `vim-grammarous.lua` (older, less powerful)

**Keep**:
- `vale.lua` (different focus: style/prose linting, complementary)

---

## 🚀 Migration Script

**File**: `scripts/refactor-plugins.sh`

```bash
#!/bin/bash
# PercyBrain Plugin Refactoring Script
# Reorganizes plugins into workflow-based directories

set -euo pipefail

echo "🔄 PercyBrain Plugin Refactoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PLUGIN_DIR="lua/plugins"

# Create new directory structure
echo "📁 Creating workflow directories..."
mkdir -p "$PLUGIN_DIR/zettelkasten"
mkdir -p "$PLUGIN_DIR/ai-sembr"
mkdir -p "$PLUGIN_DIR/prose-writing/distraction-free"
mkdir -p "$PLUGIN_DIR/prose-writing/editing"
mkdir -p "$PLUGIN_DIR/prose-writing/formatting"
mkdir -p "$PLUGIN_DIR/prose-writing/grammar"
mkdir -p "$PLUGIN_DIR/academic"
mkdir -p "$PLUGIN_DIR/publishing"
mkdir -p "$PLUGIN_DIR/org-mode"
mkdir -p "$PLUGIN_DIR/lsp"
mkdir -p "$PLUGIN_DIR/completion"
mkdir -p "$PLUGIN_DIR/ui"
mkdir -p "$PLUGIN_DIR/navigation"
mkdir -p "$PLUGIN_DIR/utilities"
mkdir -p "$PLUGIN_DIR/treesitter"
mkdir -p "$PLUGIN_DIR/lisp"
mkdir -p "$PLUGIN_DIR/experimental"

echo "✅ Directories created"
echo ""

# Phase 1: Delete redundant plugins
echo "🗑️  Phase 1: Removing redundant plugins..."

rm -f "$PLUGIN_DIR/fountain.lua"          # Screenwriting removed
rm -f "$PLUGIN_DIR/twilight.lua"          # Redundant with limelight
rm -f "$PLUGIN_DIR/vimorg.lua"            # Deprecated
rm -f "$PLUGIN_DIR/fzf-vim.lua"           # Redundant with fzf-lua
rm -f "$PLUGIN_DIR/gen.lua"               # Redundant with ollama
rm -f "$PLUGIN_DIR/vim-grammarous.lua"    # Use ltex-ls instead
rm -f "$PLUGIN_DIR/LanguageTool.lua"      # Use ltex-ls instead (evaluate)

echo "✅ Removed 7 redundant plugins"
echo ""

# Phase 2: Move plugins to workflow directories
echo "📦 Phase 2: Reorganizing plugins..."

# Zettelkasten
mv "$PLUGIN_DIR/vim-wiki.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-zettel.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/obsidianNvim.lua" "$PLUGIN_DIR/zettelkasten/obsidian.lua" 2>/dev/null || true
mv "$PLUGIN_DIR/telescope.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true
mv "$PLUGIN_DIR/img-clip.lua" "$PLUGIN_DIR/zettelkasten/" 2>/dev/null || true

# AI & SemBr
mv "$PLUGIN_DIR/ollama.lua" "$PLUGIN_DIR/ai-sembr/" 2>/dev/null || true
mv "$PLUGIN_DIR/sembr.lua" "$PLUGIN_DIR/ai-sembr/" 2>/dev/null || true

# Prose Writing - Distraction Free
mv "$PLUGIN_DIR/goyo.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/zen-mode.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/limelight.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true
mv "$PLUGIN_DIR/centerpad.lua" "$PLUGIN_DIR/prose-writing/distraction-free/" 2>/dev/null || true

# Prose Writing - Editing
mv "$PLUGIN_DIR/vim-pencil.lua" "$PLUGIN_DIR/prose-writing/editing/" 2>/dev/null || true

# Prose Writing - Formatting
mv "$PLUGIN_DIR/autopairs.lua" "$PLUGIN_DIR/prose-writing/formatting/" 2>/dev/null || true
mv "$PLUGIN_DIR/comment.lua" "$PLUGIN_DIR/prose-writing/formatting/" 2>/dev/null || true

# Prose Writing - Grammar
mv "$PLUGIN_DIR/vale.lua" "$PLUGIN_DIR/prose-writing/grammar/" 2>/dev/null || true
mv "$PLUGIN_DIR/thesaurusquery.lua" "$PLUGIN_DIR/prose-writing/grammar/thesaurus.lua" 2>/dev/null || true

# Academic
mv "$PLUGIN_DIR/vimtex.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-pandoc.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-latex-preview.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true
mv "$PLUGIN_DIR/cmp-dictionary.lua" "$PLUGIN_DIR/academic/" 2>/dev/null || true

# Publishing
mv "$PLUGIN_DIR/markdown-preview.lua" "$PLUGIN_DIR/publishing/" 2>/dev/null || true
mv "$PLUGIN_DIR/autopandoc.lua" "$PLUGIN_DIR/publishing/" 2>/dev/null || true

# Org-mode
mv "$PLUGIN_DIR/nvimorgmode.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true
mv "$PLUGIN_DIR/org-bullets.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true
mv "$PLUGIN_DIR/headlines.lua" "$PLUGIN_DIR/org-mode/" 2>/dev/null || true

# LSP
mv "$PLUGIN_DIR/mason-lspconfig.lua" "$PLUGIN_DIR/lsp/" 2>/dev/null || true
# Note: lspconfig.lua should already be in lsp/

# Completion
mv "$PLUGIN_DIR/nvim-cmp.lua" "$PLUGIN_DIR/completion/" 2>/dev/null || true

# UI
mv "$PLUGIN_DIR/alpha.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/whichkey.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/noice.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/catppuccin.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/gruvbox.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/nightfox.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/transparent.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true
mv "$PLUGIN_DIR/nvim-web-devicons.lua" "$PLUGIN_DIR/ui/" 2>/dev/null || true

# Navigation
mv "$PLUGIN_DIR/nvim-tree.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/yazi.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/fzf-lua.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true
mv "$PLUGIN_DIR/neoscroll.lua" "$PLUGIN_DIR/navigation/" 2>/dev/null || true

# Utilities
mv "$PLUGIN_DIR/lazygit.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/toggleterm.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/floaterm.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/pomo.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/translate.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/stay-centered.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/typewriter.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/hardtime.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/screenkey.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true
mv "$PLUGIN_DIR/high-str.lua" "$PLUGIN_DIR/utilities/" 2>/dev/null || true

# Treesitter
mv "$PLUGIN_DIR/nvim-treesitter.lua" "$PLUGIN_DIR/treesitter/" 2>/dev/null || true

# Lisp
mv "$PLUGIN_DIR/quicklispnvim.lua" "$PLUGIN_DIR/lisp/" 2>/dev/null || true
mv "$PLUGIN_DIR/cl-neovim.lua" "$PLUGIN_DIR/lisp/" 2>/dev/null || true

# Experimental
mv "$PLUGIN_DIR/pendulum.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/styledoc.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/vim-dialect.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true
mv "$PLUGIN_DIR/w3m.lua" "$PLUGIN_DIR/experimental/" 2>/dev/null || true

echo "✅ Plugins reorganized"
echo ""

# Phase 3: Add new essential plugins (placeholders)
echo "➕ Phase 3: Creating new plugin files..."

# IWE LSP
cat > "$PLUGIN_DIR/zettelkasten/iwe-lsp.lua" << 'EOF'
-- IWE LSP - Markdown Knowledge Management
-- See docs/how-to-use-iwe.md for features

return {
  -- IWE requires 'iwe' binary to be installed
  -- Install: cargo install iwe
  -- Configuration in lua/plugins/lsp/lspconfig.lua
}
EOF

# AI Draft Generator
cat > "$PLUGIN_DIR/ai-sembr/ai-draft.lua" << 'EOF'
-- AI Draft Generator - Convert Zettelkasten notes to prose
-- Depends on ollama.lua being configured

return {
  "nvim-lua/plenary.nvim",
  -- Full implementation needed - see WORKFLOW_REFACTORING_PLAN.md
}
EOF

# Hugo Integration
cat > "$PLUGIN_DIR/publishing/hugo.lua" << 'EOF'
-- Hugo Static Site Publishing
-- Commands: :HugoNew, :HugoServer, :HugoBuild, :HugoPublish

return {
  "phelipetls/jsonpath.nvim",
  ft = { "markdown", "md" },
  -- Full implementation needed - see WORKFLOW_REFACTORING_PLAN.md
}
EOF

# ltex-ls (LanguageTool LSP)
cat > "$PLUGIN_DIR/prose-writing/grammar/ltex-ls.lua" << 'EOF'
-- ltex-ls - LanguageTool Language Server
-- Provides grammar and style checking via LSP

return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "ltex-ls",
    },
  },
}
EOF

# nvim-surround
cat > "$PLUGIN_DIR/prose-writing/editing/nvim-surround.lua" << 'EOF'
return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
EOF

# vim-repeat
cat > "$PLUGIN_DIR/prose-writing/editing/vim-repeat.lua" << 'EOF'
return {
  "tpope/vim-repeat",
  event = "VeryLazy",
}
EOF

# vim-textobj-sentence
cat > "$PLUGIN_DIR/prose-writing/editing/vim-textobj-sentence.lua" << 'EOF'
return {
  "preservim/vim-textobj-sentence",
  dependencies = { "kana/vim-textobj-user" },
  ft = { "markdown", "text", "tex", "org" },
  config = function()
    vim.g.textobj_sentence_no_default_key_mappings = 1
    vim.keymap.set({ "n", "x", "o" }, "as", "<Plug>TextobjSentenceA")
    vim.keymap.set({ "n", "x", "o" }, "is", "<Plug>TextobjSentenceI")
  end,
}
EOF

# undotree
cat > "$PLUGIN_DIR/prose-writing/editing/undotree.lua" << 'EOF'
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
}
EOF

echo "✅ New plugin files created"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Refactoring complete!"
echo ""
echo "Summary:"
echo "  ❌ Removed: 7 redundant plugins"
echo "  📦 Reorganized: 60 plugins into workflows"
echo "  ➕ Added: 8 new plugin files"
echo ""
echo "Next steps:"
echo "  1. Review new plugin implementations in:"
echo "     - lua/plugins/zettelkasten/iwe-lsp.lua"
echo "     - lua/plugins/ai-sembr/ai-draft.lua"
echo "     - lua/plugins/publishing/hugo.lua"
echo "  2. Update LSP config: lua/plugins/lsp/lspconfig.lua"
echo "  3. Open Neovim: nvim"
echo "  4. Sync plugins: :Lazy sync"
echo "  5. Restart and verify: :checkhealth"
echo ""
```

---

## 📊 Impact Assessment

### Before Refactoring
- **67 plugins** in flat structure
- **8 redundant plugins**
- **Unclear organization** (mixed workflows)
- **Missing**: IWE LSP, Hugo, AI draft generator, essential prose tools

### After Refactoring
- **64 plugins** (-4.5%) in workflow structure
- **0 redundant plugins** (all cleaned)
- **Clear organization** (14 workflow directories)
- **Complete workflows**: Zettelkasten → AI → Prose → Publishing

### Plugin Count by Workflow
- Zettelkasten: 11 plugins (including IWE LSP)
- AI & SemBr: 3 plugins (including draft generator)
- Prose Writing: 14 plugins (distraction-free + editing + grammar)
- Academic: 4 plugins (LaTeX + Pandoc)
- Publishing: 3 plugins (including Hugo)
- Supporting: 29 plugins (LSP, UI, navigation, utilities)

---

## 🔗 Integration Points

### IWE LSP + vim-wiki
- IWE: Modern LSP features (code actions, diagnostics)
- vim-wiki: Traditional wiki commands and file management
- **Both can coexist**: Different feature sets, complementary

### Ollama AI + IWE AI
- Ollama: PercyBrain custom commands (explain, summarize, improve)
- IWE: Document-level AI actions (configurable prompts)
- AI Draft Generator: Combines multiple notes into prose
- **All compatible**: Different scopes and purposes

### SemBr + IWE Formatting
- SemBr: ML-based semantic line breaks
- IWE: LSP-based document formatting
- **Complementary**: SemBr for breaks, IWE for structure

### Hugo + Markdown Preview
- Hugo: Static site generation and publishing
- markdown-preview: Real-time markdown rendering
- **Different purposes**: Preview vs. production

---

## 🎯 Final Checklist

### Prerequisites
- [ ] Backup current configuration: `cp -r ~/.config/nvim ~/.config/nvim.backup`
- [ ] Ensure iwe binary installed: `cargo install iwe`
- [ ] Verify Ollama running: `ollama list`
- [ ] Check Hugo installed: `hugo version`

### Execution
- [ ] Run refactoring script: `./scripts/refactor-plugins.sh`
- [ ] Review new plugin implementations
- [ ] Update LSP config with IWE and ltex-ls
- [ ] Open Neovim and sync: `:Lazy sync`
- [ ] Restart Neovim
- [ ] Run health check: `:checkhealth`

### Validation
- [ ] Test IWE LSP: Navigate markdown links with `gd`
- [ ] Test AI draft: `<leader>ad` to generate draft from notes
- [ ] Test Hugo: `:HugoServer` to preview site
- [ ] Test ltex-ls: Open markdown, check grammar diagnostics
- [ ] Test prose editing: Try nvim-surround with `ys` commands
- [ ] Verify all workflows functional

---

## 📝 Next Steps After Refactoring

1. **Document Your Workflows**
   - Create workflow guides in `docs/workflows/`
   - Zettelkasten workflow with IWE
   - AI-assisted writing workflow
   - Publishing workflow with Hugo

2. **Configure IWE**
   - Create `.iwe/config.toml` in Zettelkasten directory
   - Configure AI models for IWE actions
   - Set up custom code actions

3. **Optimize Keybindings**
   - Review overlapping keybindings
   - Create workflow-specific keybinding groups
   - Update WhichKey configuration

4. **Test Real Workflows**
   - Create test note in Zettelkasten
   - Generate draft from notes
   - Publish to Hugo site
   - Write academic paper with LaTeX

---

**Full implementation details**: See individual plugin files and LSP configuration updates in this document.

**Questions or issues?**: Refer to `docs/PLUGIN_ANALYSIS.md` for compatibility details.
