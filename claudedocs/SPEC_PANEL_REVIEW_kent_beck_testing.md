# PercyBrain Test Specification Expert Review

**Expert Panel**: Kent Beck (lead), Lisa Crispin, Gojko Adzic, Karl Wiegers **Review Date**: 2025-10-19 **Methodology**: Kent Beck TDD (Contract/Capability/Regression/Smoke) **Project**: PercyBrain Neovim Zettelkasten + AI Writing Environment

______________________________________________________________________

## Executive Summary

**Overall Alignment**: 7.5/10 **Kent Beck Methodology**: 8/10 **Project Coverage**: 6.5/10

The PercyBrain test suite demonstrates **strong foundational TDD practices** with clear separation of contract, capability, regression, and smoke tests. The AAA (Arrange-Act-Assert) pattern is consistently applied, and test quality is generally high. However, significant coverage gaps exist for **core Zettelkasten workflows** (Hugo publishing, template frontmatter validation) and **AI integration features** (model selection, streaming responses).

### Critical Findings

**✅ Strengths**:

- Excellent Kent Beck test categorization (Contract/Capability/Regression/Smoke)
- Consistent AAA pattern usage (44/44 tests passing)
- Strong ADHD regression protection suite with clear rationale
- Comprehensive Markdown link analysis tests
- Good mock/helper framework structure

**⚠️ Critical Gaps**:

1. **No Hugo frontmatter validation** tests (high priority for publishing workflow)
2. **Missing AI model selection** tests (core feature untested)
3. **No template placeholder validation** tests (contract violation risk)
4. **Incomplete Ollama streaming** tests (capability gap)
5. **Missing LSP integration** tests for IWE (new critical dependency)

______________________________________________________________________

## Test Category Analysis

### 1. Contract Tests (MUST/FORBIDDEN)

**Quality Score**: 8/10

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/contract/percybrain_contract_spec.lua` (240 lines)
- `/home/percy/.config/nvim/tests/contract/zettelkasten_templates_spec.lua` (135 lines)

#### Kent Beck Assessment

**Excellent MUST/FORBIDDEN separation**. Contract tests clearly specify system invariants with enforcement mechanisms. Good use of explicit rationale in forbidden contracts.

**Strengths**:

- **Lines 23-118** (percybrain_contract_spec.lua): Clear "Required Contract" tests with specific assertions
  - `spell=true`, `wrap=true`, `linebreak=true` (prose writing requirements)
  - `hlsearch=false`, `cursorline=true` (ADHD optimizations)
- **Lines 120-191**: Strong "Forbidden Contract" enforcement
  - Negative assertions for anti-patterns (lines 121-130: never enable search highlighting)
  - Blocking API call detection (lines 164-190)
- **Lines 16-34** (zettelkasten_templates_spec.lua): Template-specific contracts
  - Fleeting note frontmatter simplicity (title + created only)
  - Hugo field prohibition in fleeting notes

**Issues**:

1. **Missing Hugo Frontmatter Validation** (HIGH PRIORITY)

   - **File**: `tests/contract/zettelkasten_templates_spec.lua`
   - **Location**: Lines 67-97 (wiki template tests)
   - **Problem**: Tests check for field *presence* but not *format validity*

   ```lua
   -- Current (line 79-84):
   assert.matches("title:", content)
   assert.matches("date:", content)
   assert.matches("draft:", content)

   -- Missing validation:
   -- draft: should be boolean (true/false), not string
   -- date: should match YYYY-MM-DD format
   -- tags: should be array format [tag1, tag2], not malformed
   ```

   - **Impact**: Invalid frontmatter breaks Hugo builds silently
   - **Expert**: Wiegers - "Contract should verify *correctness*, not just existence"

2. **No Template Placeholder Validation**

   - **Location**: Missing test in zettelkasten_templates_spec.lua
   - **Gap**: No contract enforcing {{title}}, {{date}}, {{timestamp}} replacement
   - **Risk**: Template application could fail silently, leaving placeholders in notes
   - **Recommendation**: Add contract test for placeholder substitution

   ```lua
   it("MUST replace all template placeholders", function()
     local template = "title: {{title}}\ndate: {{date}}\nts: {{timestamp}}"
     local result = zettel.apply_template(template, "Test")
     assert.not_matches("{{.*}}", result, "No placeholders should remain")
   end)
   ```

3. **Blocking API Call Detection Weak**

   - **File**: percybrain_contract_spec.lua
   - **Lines**: 164-190
   - **Issue**: Only validates pattern list, doesn't actually scan plugin files
   - **Current**: Lines 176-186 just count patterns, never search codebase
   - **Beck**: "This is a test *about* a test, not the test itself"
   - **Fix**: Implement actual file scanning or document as stub

4. **Performance Contract Too Generous**

   - **Lines**: 101-117 (startup performance test)
   - **Problem**: 5000ms budget (line 114) vs 500ms requirement (line 112)
   - **Wiegers**: "Contract says 500ms, test allows 5000ms - which is truth?"
   - **Recommendation**: Align test budget with actual requirement or document exception

#### Adzic Recommendations

**Specification by Example**: Contract tests would benefit from concrete examples:

```lua
-- Instead of:
it("provides writing environment optimizations", function()
  assert.is_true(vim.opt.spell:get())
end)

