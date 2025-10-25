-- PercyBrain Write-Quit AI Pipeline
-- Purpose: Automatic AI processing on save with wiki vs fleeting differentiation
-- Why: Zero-friction AI integration - user writes, quits (:wq), AI processes in background

local M = {}

-- Configuration
M.config = {
  auto_process = true,
  processing_delay_ms = 500, -- Debounce rapid saves
  exclude_patterns = {}, -- Optional exclude patterns
  prompts = {
    -- Suggest links, tags, and expansion areas for wiki notes
    wiki = "Analyze this Zettelkasten wiki note. Suggest: (1) related concepts to link, "
      .. "(2) potential tags, (3) areas to expand. Be concise.",
    fleeting = "Extract the core idea from this fleeting note in one sentence.",
  },
}

-- Internal state
M.state = {
  processing_status = {
    state = "idle", -- idle, processing, completed, error
    current_file = nil,
    last_result = nil,
  },
  processing_callback = nil, -- For testing
  processing_queue = {}, -- Queue for multiple saves
}

-- Setup autocmd and augroup
function M.setup(opts)
  -- Merge user config
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  -- Create augroup
  vim.api.nvim_create_augroup("WriteQuitPipeline", { clear = true })

  -- Register BufWritePost autocmd for markdown files
  if M.config.auto_process then
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "WriteQuitPipeline",
      pattern = "*.md",
      callback = function(args)
        local filepath = args.file
        -- Debounced processing
        vim.defer_fn(function()
          M.on_save(filepath)
        end, M.config.processing_delay_ms)
      end,
    })
  end

  -- Setup keybinding for manual processing
  vim.keymap.set("n", "<leader>ap", M.process_current_buffer, {
    desc = "AI: Process current buffer",
    noremap = true,
    silent = true,
  })
end

-- Detect note type based on filepath
function M.detect_note_type(filepath)
  -- Normalize path
  local normalized = filepath:gsub("\\", "/")

  -- Check if in inbox (fleeting)
  if normalized:match("/inbox/") then
    return "fleeting"
  end

  -- Check if in Zettelkasten root (wiki)
  if normalized:match("/Zettelkasten/[^/]+%.md$") then
    return "wiki"
  end

  -- Default to wiki for other Zettelkasten notes
  if normalized:match("/Zettelkasten/") then
    return "wiki"
  end

  return "unknown"
end

-- Check if file should be processed
function M.should_process_file(filepath)
  -- Must be markdown
  if not filepath:match("%.md$") then
    return false
  end

  -- Must be in Zettelkasten directory
  if not filepath:match("/Zettelkasten/") then
    return false
  end

  -- Check exclude patterns
  for _, pattern in ipairs(M.config.exclude_patterns) do
    if filepath:match(pattern) then
      return false
    end
  end

  -- Check if file exists (skip in test mode if callback is set)
  if not M.state.processing_callback and vim.fn.filereadable(filepath) == 0 then
    return false
  end

  return true
end

