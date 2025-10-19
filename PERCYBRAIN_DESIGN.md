# PercyBrain System Architecture Design

**Version**: 2.0 **Status**: Design Specification **Target**: Enhanced Zettelkasten system with LSP, LLM, and semantic line breaks

______________________________________________________________________

## Brand Identity

**PercyBrain** is a personal knowledge management system built on Neovim, designed for writers and researchers who value:

- **Terminal Integration**: Seamless command-line workflow without leaving your editor
- **Local-First**: Your data, your machine, your control - no cloud dependencies
- **AI-Augmented**: Local LLMs enhance your thinking without compromising privacy
- **Plain Text**: Future-proof markdown with git versioning
- **Zettelkasten Method**: Atomic notes with bidirectional linking for emergent insights

**Philosophy**: Your second brain should be as fast as your first brain - capturing ideas at the speed of thought, connecting knowledge automatically, and publishing effortlessly.

**Target Users**:

- Writers seeking Obsidian-like features in Neovim
- Researchers managing large knowledge bases
- Developers who live in the terminal
- Privacy-conscious users preferring local-only tools

______________________________________________________________________

## Executive Summary

This document specifies a comprehensive redesign of PercyBrain to integrate:

1. **IWE LSP** - Intelligent markdown LSP for link management, navigation, and knowledge graph
2. **SemBr** - ML-based semantic line break automation for prose formatting
3. **Ollama** - Local LLM integration for AI-assisted writing and note enhancement
4. **Automated Publishing** - One-command static site generation and deployment

**Design Philosophy**: Transform Neovim into a complete Zettelkasten environment rivaling Obsidian while maintaining terminal integration, plain text benefits, and local-first architecture.

______________________________________________________________________

## System Architecture

### High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Neovim (UI Layer)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ PercyBrain  │  │ IWE LSP      │  │ Ollama       │        │
│  │ Core Module  │◄─┤ Client       │◄─┤ Integration  │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                  │                 │
│         │                 │                  │                 │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐        │
│  │ SemBr        │  │ Publishing   │  │ AI Commands  │        │
│  │ Integration  │  │ Pipeline     │  │ Layer        │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                    External Services Layer                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ IWE LSP      │  │ SemBr        │  │ Ollama       │        │
│  │ Server       │  │ CLI/MCP      │  │ Server       │        │
│  │ (Rust)       │  │ (Python)     │  │ (Go)         │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                  │                 │
│         │                 │                  │                 │
├─────────┼─────────────────┼──────────────────┼─────────────────┤
│         │                 │                  │                 │
│  ┌──────▼────────────────────────────────────▼───────┐        │
│  │          Zettelkasten File System                 │        │
│  │  ~/Zettelkasten/                                  │        │
│  │    ├── inbox/      (fleeting notes)              │        │
│  │    ├── daily/      (daily notes)                 │        │
│  │    ├── permanent/  (processed notes)             │        │
│  │    ├── templates/  (note templates)              │        │
│  │    └── assets/     (images, attachments)         │        │
│  └───────────────────────────────────────────────────┘        │
│                          │                                     │
│  ┌───────────────────────▼───────────────────────────┐        │
│  │       Static Site Output                          │        │
│  │  ~/blog/                                          │        │
│  │    ├── content/    (processed markdown)           │        │
│  │    ├── public/     (generated site)               │        │
│  │    └── themes/     (site theme)                   │        │
│  └───────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

______________________________________________________________________

## Component Specifications

### 1. IWE LSP Integration

#### Purpose

Provide intelligent markdown editing with link management, navigation, backlinks, and knowledge graph analysis.

#### Architecture

```lua
-- lua/plugins/iwe-lsp.lua
return {
  "iwe-org/iwe",  -- Hypothetical Neovim client (need to verify actual repo)
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  ft = "markdown",
  config = function()
    local lspconfig = require('lspconfig')

    -- Configure IWE LSP server
    lspconfig.iwe.setup({
      cmd = { "iwe", "lsp" },  -- IWE LSP server command
      filetypes = { "markdown" },
      root_dir = lspconfig.util.root_pattern(".git", ".iwe"),
      settings = {
        iwe = {
          workspace = vim.fn.expand("~/Zettelkasten"),
          linkStyle = "wiki",  -- [[wiki-style]] links
          enableBacklinks = true,
          enableInlayHints = true,
          templates = {
            daily = "templates/daily.md",
            permanent = "templates/note.md",
          },
        },
      },
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    })
  end,
}
```