-- More specific:
it("catches typos in prose with spell checking enabled", function()
  -- Example: User types "teh" → should be underlined as misspelling
  assert.is_true(vim.opt.spell:get(), "spell=true enables typo detection")
end)
```

### 2. Capability Tests (CAN DO)

**Quality Score**: 7/10

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/capability/zettelkasten/note_creation_spec.lua` (208 lines)
- `/home/percy/.config/nvim/tests/capability/zettelkasten/template_workflow_spec.lua` (166 lines)

#### Beck Assessment

**Good behavior-focused testing** with clear user-centric language ("CAN create", "CAN add", "WORKS with"). Strong use of test helpers (`assert_can`, `assert_works`, `run_timed`).

**Strengths**:

- **Lines 27-112** (note_creation_spec.lua): User capability assertions
  - "CAN create a new timestamped note" (lines 28-46)
  - "CAN add content to a new note" (lines 48-70)
  - "CAN create daily notes" (lines 72-87)
  - "CAN capture quick notes to inbox" (lines 89-111)
- **Lines 114-206**: Behavioral validation ("WORKS correctly")
  - Unique timestamp generation (lines 115-142)
  - Concurrent note creation (lines 170-189)
  - Performance budget enforcement (lines 192-206)

**Issues**:

1. **Missing AI Model Selection Capability** (HIGH PRIORITY)

   - **Location**: No AI capability tests exist
   - **Gap**: User should be able to select between Ollama models (llama3.2, codellama, etc.)
   - **Impact**: Core AI feature completely untested at capability level
   - **Beck**: "If users can't test model selection, how do we know it works?"
   - **Recommendation**: Add `tests/capability/ai/model_selection_spec.lua`:

   ```lua
   it("CAN select different AI models", function()
     local models = {"llama3.2:latest", "codellama:latest", "mistral:latest"}
     for _, model in ipairs(models) do
       assert_can("select " .. model, function()
         ollama.set_model(model)
         return ollama.config.model == model
       end)
     end
   end)
   ```

2. **No Hugo Publishing Capability Tests**

   - **Gap**: Lines 263-301 in workflow tests only validate frontmatter *format*
   - **Missing**: Actual Hugo build test or export validation
   - **Risk**: Publishing workflow could be broken without detection
   - **Crispin**: "If publishing is a primary workflow, it needs capability validation"
   - **Recommendation**: Add capability test for `PercyPublish` command

3. **Template Workflow Tests Don't Validate User Experience**

   - **File**: template_workflow_spec.lua
   - **Lines**: 21-50 (fleeting note creation)
   - **Issue**: Tests internal logic, not user interaction flow
   - **Beck**: "Test what users experience, not implementation"
   - **Example**: Missing test for "user presses `<leader>zi` → inbox note created"

4. **Incomplete Concurrent Note Creation Test**

   - **Lines**: 170-189 (note_creation_spec.lua)
   - **Issue**: Creates 5 notes without delay (line 179), doesn't truly test concurrency
   - **Problem**: Sequential creation in loop ≠ concurrent creation
   - **Fix**: Use actual concurrent execution pattern:

   ```lua
   it("WORKS with concurrent note creation", function()
     local jobs = {}
     for i = 1, 5 do
       jobs[i] = vim.fn.jobstart({"nvim", "--headless", "-c", "lua zk.new_note('Note "..i.."')"})
     end
     -- Wait for all jobs to complete and verify
   end)
   ```

#### Crispin Recommendations

**Whole-Team Testing**: Capability tests should validate complete user workflows, not isolated functions:

```lua
-- Current: Fragmented tests
it("CAN create note")
it("CAN add content")
it("CAN save note")

-- Better: End-to-end capability
it("CAN capture fleeting idea from scratch to saved note", function()
  -- User journey: idea → inbox note → saved file → searchable
  local idea = "Quick thought about distributed cognition"

  -- User presses <leader>zi (capture to inbox)
  local note_path = zk.capture_to_inbox(idea)

  -- Note is saved with timestamp
  assert.is_true(vim.fn.filereadable(note_path) == 1)

  -- Note is searchable via grep
  local results = zk.search("distributed cognition")
  assert.equals(1, #results)
end)
```

