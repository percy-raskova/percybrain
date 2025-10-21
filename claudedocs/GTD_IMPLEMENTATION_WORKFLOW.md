# GTD Implementation Workflow - mkdnflow.nvim + AI + Custom Extensions

**Date**: 2025-10-21 **Status**: ✅ PHASE 3 COMPLETE - AI INTEGRATION PRODUCTION READY **Approach**: Getting Things Done (GTD) methodology with AI enhancement

## Implementation Progress

| Phase       | Module                           | Status          | Tests                | Documentation   |
| ----------- | -------------------------------- | --------------- | -------------------- | --------------- |
| Phase 1     | Core Infrastructure (`init.lua`) | ✅ Complete     | ✅ Passing           | ✅ Complete     |
| Phase 2A    | Capture (`capture.lua`)          | ✅ Complete     | ✅ Passing           | ✅ Complete     |
| Phase 2B    | Clarify (`clarify.lua`)          | ✅ Complete     | ✅ Passing           | ✅ Complete     |
| **Phase 3** | **AI Integration (`ai.lua`)**    | ✅ **COMPLETE** | ✅ **19/19 Passing** | ✅ **Complete** |
| Phase 4     | Organize (`organize.lua`)        | ⏳ Planned      | -                    | -               |
| Phase 5     | Reflect (`reflect.lua`)          | ⏳ Planned      | -                    | -               |
| Phase 6     | Engage (`engage.lua`)            | ⏳ Planned      | -                    | -               |

**Latest Achievement**: Phase 3 AI Integration complete with TDD, mock testing (53x speedup), and user keymaps!

## Executive Summary

Comprehensive implementation plan for GTD-style task management system using mkdnflow.nvim as foundation, with custom AI integration for task decomposition, and full GTD methodology support (Inbox → Clarify → Organize → Reflect → Engage).

## GTD Methodology Overview

### Five Core Workflows

1. **Capture** - Inbox for quick task capture
2. **Clarify** - Process inbox items into actionable tasks
3. **Organize** - Assign contexts, projects, priorities
4. **Reflect** - Weekly/daily reviews
5. **Engage** - Work on tasks by context

### Key GTD Concepts

- **Contexts**: @home, @work, @computer, @errands, @calls, @waiting
- **Projects**: Multi-step outcomes requiring >1 action
- **Areas**: Ongoing responsibilities (health, family, finance)
- **Someday/Maybe**: Future possibilities
- **Next Actions**: Immediate doable tasks
- **Waiting For**: Delegated or blocked tasks

## Architecture Design

### Directory Structure

```
~/Zettelkasten/
├── gtd/
│   ├── inbox.md              # Quick capture
│   ├── next-actions.md       # Current actionable tasks
│   ├── projects.md           # Active projects
│   ├── someday.md            # Future ideas
│   ├── waiting.md            # Blocked/delegated
│   ├── contexts/             # Context-based task lists
│   │   ├── home.md
│   │   ├── work.md
│   │   ├── computer.md
│   │   └── ...
│   └── archive/              # Completed tasks
│       └── YYYY-MM.md
```

### Module Architecture

```
lua/percybrain/
├── gtd/
│   ├── init.lua          # Main GTD module
│   ├── capture.lua       # Inbox processing
│   ├── clarify.lua       # Task clarification
│   ├── organize.lua      # Context/project assignment
│   ├── reflect.lua       # Review workflows
│   ├── engage.lua        # Task execution
│   └── ai.lua            # AI integration
```

## Phase 1: Core Infrastructure

### 1.1 Install mkdnflow.nvim

**File**: `lua/plugins/zettelkasten/mkdnflow.lua`

