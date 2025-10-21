--- GTD Clarify UI Module
---
--- Interactive UI for GTD Clarify workflow - the second step in GTD methodology.
--- "Clarify what each item is and what to do about it. Decide if it's actionable.
--- If it is, decide the next action and project (if needed). If it isn't,
--- decide if it's reference, someday/maybe, or trash." - David Allen
---
--- Features:
--- - Interactive decision prompts with clear GTD terminology
--- - Progressive enhancement (process one item at a time)
--- - Visual feedback with notifications and progress tracking
--- - Recursive workflow for batch inbox processing
--- - Integration with core clarify module for routing logic
---
--- GTD Clarify Principles (UI Implementation):
--- 1. Clear decisions: Present actionable vs non-actionable choice first
--- 2. Progressive disclosure: Only ask relevant follow-up questions
--- 3. No back-pedaling: Once decision is made, item is processed
--- 4. Visual feedback: Show progress and completion status
--- 5. Batch processing: Option to continue with next item immediately
---
--- @module percybrain.gtd.clarify_ui
--- @author PercyBrain
--- @license MIT

local M = {}

-- ============================================================================
-- Private Helper Functions
-- ============================================================================

--- Build decision structure from user prompts
---
--- Converts interactive prompt responses into decision structure compatible
--- with clarify.clarify_item() function. Handles both actionable and non-actionable paths.
---
--- Prompt Structure:
--- ```lua
--- {
---   actionable = "y"|"n",
---   action_type = "1"|"2"|"3",  -- if actionable
---   context = "home"|"work"|...,  -- if next_action
---   project_outcome = "desired outcome",  -- if project
---   waiting_for_who = "person name",  -- if waiting_for
---   route = "1"|"2"|"3",  -- if not actionable
--- }
--- ```
---
--- @param prompts table Table with prompt responses (actionable, action_type, context, etc.)
--- @return table decision Decision structure for clarify.clarify_item()
--- @private
function M._build_decision_from_prompts(prompts)
  local decision = {}

  -- Determine if actionable
  decision.actionable = prompts.actionable == "y" or prompts.actionable == "Y"

  if decision.actionable then
    -- Convert numeric action type to string
    if prompts.action_type == "1" then
      decision.action_type = "next_action"
      decision.context = prompts.context ~= "" and prompts.context or nil
    elseif prompts.action_type == "2" then
      decision.action_type = "project"
      decision.project_outcome = prompts.project_outcome
    elseif prompts.action_type == "3" then
      decision.action_type = "waiting_for"
      decision.waiting_for_who = prompts.waiting_for_who
    end
  else
    -- Convert numeric route to string
    if prompts.route == "1" then
      decision.route = "reference"
    elseif prompts.route == "2" then
      decision.route = "someday_maybe"
    elseif prompts.route == "3" then
      decision.route = "trash"
    end
  end

  return decision
end

--- Get next unprocessed item from inbox
---
--- Retrieves the first item from inbox using clarify.get_inbox_items().
--- Returns nil if inbox is empty, signaling completion of clarify session.
---
--- @return string|nil Next inbox item (full format with checkbox and timestamp) or nil if empty
--- @private
function M._get_next_item()
  local clarify = require("percybrain.gtd.clarify")
  local items = clarify.get_inbox_items()

  if #items == 0 then
    return nil
  end

  return items[1]
end

