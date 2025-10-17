#!/bin/bash
# PercyBrain New Plugin Implementation Script
# Adds 8 new plugins with full implementations

set -euo pipefail

echo "➕ PercyBrain New Plugin Implementation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PLUGIN_DIR="lua/plugins"

# Ensure directories exist (they should from refactoring script)
echo "📁 Verifying directory structure..."
mkdir -p "$PLUGIN_DIR/zettelkasten"
mkdir -p "$PLUGIN_DIR/ai-sembr"
mkdir -p "$PLUGIN_DIR/publishing"
mkdir -p "$PLUGIN_DIR/prose-writing/grammar"
mkdir -p "$PLUGIN_DIR/prose-writing/editing"

echo "✅ Directories verified"
echo ""

# Plugin 1: IWE LSP - Markdown Knowledge Management
echo "📝 Creating IWE LSP plugin..."
cat > "$PLUGIN_DIR/zettelkasten/iwe-lsp.lua" << 'EOF'
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
EOF

# Plugin 2: AI Draft Generator - Full Implementation
echo "🤖 Creating AI Draft Generator..."
cat > "$PLUGIN_DIR/ai-sembr/ai-draft.lua" << 'EOF'
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
EOF

# Plugin 3: Hugo Integration
echo "🌐 Creating Hugo integration..."
cat > "$PLUGIN_DIR/publishing/hugo.lua" << 'EOF'
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
EOF

# Plugin 4: ltex-ls (LanguageTool LSP)
echo "✍️  Creating ltex-ls grammar checker..."
cat > "$PLUGIN_DIR/prose-writing/grammar/ltex-ls.lua" << 'EOF'
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "ltex-ls", -- LanguageTool Language Server
    },
  },
}
EOF

# Plugin 5: nvim-surround
echo "🔄 Creating nvim-surround..."
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

# Plugin 6: vim-repeat
echo "↩️  Creating vim-repeat..."
cat > "$PLUGIN_DIR/prose-writing/editing/vim-repeat.lua" << 'EOF'
return {
  "tpope/vim-repeat",
  event = "VeryLazy",
}
EOF

# Plugin 7: vim-textobj-sentence
echo "📖 Creating vim-textobj-sentence..."
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

# Plugin 8: undotree
echo "🌳 Creating undotree..."
cat > "$PLUGIN_DIR/prose-writing/editing/undotree.lua" << 'EOF'
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
}
EOF

echo ""
echo "✅ All 8 plugin files created!"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ New plugins added successfully!"
echo ""
echo "Summary:"
echo "  ✅ IWE LSP - Markdown knowledge management"
echo "  ✅ AI Draft Generator - Convert notes to prose"
echo "  ✅ Hugo Integration - Static site publishing"
echo "  ✅ ltex-ls - LanguageTool grammar checking"
echo "  ✅ nvim-surround - Surround operations"
echo "  ✅ vim-repeat - Dot repeat support"
echo "  ✅ vim-textobj-sentence - Sentence text objects"
echo "  ✅ undotree - Visual undo history"
echo ""
echo "⚠️  IMPORTANT: Next steps required!"
echo ""
echo "1. Update LSP configuration:"
echo "   Edit: lua/plugins/lsp/lspconfig.lua"
echo "   Add: IWE LSP (markdown_oxide) setup"
echo "   Add: ltex-ls setup"
echo ""
echo "2. Install dependencies:"
echo "   - IWE: cargo install iwe"
echo "   - Ollama: ollama pull llama3.2"
echo "   - Hugo: Install from https://gohugo.io/"
echo ""
echo "3. Test in Neovim:"
echo "   nvim"
echo "   :Lazy sync"
echo "   :checkhealth"
echo ""