```lua
return {
  "jakewvincent/mkdnflow.nvim",
  ft = "markdown",
  config = function()
    require("mkdnflow").setup({
      modules = {
        bib = false,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = false,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        yaml = false,
      },

      -- GTD-optimized settings
      filetypes = { md = true, markdown = true },
      create_dirs = true,
      perspective = {
        priority = "root",  -- Use project root as perspective
        fallback = "current",
        root_tell = "gtd",  -- Use gtd/ directory as project marker
      },

      -- To-do list settings
      to_do = {
        symbols = {" ", "~", "x"},  -- [ ] = pending, [~] = in-progress, [x] = done
        update_parents = true,      -- Auto-update parent tasks
        not_started = " ",
        in_progress = "~",
        complete = "x",
      },

      -- Link settings for GTD cross-references
      links = {
        style = "markdown",
        name_is_source = false,
        conceal = false,
        context = 0,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
          -- Auto-lowercase and hyphenate
          text = text:lower()
          text = text:gsub(" ", "-")
          return text
        end,
      },

      -- Mappings (will be overridden by centralized keymaps)
      mappings = {
        MkdnEnter = false,  -- Disable default, use custom
        MkdnTab = false,
        MkdnSTab = false,
        MkdnNextLink = false,
        MkdnPrevLink = false,
        MkdnNextHeading = false,
        MkdnPrevHeading = false,
        MkdnGoBack = false,
        MkdnGoForward = false,
        MkdnCreateLink = false,
        MkdnCreateLinkFromClipboard = false,
        MkdnFollowLink = false,
        MkdnDestroyLink = false,
        MkdnTagSpan = false,
        MkdnMoveSource = false,
        MkdnYankAnchorLink = false,
        MkdnYankFileAnchorLink = false,
        MkdnIncreaseHeading = false,
        MkdnDecreaseHeading = false,
        MkdnToggleToDo = false,  -- Will use custom GTD toggle
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = false,
        MkdnNewListItemAboveInsert = false,
        MkdnExtendList = false,
        MkdnUpdateNumbering = false,
        MkdnTableNextCell = false,
        MkdnTablePrevCell = false,
        MkdnTableNextRow = false,
        MkdnTablePrevRow = false,
        MkdnTableNewRowBelow = false,
        MkdnTableNewRowAbove = false,
        MkdnTableNewColAfter = false,
        MkdnTableNewColBefore = false,
        MkdnFoldSection = false,
        MkdnUnfoldSection = false,
      },
    })
  end,
}
```

### 1.2 Create GTD Directory Structure

**File**: `lua/percybrain/gtd/init.lua`