#### Key Features to Leverage

1. **Link Completion**: Auto-complete `[[note-name]]` as you type
2. **Link Navigation**: `gd` to follow links, `gr` for references
3. **Backlinks**: Show all notes linking to current note
4. **Rename Refactoring**: Rename notes with automatic link updates across entire vault
5. **Document Formatting**: Format notes with proper frontmatter and structure
6. **Inlay Hints**: Display parent references and link counts inline
7. **Code Actions**: Extract sub-notes, inline notes, convert formats

#### Keymaps

```lua
-- In lua/config/zettelkasten.lua
vim.keymap.set('n', '<leader>zl', vim.lsp.buf.definition, { desc = "Follow link" })
vim.keymap.set('n', '<leader>zr', vim.lsp.buf.references, { desc = "Show references (backlinks)" })
vim.keymap.set('n', '<leader>zh', vim.lsp.buf.hover, { desc = "Show note preview" })
vim.keymap.set('n', '<leader>za', vim.lsp.buf.code_action, { desc = "LSP code actions" })
vim.keymap.set('n', '<leader>zR', vim.lsp.buf.rename, { desc = "Rename note" })
```

#### IWE-Specific Commands

```lua
-- Custom commands leveraging IWE LSP
vim.api.nvim_create_user_command('PercyGraph', function()
  -- Trigger IWE to generate DOT graph visualization
  vim.cmd('!iwe graph ~/Zettelkasten > /tmp/zettel-graph.dot && xdg-open /tmp/zettel-graph.dot')
end, {})

vim.api.nvim_create_user_command('PercyAnalyze', function()
  -- Run IWE knowledge base analysis
  vim.cmd('!iwe analyze ~/Zettelkasten')
end, {})

vim.api.nvim_create_user_command('PercyNormalize', function()
  -- Normalize all documents in vault
  vim.cmd('!iwe normalize ~/Zettelkasten')
end, {})
```

______________________________________________________________________

### 2. SemBr Integration (Semantic Line Breaks)

#### Purpose

Automatically format prose with semantic line breaks for better version control diffs and readability.

#### Architecture

**Integration Strategy**: SemBr supports three integration paths:

1. **CLI wrapper**: Direct command-line calls via `:!sembr`
2. **MCP Server**: Model Context Protocol for persistent model loading
3. **Future plugin**: Direct Lua/FFI integration (when available)

**Recommended Approach**: CLI wrapper initially, migrate to MCP server for performance.

```lua
-- lua/plugins/sembr.lua
return {
  -- Custom plugin wrapping SemBr CLI
  dir = "~/.config/nvim/lua/plugins/sembr",  -- Local plugin
  event = "BufRead",
  ft = { "markdown", "text", "latex" },
  config = function()
    -- Ensure sembr is installed
    local sembr_path = vim.fn.exepath("sembr")
    if sembr_path == "" then
      vim.notify("SemBr not found. Install: pip install sembr", vim.log.levels.WARN)
      return
    end

    -- Configuration
    local sembr_config = {
      model = "bert-small",  -- Balance speed and accuracy
      auto_format_on_save = true,
      filetypes = { "markdown", "text", "latex" },
    }

    -- Format current buffer with SemBr
    local function format_with_sembr()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local text = table.concat(lines, "\n")

      -- Create temp file
      local tmpfile = vim.fn.tempname()
      vim.fn.writefile(lines, tmpfile)

      -- Run sembr
      local cmd = string.format("sembr --model %s %s", sembr_config.model, tmpfile)
      local output = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        -- Replace buffer contents with formatted text
        local formatted = vim.split(output, "\n")
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
        vim.notify("SemBr: Formatted with semantic line breaks", vim.log.levels.INFO)
      else
        vim.notify("SemBr error: " .. output, vim.log.levels.ERROR)
      end

      -- Cleanup
      vim.fn.delete(tmpfile)
    end

    -- Format selection with SemBr
    local function format_selection_sembr()
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_pos[2]-1, end_pos[2], false)

      local tmpfile = vim.fn.tempname()
      vim.fn.writefile(lines, tmpfile)

      local cmd = string.format("sembr --model %s %s", sembr_config.model, tmpfile)
      local output = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        local formatted = vim.split(output, "\n")
        vim.api.nvim_buf_set_lines(0, start_pos[2]-1, end_pos[2], false, formatted)
        vim.notify("SemBr: Formatted selection", vim.log.levels.INFO)
      else
        vim.notify("SemBr error: " .. output, vim.log.levels.ERROR)
      end

      vim.fn.delete(tmpfile)
    end

    -- Keymaps
    vim.keymap.set('n', '<leader>zs', format_with_sembr, { desc = "SemBr: Format buffer" })
    vim.keymap.set('v', '<leader>zs', format_selection_sembr, { desc = "SemBr: Format selection" })

    -- Auto-format on save (if enabled)
    if sembr_config.auto_format_on_save then
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = sembr_config.filetypes,
        callback = function()
          if vim.bo.filetype == "markdown" or vim.bo.filetype == "text" then
            format_with_sembr()
          end
        end,
      })
    end

    -- User commands
    vim.api.nvim_create_user_command('SemBrFormat', format_with_sembr, {})
    vim.api.nvim_create_user_command('SemBrToggleAuto', function()
      sembr_config.auto_format_on_save = not sembr_config.auto_format_on_save
      local status = sembr_config.auto_format_on_save and "enabled" or "disabled"
      vim.notify("SemBr auto-format on save: " .. status, vim.log.levels.INFO)
    end, {})
  end,
}
```