### 3. Regression Tests (PROTECT)

**Quality Score**: 9/10

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/regression/adhd_protections_spec.lua` (308 lines)

#### Beck Assessment

**Exceptional regression protection suite**. Best file in the entire test suite. Clear rationale for each protection, comprehensive coverage, excellent documentation.

**Strengths**:

- **Lines 26-74**: Visual noise reduction protections with explanations
  - Line 31-35: `hlsearch=false` with ADHD rationale
  - Line 46-53: No animated scrolling protection
  - Line 55-73: Search count suppression
- **Lines 76-127**: Visual anchors and spatial navigation
  - Each setting protected with neurodiversity justification
  - Lines 79-91: Cursorline protection ("visual anchor for ADHD users")
- **Lines 129-180**: Writing support protections
  - Spell checking (lines 130-145)
  - Line wrapping (lines 147-162)
  - Word boundary breaks (lines 164-179)
- **Lines 182-270**: Behavioral protections
  - No auto-save (lines 183-210) - "disrupts sense of control"
  - No automatic popups (lines 212-245) - "startle ADHD users"
  - Fast startup (lines 247-269) - "task avoidance"
- **Lines 272-306**: Comprehensive validation report

**Issues** (Minor):

1. **Smooth Scroll Detection Weak**

   - **Lines**: 46-53
   - **Problem**: Only checks `vim.opt.smoothscroll`, doesn't detect plugin-based smooth scrolling
   - **Gap**: Plugins like `neoscroll.nvim` or `cinnamon.nvim` could violate contract
   - **Fix**: Add plugin detection to regression checks

2. **No Protection for Diagnostic Virtual Text**

   - **Gap**: Missing regression test for LSP diagnostic display settings
   - **ADHD Impact**: Inline virtual text can be visually distracting
   - **Recommendation**: Add protection for diagnostic presentation:

   ```lua
   it("limits diagnostic virtual text visual noise", function()
     local diag_config = vim.diagnostic.config()
     -- Should use signs/underline, not inline virtual text
     assert.is_false(diag_config.virtual_text and diag_config.virtual_text.enabled,
       "Inline diagnostic text creates visual noise for ADHD users")
   end)
   ```

3. **Performance Regression Only Checks lazy.nvim**

   - **Lines**: 247-269
   - **Issue**: Only validates lazy.nvim directory exists, doesn't measure actual startup time
   - **Beck**: "Performance regression should regress on performance, not presence of tool"
   - **Fix**: Add actual startup timing measurement or document as proxy test

#### Wiegers Assessment

**Excellent requirements traceability**. Each regression test clearly states:

1. What is protected
2. Why it matters for ADHD/neurodiversity
3. What happens if violated

This is a model for specification quality. Recommend applying this pattern to all test categories.

### 4. Smoke Tests (STARTS)

**Quality Score**: 7.5/10

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/startup/startup_smoke_spec.lua` (211 lines)

#### Beck Assessment

**Good focus on "does it even start" validation**. Tests catch real-world startup issues (deprecation warnings, invalid config fields).

**Strengths**:

- **Lines 14-36**: LSP deprecation warning detection
  - Actual `nvim --headless` execution (line 17)
  - Runtime warning detection (line 28)
- **Lines 38-51**: Deprecated tsserver detection
  - File content scanning for old API usage
- **Lines 53-74**: Non-existent language server check
  - Prevents configuration of unavailable LSPs
- **Lines 76-98**: Graceful degradation for optional LSPs
- **Lines 100-138**: Gitsigns invalid configuration detection
  - Catches removed/internal fields (lines 112-125)
- **Lines 140-193**: User experience smoke tests
  - No annoying popups (lines 141-165)
  - No LICENSE file auto-open (lines 167-192)
- **Lines 195-209**: Performance smoke test

**Issues**:

1. **Missing IWE LSP Startup Test** (HIGH PRIORITY - New Dependency)

   - **Gap**: No smoke test for IWE Language Server (added Oct 2025)
   - **Location**: Should be added to "LSP Configuration Contract" (lines 14-98)
   - **Risk**: IWE LSP could fail silently on startup
   - **Recommendation**: Add smoke test:

   ```lua
   it("should gracefully handle missing IWE LSP", function()
     local iwe_installed = vim.fn.executable("iwe") == 1
     local config_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/lspconfig.lua"

     if not iwe_installed then
       local file = io.open(config_path, "r")
       local content = file:read("*all")
       file:close()

       local has_availability_check = content:match("if.*executable.*iwe")
       assert.is_truthy(has_availability_check,
         "IWE LSP configured but not installed and no availability check")
     end
   end)
   ```

