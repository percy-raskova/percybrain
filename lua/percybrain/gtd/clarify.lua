--- GTD Clarify Module
---
--- Implements David Allen's GTD Clarify workflow - the second step in GTD methodology.
--- "Clarify what each item is and what to do about it. Decide if it's actionable.
--- If it is, decide the next action and project (if needed). If it isn't,
--- decide if it's reference, someday/maybe, or trash." - David Allen
---
--- Features:
--- - Decision-driven routing for inbox items
--- - Support for next actions, projects, waiting-for, reference, someday/maybe
--- - Context-based action routing (@home, @work, @computer, @phone, @errands)
--- - Inbox management utilities (get items, remove items, count)
---
--- GTD Clarify Principles:
--- 1. Process inbox items one at a time
--- 2. Never put items back in inbox - make a decision
--- 3. Actionable? → Next action, project, or waiting-for
--- 4. Not actionable? → Reference, someday/maybe, or trash
--- 5. Less than 2 minutes? → Do it now (not implemented here)
---
--- @module percybrain.gtd.clarify
--- @author PercyBrain
--- @license MIT

local M = {}

-- ============================================================================
-- Private Helper Functions
-- ============================================================================

--- Get inbox file path from GTD core module
---
--- @return string Absolute path to inbox.md
--- @private
local function _get_inbox_path()
  local gtd = require("percybrain.gtd")
  return gtd.get_inbox_path()
end

--- Get path to a GTD file
---
--- @param filename string File name relative to GTD root (e.g., "next-actions.md" or "contexts/home.md")
--- @return string Absolute path to the file
--- @private
local function _get_gtd_file_path(filename)
  local gtd = require("percybrain.gtd")
  local gtd_root = gtd.get_gtd_root()
  return gtd_root .. "/" .. filename
end

--- Append lines to a GTD file
---
--- Implementation: Read-modify-write to ensure atomicity.
--- Same pattern as Capture module for data integrity.
---
--- @param file_path string Absolute path to the file
--- @param lines table Array of lines to append
--- @private
local function _append_to_file(file_path, lines)
  -- Read existing content
  local file = io.open(file_path, "r")
  local existing_content = {}
  if file then
    for line in file:lines() do
      table.insert(existing_content, line)
    end
    file:close()
  end

  -- Append new lines
  for _, line in ipairs(lines) do
    table.insert(existing_content, line)
  end

  -- Write back to file
  file = io.open(file_path, "w")
  if file then
    for _, line in ipairs(existing_content) do
      file:write(line .. "\n")
    end
    file:close()
  end
end

--- Route to next-actions.md or context file
--- @param text string Item text to route
--- @param context string|nil Context (@home, @work, etc.)
local function _route_next_action(text, context)
  local formatted = "- [ ] " .. text

  if context then
    -- Route to context file
    local context_file = _get_gtd_file_path("contexts/" .. context .. ".md")
    _append_to_file(context_file, { formatted })
  else
    -- Route to next-actions.md
    local next_actions_file = _get_gtd_file_path("next-actions.md")
    _append_to_file(next_actions_file, { formatted })
  end
end

--- Route to projects.md with outcome
--- @param text string Project title
--- @param outcome string Desired outcome
local function _route_project(text, outcome)
  local lines = {
    "",
    "## " .. text,
    "**Outcome**: " .. outcome,
  }

  local projects_file = _get_gtd_file_path("projects.md")
  _append_to_file(projects_file, lines)
end

--- Route to waiting-for.md
--- @param text string Item text
--- @param who string Person or entity
local function _route_waiting_for(text, who)
  local date = os.date("%Y-%m-%d")
  local formatted = "- [ ] " .. who .. ": " .. text .. " (" .. date .. ")"

  local waiting_file = _get_gtd_file_path("waiting-for.md")
  _append_to_file(waiting_file, { formatted })
end

--- Route to reference.md
--- @param text string Reference material
local function _route_reference(text)
  local formatted = "- " .. text

  local reference_file = _get_gtd_file_path("reference.md")
  _append_to_file(reference_file, { formatted })
end

--- Route to someday-maybe.md
--- @param text string Future idea
local function _route_someday_maybe(text)
  local formatted = "- [ ] " .. text

  local someday_file = _get_gtd_file_path("someday-maybe.md")
  _append_to_file(someday_file, { formatted })
end

-- ============================================================================
-- Public API Functions
-- ============================================================================