#### Performance Optimization

**MCP Server Mode** (for persistent model loading):

```lua
-- Alternative: Use SemBr MCP server for faster processing
local function start_sembr_mcp()
  vim.fn.jobstart("sembr --listen localhost:8765", {
    on_exit = function()
      vim.notify("SemBr MCP server stopped", vim.log.levels.WARN)
    end,
  })
end

-- Format via MCP server (much faster - model stays loaded)
local function format_with_sembr_mcp()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")

  -- Send to MCP server via HTTP
  local cmd = string.format([[
    curl -X POST http://localhost:8765/format \
      -H "Content-Type: text/plain" \
      --data-binary @- <<< %q
  ]], text)

  local output = vim.fn.system(cmd)
  local formatted = vim.split(output, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
end
```

______________________________________________________________________

### 3. Ollama Integration (Local LLM)

#### Purpose

AI-assisted writing, note enhancement, summarization, and knowledge synthesis using local LLMs.

#### Architecture

```lua
-- lua/plugins/ollama.lua
return {
  -- Custom Ollama integration
  dir = "~/.config/nvim/lua/plugins/ollama",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local curl = require('plenary.curl')

    local ollama_config = {
      base_url = "http://localhost:11434",
      default_model = "llama3.2",  -- User configurable
      timeout = 30000,  -- 30 seconds
    }

    -- Core function: Call Ollama API
    local function ollama_chat(messages, model, stream_callback)
      model = model or ollama_config.default_model

      local response = curl.post(ollama_config.base_url .. "/api/chat", {
        body = vim.fn.json_encode({
          model = model,
          messages = messages,
          stream = stream_callback ~= nil,
        }),
        headers = {
          ["Content-Type"] = "application/json",
        },
        timeout = ollama_config.timeout,
        stream = stream_callback,
      })

      if response.status ~= 200 then
        vim.notify("Ollama error: " .. response.body, vim.log.levels.ERROR)
        return nil
      end

      if not stream_callback then
        local data = vim.fn.json_decode(response.body)
        return data.message.content
      end
    end

    -- AI Commands

    -- 1. Summarize current note
    local function summarize_note()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")

      vim.notify("Ollama: Generating summary...", vim.log.levels.INFO)

      local summary = ollama_chat({
        {
          role = "system",
          content = "You are a helpful assistant that summarizes Zettelkasten notes concisely. Provide a 2-3 sentence summary capturing the key ideas."
        },
        {
          role = "user",
          content = "Summarize this note:\n\n" .. content
        }
      })

      if summary then
        -- Insert summary at top of note
        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
          "<!-- AI Summary -->",
          "**Summary**: " .. summary,
          "",
        })
        vim.notify("Ollama: Summary added", vim.log.levels.INFO)
      end
    end

    -- 2. Generate connection suggestions
    local function suggest_connections()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")

      vim.notify("Ollama: Finding connections...", vim.log.levels.INFO)

      local suggestions = ollama_chat({
        {
          role = "system",
          content = "You are a Zettelkasten assistant. Analyze the note and suggest 3-5 conceptual connections or related topics that would make good links to other notes."
        },
        {
          role = "user",
          content = "Suggest connections for this note:\n\n" .. content
        }
      })

      if suggestions then
        -- Append to note
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {
          "",
          "## AI-Suggested Connections",
          suggestions,
          "",
        })
        vim.notify("Ollama: Connections suggested", vim.log.levels.INFO)
      end
    end

    -- 3. Expand fleeting note into permanent note
    local function expand_note()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")

      vim.notify("Ollama: Expanding note...", vim.log.levels.INFO)

      local expanded = ollama_chat({
        {
          role = "system",
          content = "You are a Zettelkasten assistant. Take this fleeting note and expand it into a well-structured permanent note with: 1) Clear context section, 2) Main argument/idea section, 3) Potential connections section. Maintain markdown format."
        },
        {
          role = "user",
          content = "Expand this fleeting note:\n\n" .. content
        }
      })

      if expanded then
        -- Replace buffer with expanded note
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(expanded, "\n"))
        vim.notify("Ollama: Note expanded", vim.log.levels.INFO)
      end
    end

    -- 4. Generate tags
    local function generate_tags()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")

      vim.notify("Ollama: Generating tags...", vim.log.levels.INFO)

      local tags = ollama_chat({
        {
          role = "system",
          content = "You are a Zettelkasten assistant. Analyze this note and suggest 3-5 relevant tags as a YAML list. Format: `tags: [tag1, tag2, tag3]`"
        },
        {
          role = "user",
          content = "Generate tags for:\n\n" .. content
        }
      })

      if tags then
        -- Find and replace tags line in frontmatter
        for i, line in ipairs(lines) do
          if line:match("^tags:") then
            vim.api.nvim_buf_set_lines(0, i-1, i, false, { tags })
            vim.notify("Ollama: Tags updated", vim.log.levels.INFO)
            return
          end
        end
        -- If no tags line found, add after title
        vim.notify("No tags line found in frontmatter", vim.log.levels.WARN)
      end
    end

    -- 5. Interactive chat for note writing
    local function chat_about_note()
      local prompt = vim.fn.input("Ask Ollama about this note: ")
      if prompt == "" then return end

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")

      vim.notify("Ollama: Processing...", vim.log.levels.INFO)

      local response = ollama_chat({
        {
          role = "system",
          content = "You are a helpful Zettelkasten assistant. You help users think through their notes and ideas."
        },
        {
          role = "user",
          content = "Context (current note):\n" .. content .. "\n\nQuestion: " .. prompt
        }
      })

      if response then
        -- Open response in split
        vim.cmd("vsplit")
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
        vim.bo[buf].filetype = "markdown"
      end
    end

    -- Keymaps
    vim.keymap.set('n', '<leader>zas', summarize_note, { desc = "AI: Summarize note" })
    vim.keymap.set('n', '<leader>zac', suggest_connections, { desc = "AI: Suggest connections" })
    vim.keymap.set('n', '<leader>zae', expand_note, { desc = "AI: Expand note" })
    vim.keymap.set('n', '<leader>zat', generate_tags, { desc = "AI: Generate tags" })
    vim.keymap.set('n', '<leader>zaq', chat_about_note, { desc = "AI: Chat about note" })

    -- User commands
    vim.api.nvim_create_user_command('OllamaSummarize', summarize_note, {})
    vim.api.nvim_create_user_command('OllamaConnections', suggest_connections, {})
    vim.api.nvim_create_user_command('OllamaExpand', expand_note, {})
    vim.api.nvim_create_user_command('OllamaTags', generate_tags, {})
    vim.api.nvim_create_user_command('OllamaChat', chat_about_note, {})
  end,
}
```

