--- Mock Ollama for Fast Testing
--- Provides deterministic AI responses without network calls
--- @module tests.helpers.mock_ollama

local M = {}

-- Mock state
M._responses = {}
M._enabled = false

--- Enable mock Ollama (disable real API calls)
function M.enable()
  M._enabled = true
end

--- Disable mock Ollama (use real API calls)
function M.disable()
  M._enabled = false
end

--- Check if mock is enabled
--- @return boolean
function M.is_enabled()
  return M._enabled
end

--- Reset all mock responses
function M.reset()
  M._responses = {}
end

--- Set a mock response for a specific prompt pattern
--- @param pattern string Lua pattern to match against prompts
--- @param response string|function Response string or function that returns response
function M.set_response(pattern, response)
  table.insert(M._responses, {
    pattern = pattern,
    response = response,
  })
end

--- Get mock response for a prompt
--- @param prompt string The prompt to match
--- @return string|nil Mock response or nil if no match
function M._get_response(prompt)
  for _, entry in ipairs(M._responses) do
    if prompt:match(entry.pattern) then
      if type(entry.response) == "function" then
        return entry.response(prompt)
      else
        return entry.response
      end
    end
  end
  return nil
end

--- Mock implementation of call_ollama
--- @param prompt string The prompt to send
--- @param callback function Callback function(response)
function M.call_ollama(prompt, callback)
  if not M._enabled then
    error("Mock Ollama is not enabled. Call mock_ollama.enable() first.")
  end

  local response = M._get_response(prompt)

  -- Schedule callback to simulate async behavior
  vim.schedule(function()
    callback(response)
  end)
end

--- Setup default GTD task responses
function M.setup_gtd_defaults()
  -- Task decomposition: Return subtasks
  M.set_response("Break down this task", function(prompt)
    -- Extract task name from prompt
    local task = prompt:match('Task: "([^"]+)"') or "Unknown Task"

    -- Generate context-aware subtasks
    if task:match("[Ww]ebsite") or task:match("[Aa]pp") then
      return [[- [ ] Design wireframes and user flows
- [ ] Set up development environment
- [ ] Implement frontend components
- [ ] Build backend API endpoints
- [ ] Add authentication and authorization
- [ ] Write tests and documentation
- [ ] Deploy to production]]
    elseif task:match("[Vv]acation") or task:match("[Tt]rip") then
      return [[- [ ] Research destinations and activities
- [ ] Book flights and accommodations
- [ ] Create packing list
- [ ] Arrange transportation
- [ ] Notify work and set out-of-office]]
    elseif task:match("[Dd]ocumentation") or task:match("[Ww]rite") then
      return [[- [ ] Outline key sections and topics
- [ ] Draft introduction and overview
- [ ] Write detailed content for each section
- [ ] Add examples and code snippets
- [ ] Review and edit for clarity
- [ ] Publish and share]]
    else
      -- Generic subtasks
      return [[- [ ] Research and gather requirements
- [ ] Plan approach and timeline
- [ ] Execute main implementation
- [ ] Test and validate results
- [ ] Document and communicate]]
    end
  end)

  -- Context suggestion: Return appropriate GTD context
  -- luacheck: ignore 561 (cyclomatic complexity acceptable for pattern matching)
  M.set_response("suggest the most appropriate GTD context", function(prompt)
    local task = prompt:match('Task: "([^"]+)"') or ""

    if task:match("[Kk]itchen") or task:match("[Hh]ome") or task:match("[Cc]lean") then
      return "home"
    elseif task:match("[Cc]all") or task:match("[Pp]hone") or task:match("[Tt]alk") then
      return "phone"
    elseif task:match("[Cc]ode") or task:match("[Cc]omputer") or task:match("[Ww]rite") or task:match("[Ee]mail") then
      return "computer"
    elseif task:match("[Ww]ork") or task:match("[Mm]eeting") or task:match("[Oo]ffice") then
      return "work"
    elseif task:match("[Bb]uy") or task:match("[Ss]hop") or task:match("[Ss]tore") then
      return "errands"
    else
      return "work" -- Default context
    end
  end)

  -- Priority inference: Return HIGH/MEDIUM/LOW
  M.set_response("assign a priority", function(prompt)
    local task = prompt:match('Task: "([^"]+)"') or ""

    -- HIGH priority indicators
    if
      task:match("[Uu]rgent")
      or task:match("[Ee]mergency")
      or task:match("[Cc]ritical")
      or task:match("NOW")
      or task:match("[Dd]eadline")
      or task:match("[Tt]ax")
    then
      return "HIGH"
    -- LOW priority indicators
    elseif
      task:match("[Ss]omeday")
      or task:match("[Mm]aybe")
      or task:match("[Ll]ater")
      or task:match("[Gg]roceries")
      or task:match("[Bb]uy")
    then
      return "LOW"
    else
      -- MEDIUM is default
      return "MEDIUM"
    end
  end)
end

--- Setup mock to override ai.lua's call_ollama function
--- @param ai_module table The ai module to patch
function M.patch_ai_module(ai_module)
  if not M._enabled then
    error("Mock Ollama is not enabled. Call mock_ollama.enable() first.")
  end

  -- Store original function
  M._original_call_ollama = ai_module.call_ollama

  -- Replace with mock
  ai_module.call_ollama = function(prompt, callback)
    M.call_ollama(prompt, callback)
  end
end

--- Restore original ai.lua call_ollama function
--- @param ai_module table The ai module to restore
function M.unpatch_ai_module(ai_module)
  if M._original_call_ollama then
    ai_module.call_ollama = M._original_call_ollama
    M._original_call_ollama = nil
  end
end

return M