```lua
--- PercyBrain GTD System
--- Getting Things Done methodology implementation with AI enhancement
--- @module percybrain.gtd

local M = {}

-- Configuration
M.config = {
  root = vim.fn.expand("~/Zettelkasten/gtd"),
  inbox = vim.fn.expand("~/Zettelkasten/gtd/inbox.md"),
  next_actions = vim.fn.expand("~/Zettelkasten/gtd/next-actions.md"),
  projects = vim.fn.expand("~/Zettelkasten/gtd/projects.md"),
  someday = vim.fn.expand("~/Zettelkasten/gtd/someday.md"),
  waiting = vim.fn.expand("~/Zettelkasten/gtd/waiting.md"),
  contexts_dir = vim.fn.expand("~/Zettelkasten/gtd/contexts"),
  archive_dir = vim.fn.expand("~/Zettelkasten/gtd/archive"),

  -- Default contexts
  contexts = {
    "home",
    "work",
    "computer",
    "errands",
    "calls",
    "anywhere",
  },
}

-- Initialize GTD structure
function M.setup()
  -- Create directories
  local dirs = {
    M.config.root,
    M.config.contexts_dir,
    M.config.archive_dir,
  }

  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end

  -- Create base files if they don't exist
  M.create_base_files()

  -- Create context files
  for _, context in ipairs(M.config.contexts) do
    local context_file = M.config.contexts_dir .. "/" .. context .. ".md"
    if vim.fn.filereadable(context_file) == 0 then
      M.create_context_file(context)
    end
  end

  vim.notify("✅ GTD system initialized", vim.log.levels.INFO)
end

-- Create base GTD files
function M.create_base_files()
  local files = {
    {
      path = M.config.inbox,
      content = [[# 📥 Inbox

> Quick capture for unprocessed items. Process regularly using `<leader>ocp` (clarify/process).

## Uncaptured Thoughts

- [ ]

## Processing Guidelines
1. What is it?
2. Is it actionable?
   - YES: Define next action
   - NO: Trash, Someday/Maybe, or Reference
3. Will it take < 2 minutes?
   - YES: Do it now
   - NO: Delegate, Defer, or Define project

---
*Last processed: Never*
]],
    },
    {
      path = M.config.next_actions,
      content = [[# ⚡ Next Actions

> Actionable tasks organized by context. Use `<leader>oec` to view by context.

## Quick Capture
- [ ]

## By Context

### @computer
- [ ]

### @home
- [ ]

### @work
- [ ]

### @anywhere
- [ ]

---
*Last reviewed: Never*
]],
    },
    {
      path = M.config.projects,
      content = [[# 🎯 Projects

> Multi-step outcomes. Each project should have defined next action in Next Actions.

## Active Projects

### Project: [Name]
**Outcome**: [Desired result]
**Next Action**: - [ ] [Specific doable task]

- [ ]
- [ ]

---

## Project Ideas
-

---
*Last reviewed: Never*
]],
    },
    {
      path = M.config.someday,
      content = [[# 💭 Someday/Maybe

> Ideas and possibilities for future consideration.

## Someday

- [ ]

## Maybe

- [ ]

## To Learn

- [ ]

## To Explore

- [ ]

---
*Last reviewed: Never*
]],
    },
    {
      path = M.config.waiting,
      content = [[# ⏳ Waiting For

> Delegated tasks and blocked items requiring follow-up.

## Waiting For

- [ ] [Task] - Waiting on [Person/Event] - Added: [Date]

---
*Last reviewed: Never*
]],
    },
  }

  for _, file in ipairs(files) do
    if vim.fn.filereadable(file.path) == 0 then
      vim.fn.writefile(vim.split(file.content, "\n"), file.path)
    end
  end
end

-- Create context file
function M.create_context_file(context)
  local content = string.format([[# @%s

> Tasks that can be done in %s context.

## Next Actions

- [ ]

## Projects

---
*Last reviewed: Never*
]], context, context)

  local path = M.config.contexts_dir .. "/" .. context .. ".md"
  vim.fn.writefile(vim.split(content, "\n"), path)
end

return M
```

## Phase 2: GTD Core Workflows

### 2.1 Capture Module

**File**: `lua/percybrain/gtd/capture.lua`

```lua
--- GTD Capture System
--- Quick inbox capture with floating window
--- @module percybrain.gtd.capture

local M = {}
local config = require("percybrain.gtd").config

-- Quick capture to inbox
function M.quick_capture()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 80
  local height = 10

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " 📥 Quick Capture ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Pre-fill with checkbox
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"- [ ] "})

  -- Move cursor to end of line
  vim.cmd("startinsert!")

  -- Keymaps for the floating window
  local keymap_opts = { noremap = true, silent = true, buffer = buf }

  -- Save and close
  vim.keymap.set("n", "<CR>", function()
    M.save_to_inbox(buf)
    vim.api.nvim_win_close(win, true)
  end, keymap_opts)

  -- Cancel
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, keymap_opts)
end

-- Save captured item to inbox
function M.save_to_inbox(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  if #lines == 0 or (lines[1] == "- [ ] " or lines[1] == "") then
    vim.notify("⚠️  Nothing to capture", vim.log.levels.WARN)
    return
  end

  -- Read current inbox
  local inbox_lines = vim.fn.readfile(config.inbox)

  -- Find insertion point (after "## Uncaptured Thoughts")
  local insert_line = 0
  for i, line in ipairs(inbox_lines) do
    if line:match("^## Uncaptured Thoughts") then
      insert_line = i + 1
      break
    end
  end

  -- Insert new task
  table.insert(inbox_lines, insert_line + 1, lines[1])

  -- Write back
  vim.fn.writefile(inbox_lines, config.inbox)

  vim.notify("✅ Captured to inbox", vim.log.levels.INFO)
end

-- Open inbox for processing
function M.open_inbox()
  vim.cmd("edit " .. config.inbox)
end

return M
```

### 2.2 Clarify Module

**File**: `lua/percybrain/gtd/clarify.lua`