2. **No AI Service Startup Validation**

   - **Gap**: No smoke test for Ollama service availability
   - **Risk**: User could start PercyBrain without Ollama running
   - **Impact**: All AI commands fail with unclear errors
   - **Recommendation**: Add optional Ollama service check:

   ```lua
   it("documents Ollama availability at startup", function()
     local ollama_running = vim.fn.system("curl -s http://localhost:11434/api/tags"):match("models")
     if not ollama_running then
       vim.notify("📝 Optional: Ollama not running. Start with: ollama serve", vim.log.levels.INFO)
     end
   end)
   ```

3. **Deprecation Warning Test is Weak**

   - **Lines**: 14-36
   - **Issue**: `timeout 10 nvim --headless -c 'qa!'` (line 17) doesn't load full config
   - **Problem**: Deprecation warnings from lazy-loaded plugins won't be detected
   - **Fix**: Run with actual config loading:

   ```lua
   local handle = io.popen("timeout 10 nvim --headless +'lua require(\"config\")' -c 'qa!' 2>&1")
   ```

4. **Performance Smoke Test Doesn't Fail**

   - **Lines**: 195-209
   - **Problem**: Only measures plugin loading (line 201), not full startup
   - **Issue**: Assertion is `< 2000ms` but no failure mechanism if exceeded
   - **Beck**: "Smoke test should smoke when there's fire"
   - **Fix**: Make it a hard failure with actionable message

______________________________________________________________________

