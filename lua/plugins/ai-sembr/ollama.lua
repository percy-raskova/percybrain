-- Ollama AI Integration for PercyBrain
-- Local LLM features for knowledge base assistance

return {
  "nvim-lua/plenary.nvim", -- Required for job control
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim", -- For AI command picker
  },
  config = function()
    local M = {}

    -- Configuration
    M.config = {
      model = "llama3.2:latest",
      ollama_url = "http://localhost:11434",
      temperature = 0.7,
      timeout = 30000, -- 30 seconds
      context_lines = 50, -- Lines of context to include
    }

    -- Check if Ollama is running
    function M.check_ollama()
      local handle = io.popen("pgrep -x ollama")
      local result = handle:read("*a")
      handle:close()
      return result ~= ""
    end

    -- Start Ollama service if not running
    function M.start_ollama()
      if not M.check_ollama() then
        vim.notify("🚀 Starting Ollama service...", vim.log.levels.INFO)
        vim.fn.jobstart("ollama serve", {
          detach = true,
          on_exit = function()
            vim.notify("✅ Ollama service started", vim.log.levels.INFO)
          end,
        })
        vim.loop.sleep(2000) -- Wait 2 seconds for service to start
      end
    end

    -- Call Ollama API
    function M.call_ollama(prompt, callback)
      M.start_ollama() -- Ensure Ollama is running

      local curl_cmd = string.format(
        'curl -s -X POST %s/api/generate -d \'{"model": "%s", "prompt": "%s", "stream": false, "options": {"temperature": %.1f}}\'',
        M.config.ollama_url,
        M.config.model,
        prompt:gsub('"', '\\"'):gsub("\n", "\\n"),
        M.config.temperature
      )

      vim.fn.jobstart(curl_cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data and #data > 0 then
            local json_str = table.concat(data, "")
            local success, result = pcall(vim.fn.json_decode, json_str)
            if success and result.response then
              callback(result.response)
            else
              vim.notify("❌ Ollama API error", vim.log.levels.ERROR)
            end
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            vim.notify("❌ Ollama error: " .. table.concat(data, ""), vim.log.levels.ERROR)
          end
        end,
      })
    end

    -- Get current buffer context
    function M.get_buffer_context()
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local current_line = cursor[1]

      -- Get context around cursor
      local start_line = math.max(0, current_line - M.config.context_lines)
      local end_line = math.min(vim.api.nvim_buf_line_count(bufnr), current_line + M.config.context_lines)

      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
      return table.concat(lines, "\n")
    end

    -- Get visual selection
    function M.get_visual_selection()
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local start_line = start_pos[2] - 1
      local end_line = end_pos[3]

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
      return table.concat(lines, "\n")
    end

    -- Display result in floating window
    function M.show_result(title, content)
      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)

      -- Split content into lines
      local lines = vim.split(content, "\n", { plain = true })

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
      vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

      local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " " .. title .. " ",
        title_pos = "center",
      }

      local win = vim.api.nvim_open_win(buf, true, opts)
      vim.api.nvim_win_set_option(win, "wrap", true)
      vim.api.nvim_win_set_option(win, "linebreak", true)

      -- Close on q or Escape
      vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
    end

    -- AI Commands

    -- Explain selected text or current paragraph
    function M.explain()
      local text = vim.fn.mode() == "v" and M.get_visual_selection() or M.get_buffer_context()

      vim.notify("🤔 Asking AI to explain...", vim.log.levels.INFO)

      local prompt = string.format(
        "Explain the following text clearly and concisely. Focus on key concepts and connections:\n\n%s",
        text
      )

      M.call_ollama(prompt, function(response)
        M.show_result("AI Explanation", response)
      end)
    end

    -- Summarize note or selection
    function M.summarize()
      local text = vim.fn.mode() == "v" and M.get_visual_selection() or M.get_buffer_context()

      vim.notify("📝 Summarizing content...", vim.log.levels.INFO)

      local prompt =
        string.format("Provide a concise summary of the following text, highlighting the main points:\n\n%s", text)

      M.call_ollama(prompt, function(response)
        M.show_result("AI Summary", response)
      end)
    end

    -- Suggest related links based on content
    function M.suggest_links()
      local text = M.get_buffer_context()

      vim.notify("🔗 Finding related concepts...", vim.log.levels.INFO)

      local prompt = string.format(
        [[Based on the following text, suggest 5-7 related concepts or topics that would be valuable to link to in a Zettelkasten knowledge base. Format as a bulleted list with brief explanations:

%s]],
        text
      )

      M.call_ollama(prompt, function(response)
        M.show_result("Suggested Links", response)
      end)
    end

    -- Improve writing quality
    function M.improve()
      local text = vim.fn.mode() == "v" and M.get_visual_selection() or M.get_buffer_context()

      vim.notify("✨ Improving writing...", vim.log.levels.INFO)

      local prompt = string.format(
        [[Improve the following text for clarity, conciseness, and flow. Maintain the original meaning and tone:

%s]],
        text
      )

      M.call_ollama(prompt, function(response)
        M.show_result("Improved Version", response)
      end)
    end

    -- Answer questions about knowledge base
    function M.answer_question()
      vim.ui.input({ prompt = "Ask a question: " }, function(question)
        if not question or question == "" then
          return
        end

        local context = M.get_buffer_context()

        vim.notify("💡 Thinking...", vim.log.levels.INFO)

        local prompt = string.format(
          [[Based on the following context from a knowledge base note, answer this question:

Question: %s

Context:
%s]],
          question,
          context
        )

        M.call_ollama(prompt, function(response)
          M.show_result("AI Answer", response)
        end)
      end)
    end

    -- Generate ideas from current note
    function M.generate_ideas()
      local text = M.get_buffer_context()

      vim.notify("💭 Generating ideas...", vim.log.levels.INFO)

      local prompt = string.format(
        [[Based on the following note, generate 5 new ideas, questions, or angles to explore. Be creative and thought-provoking:

%s]],
        text
      )

      M.call_ollama(prompt, function(response)
        M.show_result("Generated Ideas", response)
      end)
    end

    -- AI command picker using Telescope
    function M.ai_menu()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values

      local commands = {
        { name = "🤔 Explain", func = M.explain, desc = "Explain selected text or current context" },
        { name = "📝 Summarize", func = M.summarize, desc = "Summarize note or selection" },
        { name = "🔗 Suggest Links", func = M.suggest_links, desc = "Find related concepts to link" },
        { name = "✨ Improve Writing", func = M.improve, desc = "Enhance clarity and flow" },
        { name = "💡 Answer Question", func = M.answer_question, desc = "Ask AI about this note" },
        { name = "💭 Generate Ideas", func = M.generate_ideas, desc = "Brainstorm new angles" },
      }

      pickers
        .new({}, {
          prompt_title = "PercyBrain AI Commands",
          finder = finders.new_table({
            results = commands,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.name .. " - " .. entry.desc,
                ordinal = entry.name .. " " .. entry.desc,
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              selection.value.func()
            end)
            return true
          end,
        })
        :find()
    end

    -- User commands
    vim.api.nvim_create_user_command("PercyExplain", M.explain, {
      desc = "AI: Explain text",
      range = true,
    })

    vim.api.nvim_create_user_command("PercySummarize", M.summarize, {
      desc = "AI: Summarize note",
      range = true,
    })

    vim.api.nvim_create_user_command("PercyLinks", M.suggest_links, {
      desc = "AI: Suggest related links",
    })

    vim.api.nvim_create_user_command("PercyImprove", M.improve, {
      desc = "AI: Improve writing",
      range = true,
    })

    vim.api.nvim_create_user_command("PercyAsk", M.answer_question, {
      desc = "AI: Answer question",
    })

    vim.api.nvim_create_user_command("PercyIdeas", M.generate_ideas, {
      desc = "AI: Generate ideas",
    })

    vim.api.nvim_create_user_command("PercyAI", M.ai_menu, {
      desc = "AI: Show command menu",
    })

    -- Keymaps for PercyBrain AI (all under <leader>a* prefix)
    local opts = { noremap = true, silent = true }

    -- AI menu
    vim.keymap.set("n", "<leader>aa", M.ai_menu, vim.tbl_extend("force", opts, { desc = "AI: Command Menu" }))

    -- Individual AI commands
    vim.keymap.set({ "n", "v" }, "<leader>ae", M.explain, vim.tbl_extend("force", opts, { desc = "AI: Explain" }))

    vim.keymap.set({ "n", "v" }, "<leader>as", M.summarize, vim.tbl_extend("force", opts, { desc = "AI: Summarize" }))

    vim.keymap.set("n", "<leader>al", M.suggest_links, vim.tbl_extend("force", opts, { desc = "AI: Suggest Links" }))

    vim.keymap.set(
      { "n", "v" },
      "<leader>aw",
      M.improve,
      vim.tbl_extend("force", opts, { desc = "AI: Improve Writing" })
    )

    vim.keymap.set("n", "<leader>aq", M.answer_question, vim.tbl_extend("force", opts, { desc = "AI: Ask Question" }))

    vim.keymap.set(
      "n",
      "<leader>ax",
      M.generate_ideas,
      vim.tbl_extend("force", opts, { desc = "AI: Generate Ideas (eXplore)" })
    )

    vim.notify("🧠 PercyBrain AI loaded - <leader>aa for AI menu", vim.log.levels.INFO)

    -- Export module globally for testing
    _G.M = M
  end,
}