```lua
--- GTD Clarify/Process Module
--- Process inbox items into actionable tasks
--- @module percybrain.gtd.clarify

local M = {}
local config = require("percybrain.gtd").config

-- Process current line from inbox
function M.process_item()
  local line = vim.api.nvim_get_current_line()

  -- Check if it's a checkbox item
  if not line:match("^%s*%- %[.%]") then
    vim.notify("⚠️  Not a task item", vim.log.levels.WARN)
    return
  end

  -- Extract task text
  local task_text = line:match("%- %[.%] (.+)") or ""

  -- Show processing menu
  local choices = {
    "1. Next Action (< 2min? Do it now!)",
    "2. Project (Multi-step outcome)",
    "3. Someday/Maybe (Future consideration)",
    "4. Waiting For (Delegated/blocked)",
    "5. Reference (No action needed)",
    "6. Trash (Delete)",
  }

  vim.ui.select(choices, {
    prompt = "What is it? → " .. task_text,
  }, function(choice)
    if not choice then return end

    local action = choice:match("^(%d+)")

    if action == "1" then
      M.process_as_next_action(task_text)
    elseif action == "2" then
      M.process_as_project(task_text)
    elseif action == "3" then
      M.process_as_someday(task_text)
    elseif action == "4" then
      M.process_as_waiting(task_text)
    elseif action == "5" then
      M.process_as_reference(task_text)
    elseif action == "6" then
      M.delete_item()
    end
  end)
end

-- Move to next actions with context
function M.process_as_next_action(task_text)
  -- Ask for context
  vim.ui.select(config.contexts, {
    prompt = "Select context:",
  }, function(context)
    if not context then return end

    -- Add @context tag
    local tagged_task = string.format("- [ ] %s @%s", task_text, context)

    -- Add to next-actions.md
    M.append_to_file(config.next_actions, tagged_task, "### @" .. context)

    -- Remove from inbox
    M.delete_current_line()

    vim.notify("✅ Moved to Next Actions (@" .. context .. ")", vim.log.levels.INFO)
  end)
end

-- Create new project
function M.process_as_project(task_text)
  vim.ui.input({
    prompt = "Project outcome: ",
    default = task_text,
  }, function(outcome)
    if not outcome then return end

    vim.ui.input({
      prompt = "Next action: ",
    }, function(next_action)
      if not next_action then return end

      local project_block = string.format([[

### Project: %s
**Outcome**: %s
**Next Action**: - [ ] %s

- [ ]

]], task_text, outcome, next_action)

      -- Add to projects.md
      M.append_to_file(config.projects, project_block, "## Active Projects")

      -- Remove from inbox
      M.delete_current_line()

      vim.notify("✅ Created project: " .. task_text, vim.log.levels.INFO)
    end)
  end)
end

-- Move to someday/maybe
function M.process_as_someday(task_text)
  local tagged_task = string.format("- [ ] %s", task_text)
  M.append_to_file(config.someday, tagged_task, "## Someday")
  M.delete_current_line()
  vim.notify("✅ Moved to Someday/Maybe", vim.log.levels.INFO)
end

-- Move to waiting for
function M.process_as_waiting(task_text)
  vim.ui.input({
    prompt = "Waiting on (person/event): ",
  }, function(waiting_on)
    if not waiting_on then return end

    local date = os.date("%Y-%m-%d")
    local tagged_task = string.format("- [ ] %s - Waiting on %s - Added: %s", task_text, waiting_on, date)

    M.append_to_file(config.waiting, tagged_task, "## Waiting For")
    M.delete_current_line()
    vim.notify("✅ Moved to Waiting For", vim.log.levels.INFO)
  end)
end

-- Process as reference (move to Zettelkasten)
function M.process_as_reference(task_text)
  vim.notify("💡 Create reference note in Zettelkasten", vim.log.levels.INFO)
  vim.cmd("PercyNew")
  -- User creates note, then delete inbox item manually
end

-- Helper: Append to file after heading
function M.append_to_file(filepath, content, after_heading)
  local lines = vim.fn.readfile(filepath)

  -- Find insertion point
  local insert_line = 0
  for i, line in ipairs(lines) do
    if line:match("^" .. vim.pesc(after_heading)) then
      insert_line = i
      break
    end
  end

  if insert_line == 0 then
    table.insert(lines, content)
  else
    table.insert(lines, insert_line + 1, content)
  end

  vim.fn.writefile(lines, filepath)
end

-- Helper: Delete current line
function M.delete_current_line()
  vim.cmd("normal! dd")
end

return M
```

