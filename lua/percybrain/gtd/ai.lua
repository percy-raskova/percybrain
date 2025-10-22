--- GTD AI Integration
--- AI-powered task decomposition, context suggestion, and priority inference
--- @module percybrain.gtd.ai

local M = {}
local Job = require("plenary.job")

--- Call Ollama API with a prompt using OpenAI-compatible endpoint
--- @param prompt string The prompt to send to Ollama
--- @param callback function Callback function to handle the response
function M.call_ollama(prompt, callback)
  -- Get model from ollama-manager or use default
  local model = vim.g.ollama_model or "llama3.2"

  -- Build OpenAI-compatible chat completion request
  local body = vim.fn.json_encode({
    model = model,
    messages = {
      {
        role = "user",
        content = prompt,
      },
    },
    stream = false,
  })

  -- Make HTTP request to OpenAI-compatible endpoint
  Job:new({
    command = "curl",
    args = {
      "-s", -- Silent mode
      "-X",
      "POST",
      "http://localhost:11434/v1/chat/completions", -- OpenAI-compatible endpoint
      "-H",
      "Content-Type: application/json",
      "-H",
      "Authorization: Bearer ollama", -- Required but ignored
      "-d",
      body,
    },
    on_exit = function(j, return_val)
      -- Schedule callback to run in main thread
      vim.schedule(function()
        -- Check for curl errors
        if return_val ~= 0 then
          vim.notify("⚠️  Failed to connect to Ollama (is it running?)", vim.log.levels.WARN)
          callback(nil)
          return
        end

        -- Parse response
        local result = table.concat(j:result(), "")

        -- Decode JSON response (OpenAI format)
        local ok, decoded = pcall(vim.fn.json_decode, result)

        if ok and decoded and decoded.choices and decoded.choices[1] then
          local message = decoded.choices[1].message
          if message and message.content then
            callback(message.content)
            return
          end
        end

        vim.notify("⚠️  Invalid response from Ollama", vim.log.levels.WARN)
        callback(nil)
      end)
    end,
  }):start()
end

