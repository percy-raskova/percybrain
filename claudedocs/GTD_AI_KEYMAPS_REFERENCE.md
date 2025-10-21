# GTD AI Keymaps Reference

**Phase 3 AI Integration** - Keybindings for AI-powered GTD enhancements

## Quick Reference

All GTD keymaps use the `<leader>o` namespace (organization):

| Keymap       | Function        | Description                                                 |
| ------------ | --------------- | ----------------------------------------------------------- |
| `<leader>od` | Decompose Task  | 🤖 Break down complex task into subtasks using AI           |
| `<leader>ox` | Suggest Context | 🏷️ AI suggests appropriate GTD context (@home, @work, etc.) |
| `<leader>or` | Infer Priority  | ⚡ AI assigns priority level (HIGH/MEDIUM/LOW)              |

## Existing GTD Keymaps

| Keymap       | Function      | Description                      |
| ------------ | ------------- | -------------------------------- |
| `<leader>oc` | Quick Capture | 📥 Capture item to inbox         |
| `<leader>op` | Process Inbox | 🔄 Clarify inbox items           |
| `<leader>oi` | Inbox Count   | 📬 Show number of items in inbox |

## Usage Examples

### Decompose Task (`<leader>od`)

**Use when**: You have a complex task that needs breaking down

**Workflow**:

1. Position cursor on task line: `- [ ] Build a website`
2. Press `<leader>od`
3. AI analyzes task and generates subtasks
4. Subtasks inserted as indented children

**Example**:

```markdown
Before:
- [ ] Build a website

After:
- [ ] Build a website
  - [ ] Design wireframes and user flows
  - [ ] Set up development environment
  - [ ] Implement frontend components
  - [ ] Build backend API endpoints
  - [ ] Add authentication and authorization
  - [ ] Write tests and documentation
  - [ ] Deploy to production
```

### Suggest Context (`<leader>ox`)

**Use when**: Task needs a GTD context tag

**Workflow**:

1. Position cursor on task line: `- [ ] Fix kitchen sink`
2. Press `<leader>ox`
3. AI analyzes task and suggests context
4. Context tag appended to line

**Example**:

```markdown
Before:
- [ ] Fix kitchen sink

After:
- [ ] Fix kitchen sink @home
```

**Valid Contexts**:

- `@home` - Home-related tasks
- `@work` - Work/office tasks
- `@computer` - Computer-required tasks
- `@phone` - Phone calls
- `@errands` - Shopping, errands

### Infer Priority (`<leader>or`)

**Use when**: Task needs priority classification

**Workflow**:

1. Position cursor on task line: `- [ ] Submit tax return`
2. Press `<leader>or`
3. AI analyzes urgency and importance
4. Priority tag appended to line

**Example**:

```markdown
Before:
- [ ] Submit tax return

After:
- [ ] Submit tax return !HIGH
```

**Priority Levels**:

- `!HIGH` - Urgent and important
- `!MEDIUM` - Important or urgent (not both)
- `!LOW` - Neither urgent nor important

## Combining AI Features

You can use multiple AI features on the same task:

```markdown
1. Start: - [ ] Fix production bug
2. <leader>od → Decompose into subtasks
3. <leader>ox → Add context (@computer)
4. <leader>or → Add priority (!HIGH)

Result:
- [ ] Fix production bug @computer !HIGH
  - [ ] Reproduce error in local environment
  - [ ] Identify root cause with debugging
  - [ ] Implement fix and add regression test
  - [ ] Deploy fix to production
  - [ ] Monitor for issues
```

## AI Model

**Model**: llama3.2 (via Ollama) **Endpoint**: http://localhost:11434/api/generate **Requirement**: Ollama must be running locally

### Check Ollama Status

```bash
# Verify Ollama is running
ollama list

# Start Ollama service if needed
ollama serve

# Pull model if not installed
ollama pull llama3.2
```

## Troubleshooting

**"Failed to connect to Ollama"**:

- Ensure Ollama is running: `ollama serve`
- Verify model is installed: `ollama list`
- Check endpoint: http://localhost:11434

**"No task found on current line"**:

- Ensure cursor is on a line with text
- Task detection works for both checkbox (`- [ ]`) and plain text

**"Task already has context/priority tag"**:

- AI won't add duplicate tags
- Remove existing tag first if you want AI to suggest new one

**Slow response**:

- AI processing typically takes 3-10 seconds
- Complex tasks may take longer
- Check Ollama resource usage

## Technical Details

**Implementation**: `lua/percybrain/gtd/ai.lua` **Tests**: `tests/unit/gtd/gtd_ai_spec.lua` (19/19 passing) **Test Performance**: 0.386s with mock Ollama, ~20s with real Ollama

**Architecture**:

- Async API calls via plenary.job
- Non-blocking UI updates via vim.schedule()
- Context-aware prompts for accurate suggestions
- Graceful error handling for offline scenarios

## See Also

- `GTD_IMPLEMENTATION_WORKFLOW.md` - Complete GTD implementation plan
- `GTD_PHASE3_AI_INTEGRATION_COMPLETE.md` - Phase 3 completion report (coming soon)
- `tests/helpers/README_MOCK_OLLAMA.md` - Mock testing documentation
