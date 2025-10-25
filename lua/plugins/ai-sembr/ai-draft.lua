return {
  "nvim-lua/plenary.nvim", -- Dependency
  keys = {
    {
      "<leader>ad",
      function()
        if _G.ai_draft then
          _G.ai_draft.generate_draft()
        else
          vim.notify("❌ AI Draft not loaded yet", vim.log.levels.ERROR)
        end
      end,
      desc = "AI: Generate Draft from Notes",
    },
  },
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
            content = file:read("*a"),
          })
          file:close()
        end
      end

      return notes
    end

    -- Generate draft from notes
    function M.generate_draft()
      vim.ui.input({ prompt = "Search notes for topic: " }, function(topic)
        if not topic or topic == "" then
          return
        end

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
          combined_content = combined_content
            .. string.format("## Note %d: %s\n\n%s\n\n", i, note.path:match("([^/]+)%.md$") or "Untitled", note.content)
        end

        -- Create prompt for AI
        local prompt = string.format(
          [[
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
]],
          topic,
          combined_content
        )

        -- Call Ollama API
        local curl_cmd = string.format(
          'curl -s -X POST %s/api/generate -d \'{"model": "%s", "prompt": %s, '
            .. '"stream": false, "options": {"temperature": %.1f, "num_predict": %d}}\'',
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
                vim.cmd("new")
                local buf = vim.api.nvim_get_current_buf()

                -- Set filename
                local filename = string.format("draft-%s-%s.md", topic:gsub("%s+", "-"):lower(), os.date("%Y%m%d"))
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

    -- Expose module for keybinding
    _G.ai_draft = M

    vim.notify("📝 PercyBrain Draft Generator loaded - <leader>ad to create drafts", vim.log.levels.INFO)
  end,
}
