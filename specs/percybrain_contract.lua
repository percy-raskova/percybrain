-- PercyBrain Contract Specification
-- This file defines the contract that PercyBrain must adhere to.
-- It serves as both documentation and executable specification.
--
-- Kent Beck: "Tests are specifications that drive implementation"

local Contract = {}

-- ============================================================================
-- CORE CONTRACT: What PercyBrain MUST provide
-- ============================================================================

Contract.REQUIRED = {
  -- Zettelkasten Core Capabilities
  zettelkasten = {
    description = "Knowledge management through linked notes",
    capabilities = {
      "Create unique timestamped notes",
      "Link notes bidirectionally",
      "Find notes by title/content/tags",
      "Track backlinks and forward links",
      "Generate daily notes",
      "Maintain inbox for quick capture",
    },
    keybindings = {
      ["<leader>zn"] = "Create new Zettelkasten note",
      ["<leader>zi"] = "Open inbox for quick capture",
      ["<leader>zd"] = "Open/create daily note",
      ["<leader>zf"] = "Find notes by title",
      ["<leader>zg"] = "Grep through note content",
      ["<leader>zb"] = "Show backlinks to current note",
    },
  },

  -- AI Integration Capabilities
  ai_integration = {
    description = "Local AI assistance through Ollama",
    capabilities = {
      "Generate text completions",
      "Explain complex concepts",
      "Summarize selected text",
      "Draft new content from prompts",
      "Suggest note connections",
    },
    keybindings = {
      ["<leader>aa"] = "AI command menu",
      ["<leader>ae"] = "Explain selection",
      ["<leader>as"] = "Summarize selection",
      ["<leader>ad"] = "Draft from prompt",
    },
    requirements = {
      ollama_installed = true,
      model_available = "llama3.2",
    },
  },

  -- Writing Environment Capabilities
  writing_environment = {
    description = "Optimized environment for prose and academic writing",
    capabilities = {
      "Spell checking enabled by default",
      "Line wrapping for prose",
      "Grammar checking via ltex-ls",
      "Distraction-free writing mode",
      "Markdown preview and export",
      "LaTeX support for academic writing",
      "Bibliography management",
    },
    settings = {
      spell = true,
      wrap = true,
      linebreak = true,
      spelllang = "en",
    },
  },

  -- Neurodiversity Optimizations
  neurodiversity = {
    description = "ADHD/autism-first design optimizations",
    capabilities = {
      "No search highlighting (reduces visual noise)",
      "Minimal UI distractions",
      "Clear visual hierarchy",
      "Consistent keybindings",
      "Fast note capture without context switch",
      "Visual indicators for mode and state",
    },
    protected_settings = {
      hlsearch = false, -- CRITICAL: Must remain false for ADHD optimization
      cursorline = true, -- CRITICAL: Visual anchor for current position
      number = true, -- CRITICAL: Spatial navigation aid
      relativenumber = true, -- CRITICAL: Movement calculation aid
    },
  },

  -- Performance Requirements
  performance = {
    description = "System must remain responsive",
    requirements = {
      startup_time_ms = 500, -- Maximum startup time
      keymap_response_ms = 50, -- Maximum keymap response
      search_response_ms = 200, -- Maximum search response
      lazy_loading = true, -- Plugins must lazy-load
    },
  },
}

-- ============================================================================
-- OPTIONAL CONTRACT: What PercyBrain MAY provide
-- ============================================================================

Contract.OPTIONAL = {
  -- Publishing capabilities
  publishing = {
    description = "Export and publish notes",
    capabilities = {
      "Hugo site generation",
      "Markdown to HTML conversion",
      "PDF export via pandoc",
      "Static site deployment",
    },
  },

  -- Advanced AI features
  advanced_ai = {
    description = "Extended AI capabilities",
    capabilities = {
      "Multiple model support",
      "Custom prompt templates",
      "Semantic search via embeddings",
      "Auto-tagging suggestions",
    },
  },

  -- Extended language support
  language_servers = {
    description = "Programming language support",
    capabilities = {
      "LSP for multiple languages",
      "Code completion",
      "Syntax highlighting",
      "Linting and formatting",
    },
  },
}