#### Ollama Model Management

```lua
-- Model selection UI
local function select_model()
  local curl = require('plenary.curl')
  local response = curl.get(ollama_config.base_url .. "/api/tags")

  if response.status == 200 then
    local data = vim.fn.json_decode(response.body)
    local models = {}
    for _, model in ipairs(data.models) do
      table.insert(models, model.name)
    end

    vim.ui.select(models, {
      prompt = "Select Ollama model:",
    }, function(choice)
      if choice then
        ollama_config.default_model = choice
        vim.notify("Ollama model set to: " .. choice, vim.log.levels.INFO)
      end
    end)
  end
end

vim.api.nvim_create_user_command('OllamaSelectModel', select_model, {})
```

______________________________________________________________________

### 4. Automated Publishing Pipeline

#### Purpose

One-command workflow to publish Zettelkasten to static site with preprocessing, optimization, and deployment.

#### Architecture

```lua
-- lua/config/publishing.lua
local M = {}

M.config = {
  source_dir = vim.fn.expand("~/Zettelkasten"),
  build_dir = vim.fn.expand("~/blog"),
  temp_dir = vim.fn.expand("/tmp/zettel-publish"),

  -- Static site generator
  generator = "hugo",  -- or "quartz", "jekyll"

  -- Publishing options
  exclude_dirs = { "inbox", ".git" },
  process_with_sembr = true,
  minify_output = true,

  -- Deployment
  deploy_method = "git",  -- or "rsync", "netlify", "vercel"
  deploy_remote = "origin",
  deploy_branch = "gh-pages",
}

-- Publishing pipeline
function M.publish()
  vim.notify("📤 Starting publishing pipeline...", vim.log.levels.INFO)

  -- Step 1: Copy notes to temp directory
  vim.notify("1/6 Copying notes...", vim.log.levels.INFO)
  vim.fn.system(string.format("rm -rf %s && mkdir -p %s", M.config.temp_dir, M.config.temp_dir))

  local exclude_args = ""
  for _, dir in ipairs(M.config.exclude_dirs) do
    exclude_args = exclude_args .. string.format(" --exclude='%s'", dir)
  end

  local copy_cmd = string.format("rsync -av %s %s/ %s/",
    exclude_args, M.config.source_dir, M.config.temp_dir)
  vim.fn.system(copy_cmd)

  -- Step 2: Process with SemBr (optional)
  if M.config.process_with_sembr then
    vim.notify("2/6 Applying semantic line breaks...", vim.log.levels.INFO)
    local find_cmd = string.format("find %s -name '*.md' -type f", M.config.temp_dir)
    local md_files = vim.fn.systemlist(find_cmd)

    for _, file in ipairs(md_files) do
      vim.fn.system(string.format("sembr --model bert-small %s > %s.tmp && mv %s.tmp %s",
        file, file, file, file))
    end
  else
    vim.notify("2/6 Skipping SemBr processing", vim.log.levels.INFO)
  end

  -- Step 3: Process frontmatter and links
  vim.notify("3/6 Processing metadata...", vim.log.levels.INFO)
  local process_script = string.format([[
import os
import re
import yaml

def process_note(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Extract frontmatter
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if not match:
        return

    frontmatter = yaml.safe_load(match.group(1))
    body = match.group(2)

    # Ensure required fields
    if 'draft' not in frontmatter:
        frontmatter['draft'] = False

    if 'date' in frontmatter:
        # Ensure ISO format
        frontmatter['date'] = str(frontmatter['date'])

    # Convert wiki links to markdown links
    body = re.sub(r'\[\[([^\]]+)\]\]', r'[\1](\1.md)', body)

    # Write back
    with open(filepath, 'w') as f:
        f.write('---\n')
        f.write(yaml.dump(frontmatter))
        f.write('---\n')
        f.write(body)

for root, dirs, files in os.walk('%s'):
    for file in files:
        if file.endswith('.md'):
            process_note(os.path.join(root, file))
]], M.config.temp_dir)

  local script_file = M.config.temp_dir .. "/process.py"
  vim.fn.writefile(vim.split(process_script, "\n"), script_file)
  vim.fn.system("python3 " .. script_file)

  -- Step 4: Copy to Hugo content directory
  vim.notify("4/6 Syncing to static site...", vim.log.levels.INFO)
  local content_dir = M.config.build_dir .. "/content/notes"
  vim.fn.system(string.format("rm -rf %s && mkdir -p %s", content_dir, content_dir))
  vim.fn.system(string.format("rsync -av %s/ %s/", M.config.temp_dir, content_dir))

  -- Step 5: Build static site
  vim.notify("5/6 Building static site...", vim.log.levels.INFO)
  local build_cmd = ""
  if M.config.generator == "hugo" then
    build_cmd = string.format("cd %s && hugo --minify", M.config.build_dir)
  elseif M.config.generator == "quartz" then
    build_cmd = string.format("cd %s && npx quartz build", M.config.build_dir)
  elseif M.config.generator == "jekyll" then
    build_cmd = string.format("cd %s && bundle exec jekyll build", M.config.build_dir)
  end

  local build_output = vim.fn.system(build_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Build failed:\n" .. build_output, vim.log.levels.ERROR)
    return
  end

  -- Step 6: Deploy
  vim.notify("6/6 Deploying...", vim.log.levels.INFO)
  if M.config.deploy_method == "git" then
    local deploy_cmd = string.format([[
      cd %s/public &&
      git init &&
      git add -A &&
      git commit -m "Deploy: $(date)" &&
      git push -f %s main:%s
    ]], M.config.build_dir, M.config.deploy_remote, M.config.deploy_branch)

    vim.fn.system(deploy_cmd)
  elseif M.config.deploy_method == "netlify" then
    vim.fn.system(string.format("netlify deploy --prod --dir=%s/public", M.config.build_dir))
  end

  -- Cleanup
  vim.fn.system("rm -rf " .. M.config.temp_dir)

  vim.notify("✅ Published successfully!", vim.log.levels.INFO)
end

-- Preview before publishing
function M.preview()
  vim.notify("🌐 Starting preview server...", vim.log.levels.INFO)

  local preview_cmd = ""
  if M.config.generator == "hugo" then
    preview_cmd = string.format("cd %s && hugo server -D", M.config.build_dir)
  elseif M.config.generator == "quartz" then
    preview_cmd = string.format("cd %s && npx quartz build --serve", M.config.build_dir)
  elseif M.config.generator == "jekyll" then
    preview_cmd = string.format("cd %s && bundle exec jekyll serve", M.config.build_dir)
  end

  vim.fn.jobstart(preview_cmd, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line:match("localhost") or line:match("127.0.0.1") then
          vim.notify("Preview: " .. line, vim.log.levels.INFO)
        end
      end
    end,
  })
end

-- Quick publish (no preprocessing)
function M.quick_publish()
  vim.notify("⚡ Quick publish (no preprocessing)...", vim.log.levels.INFO)

  -- Skip SemBr and frontmatter processing
  local temp_config = M.config.process_with_sembr
  M.config.process_with_sembr = false

  M.publish()

  M.config.process_with_sembr = temp_config
end

return M
```

