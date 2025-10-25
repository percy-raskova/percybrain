-- Integration Test Environment Setup
-- Kent Beck: "A clean test environment is a happy test environment"

local M = {}

-- Create a complete test Zettelkasten vault
function M.create_test_vault(name)
  name = name or "test_vault_" .. os.time()
  local test_dir = vim.fn.tempname() .. "/" .. name

  -- Create directory structure
  vim.fn.mkdir(test_dir, "p")
  vim.fn.mkdir(test_dir .. "/inbox", "p")
  vim.fn.mkdir(test_dir .. "/templates", "p")
  vim.fn.mkdir(test_dir .. "/daily", "p")
  vim.fn.mkdir(test_dir .. "/.iwe", "p")

  -- Create default templates
  M.create_template(
    test_dir,
    "wiki",
    [[---
title: {{title}}
date: {{date}}
draft: false
tags: []
categories: []
description: ""
---

# {{title}}
]]
  )

  M.create_template(
    test_dir,
    "fleeting",
    [[---
title: {{title}}
created: {{timestamp}}
---

{{content}}
]]
  )

  return test_dir
end

-- Create a template file
function M.create_template(vault_path, template_name, content)
  local template_path = vault_path .. "/templates/" .. template_name .. ".md"
  vim.fn.writefile(vim.split(content, "\n"), template_path)
  return template_path
end

-- Clean up test vault
function M.cleanup_test_vault(path)
  if path and vim.fn.isdirectory(path) == 1 then
    vim.fn.delete(path, "rf")
  end
end

-- Set up test environment variables
function M.setup_env(vault_path)
  local original = {
    HOME = vim.env.HOME,
    ZETTELKASTEN = vim.env.ZETTELKASTEN,
    PERCYBRAIN_TEST = vim.env.PERCYBRAIN_TEST,
  }

  -- Override for testing
  vim.env.ZETTELKASTEN = vault_path
  vim.env.PERCYBRAIN_TEST = "true"

  -- Adjust HOME if needed for ~/Zettelkasten resolution
  if vault_path:match("/Zettelkasten$") then
    vim.env.HOME = vault_path:gsub("/Zettelkasten$", "")
  end

  return original
end

-- Restore original environment
function M.restore_env(original)
  for key, value in pairs(original) do
    vim.env[key] = value
  end
end

-- Create a test file with content
function M.create_test_file(vault_path, relative_path, content)
  local full_path = vault_path .. "/" .. relative_path
  local dir = vim.fn.fnamemodify(full_path, ":h")

  -- Ensure directory exists
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  vim.fn.writefile(vim.split(content or "", "\n"), full_path)
  return full_path
end

-- Load component with test configuration
function M.load_component(name, config)
  -- Clear any existing module
  package.loaded["lib." .. name] = nil

  -- Load with config
  local component = require("lib." .. name)
  if component.setup then
    component.setup(config or {})
  end

  return component
end

-- Clear all test-related autocmds
function M.clear_autocmds()
  local groups = {
    "WriteQuitPipeline",
    "TemplateSystem",
    "HugoValidation",
    "QuickCapture",
    "AIModelSelection",
  }

  for _, group in ipairs(groups) do
    pcall(function()
      vim.api.nvim_clear_autocmds({ group = group })
    end)
  end
end

-- Verify test environment is clean
function M.verify_clean_state()
  local issues = {}

  -- Check for leftover buffers
  local buffers = vim.api.nvim_list_bufs()
  if #buffers > 1 then -- More than just the initial buffer
    table.insert(issues, "Leftover buffers detected: " .. #buffers)
  end

  -- Check for leftover autocmds
  local autocmds = vim.api.nvim_get_autocmds({})
  local test_autocmds = vim.tbl_filter(function(au)
    return au.group_name and au.group_name:match("Pipeline") or au.group_name and au.group_name:match("Template")
  end, autocmds)

  if #test_autocmds > 0 then
    table.insert(issues, "Leftover autocmds detected: " .. #test_autocmds)
  end

  return #issues == 0, issues
end

return M