--- Get all inbox items as array
---
--- Returns all checkbox-formatted items from inbox.md.
--- Filters out headers and empty lines.
---
--- @return table Array of inbox item strings (includes full checkbox format)
--- @usage
--- local clarify = require("percybrain.gtd.clarify")
--- local items = clarify.get_inbox_items()
--- for _, item in ipairs(items) do
---   print(item)  -- "- [ ] Task name (captured: YYYY-MM-DD HH:MM)"
--- end
function M.get_inbox_items()
  local inbox_path = _get_inbox_path()
  local file = io.open(inbox_path, "r")
  local items = {}

  if file then
    for line in file:lines() do
      -- Only include checkbox items (filter out headers/empty lines)
      if line:match("^%- %[") then
        table.insert(items, line)
      end
    end
    file:close()
  end

  return items
end

--- Remove specific item from inbox
---
--- Searches for items containing the specified text and removes them.
--- Uses pattern escaping to handle special characters safely.
---
--- @param text string The text to search for and remove (case-sensitive substring match)
--- @usage
--- local clarify = require("percybrain.gtd.clarify")
--- clarify.remove_inbox_item("Buy groceries")  -- Removes item with this text
function M.remove_inbox_item(text)
  local inbox_path = _get_inbox_path()
  local file = io.open(inbox_path, "r")
  local lines = {}

  if file then
    for line in file:lines() do
      -- Keep lines that don't contain the text
      if not line:match(vim.pesc(text)) then
        table.insert(lines, line)
      end
    end
    file:close()
  end

  -- Write back filtered content
  file = io.open(inbox_path, "w")
  if file then
    for _, line in ipairs(lines) do
      file:write(line .. "\n")
    end
    file:close()
  end
end

--- Count remaining inbox items
---
--- Returns the count of unprocessed checkbox items in inbox.
--- Useful for tracking progress during clarify sessions.
---
--- @return number Count of checkbox items in inbox
--- @usage
--- local clarify = require("percybrain.gtd.clarify")
--- local count = clarify.inbox_count()
--- print("Items remaining: " .. count)
function M.inbox_count()
  local items = M.get_inbox_items()
  return #items
end

--- Clarify an inbox item based on decision structure
---
--- Core clarify function that routes inbox items to appropriate GTD files
--- based on the decision structure. Removes item from inbox after routing.
---
--- Decision Structure:
--- ```lua
--- {
---   actionable = boolean,  -- Is this item actionable?
---
---   -- If actionable = true:
---   action_type = "next_action"|"project"|"waiting_for",
---   context = "home"|"work"|"computer"|"phone"|"errands"|nil,  -- for next_action
---   project_outcome = "desired outcome",  -- for project
---   waiting_for_who = "person name",  -- for waiting_for
---
---   -- If actionable = false:
---   route = "reference"|"someday_maybe"|"trash",
--- }
--- ```
---
--- @param text string The item text to clarify (will be matched in inbox for removal)
--- @param decision table Decision structure with routing information (see above)
--- @usage
--- local clarify = require("percybrain.gtd.clarify")
---
--- -- Example 1: Next action with context
--- clarify.clarify_item("Fix leaky faucet", {
---   actionable = true,
---   action_type = "next_action",
---   context = "home",
--- })
---
--- -- Example 2: Project
--- clarify.clarify_item("Website redesign", {
---   actionable = true,
---   action_type = "project",
---   project_outcome = "Launch new company website with improved UX",
--- })
---
--- -- Example 3: Reference material
--- clarify.clarify_item("Interesting article", {
---   actionable = false,
---   route = "reference",
--- })
function M.clarify_item(text, decision)
  -- Route based on decision
  if decision.actionable then
    if decision.action_type == "next_action" then
      _route_next_action(text, decision.context)
    elseif decision.action_type == "project" then
      _route_project(text, decision.project_outcome)
    elseif decision.action_type == "waiting_for" then
      _route_waiting_for(text, decision.waiting_for_who)
    end
  else
    if decision.route == "reference" then
      _route_reference(text)
    elseif decision.route == "someday_maybe" then
      _route_someday_maybe(text)
    elseif decision.route == "trash" then
      -- Trash: no routing needed, just remove from inbox (handled below)
      local _ = decision.route -- Satisfy luacheck
    end
  end

  -- Remove from inbox
  M.remove_inbox_item(text)
end

return M