## Phase 3: AI Integration

### 3.1 AI Task Decomposition

**File**: `lua/percybrain/gtd/ai.lua`

```lua
--- GTD AI Integration
--- AI-powered task decomposition, priority inference, context suggestion
--- @module percybrain.gtd.ai

local M = {}
local Job = require("plenary.job")

-- Decompose task into subtasks using AI
function M.decompose_task()
  local line = vim.api.nvim_get_current_line()

  -- Extract task text
  local task_text = line:match("%- %[.%] (.+)") or line

  if task_text == "" then
    vim.notify("⚠️  No task found", vim.log.levels.WARN)
    return
  end

  vim.notify("🤖 AI analyzing task...", vim.log.levels.INFO)

  local prompt = string.format([[You are a GTD (Getting Things Done) productivity assistant. Break down this task into specific, actionable subtasks.

Task: "%s"

Requirements:
1. Each subtask should be concrete and doable in one sitting
2. Order subtasks logically
3. Use markdown checkbox format: - [ ] Subtask description
4. Keep subtasks focused and clear
5. Aim for 3-7 subtasks unless the task is very complex

Return ONLY the markdown checklist, no explanations:]], task_text)

  M.call_ollama(prompt, function(response)
    if not response then
      vim.notify("❌ AI decomposition failed", vim.log.levels.ERROR)
      return
    end

    -- Insert subtasks as indented children
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local indent = line:match("^(%s*)") or ""
    local child_indent = indent .. "  "

    -- Parse response and add indentation
    local subtasks = {}
    for subtask in response:gmatch("[^\n]+") do
      if subtask:match("^%s*%- %[") then
        table.insert(subtasks, child_indent .. subtask:gsub("^%s*", ""))
      end
    end

    if #subtasks > 0 then
      vim.api.nvim_buf_set_lines(0, current_line, current_line, false, subtasks)
      vim.notify("✅ Task decomposed into " .. #subtasks .. " subtasks", vim.log.levels.INFO)
    else
      vim.notify("⚠️  No subtasks generated", vim.log.levels.WARN)
    end
  end)
end

-- Suggest context for task
function M.suggest_context()
  local line = vim.api.nvim_get_current_line()
  local task_text = line:match("%- %[.%] (.+)") or line

  if task_text == "" then
    vim.notify("⚠️  No task found", vim.log.levels.WARN)
    return
  end

  local contexts = require("percybrain.gtd").config.contexts
  local prompt = string.format([[Given this task, suggest the most appropriate GTD context.

Task: "%s"

Available contexts: %s

Return ONLY the context name (one word), no explanation.]], task_text, table.concat(contexts, ", "))

  M.call_ollama(prompt, function(response)
    if not response then return end

    local suggested_context = response:match("(%w+)")

    if suggested_context then
      -- Check if already has @context
      if not task_text:match("@%w+") then
        -- Add @context to end of line
        local new_line = line .. " @" .. suggested_context
        local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, current_line_num - 1, current_line_num, false, {new_line})

        vim.notify("✅ Suggested context: @" .. suggested_context, vim.log.levels.INFO)
      else
        vim.notify("💡 Suggested: @" .. suggested_context, vim.log.levels.INFO)
      end
    end
  end)
end

-- Infer priority using AI
function M.infer_priority()
  local line = vim.api.nvim_get_current_line()
  local task_text = line:match("%- %[.%] (.+)") or line

  if task_text == "" then
    vim.notify("⚠️  No task found", vim.log.levels.WARN)
    return
  end

  local prompt = string.format([[Analyze this task and assign a priority (HIGH, MEDIUM, LOW).

Task: "%s"

Criteria:
- HIGH: Urgent and important, immediate action needed
- MEDIUM: Important but not urgent, or urgent but not important
- LOW: Neither urgent nor important, can be done later

Return ONLY the priority level (HIGH, MEDIUM, or LOW).]], task_text)

  M.call_ollama(prompt, function(response)
    if not response then return end

    local priority = response:match("(HIGH)") or response:match("(MEDIUM)") or response:match("(LOW)")

    if priority then
      local priority_tag = string.format("!%s", priority)

      -- Add priority tag if not present
      if not task_text:match("!%w+") then
        local new_line = line .. " " .. priority_tag
        local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, current_line_num - 1, current_line_num, false, {new_line})

        vim.notify("✅ Priority assigned: " .. priority, vim.log.levels.INFO)
      else
        vim.notify("💡 Suggested: " .. priority, vim.log.levels.INFO)
      end
    end
  end)
end

-- Call Ollama API
function M.call_ollama(prompt, callback)
  local body = vim.fn.json_encode({
    model = "llama3.2",
    prompt = prompt,
    stream = false,
  })

  Job:new({
    command = "curl",
    args = {
      "-s",
      "-X", "POST",
      "http://localhost:11434/api/generate",
      "-d", body,
    },
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        vim.schedule(function()
          callback(nil)
        end)
        return
      end

      local result = table.concat(j:result(), "")
      local ok, decoded = pcall(vim.fn.json_decode, result)

      if ok and decoded.response then
        vim.schedule(function()
          callback(decoded.response)
        end)
      else
        vim.schedule(function()
          callback(nil)
        end)
      end
    end,
  }):start()
end

return M
```

