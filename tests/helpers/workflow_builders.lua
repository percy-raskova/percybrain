-- Test Builders for Integration Workflows
-- Kent Beck: "Make tests easy to write by providing fluent builders"

local env_setup = require("tests.integration.helpers.environment_setup")
local mock_services = require("tests.integration.helpers.mock_services")

local M = {}

-- ============================================================================
-- Wiki Note Creation Builder
-- ============================================================================

function M.wiki_creation_builder()
  local builder = {
    template = "wiki",
    title = "Test Note",
    content = {},
    ai_model = "llama3.2",
    ai_available = true,
    ai_delay_ms = 50,
    hugo_valid = true,
    vault = nil,
  }

  function builder:with_template(name)
    self.template = name
    return self
  end

  function builder:with_title(title)
    self.title = title
    return self
  end

  function builder:with_content(lines)
    self.content = lines
    return self
  end

  function builder:with_ai_model(model)
    self.ai_model = model
    return self
  end

  function builder:ai_unavailable()
    self.ai_available = false
    return self
  end

  function builder:ai_slow(delay_ms)
    self.ai_delay_ms = delay_ms
    return self
  end

  function builder:hugo_invalid()
    self.hugo_valid = false
    return self
  end

  function builder:execute()
    -- Create test vault
    self.vault = env_setup.create_test_vault("wiki_creation_test")

    -- Setup environment
    env_setup.setup_env(self.vault)

    -- Create and configure services
    local services = mock_services.create_test_services({
      ollama = {
        available = self.ai_available,
        delay_ms = self.ai_delay_ms,
        model = self.ai_model,
      },
      hugo = {
        valid = self.hugo_valid,
        content_path = self.vault,
      },
    })
    services:setup()

    -- Load components with test configuration
    env_setup.load_component("template-system", {
      vault_path = self.vault,
      templates_dir = self.vault .. "/templates",
    })

    env_setup.load_component("write-quit-pipeline", {
      ai_processor = services.ollama,
      auto_process = true,
    })

    env_setup.load_component("hugo-menu", {
      content_path = self.vault,
      validator = services.hugo,
    })

    env_setup.load_component("ai-model-selector", {
      default_model = self.ai_model,
    })

    -- Create note from template
    local template_sys = require("percybrain.template-system")
    local file_path = template_sys.create_from_template(self.template, self.title)

    -- Add content if provided
    if #self.content > 0 then
      vim.cmd("edit " .. file_path)
      local buf = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for _, line in ipairs(self.content) do
        table.insert(lines, line)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    -- Return test context
    return {
      vault = self.vault,
      file_path = file_path,
      services = services,
      cleanup = function()
        services:teardown()
        env_setup.cleanup_test_vault(self.vault)
      end,
    }
  end

  return builder
end

-- ============================================================================
-- Quick Capture Builder
-- ============================================================================

function M.quick_capture_builder()
  local builder = {
    content = "",
    save_expected = true,
    vault = nil,
  }

  function builder:with_content(text)
    self.content = text
    return self
  end

  function builder:expect_cancel()
    self.save_expected = false
    return self
  end

  function builder:execute()
    -- Create test vault
    self.vault = env_setup.create_test_vault("quick_capture_test")

    -- Setup environment
    env_setup.setup_env(self.vault)

    -- Load component
    env_setup.load_component("floating-quick-capture", {
      inbox_dir = self.vault .. "/inbox",
      auto_notify = false,
    })

    local capture = require("percybrain.floating-quick-capture")

    -- Open capture window
    local buffer = capture.open_capture_window()

    -- Add content if provided
    if self.content ~= "" then
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(self.content, "\n"))
    end

    return {
      vault = self.vault,
      buffer = buffer,
      capture = capture,
      cleanup = function()
        env_setup.cleanup_test_vault(self.vault)
      end,
    }
  end

  return builder
end

-- ============================================================================
-- Publishing Validation Builder
-- ============================================================================