--- Extract clean text from inbox item
---
--- Removes checkbox, timestamp, and formatting to get just the task text.
--- Handles format: "- [ ] Task text (captured: YYYY-MM-DD HH:MM)"
---
--- Implementation: Pattern matches everything between checkbox and "(captured:"
--- Falls back to simple checkbox removal if pattern doesn't match.
---
--- @param raw_item string Raw inbox item line (e.g., "- [ ] Buy groceries (captured: 2025-10-21 14:30)")
--- @return string Clean task text (e.g., "Buy groceries")
--- @private
function M._extract_item_text(raw_item)
  -- Pattern: "- [ ] Task text (captured: timestamp)"
  -- Extract everything between checkbox and (captured:
  local text = raw_item:match("%-%s*%[%s*%]%s*(.-)%s*%(captured:")

  if not text then
    -- Fallback: just remove checkbox and trim
    text = raw_item:gsub("^%-%s*%[%s*%]%s*", "")
  end

  return text
end

-- ============================================================================
-- Public API Functions
-- ============================================================================

--- Process next inbox item interactively
---
--- Main entry point for interactive clarify workflow. Implements GTD clarify
--- methodology with progressive disclosure and visual feedback.
---
--- Workflow:
--- 1. Get next inbox item (or show completion if empty)
--- 2. Display item text with visual separator
--- 3. Prompt for actionable decision (y/n)
--- 4. If actionable: prompt for action type (next_action/project/waiting_for)
--- 5. Collect context-specific details (context, outcome, person)
--- 6. If not actionable: prompt for route (reference/someday_maybe/trash)
--- 7. Build decision structure and call clarify.clarify_item()
--- 8. Show completion notification with remaining count
--- 9. Prompt to continue with next item (recursive)
---
--- GTD Principles:
--- - Process one item at a time (no batch decisions)
--- - Never put back in inbox (always make a decision)
--- - Actionable first (core GTD question)
--- - Progressive disclosure (only ask relevant questions)
---
--- @usage
--- -- From command line:
--- :lua require("percybrain.gtd.clarify_ui").process_next()
---
--- -- From keymap:
--- vim.keymap.set("n", "<leader>gp", function()
---   require("percybrain.gtd.clarify_ui").process_next()
--- end, { desc = "GTD process inbox" })
function M.process_next()
  -- Get next item
  local item = M._get_next_item()

  if not item then
    vim.notify("✅ Inbox is empty! All items processed.", vim.log.levels.INFO)
    return
  end

  -- Extract clean text
  local text = M._extract_item_text(item)

  -- Show item
  print(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  )
  print("📥 Inbox Item: " .. text)
  print(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  )
  print("")

  -- Collect prompts
  local prompts = {}

  -- Actionable decision
  prompts.actionable = vim.fn.input("Is this actionable? (y/n): ")
  print("") -- newline after input

  if prompts.actionable == "y" or prompts.actionable == "Y" then
    -- Actionable item - get action type
    print("\nAction Types:")
    print("  1. Next Action (specific physical action)")
    print("  2. Project (multi-step outcome)")
    print("  3. Waiting For (delegated to someone)")
    print("")
    prompts.action_type = vim.fn.input("Action type (1/2/3): ")
    print("") -- newline

    if prompts.action_type == "1" then
      -- Next action - optional context
      print("\nContexts: home, work, computer, phone, errands")
      prompts.context = vim.fn.input("Context (optional): ")
      print("") -- newline
    elseif prompts.action_type == "2" then
      -- Project - required outcome
      prompts.project_outcome = vim.fn.input("Desired outcome: ")
      print("") -- newline
    elseif prompts.action_type == "3" then
      -- Waiting for - required person
      prompts.waiting_for_who = vim.fn.input("Waiting for (person): ")
      print("") -- newline
    end
  else
    -- Non-actionable - get route
    print("\nNon-Actionable Routes:")
    print("  1. Reference (save for later)")
    print("  2. Someday/Maybe (future idea)")
    print("  3. Trash (delete)")
    print("")
    prompts.route = vim.fn.input("Route (1/2/3): ")
    print("") -- newline
  end

  -- Build decision and process
  local decision = M._build_decision_from_prompts(prompts)
  local clarify = require("percybrain.gtd.clarify")
  clarify.clarify_item(text, decision)

  -- Show completion
  local remaining = clarify.inbox_count()
  vim.notify(string.format("✅ Item processed! %d items remaining in inbox.", remaining), vim.log.levels.INFO)

  -- Continue processing?
  if remaining > 0 then
    local continue = vim.fn.input("\nProcess next item? (y/n): ")
    if continue == "y" or continue == "Y" then
      M.process_next() -- Recursive call
    end
  end
end

return M