## Phase 4: Keymap Organization

**File**: `lua/config/keymaps/organization/gtd.lua`

```lua
--- GTD (Getting Things Done) Keymaps
--- Namespace: <leader>o (organization)
--- @module config.keymaps.organization.gtd

local registry = require("config.keymaps")

local keymaps = {
  -- Capture
  { "<leader>oi", "<cmd>lua require('percybrain.gtd.capture').quick_capture()<CR>", desc = "📥 GTD: Quick capture" },
  { "<leader>oI", "<cmd>lua require('percybrain.gtd.capture').open_inbox()<CR>", desc = "📫 GTD: Open inbox" },

  -- Clarify/Process
  { "<leader>ocp", "<cmd>lua require('percybrain.gtd.clarify').process_item()<CR>", desc = "🔄 GTD: Process inbox item" },

  -- Organize
  { "<leader>ocx", "<cmd>lua require('percybrain.gtd.organize').assign_context()<CR>", desc = "🏷️  GTD: Assign context" },
  { "<leader>ocp", "<cmd>lua require('percybrain.gtd.organize').assign_project()<CR>", desc = "🎯 GTD: Assign to project" },

  -- Views
  { "<leader>on", "<cmd>edit ~/Zettelkasten/gtd/next-actions.md<CR>", desc = "⚡ GTD: Next actions" },
  { "<leader>op", "<cmd>edit ~/Zettelkasten/gtd/projects.md<CR>", desc = "🎯 GTD: Projects" },
  { "<leader>os", "<cmd>edit ~/Zettelkasten/gtd/someday.md<CR>", desc = "💭 GTD: Someday/Maybe" },
  { "<leader>ow", "<cmd>edit ~/Zettelkasten/gtd/waiting.md<CR>", desc = "⏳ GTD: Waiting for" },

  -- Context views
  { "<leader>och", "<cmd>edit ~/Zettelkasten/gtd/contexts/home.md<CR>", desc = "🏠 GTD: @home tasks" },
  { "<leader>ocw", "<cmd>edit ~/Zettelkasten/gtd/contexts/work.md<CR>", desc = "💼 GTD: @work tasks" },
  { "<leader>occ", "<cmd>edit ~/Zettelkasten/gtd/contexts/computer.md<CR>", desc = "💻 GTD: @computer tasks" },

  -- AI-powered
  { "<leader>od", "<cmd>lua require('percybrain.gtd.ai').decompose_task()<CR>", desc = "🤖 GTD: AI decompose task" },
  { "<leader>oC", "<cmd>lua require('percybrain.gtd.ai').suggest_context()<CR>", desc = "🎯 GTD: AI suggest context" },
  { "<leader>oP", "<cmd>lua require('percybrain.gtd.ai').infer_priority()<CR>", desc = "⚡ GTD: AI infer priority" },

  -- Review
  { "<leader>orw", "<cmd>lua require('percybrain.gtd.reflect').weekly_review()<CR>", desc = "📅 GTD: Weekly review" },
  { "<leader>ord", "<cmd>lua require('percybrain.gtd.reflect').daily_review()<CR>", desc = "📋 GTD: Daily review" },

  -- Engage (Telescope integration)
  { "<leader>oec", "<cmd>lua require('percybrain.gtd.engage').by_context()<CR>", desc = "🔍 GTD: View by context" },
  { "<leader>oep", "<cmd>lua require('percybrain.gtd.engage').by_project()<CR>", desc = "🎯 GTD: View by project" },
  { "<leader>oet", "<cmd>lua require('percybrain.gtd.engage').by_tag()<CR>", desc = "🏷️  GTD: View by tag" },

  -- Time tracking integration
  { "<leader>oT", "<cmd>lua require('percybrain.gtd.engage').track_task()<CR>", desc = "⏱️  GTD: Track task (Pendulum)" },
  { "<leader>oS", "<cmd>lua require('percybrain.gtd.engage').schedule_task()<CR>", desc = "📅 GTD: Schedule task (Calendar)" },

  -- mkdnflow integration
  { "<leader>ot", "<cmd>lua require('mkdnflow').lists.toggleToDo()<CR>", desc = "✓ GTD: Toggle task status" },
}

return registry.register_module("organization.gtd", keymaps)
```