#### User Commands

```lua
-- In lua/config/zettelkasten.lua
local publishing = require('config.publishing')

vim.api.nvim_create_user_command('PercyPublish', publishing.publish, {})
vim.api.nvim_create_user_command('PercyPreview', publishing.preview, {})
vim.api.nvim_create_user_command('PercyQuickPublish', publishing.quick_publish, {})

-- Keymaps
vim.keymap.set('n', '<leader>zp', publishing.publish, { desc = "Publish to static site" })
vim.keymap.set('n', '<leader>zP', publishing.preview, { desc = "Preview site locally" })
```

______________________________________________________________________

## Enhanced Keyboard Shortcuts

### Zettelkasten Core (`<leader>z`)

| Key          | Command      | Description                       |
| ------------ | ------------ | --------------------------------- |
| `<leader>zn` | New note     | Create permanent note with prompt |
| `<leader>zd` | Daily note   | Open/create today's daily note    |
| `<leader>zi` | Inbox note   | Quick fleeting note capture       |
| `<leader>zf` | Find notes   | Telescope fuzzy find              |
| `<leader>zg` | Search notes | Telescope live grep               |
| `<leader>zb` | Backlinks    | Find notes linking here           |
| `<leader>zw` | Zen mode     | Distraction-free writing          |

### IWE LSP (`<leader>zl` - LSP operations)