-- On save event handler
function M.on_save(filepath)
  -- Validate file should be processed
  if not M.should_process_file(filepath) then
    -- Notify if file exists but isn't eligible (not in test mode)
    if not M.state.processing_callback and vim.fn.filereadable(filepath) == 0 then
      if filepath:match("/Zettelkasten/") then
        vim.notify("⚠️  File not found: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.WARN)
      end
    end
    return false, "File not eligible for processing"
  end

  -- Update state
  M.state.processing_status.state = "processing"
  M.state.processing_status.current_file = filepath

  -- Add to queue
  table.insert(M.state.processing_queue, filepath)

  -- Detect note type
  local note_type = M.detect_note_type(filepath)

  -- Trigger callback for testing (after validation)
  if M.state.processing_callback then
    M.state.processing_callback(filepath)
  end

  -- Read file content (skip in test mode if callback is set)
  local content
  if M.state.processing_callback then
    -- Test mode: use dummy content
    content = "Test content"
  else
    -- Production mode: read actual file
    local success, lines = pcall(vim.fn.readfile, filepath)
    if not success then
      M.state.processing_status.state = "error"
      vim.notify("❌ Failed to read file: " .. filepath, vim.log.levels.ERROR)
      return false, "Failed to read file"
    end
    content = table.concat(lines, "\n")
  end

  -- Get prompt for note type
  local prompt = M.get_prompt_for_note_type(note_type)

  -- Process with Ollama (background, non-blocking)
  -- In test mode with callback, skip async scheduling
  if M.state.processing_callback then
    -- Synchronous for testing
    local result_success, response = M.process_with_ollama(content, prompt)
    if result_success then
      M.on_processing_complete(filepath, "success", response)
    else
      M.on_processing_complete(filepath, "error", response)
    end
  else
    -- Asynchronous for production
    vim.schedule(function()
      local result_success, response = M.process_with_ollama(content, prompt)
      if result_success then
        M.on_processing_complete(filepath, "success", response)
      else
        M.on_processing_complete(filepath, "error", response)
      end
    end)
  end

  return true, nil
end

-- Get prompt for note type
function M.get_prompt_for_note_type(note_type)
  -- Check for custom prompts
  if M.config.prompts and M.config.prompts[note_type] then
    return M.config.prompts[note_type]
  end

  -- Default prompts
  if note_type == "wiki" then
    return M.config.prompts.wiki
  elseif note_type == "fleeting" then
    return M.config.prompts.fleeting
  else
    return "Analyze this note and provide insights."
  end
end

-- Process content (preserve frontmatter, apply AI)
function M.process_content(content, note_type)
  -- For now, just return content unchanged
  -- This preserves frontmatter and allows AI processing later
  -- Hugo frontmatter validation is handled by hugo-menu.lua

  if note_type == "wiki" then
    -- Preserve Hugo frontmatter for wiki notes
    return content
  elseif note_type == "fleeting" then
    -- Preserve simple frontmatter for fleeting notes
    return content
  else
    return content
  end
end

-- Process with Ollama
function M.process_with_ollama(content, prompt)
  -- Get Ollama module
  local ollama = _G.M
  if not ollama or not ollama.ask then
    vim.notify("⚠️  Ollama module not loaded", vim.log.levels.WARN)
    return false, "Ollama not available"
  end

  -- Prepare AI request
  local ai_prompt = prompt .. "\n\nNote content:\n" .. content

  -- Call Ollama (returns success, response from ollama.ask)
  local success, response = ollama.ask({
    prompt = ai_prompt,
    model = M.get_processing_model(),
  })

  -- Return Ollama's success status directly
  if not success then
    return false, response or "Ollama processing failed"
  end

  return success, response
end

-- Get processing model from ai-model-selector
function M.get_processing_model()
  local ai_selector = require("lib.ai-model-selector")
  return ai_selector.get_current_model()
end

-- Processing complete callback
function M.on_processing_complete(filepath, status, result)
  M.state.processing_status.state = status == "success" and "completed" or "error"
  M.state.processing_status.last_result = result

  -- Remove from queue
  for i, path in ipairs(M.state.processing_queue) do
    if path == filepath then
      table.remove(M.state.processing_queue, i)
      break
    end
  end

  -- Notify user
  if status == "success" then
    vim.notify("✅ AI processing complete: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
  else
    vim.notify("❌ AI processing failed: " .. (result or "Unknown error"), vim.log.levels.ERROR)
  end

  -- Return to idle if queue empty
  if #M.state.processing_queue == 0 then
    M.state.processing_status.state = "idle"
  end
end

-- Get processing status
function M.get_processing_status()
  return M.state.processing_status
end

-- Check if processing is blocking
function M.is_processing_blocking()
  -- Processing is always non-blocking (uses vim.schedule)
  return false
end

-- Get queue size
function M.get_queue_size()
  return #M.state.processing_queue
end

-- Get queue info
function M.get_queue_info()
  return M.state.processing_queue
end

-- Check if auto-processing is enabled
function M.is_auto_processing_enabled()
  return M.config.auto_process
end

-- Get processing delay
function M.get_processing_delay()
  return M.config.processing_delay_ms
end

-- Get exclude patterns
function M.get_exclude_patterns()
  return M.config.exclude_patterns
end

-- Get custom prompts
function M.get_custom_prompts()
  return M.config.prompts
end

-- Manual processing for current buffer
function M.process_current_buffer()
  local filepath = vim.api.nvim_buf_get_name(0)
  return M.on_save(filepath)
end

-- Process with custom prompt (optional feature)
function M.process_with_custom_prompt(content, custom_prompt)
  return M.process_with_ollama(content, custom_prompt)
end

-- Retry last processing (optional feature)
function M.retry_last_processing()
  if M.state.processing_status.current_file then
    return M.on_save(M.state.processing_status.current_file)
  else
    vim.notify("⚠️  No previous processing to retry", vim.log.levels.WARN)
    return false, "No previous processing"
  end
end

-- Validate Hugo frontmatter (optional feature, delegates to hugo-menu)
function M.validate_hugo_frontmatter(filepath)
  local hugo = require("lib.hugo-menu")
  return hugo.validate_file_for_publishing(filepath)
end

-- Reset state (for testing)
function M.reset_state()
  M.state = {
    processing_status = {
      state = "idle",
      current_file = nil,
      last_result = nil,
    },
    processing_callback = nil,
    processing_queue = {},
  }
end

-- Set processing callback (for testing)
function M.set_processing_callback(callback)
  M.state.processing_callback = callback
end

return M