## Integration and Workflow Tests

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/plenary/workflows/zettelkasten_spec.lua` (346 lines)
- `/home/percy/.config/nvim/tests/plenary/unit/zettelkasten/config_spec.lua` (195 lines)
- `/home/percy/.config/nvim/tests/plenary/unit/zettelkasten/link_analysis_spec.lua` (314 lines)

### Kent Beck Assessment

**Strong unit test coverage for Zettelkasten core**. Good separation of config, link analysis, and workflow concerns. Consistent test structure.

**Strengths**:

- **Markdown Link Analysis** (link_analysis_spec.lua): Comprehensive
  - Lines 42-117: Pattern matching (with/without .md extension, normalization)
  - Lines 119-167: Orphan detection
  - Lines 169-241: Hub note detection
  - Lines 243-256: Backlinks functionality
  - Lines 258-313: Edge cases (subdirectories, empty notes, special characters)
- **Workflow Integration** (zettelkasten_spec.lua): Good end-to-end coverage
  - Lines 41-93: Core note operations
  - Lines 95-147: Markdown-style linking
  - Lines 149-213: Knowledge graph operations
  - Lines 215-261: Search and navigation
  - Lines 263-301: Publishing integration

**Issues**:

1. **Publishing Integration Tests Don't Validate Hugo Output**

   - **File**: workflows/zettelkasten_spec.lua
   - **Lines**: 263-301
   - **Problem**: Only checks frontmatter format, doesn't run Hugo build
   - **Gap**: No validation that Hugo actually accepts the output
   - **Recommendation**: Add integration test with Hugo:

   ```lua
   it("exports notes that Hugo can build", function()
     -- Create test note with frontmatter
     local note_path = test_home .. "/test-publish.md"
     create_note(note_path, valid_hugo_frontmatter)

     -- Run Hugo build (if available)
     if vim.fn.executable("hugo") == 1 then
       local result = vim.fn.system("hugo --quiet --source " .. test_home)
       assert.equals(0, vim.v.shell_error, "Hugo build should succeed")
     end
   end)
   ```

2. **No Tests for Template Variable Edge Cases**

   - **File**: config_spec.lua
   - **Lines**: 137-194 (template system tests)
   - **Gap**: Missing tests for:
     - Undefined variables in template
     - Missing template files (returns nil but no handling test)
     - Malformed template syntax
   - **Recommendation**: Add edge case coverage

3. **Workflow Tests Don't Validate Command Registration**

   - **File**: workflows/zettelkasten_spec.lua
   - **Lines**: 303-344 (workflow commands)
   - **Issue**: Tests command *existence* but not actual *execution*
   - **Example**: Line 332 checks `PercyPublish` exists but doesn't call it
   - **Fix**: Add command execution tests with assertions

______________________________________________________________________

## AI Integration Tests

**Files Reviewed**:

- `/home/percy/.config/nvim/tests/plenary/unit/ai-sembr/ollama_spec.lua` (735 lines)
- `/home/percy/.config/nvim/tests/plenary/unit/sembr/formatter_spec.lua` (329 lines)

### Beck Assessment

**Comprehensive Ollama integration testing**. Good mock framework. Strong command and API coverage. Missing critical streaming and model selection tests.

**Strengths** (ollama_spec.lua):

- **Lines 41-87**: Service management (detect running, start service)
- **Lines 89-160**: API communication (request format, escaping, error handling)
- **Lines 162-213**: Context extraction (buffer context, visual selection)
- **Lines 215-296**: AI commands (explain, summarize, suggest links, improve, generate ideas)
- **Lines 298-346**: Result display (floating window, markdown formatting)
- **Lines 348-396**: Model configuration (model selection, temperature, URL)
- **Lines 398-435**: Interactive features (question prompting)
- **Lines 462-542**: Telescope integration (menu creation, command population)
- **Lines 544-596**: User command registration (all Percy\* commands)
- **Lines 598-673**: Keymap registration (leader-a mappings)
- **Lines 675-733**: Error edge cases (malformed JSON, long prompts, Unicode)

**Critical Gaps**:

1. **No AI Model Selection UI Test** (HIGH PRIORITY)

   - **Gap**: No test for user changing models via Telescope or command
   - **Current**: Line 348-363 tests *config* setting, not *user interaction*
   - **Missing**: User workflow for selecting between ollama models
   - **Impact**: Core AI feature (multiple models) has no user-facing test
   - **Recommendation**: Add model selection capability test:

   ```lua
   it("allows user to select AI model from available models", function()
     -- Arrange: Mock ollama list command
     vim.fn.system = function(cmd)
       if cmd:match("ollama list") then
         return "llama3.2:latest\ncodellama:latest\nmistral:latest"
       end
     end

     -- Act: User invokes model selection
     local selected_model = ollama.select_model() -- via Telescope

     -- Assert: Model is changed
     assert.is_not_nil(selected_model)
     assert.equals(selected_model, ollama.config.model)
   end)
   ```

2. **No Streaming Response Test**

   - **Lines**: 89-160 (API communication tests)
   - **Problem**: Only tests single-shot responses (line 124-143)
   - **Gap**: Ollama API supports streaming responses (done=false chunks)
   - **Missing**: Test for progressive response handling
   - **Recommendation**: Add streaming test:

   ```lua
   it("handles streaming API responses progressively", function()
     local responses = {}
     vim.fn.jobstart = function(cmd, opts)
       -- Simulate streaming chunks
       opts.on_stdout(nil, {'{"response":"Hello ","done":false}'})
       opts.on_stdout(nil, {'{"response":"World","done":false}'})
       opts.on_stdout(nil, {'{"response":"!","done":true}'})
     end

     ollama.call_ollama("Test", function(chunk, done)
       table.insert(responses, chunk)
     end)

     assert.equals(3, #responses)
     assert.equals("Hello World!", table.concat(responses))
   end)
   ```

3. **SemBr Formatter Tests Mock Too Much**

   - **File**: formatter_spec.lua
   - **Lines**: 50-106 (command creation tests)
   - **Issue**: All tests mock `vim.fn.executable` to return success
   - **Problem**: Never actually tests with real sembr binary
   - **Gap**: No integration test with actual formatter
   - **Recommendation**: Add optional real-binary test:

   ```lua
   it("formats real markdown with sembr binary (if installed)", function()
     if vim.fn.executable("sembr") == 1 then
       local input = "This is a long sentence that should be broken into semantic line breaks."
       local result = vim.fn.system("echo '" .. input .. "' | sembr")
       assert.truthy(result:match("\n"), "Should break long sentence")
     end
   end)
   ```

### Crispin Recommendations

**Acceptance Criteria**: AI integration tests should validate user stories:

```lua
-- User Story: "As a writer, I want to improve my prose with AI suggestions"
describe("Writer improves prose with AI", function()
  it("selects text, invokes improve, receives suggestions, applies changes", function()
    -- Given: Writer has a paragraph with awkward phrasing
    set_buffer_content("The thing is that the concept is complex.")

    -- When: Writer selects text and invokes <leader>aw (improve)
    select_visual(1, 1, 1, 50)
    execute_keymap("<leader>aw")

    -- Then: AI suggests improvement
    assert.truthy(get_floating_window_content():match("improved"))

    -- When: Writer accepts suggestion
    execute_keymap("<CR>")

    -- Then: Buffer is updated with improved text
    assert.equals("This concept is complex.", get_buffer_content())
  end)
end)
```

______________________________________________________________________

## Critical Coverage Gaps

### 1. Hugo Publishing Workflow (HIGH PRIORITY)

**Impact**: Primary use case for PercyBrain wiki publishing **Expert**: Wiegers - "If publishing is core workflow, it needs first-class testing"

**Missing Tests**:

```lua
-- Contract: Hugo frontmatter validity
it("MUST generate valid Hugo frontmatter format", function()
  local note = create_wiki_note("Test")
  local frontmatter = extract_frontmatter(note)

  -- Validate YAML structure
  assert.equals("boolean", type(frontmatter.draft))
  assert.matches("^%d%d%d%d%-%d%d%-%d%d", frontmatter.date)
  assert.equals("table", type(frontmatter.tags))
end)

-- Capability: User can publish to Hugo
it("CAN publish notes to Hugo site", function()
  create_wiki_note("Published Note")

  helpers.assert_can("publish to Hugo", function()
    vim.cmd("PercyPublish")
    return vim.fn.isdirectory("public") == 1
  end)
end)

-- Integration: Hugo builds successfully
it("exports notes that Hugo accepts", function()
  if vim.fn.executable("hugo") == 1 then
    create_wiki_note("Build Test")
    vim.cmd("PercyPublish")

    local result = vim.fn.system("hugo --source " .. export_path)
    assert.equals(0, vim.v.shell_error)
  end
end)
```

### 2. AI Model Selection (HIGH PRIORITY)

**Impact**: Multiple AI models is advertised feature **Expert**: Beck - "If users can't switch models, test should fail"

**Missing Tests**:

```lua
-- Capability: User can select AI model
it("CAN select from available Ollama models", function()
  mock_ollama_models({"llama3.2:latest", "codellama:latest"})

  helpers.assert_can("select model via Telescope", function()
    ollama.model_picker() -- Opens Telescope with model list
    select_telescope_entry(2) -- Select codellama
    return ollama.config.model == "codellama:latest"
  end)
end)

-- Smoke: Detect when no models available
it("warns user when Ollama has no models installed", function()
  mock_ollama_models({}) -- Empty model list

  local notify_called = false
  vim.notify = function(msg, level)
    if msg:match("No Ollama models") then
      notify_called = true
    end
  end

  ollama.check_models()
  assert.is_true(notify_called)
end)
```

### 3. IWE LSP Integration (HIGH PRIORITY - New Dependency)

**Impact**: IWE LSP added Oct 2025, no test coverage **Expert**: Crispin - "New critical dependency needs immediate test coverage"

**Missing Tests**:

```lua
-- Smoke: IWE LSP starts correctly
it("starts IWE language server for .md files", function()
  if vim.fn.executable("iwe") == 1 then
    open_file("test.md")
    wait_for_lsp_attach()

    local clients = vim.lsp.get_active_clients()
    local iwe_attached = false
    for _, client in ipairs(clients) do
      if client.name == "iwe" then
        iwe_attached = true
      end
    end

    assert.is_true(iwe_attached, "IWE LSP should attach to markdown files")
  end
end)

-- Capability: IWE provides link suggestions
it("CAN get link suggestions from IWE LSP", function()
  if vim.fn.executable("iwe") == 1 then
    open_file("test.md")
    set_cursor(5, 10) -- Position on text

    local suggestions = vim.lsp.buf.completion()
    assert.is_not_nil(suggestions)
    -- IWE should suggest existing note links
  end
end)
```

### 4. Template System Edge Cases

**Impact**: Template failures break note creation workflow **Expert**: Adzic - "Templates are examples, test example failures"

**Missing Tests**:

```lua
-- Contract: Template placeholders must be replaced
it("FORBIDDEN to leave unreplaced placeholders", function()
  local template = "title: {{title}}\ndate: {{date}}\nmissing: {{undefined}}"
  local result = zettel.apply_template(template, "Test")

  assert.not_matches("{{.*}}", result, "No placeholders should remain")
  -- OR should error on undefined variables
end)

-- Capability: Handles missing template gracefully
it("CAN create note even if template missing", function()
  vim.fn.delete(zettel.config.templates .. "/fleeting.md")

  helpers.assert_can("create note with fallback", function()
    local note = zettel.new_note("Test")
    return vim.fn.filereadable(note) == 1
  end, "Should use fallback template")
end)
```

### 5. Streaming AI Responses

**Impact**: Better UX for long AI generations **Expert**: Beck - "If API supports it, user expects it"

**Missing Tests**:

```lua
-- Capability: User sees progressive AI response
it("CAN see AI response streaming progressively", function()
  local chunks_received = 0

  vim.fn.jobstart = function(cmd, opts)
    opts.on_stdout(nil, {'{"response":"Word1 ","done":false}'})
    chunks_received = chunks_received + 1

    vim.wait(100)
    opts.on_stdout(nil, {'{"response":"Word2 ","done":false}'})
    chunks_received = chunks_received + 1

    opts.on_stdout(nil, {'{"response":"Word3","done":true}'})
    chunks_received = chunks_received + 1
  end

  ollama.call_ollama_streaming("Test")

  assert.equals(3, chunks_received, "Should receive 3 progressive chunks")
end)
```

______________________________________________________________________

## Test Quality Patterns

### Excellent Patterns to Replicate

1. **ADHD Regression Tests** (adhd_protections_spec.lua)

   - Every protection has clear rationale
   - Violations include explanation of harm
   - Comprehensive final validation report
   - **Apply to**: All test categories

2. **Consistent AAA Pattern**

   - All 44 tests follow Arrange-Act-Assert
   - Clear comments marking sections
   - **Maintain**: Continue enforcing via pre-commit hook

3. **Helper Framework** (tests/helpers/test_framework.lua)

   - `assert_can`, `assert_works`, `run_timed` helpers
   - StateManager for setup/teardown
   - **Expand**: Add more domain-specific helpers

4. **Mock Framework** (tests/helpers/mocks.lua)

   - Ollama, notifications, vim API mocks
   - **Expand**: Add Hugo, IWE LSP mocks

### Anti-Patterns to Fix

1. **Test Pollution** (MINOR - Fixed by Standards)

   - Tests properly avoid `_G.` pollution (standard enforced)
   - Good use of before_each/after_each
   - **Maintain**: Current quality level

2. **Incomplete Stub Tests**

   - Example: Lines 164-190 in percybrain_contract_spec.lua
   - Tests validate pattern list, not actual behavior
   - **Fix**: Either implement fully or document as stub

3. **Over-Mocking in Unit Tests**

   - SemBr formatter tests mock everything, never run real binary
   - **Fix**: Add optional integration tests with real tools

______________________________________________________________________

## Recommendations by Priority

### Immediate (Critical for PercyBrain Core Workflows)

1. **Add Hugo Frontmatter Validation Tests**

   - File: `tests/contract/zettelkasten_templates_spec.lua`
   - Impact: Publishing workflow depends on valid Hugo frontmatter
   - Effort: LOW (2-3 tests, ~50 lines)
   - Owner: Wiegers validation, Beck implementation

2. **Add IWE LSP Smoke Tests**

   - File: `tests/startup/startup_smoke_spec.lua`
   - Impact: New critical dependency (added Oct 2025) has zero coverage
   - Effort: LOW (1-2 tests, ~30 lines)
   - Owner: Crispin integration testing

3. **Add AI Model Selection Capability Tests**

   - File: NEW `tests/capability/ai/model_selection_spec.lua`
   - Impact: Advertised feature completely untested
   - Effort: MEDIUM (3-4 tests, ~80 lines)
   - Owner: Beck capability testing

### Short-Term (Quality Improvements)

4. **Add Template Placeholder Contract Test**

   - File: `tests/contract/zettelkasten_templates_spec.lua`
   - Impact: Prevents silent template failures
   - Effort: LOW (1 test, ~15 lines)

5. **Implement Actual Blocking API Call Detection**

   - File: `tests/contract/percybrain_contract_spec.lua` (lines 164-190)
   - Impact: Actually enforces contract instead of testing test
   - Effort: MEDIUM (refactor, ~40 lines)

6. **Add Hugo Build Integration Test**

   - File: `tests/plenary/workflows/zettelkasten_spec.lua`
   - Impact: Validates actual publishing workflow
   - Effort: MEDIUM (1 test, conditional on hugo binary, ~30 lines)

7. **Add Streaming AI Response Tests**

   - File: `tests/plenary/unit/ai-sembr/ollama_spec.lua`
   - Impact: Better UX validation for AI features
   - Effort: MEDIUM (2-3 tests, ~60 lines)

### Long-Term (Comprehensive Coverage)

08. **Add LSP Integration Test Suite**

    - File: NEW `tests/integration/lsp/iwe_spec.lua`
    - Impact: Critical IWE LSP dependency fully tested
    - Effort: HIGH (10+ tests, ~200 lines)

09. **Add Publishing Workflow E2E Tests**

    - File: NEW `tests/e2e/publishing_workflow_spec.lua`
    - Impact: Complete publishing workflow validated
    - Effort: HIGH (5-7 tests, ~150 lines)

10. **Add Real Binary Integration Tests**

    - Files: All unit test files
    - Impact: Validate actual tools, not just mocks
    - Effort: HIGH (optional tests across suite)

______________________________________________________________________

## Improvement Roadmap

### Phase 1: Critical Gaps (Week 1-2)

**Goal**: Cover high-priority missing functionality

- [ ] Hugo frontmatter validation tests (2 hours)
- [ ] IWE LSP smoke tests (2 hours)
- [ ] AI model selection capability tests (4 hours)
- [ ] Template placeholder contract test (1 hour)

**Deliverable**: 90% coverage of core workflows

### Phase 2: Quality Improvements (Week 3-4)

**Goal**: Fix incomplete/weak tests

- [ ] Implement real blocking API call detection (3 hours)
- [ ] Add Hugo build integration test (2 hours)
- [ ] Add streaming AI response tests (3 hours)
- [ ] Fix performance regression tests to measure actual startup (2 hours)

**Deliverable**: All tests validate real behavior

### Phase 3: Comprehensive Coverage (Month 2)

**Goal**: Full test suite maturity

- [ ] LSP integration test suite (8 hours)
- [ ] Publishing workflow E2E tests (6 hours)
- [ ] Real binary integration tests (optional) (4 hours)
- [ ] Test suite documentation and examples (3 hours)

**Deliverable**: Production-ready test coverage

______________________________________________________________________

## Expert Panel Verdict

### Kent Beck (Lead)

**Score**: 7.5/10

"This is a **solid TDD foundation** with clear test categorization and good discipline. The ADHD regression suite is exemplary - every project should document *why* tests exist like that.

**Critical issues**: Hugo publishing and AI model selection are core features with inadequate test coverage. Fix those immediately.

**Recommendation**: Add the 4 critical tests in Phase 1, then systematically expand. You have the patterns right, just need more coverage."

### Lisa Crispin

**Score**: 7/10

"Good **whole-team testing mindset** with user-centric capability tests. The 'CAN DO' and 'WORKS' language keeps focus on user experience.

**Needs improvement**: Tests are too fragmented. Need more end-to-end workflow validation. Publishing, AI interaction, and note-to-note linking should have complete user journey tests.

**Recommendation**: Add E2E tests that mirror real user workflows from ADHD user's perspective."

### Gojko Adzic

**Score**: 6.5/10

"Tests are **technically correct but lack specification context**. They verify behavior but don't document the *examples* that led to requirements.

**Example**: Template tests check for fields but don't show *why* those fields or *what problem* they solve.

**Recommendation**: Add concrete examples to test names and comments:

- Instead of: `it('MUST have Hugo-compatible frontmatter')`
- Better: `it('MUST have draft:false so Hugo publishes immediately, not as draft')`"

### Karl Wiegers

**Score**: 8/10

"**Excellent requirements quality** in regression tests. ADHD protections show exactly what's required and why. Other test categories lack this rigor.

**Gap**: Hugo frontmatter format is ambiguous. Tests check presence but not correctness. Contract should specify: 'draft' is boolean not string, 'date' is YYYY-MM-DD not timestamp.

**Recommendation**: Apply regression test quality patterns to contract and capability tests. Every test should state *what* and *why*."

______________________________________________________________________

## Conclusion

The PercyBrain test suite demonstrates **strong foundational TDD practices** with clear Kent Beck methodology adherence. The test organization (Contract/Capability/Regression/Smoke) is excellent, AAA patterns are consistent, and the ADHD regression suite is exemplary.

**Critical improvements needed**:

1. Hugo publishing workflow validation (frontmatter + build tests)
2. AI model selection capability tests
3. IWE LSP integration smoke tests
4. Template placeholder contract enforcement

**Implement Phase 1 recommendations immediately** to achieve 90% coverage of core workflows. The patterns are solid - just need expanded application to all critical features.

**Overall Assessment**: Well-architected test suite with clear gaps in core feature coverage. Fix the 4 critical items, and this becomes a production-ready test foundation.

______________________________________________________________________

## Appendix A: Test File Inventory

### Contract Tests (2 files, 375 lines)

- `tests/contract/percybrain_contract_spec.lua` (240 lines) - System-wide contracts
- `tests/contract/zettelkasten_templates_spec.lua` (135 lines) - Template contracts

### Capability Tests (2 files, 374 lines)

- `tests/capability/zettelkasten/note_creation_spec.lua` (208 lines) - Note creation capabilities
- `tests/capability/zettelkasten/template_workflow_spec.lua` (166 lines) - Template workflow capabilities

### Regression Tests (1 file, 308 lines)

- `tests/regression/adhd_protections_spec.lua` (308 lines) - ADHD optimization protections

### Smoke Tests (1 file, 211 lines)

- `tests/startup/startup_smoke_spec.lua` (211 lines) - Startup validation

### Integration/Workflow Tests (3 files, 855 lines)

- `tests/plenary/workflows/zettelkasten_spec.lua` (346 lines) - Zettelkasten workflows
- `tests/plenary/unit/zettelkasten/config_spec.lua` (195 lines) - Zettelkasten config
- `tests/plenary/unit/zettelkasten/link_analysis_spec.lua` (314 lines) - Link analysis

### AI Integration Tests (2 files, 1064 lines)

- `tests/plenary/unit/ai-sembr/ollama_spec.lua` (735 lines) - Ollama integration
- `tests/plenary/unit/sembr/formatter_spec.lua` (329 lines) - SemBr formatter

**Total**: 11 test files, 3,187 lines, 44/44 passing, 6/6 standards enforced

______________________________________________________________________

**Review Completed**: 2025-10-19 **Next Review**: After Phase 1 implementation (Hugo + IWE + AI model tests)