| Key          | Command      | Description                         |
| ------------ | ------------ | ----------------------------------- |
| `<leader>zl` | Follow link  | Jump to linked note                 |
| `<leader>zr` | References   | Show all references (backlinks)     |
| `<leader>zh` | Hover        | Preview note content                |
| `<leader>za` | Code actions | LSP actions (extract, inline, etc.) |
| `<leader>zR` | Rename       | Rename note + update all links      |

### SemBr Formatting (`<leader>zs`)

| Key                   | Command          | Description                |
| --------------------- | ---------------- | -------------------------- |
| `<leader>zs`          | Format buffer    | Apply semantic line breaks |
| `<leader>zs` (visual) | Format selection | Format selected text only  |

### AI Commands (`<leader>za` - AI operations)

| Key           | Command        | Description                 |
| ------------- | -------------- | --------------------------- |
| `<leader>zas` | AI summarize   | Generate note summary       |
| `<leader>zac` | AI connections | Suggest related topics      |
| `<leader>zae` | AI expand      | Expand fleeting → permanent |
| `<leader>zat` | AI tags        | Generate tags               |
| `<leader>zaq` | AI chat        | Interactive Q&A about note  |

### Publishing (`<leader>zp`)

| Key          | Command | Description                             |
| ------------ | ------- | --------------------------------------- |
| `<leader>zp` | Publish | Full pipeline: process → build → deploy |
| `<leader>zP` | Preview | Start local preview server              |