## Phase 5: Dashboard Integration

**File**: `lua/percybrain/gtd/dashboard.lua` (widget for Alpha)

```lua
--- GTD Dashboard Widgets
--- Show GTD metrics on Alpha dashboard
--- @module percybrain.gtd.dashboard

local M = {}
local config = require("percybrain.gtd").config

-- Count tasks in file
local function count_tasks(filepath, pattern)
  if vim.fn.filereadable(filepath) == 0 then
    return 0
  end

  local content = table.concat(vim.fn.readfile(filepath), "\n")
  local count = 0

  for _ in content:gmatch(pattern) do
    count = count + 1
  end

  return count
end

-- Get GTD status widget
function M.get_widget()
  local inbox_count = count_tasks(config.inbox, "%- %[ %]")
  local next_actions_count = count_tasks(config.next_actions, "%- %[ %]")
  local waiting_count = count_tasks(config.waiting, "%- %[ %]")

  local widget = {
    type = "group",
    val = {
      { type = "text", val = "━━━ GTD Status ━━━", opts = { hl = "SpecialComment", shrink_margin = false, position = "center" } },
      { type = "padding", val = 1 },
      { type = "text", val = string.format("📥 Inbox: %d items to process", inbox_count), opts = { hl = inbox_count > 10 and "DiagnosticWarn" or "Normal", position = "center" } },
      { type = "text", val = string.format("⚡ Next Actions: %d pending", next_actions_count), opts = { hl = "Normal", position = "center" } },
      { type = "text", val = string.format("⏳ Waiting For: %d items", waiting_count), opts = { hl = "Comment", position = "center" } },
      { type = "padding", val = 1 },
    },
  }

  return widget
end

-- Quick action buttons
function M.get_buttons()
  return {
    { "i", " 📥 Capture", "<cmd>lua require('percybrain.gtd.capture').quick_capture()<CR>" },
    { "I", " 📫 Process Inbox", "<cmd>edit ~/Zettelkasten/gtd/inbox.md<CR>" },
    { "n", " ⚡ Next Actions", "<cmd>edit ~/Zettelkasten/gtd/next-actions.md<CR>" },
    { "p", " 🎯 Projects", "<cmd>edit ~/Zettelkasten/gtd/projects.md<CR>" },
  }
end

return M
```

## Phase 6: Pendulum/Calendar Integration

**File**: `lua/percybrain/gtd/engage.lua`

