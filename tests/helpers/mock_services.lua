-- Mock External Services for Integration Testing
-- Kent Beck: "Mock at the boundaries, keep the core real"

local M = {}

-- =============================================================================
-- OLLAMA AI SERVICE MOCK
-- =============================================================================

function M.create_ollama_mock(options)
  options = options or {}

  local mock = {
    -- Configuration
    model = options.model or "llama3.2:latest",
    delay_ms = options.delay_ms or 100,
    fail_rate = options.fail_rate or 0,
    responses = options.responses or {},

    -- State tracking
    call_count = 0,
    last_prompt = nil,
    processing = false,
  }

  -- Process a prompt with simulated AI behavior
  function mock:process(prompt, note_type)
    self.call_count = self.call_count + 1
    self.last_prompt = prompt
    self.processing = true

    -- Simulate random failures
    if self.fail_rate > 0 and math.random() < self.fail_rate then
      self.processing = false
      return nil, "Simulated AI service failure"
    end

    -- Simulate processing delay
    vim.wait(self.delay_ms)

    -- Get response based on note type
    local response = self.responses[note_type] or self:generate_default_response(note_type)

    self.processing = false
    return response
  end

  -- Generate contextual default response
  function mock:generate_default_response(note_type)
    if note_type == "wiki" then
      return {
        summary = "Comprehensive analysis of the wiki note content",
        tags = { "processed", "wiki", "ai-enhanced" },
        connections = { "related-note-1", "related-note-2" },
        metadata = {
          model = self.model,
          timestamp = os.date("%Y-%m-%d %H:%M:%S"),
          processing_time = self.delay_ms,
        },
      }
    elseif note_type == "fleeting" then
      return {
        summary = "Quick insight from fleeting note",
        tags = { "fleeting", "inbox" },
        metadata = {
          model = self.model,
          timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        },
      }
    else
      return {
        content = "Generic AI response",
        model = self.model,
      }
    end
  end

  -- Check if service is available
  function mock:is_available()
    return self.fail_rate < 1.0
  end

  -- Get processing status
  function mock:get_status()
    return {
      available = self:is_available(),
      processing = self.processing,
      call_count = self.call_count,
      model = self.model,
    }
  end

  -- Reset mock state
  function mock:reset()
    self.call_count = 0
    self.last_prompt = nil
    self.processing = false
  end

  return mock
end

-- =============================================================================
-- HUGO STATIC SITE GENERATOR MOCK
-- =============================================================================

function M.create_hugo_mock(options)
  options = options or {}

  local mock = {
    -- Configuration
    content_path = options.content_path or "/tmp/hugo_test",
    valid_categories = options.valid_categories or { "tech", "personal", "reference" },
    required_fields = options.required_fields or { "title", "date", "draft" },

    -- State tracking
    validated_files = {},
    published_files = {},
  }

  -- Validate frontmatter for Hugo compatibility
  function mock:validate_frontmatter(frontmatter)
    local errors = {}

    -- Check required fields
    for _, field in ipairs(self.required_fields) do
      if not frontmatter[field] then
        table.insert(errors, "Missing required field: " .. field)
      end
    end

    -- Validate date format
    if frontmatter.date and not frontmatter.date:match("^%d%d%d%d%-%d%d%-%d%d") then
      table.insert(errors, "Invalid date format (expected YYYY-MM-DD)")
    end

    -- Validate categories
    if frontmatter.categories then
      for _, cat in ipairs(frontmatter.categories) do
        local valid = false
        for _, valid_cat in ipairs(self.valid_categories) do
          if cat == valid_cat then
            valid = true
            break
          end
        end
        if not valid then
          table.insert(errors, "Invalid category: " .. cat)
        end
      end
    end

    return #errors == 0, errors
  end

  -- Check if file should be published
  function mock:should_publish(file_path, frontmatter)
    -- Don't publish inbox files
    if file_path:match("/inbox/") then
      return false, "Inbox files are not published"
    end

    -- Don't publish drafts
    if frontmatter and frontmatter.draft == true then
      return false, "Draft files are not published"
    end

    -- Don't publish files without valid frontmatter
    local is_valid, errors = self:validate_frontmatter(frontmatter or {})
    if not is_valid then
      return false, "Invalid frontmatter: " .. table.concat(errors, ", ")
    end

    return true
  end

  -- Simulate Hugo build process
  function mock:build()
    -- This would simulate a Hugo build
    -- For integration tests, we just track what would be built
    local build_results = {
      pages = #self.published_files,
      errors = {},
      warnings = {},
      duration_ms = 250,
    }

    vim.wait(250) -- Simulate build time

    return true, build_results
  end

  -- Track file for publishing
  function mock:add_to_publish_queue(file_path)
    table.insert(self.published_files, file_path)
  end

  -- Reset mock state
  function mock:reset()
    self.validated_files = {}
    self.published_files = {}
  end

  return mock