______________________________________________________________________

## Workflow Examples

### 1. Quick Capture → AI Expansion → Publish

```
1. Press <leader>zi           # Create quick inbox note
2. Type fleeting thoughts      # Quick capture
3. Save and press <leader>zae  # AI expands into permanent note
4. Press <leader>zat           # AI generates tags
5. Press <leader>zac           # AI suggests connections
6. Manually add [[links]]      # IWE provides link completion
7. Press <leader>zp            # Publish to website
```

### 2. Research Session with IWE LSP

```
1. Press <leader>zn            # Create new research note
2. Write initial thoughts
3. Type [[ to link             # IWE autocompletes existing notes
4. Press <leader>zl            # Follow link to read context
5. Press <C-o>                 # Jump back
6. Press <leader>zr            # See what else links here
7. Press <leader>zas           # AI summarize related notes
8. Press <leader>zs            # Format with semantic line breaks
```

### 3. Daily Writing Routine

```
1. Press <leader>zd            # Open today's daily note
2. Write journal entries
3. Press <leader>zi            # Quick inbox captures during day
4. End of day: review inbox/
5. Press <leader>zae on each   # AI expand fleeting notes
6. Move expanded to permanent/
7. Press <leader>zR            # Rename with proper titles
8. Press <leader>zp            # Publish daily
```

______________________________________________________________________

## Installation and Setup

### Prerequisites

```bash
# 1. Install IWE LSP
cargo install iwe  # Assuming Rust-based install

# 2. Install SemBr
pip install sembr

# 3. Install Ollama
curl https://ollama.ai/install.sh | sh

# 4. Pull LLM models
ollama pull llama3.2
ollama pull mistral

# 5. Install static site generator
# For Hugo:
brew install hugo  # macOS
# Or: https://gohugo.io/installation/

# For Quartz:
npm install -g @jackyzha0/quartz
```

### Neovim Configuration

```bash
# 1. Update zettelkasten.lua
nvim ~/.config/nvim/lua/config/zettelkasten.lua

# 2. Add new plugins
touch ~/.config/nvim/lua/plugins/iwe-lsp.lua
touch ~/.config/nvim/lua/plugins/sembr.lua
touch ~/.config/nvim/lua/plugins/ollama.lua

# 3. Add publishing module
touch ~/.config/nvim/lua/config/publishing.lua

# 4. Install plugins
nvim +Lazy sync
```

### Directory Structure Setup

```bash
# Create enhanced directory structure
mkdir -p ~/Zettelkasten/{inbox,daily,permanent,templates,assets}
mkdir -p ~/blog/{content,themes,static}

# Initialize Hugo site (if using Hugo)
cd ~/blog
hugo new site . --force

# Add theme
git submodule add https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
echo "theme = 'PaperMod'" >> config.toml
```

### IWE Workspace Initialization

```bash
cd ~/Zettelkasten
iwe init  # Initialize IWE workspace
```

______________________________________________________________________

## Configuration Files

### `config.toml` (Hugo example)

```toml
baseURL = 'https://yoursite.com/'
languageCode = 'en-us'
title = 'My Zettelkasten'
theme = 'PaperMod'

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true  # Allow HTML in markdown

[params]
  description = "Personal knowledge management system"
  ShowReadingTime = true
  ShowShareButtons = false
  ShowPostNavLinks = true
  ShowBreadCrumbs = true
  ShowCodeCopyButtons = true

  [params.homeInfoParams]
    Title = "Welcome to my Zettelkasten"
    Content = "A collection of interconnected notes and ideas"
```