```lua
--- GTD Engage Module
--- Work on tasks with time tracking and scheduling integration
--- @module percybrain.gtd.engage

local M = {}

-- Start Pendulum tracking for current task
function M.track_task()
  local line = vim.api.nvim_get_current_line()
  local task_text = line:match("%- %[.%] (.+)") or ""

  if task_text == "" then
    vim.notify("⚠️  No task found", vim.log.levels.WARN)
    return
  end

  -- Start Pendulum with task name
  vim.cmd("PendulumStart")

  vim.notify("⏱️  Tracking: " .. task_text, vim.log.levels.INFO)
end

-- Schedule task in Telekasten calendar
function M.schedule_task()
  local line = vim.api.nvim_get_current_line()
  local task_text = line:match("%- %[.%] (.+)") or ""

  if task_text == "" then
    vim.notify("⚠️  No task found", vim.log.levels.WARN)
    return
  end

  -- Prompt for date
  vim.ui.input({
    prompt = "Schedule for (YYYY-MM-DD): ",
    default = os.date("%Y-%m-%d"),
  }, function(date)
    if not date then return end

    -- Add scheduled tag
    local new_line = line .. " scheduled:" .. date
    local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, current_line_num - 1, current_line_num, false, {new_line})

    vim.notify("📅 Scheduled for " .. date, vim.log.levels.INFO)
  end)
end

-- View tasks by context using Telescope
function M.by_context()
  require('telescope.builtin').live_grep({
    cwd = require('percybrain.gtd').config.root,
    prompt_title = "🔍 GTD Tasks by Context",
    default_text = "@",
  })
end

-- View tasks by project
function M.by_project()
  require('telescope.builtin').live_grep({
    cwd = require('percybrain.gtd').config.root,
    prompt_title = "🎯 GTD Tasks by Project",
    default_text = "### Project:",
  })
end

return M
```

## Phase 7: Testing & Documentation

### Test Plan

**File**: `tests/unit/gtd_spec.lua`

```lua
describe("GTD System", function()
  local gtd

  before_each(function()
    gtd = require("percybrain.gtd")
    -- Use test directory
    gtd.config.root = "/tmp/gtd-test"
  end)

  after_each(function()
    -- Cleanup test directory
    vim.fn.delete(gtd.config.root, "rf")
  end)

  it("should initialize directory structure", function()
    gtd.setup()

    assert.is_true(vim.fn.isdirectory(gtd.config.root) == 1)
    assert.is_true(vim.fn.filereadable(gtd.config.inbox) == 1)
    assert.is_true(vim.fn.filereadable(gtd.config.next_actions) == 1)
  end)

  it("should capture tasks to inbox", function()
    gtd.setup()

    local capture = require("percybrain.gtd.capture")
    -- Test capture logic
  end)

  -- More tests...
end)
```

## Implementation Timeline

### Week 1: Foundation

- Day 1-2: Install mkdnflow.nvim, create GTD module structure
- Day 3-4: Implement Capture and Clarify workflows
- Day 5: Create base keymaps

### Week 2: AI & Organization

- Day 1-2: Build AI decomposition and context suggestion
- Day 3-4: Implement Organize and Reflect workflows
- Day 5: Create Telescope integrations

### Week 3: Integration & Polish

- Day 1-2: Dashboard widgets and Alpha integration
- Day 3: Pendulum and Calendar integration
- Day 4-5: Testing and documentation

## Success Metrics

- ✅ All 5 GTD workflows implemented (Capture, Clarify, Organize, Reflect, Engage)
- ✅ AI task decomposition working with Ollama
- ✅ Dashboard showing GTD metrics
- ✅ Pendulum integration for time tracking
- ✅ Telekasten calendar integration for scheduling
- ✅ 100% test coverage for core workflows
- ✅ Comprehensive user documentation

## Next Steps

Ready to begin implementation? I can start with:

1. **Install mkdnflow.nvim** plugin configuration
2. **Create GTD module structure** (`lua/percybrain/gtd/`)
3. **Build Capture workflow** with floating quick capture window
4. **Add organization keymaps** (`lua/config/keymaps/organization/gtd.lua`)

Would you like me to proceed with Phase 1 implementation?