end

-- =============================================================================
-- FILE SYSTEM WATCHER MOCK
-- =============================================================================

function M.create_watcher_mock()
  local mock = {
    watched_paths = {},
    callbacks = {},
    events = {},
  }

  -- Watch a path for changes
  function mock:watch(path, callback)
    self.watched_paths[path] = true
    self.callbacks[path] = callback
  end

  -- Simulate a file change event
  function mock:trigger_event(path, event_type)
    table.insert(self.events, {
      path = path,
      type = event_type,
      timestamp = os.time(),
    })

    -- Call registered callback
    if self.callbacks[path] then
      self.callbacks[path](path, event_type)
    end
  end

  -- Stop watching a path
  function mock:unwatch(path)
    self.watched_paths[path] = nil
    self.callbacks[path] = nil
  end

  -- Reset mock state
  function mock:reset()
    self.watched_paths = {}
    self.callbacks = {}
    self.events = {}
  end

  return mock
end

-- =============================================================================
-- NOTIFICATION SERVICE MOCK
-- =============================================================================

function M.create_notifier_mock()
  local mock = {
    messages = {},
    suppressed = false,
  }

  -- Capture notifications
  function mock:setup()
    self.original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if not self.suppressed then
        table.insert(self.messages, {
          message = msg,
          level = level,
          opts = opts,
          timestamp = os.time(),
        })
      end
    end
  end

  -- Restore original notification function
  function mock:teardown()
    if self.original_notify then
      vim.notify = self.original_notify
    end
  end

  -- Check if notification was sent
  function mock:has_message(pattern)
    for _, msg in ipairs(self.messages) do
      if msg.message:match(pattern) then
        return true, msg
      end
    end
    return false
  end

  -- Get all messages of a certain level
  function mock:get_messages_by_level(level)
    return vim.tbl_filter(function(msg)
      return msg.level == level
    end, self.messages)
  end

  -- Clear captured messages
  function mock:clear()
    self.messages = {}
  end

  -- Temporarily suppress notifications
  function mock:suppress(enabled)
    self.suppressed = enabled
  end

  return mock
end

-- =============================================================================
-- FACTORY FUNCTION FOR ALL MOCKS
-- =============================================================================

function M.create_test_services(config)
  config = config or {}

  local services = {
    ollama = M.create_ollama_mock(config.ollama),
    hugo = M.create_hugo_mock(config.hugo),
    watcher = M.create_watcher_mock(),
    notifier = M.create_notifier_mock(),
  }

  -- Setup all services
  function services:setup()
    self.notifier:setup()
    -- Add other setup as needed
  end

  -- Teardown all services
  function services:teardown()
    self.notifier:teardown()
    self.ollama:reset()
    self.hugo:reset()
    self.watcher:reset()
  end

  -- Reset all services state
  function services:reset()
    self.ollama:reset()
    self.hugo:reset()
    self.watcher:reset()
    self.notifier:clear()
  end

  return services
end

return M