### `.iwe/config.toml` (IWE configuration)

```toml
[workspace]
root = "/home/percy/Zettelkasten"

[links]
style = "wiki"  # [[note]] style
auto_complete = true

[templates]
daily = "templates/daily.md"
permanent = "templates/note.md"

[features]
backlinks = true
inlay_hints = true
graph_view = true
```

______________________________________________________________________

## Testing and Validation

### Test Suite

```lua
-- tests/zettelkasten_spec.lua
describe("PercyBrain Enhanced System", function()
  it("creates note with proper frontmatter", function()
    -- Test note creation
  end)

  it("formats text with SemBr", function()
    -- Test SemBr integration
  end)

  it("calls Ollama API successfully", function()
    -- Test Ollama integration
  end)

  it("publishes to static site", function()
    -- Test publishing pipeline
  end)
end)
```

### Manual Testing Checklist

- [ ] IWE LSP connects and provides completions
- [ ] Link navigation works (`gd`, `gr`)
- [ ] SemBr formats prose correctly
- [ ] Ollama generates summaries
- [ ] Publishing pipeline completes without errors
- [ ] Static site builds correctly
- [ ] Backlinks display properly

______________________________________________________________________

## Performance Considerations

### SemBr Performance

- **Model Selection**: Use `bert-small` for balance (850 words/sec)
- **MCP Server**: For frequent formatting, use MCP server mode to keep model loaded
- **Selective Formatting**: Format only on explicit command, not every save

### Ollama Performance

- **Model Size**: Start with `llama3.2` (3.2B params) for speed
- **Context Window**: Limit note size for summarization (max 4K tokens)
- **Async Processing**: Run AI commands asynchronously to avoid blocking

### IWE LSP Performance

- **Workspace Size**: IWE handles large vaults efficiently (tested up to 10K notes)
- **Index Caching**: LSP caches link index for fast lookups
- **Incremental Updates**: Only reindexes changed files

______________________________________________________________________

## Future Enhancements

### Phase 2 (Post-MVP)

1. **Graph Visualization**: Integrate IWE graph generation with Neovim floating windows
2. **Spaced Repetition**: Integrate with Anki for flashcard generation
3. **Mobile Sync**: Obsidian Git plugin compatibility for mobile access
4. **Advanced AI**: Fine-tune local models on personal writing style
5. **Web Clipper**: Browser extension to capture web content directly to inbox

### Phase 3 (Advanced)

1. **Collaborative Editing**: Multi-user Zettelkasten with conflict resolution
2. **Advanced Search**: Semantic search using Ollama embeddings
3. **Custom Templates**: Lua-based template engine for note creation
4. **Export Formats**: PDF, EPUB, LaTeX book generation from Zettelkasten

______________________________________________________________________

## Troubleshooting

### IWE LSP Not Connecting

```bash
# Check IWE is installed
which iwe

# Test LSP server manually
iwe lsp

# Check Neovim LSP logs
:LspInfo
:LspLog
```

### SemBr Errors

```bash
# Check sembr installation
pip show sembr

# Test CLI
echo "This is a test. It should work." | sembr

# Check model download
sembr --model bert-small --version
```

### Ollama Not Responding

```bash
# Check Ollama service
systemctl status ollama  # Linux
brew services list | grep ollama  # macOS

# Test API
curl http://localhost:11434/api/tags

# Pull models
ollama pull llama3.2
```

### Publishing Fails

```bash
# Check Hugo installation
hugo version

# Test build manually
cd ~/blog
hugo --verbose

# Check permissions
ls -la ~/blog/public
```

______________________________________________________________________

## References

- **IWE LSP**: https://github.com/iwe-org/iwe
- **SemBr**: https://github.com/admk/sembr
- **Ollama**: https://ollama.ai
- **Hugo**: https://gohugo.io
- **Quartz**: https://quartz.jzhao.xyz
- **Zettelkasten Method**: https://zettelkasten.de

______________________________________________________________________

**Document Status**: Design Complete - Ready for Implementation **Next Step**: Create plugin files and test integration