function M.publishing_builder()
  local builder = {
    notes = {},
    vault = nil,
  }

  function builder:with_valid_wiki_note(title, content)
    table.insert(self.notes, {
      type = "wiki",
      title = title,
      content = content or "Test content",
      valid = true,
    })
    return self
  end

  function builder:with_invalid_wiki_note(title, missing_fields)
    table.insert(self.notes, {
      type = "wiki",
      title = title,
      content = "Test content",
      valid = false,
      missing_fields = missing_fields or { "date", "draft" },
    })
    return self
  end

  function builder:with_inbox_note(title)
    table.insert(self.notes, {
      type = "inbox",
      title = title,
      content = "Quick capture",
      valid = false, -- Inbox notes are never publishable
    })
    return self
  end

  function builder:execute()
    -- Create test vault
    self.vault = env_setup.create_test_vault("publishing_test")

    -- Setup environment
    env_setup.setup_env(self.vault)

    -- Load Hugo validation component
    env_setup.load_component("hugo-menu", {
      content_path = self.vault,
    })

    local created_files = {}

    -- Create all test notes
    for _, note in ipairs(self.notes) do
      local path
      if note.type == "inbox" then
        path = self.vault .. "/inbox/" .. note.title .. ".md"
      else
        path = self.vault .. "/" .. note.title .. ".md"
      end

      -- Generate frontmatter based on validity
      local frontmatter = { "---" }
      table.insert(frontmatter, string.format("title: %s", note.title))

      if note.valid then
        table.insert(frontmatter, string.format("date: %s", os.date("%Y-%m-%d")))
        table.insert(frontmatter, "draft: false")
      else
        -- Intentionally omit fields if specified
        if note.missing_fields then
          -- Don't add the missing fields
          if not vim.tbl_contains(note.missing_fields, "date") then
            table.insert(frontmatter, string.format("date: %s", os.date("%Y-%m-%d")))
          end
          if not vim.tbl_contains(note.missing_fields, "draft") then
            table.insert(frontmatter, "draft: false")
          end
        end
      end

      table.insert(frontmatter, "---")
      table.insert(frontmatter, "")
      table.insert(frontmatter, note.content)

      vim.fn.writefile(frontmatter, path)
      table.insert(created_files, path)
    end

    return {
      vault = self.vault,
      files = created_files,
      hugo = require("percybrain.hugo-menu"),
      cleanup = function()
        env_setup.cleanup_test_vault(self.vault)
      end,
    }
  end

  return builder
end

-- ============================================================================
-- Error Scenario Builder
-- ============================================================================

function M.error_scenario_builder()
  local builder = {
    scenario = "none",
    vault = nil,
  }

  function builder:with_ollama_timeout()
    self.scenario = "ollama_timeout"
    return self
  end

  function builder:with_filesystem_error()
    self.scenario = "filesystem_error"
    return self
  end

  function builder:with_memory_pressure()
    self.scenario = "memory_pressure"
    return self
  end

  function builder:with_concurrent_operations(count)
    self.scenario = "concurrent"
    self.concurrent_count = count or 3
    return self
  end

  function builder:execute()
    -- Create test vault
    self.vault = env_setup.create_test_vault("error_scenario_test")

    -- Setup environment with error injection
    env_setup.setup_env(self.vault)

    -- Inject errors based on scenario
    local error_injector = require("tests.integration.helpers.error_injector")

    if self.scenario == "ollama_timeout" then
      error_injector.inject_ollama_timeout()
    elseif self.scenario == "filesystem_error" then
      error_injector.inject_filesystem_error()
    elseif self.scenario == "memory_pressure" then
      error_injector.inject_memory_pressure()
    elseif self.scenario == "concurrent" then
      error_injector.setup_concurrent_test(self.concurrent_count)
    end

    return {
      vault = self.vault,
      scenario = self.scenario,
      injector = error_injector,
      cleanup = function()
        error_injector.reset()
        env_setup.cleanup_test_vault(self.vault)
      end,
    }
  end

  return builder
end

-- ============================================================================
-- Utility Functions
-- ============================================================================

-- Helper to wait for async operations with better error messages
function M.wait_for_condition(condition_fn, timeout_ms, description)
  timeout_ms = timeout_ms or 5000
  description = description or "condition"

  local elapsed = 0
  local poll_interval = 100

  while elapsed < timeout_ms do
    if condition_fn() then
      return true
    end
    vim.wait(poll_interval)
    elapsed = elapsed + poll_interval
  end

  error(string.format("Timeout waiting for %s after %dms", description, timeout_ms))
end

-- Helper to assert file content contains expected text
function M.assert_file_contains(file_path, expected_text, message)
  local content = table.concat(vim.fn.readfile(file_path), "\n")
  if not content:match(expected_text) then
    error(message or string.format("File %s does not contain '%s'", file_path, expected_text))
  end
end

-- Helper to create a batch of test notes quickly
function M.create_test_notes_batch(vault, count, template_type)
  local notes = {}
  for i = 1, count do
    local title = string.format("Test Note %d", i)
    local builder = M.wiki_creation_builder()
      :with_template(template_type or "wiki")
      :with_title(title)
      :with_content({ "Content for note " .. i })

    local context = builder:execute()
    table.insert(notes, context)
  end
  return notes
end

return M