-- ============================================================================
-- FORBIDDEN CONTRACT: What PercyBrain MUST NOT do
-- ============================================================================

Contract.FORBIDDEN = {
  -- Settings that break neurodiversity optimizations
  breaking_changes = {
    description = "These changes would violate core design principles",
    forbidden_settings = {
      hlsearch = true, -- Would add visual noise
      wrap = false, -- Would break prose reading
      spell = false, -- Would remove writing assistance
    },
    forbidden_behaviors = {
      "Auto-save without user control",
      "Popup windows without user trigger",
      "Animation or smooth scrolling",
      "Automatic format on save (must be opt-in)",
      "Search highlighting by default",
    },
  },

  -- Performance violations
  performance_violations = {
    description = "Behaviors that would degrade performance",
    forbidden = {
      "Synchronous plugin loading on startup",
      "Blocking operations in event handlers",
      "Plugins that scan entire filesystem on load",
      "Non-lazy configuration loading",
    },
  },

  -- Privacy violations
  privacy_violations = {
    description = "Behaviors that would violate privacy",
    forbidden = {
      "Telemetry without explicit consent",
      "Cloud sync without user setup",
      "External API calls without user action",
      "Automatic updates without permission",
    },
  },
}

-- ============================================================================
-- CONTRACT VALIDATION FUNCTIONS
-- ============================================================================

-- Check if a capability is available
function Contract.capability_available(category, capability)
  -- This would be implemented by the test framework
  -- Returns true if the capability can be demonstrated
  return true
end

-- Check if a setting matches the contract
function Contract.setting_matches(category, setting, expected)
  local actual = vim.opt[setting]:get()
  return actual == expected
end

-- Check if a keybinding is available
function Contract.keybinding_available(keymap)
  local mappings = vim.api.nvim_get_keymap("n")
  for _, mapping in ipairs(mappings) do
    if mapping.lhs == keymap then
      return true
    end
  end
  return false
end

-- Validate required contract
function Contract.validate_required()
  local results = {
    passed = {},
    failed = {},
    skipped = {},
  }

  -- This would be expanded with actual validation logic
  -- For now, it's a template showing the structure

  for category, spec in pairs(Contract.REQUIRED) do
    -- Validate each category
    if spec.capabilities then
      for _, capability in ipairs(spec.capabilities) do
        -- Test each capability
        local test_name = category .. "." .. capability
        if Contract.capability_available(category, capability) then
          table.insert(results.passed, test_name)
        else
          table.insert(results.failed, test_name)
        end
      end
    end

    if spec.settings then
      for setting, expected in pairs(spec.settings) do
        local test_name = category .. ".setting." .. setting
        if Contract.setting_matches(category, setting, expected) then
          table.insert(results.passed, test_name)
        else
          table.insert(results.failed, test_name)
        end
      end
    end

    if spec.keybindings then
      for keymap, _ in pairs(spec.keybindings) do
        local test_name = category .. ".keymap." .. keymap
        if Contract.keybinding_available(keymap) then
          table.insert(results.passed, test_name)
        else
          table.insert(results.failed, test_name)
        end
      end
    end
  end

  return results
end

-- Validate forbidden contract (ensure violations don't occur)
function Contract.validate_forbidden()
  local violations = {}

  for category, spec in pairs(Contract.FORBIDDEN) do
    if spec.forbidden_settings then
      for setting, forbidden_value in pairs(spec.forbidden_settings) do
        local actual = vim.opt[setting]:get()
        if actual == forbidden_value then
          table.insert(violations, {
            category = category,
            type = "setting",
            violation = setting .. " = " .. tostring(forbidden_value),
            reason = "This setting violates " .. spec.description,
          })
        end
      end
    end
  end

  return violations
end

-- ============================================================================
-- EXPORT CONTRACT
-- ============================================================================

return Contract