--- Decompose a task into subtasks using AI
--- Reads the current line, sends to AI, and inserts subtasks as indented children
function M.decompose_task()
  -- Get current line
  local line = vim.api.nvim_get_current_line()

  -- Extract task text (handle both checkbox and plain text)
  local task_text = line:match("%- %[.%] (.+)") or line

  -- Validate input
  if task_text == "" or task_text == nil then
    vim.notify("⚠️  No task found on current line", vim.log.levels.WARN)
    return
  end

  vim.notify("🤖 AI decomposing task...", vim.log.levels.INFO)

  -- Build prompt
  local prompt = string.format(
    [[You are a GTD (Getting Things Done) productivity assistant.
Break down this task into specific, actionable subtasks.

Task: "%s"

Requirements:
1. Each subtask should be concrete and doable in one sitting
2. Order subtasks logically
3. Use markdown checkbox format: - [ ] Subtask description
4. Keep subtasks focused and clear
5. Aim for 3-7 subtasks unless the task is very complex

Return ONLY the markdown checklist, no explanations:]],
    task_text
  )

  -- Call Ollama API
  M.call_ollama(prompt, function(response)
    if not response then
      vim.notify("❌ AI decomposition failed", vim.log.levels.ERROR)
      return
    end

    -- Get current cursor position
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    -- Get current indentation
    local indent = line:match("^(%s*)") or ""
    local child_indent = indent .. "  " -- Add 2 spaces for child level

    -- Parse response and add indentation
    local subtasks = {}
    for subtask in response:gmatch("[^\n]+") do
      -- Only process lines that are checkbox items
      if subtask:match("^%s*%- %[") then
        -- Remove any existing indentation and add our child indentation
        local clean_task = subtask:gsub("^%s*", "")
        table.insert(subtasks, child_indent .. clean_task)
      end
    end

    -- Insert subtasks into buffer
    if #subtasks > 0 then
      vim.api.nvim_buf_set_lines(0, current_line, current_line, false, subtasks)
      vim.notify(string.format("✅ Task decomposed into %d subtasks", #subtasks), vim.log.levels.INFO)
    else
      vim.notify("⚠️  No subtasks generated", vim.log.levels.WARN)
    end
  end)
end

--- Suggest appropriate GTD context for a task
--- Analyzes the task and adds an @context tag
function M.suggest_context()
  -- Get current line
  local line = vim.api.nvim_get_current_line()

  -- Extract task text
  local task_text = line:match("%- %[.%] (.+)") or line

  -- Validate input
  if task_text == "" or task_text == nil then
    vim.notify("⚠️  No task found on current line", vim.log.levels.WARN)
    return
  end

  -- Check if task already has a context tag
  if task_text:match("@%w+") then
    vim.notify("💡 Task already has a context tag", vim.log.levels.INFO)
    return
  end

  -- Get valid contexts from GTD config
  local contexts = { "home", "work", "computer", "phone", "errands" }

  -- Build prompt
  local prompt = string.format(
    [[Given this task, suggest the most appropriate GTD context.

Task: "%s"

Available contexts: %s

Return ONLY the context name (one word), no explanation.]],
    task_text,
    table.concat(contexts, ", ")
  )

  -- Call Ollama API
  M.call_ollama(prompt, function(response)
    if not response then
      return
    end

    -- Extract context word from response
    local suggested_context = response:match("(%w+)")

    if suggested_context then
      -- Validate it's a known context
      local valid_contexts = {
        home = true,
        work = true,
        computer = true,
        phone = true,
        errands = true,
      }

      if valid_contexts[suggested_context:lower()] then
        -- Add @context to end of line
        local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
        local new_line = line .. " @" .. suggested_context:lower()
        vim.api.nvim_buf_set_lines(0, current_line_num - 1, current_line_num, false, { new_line })

        vim.notify(string.format("✅ Suggested context: @%s", suggested_context:lower()), vim.log.levels.INFO)
      else
        vim.notify(string.format("💡 AI suggested: %s (using default)", suggested_context), vim.log.levels.INFO)
      end
    end
  end)
end

--- Infer priority level for a task using AI
--- Analyzes urgency and importance, assigns HIGH/MEDIUM/LOW priority
function M.infer_priority()
  -- Get current line
  local line = vim.api.nvim_get_current_line()

  -- Extract task text
  local task_text = line:match("%- %[.%] (.+)") or line

  -- Validate input
  if task_text == "" or task_text == nil then
    vim.notify("⚠️  No task found on current line", vim.log.levels.WARN)
    return
  end

  -- Check if task already has a priority tag
  if task_text:match("!%u+") then
    vim.notify("💡 Task already has a priority tag", vim.log.levels.INFO)
    return
  end

  -- Build prompt
  local prompt = string.format(
    [[Analyze this task and assign a priority (HIGH, MEDIUM, LOW).

Task: "%s"

Criteria:
- HIGH: Urgent and important, immediate action needed
- MEDIUM: Important but not urgent, or urgent but not important
- LOW: Neither urgent nor important, can be done later

Return ONLY the priority level (HIGH, MEDIUM, or LOW).]],
    task_text
  )

  -- Call Ollama API
  M.call_ollama(prompt, function(response)
    if not response then
      return
    end

    -- Extract priority from response
    local priority = response:match("(HIGH)") or response:match("(MEDIUM)") or response:match("(LOW)")

    if priority then
      -- Add priority tag to end of line
      local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
      local new_line = line .. " !" .. priority
      vim.api.nvim_buf_set_lines(0, current_line_num - 1, current_line_num, false, { new_line })

      vim.notify(string.format("✅ Priority assigned: %s", priority), vim.log.levels.INFO)
    else
      vim.notify("⚠️  Could not determine priority", vim.log.levels.WARN)
    end
  end)
end

return M
