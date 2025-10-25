--- GTD AI + IWE LSP Bridge
--- @module lib.gtd.iwe-bridge
---
--- Provides automatic task detection and AI decomposition for IWE extracted content.
--- Synergizes GTD AI task management with IWE note refactoring workflows.
---
--- Features:
--- - Auto-detect tasks in extracted notes
--- - Optional prompt for AI decomposition
--- - Integration with SemBr for clean formatting

local M = {}

--- Check if text contains task markers
--- @param text string Text to analyze
--- @return boolean has_tasks True if text contains task markers
local function has_task_markers(text)
  return text:match("%- %[.%]") ~= nil
    or text:match("TODO:") ~= nil
    or text:match("TASK:") ~= nil
    or text:match("%-%-%-") and text:match("todo") ~= nil
end

--- Auto-decompose tasks in current buffer
--- @param bufnr number Buffer number
function M.auto_decompose_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    if line:match("%- %[ %]") then
      -- Found unchecked task - position cursor and decompose
      vim.api.nvim_win_set_cursor(0, { i, 0 })

      -- Call GTD AI decompose_task
      require("lib.gtd.ai").decompose_task()
      break
    end
  end
end

--- Setup auto-decompose hooks
--- @param opts table|nil Configuration options
function M.setup(opts)
  opts = opts or {}

  -- Default: prompt user for decomposition
  local auto_decompose = opts.auto_decompose or false

  -- Hook into IWE extract completion
  vim.api.nvim_create_autocmd("User", {
    pattern = "IWEExtractComplete",
    callback = function(args)
      local bufnr = args.buf or vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local content = table.concat(lines, "\n")

      if has_task_markers(content) then
        if auto_decompose then
          -- Auto-decompose without prompting
          vim.defer_fn(function()
            M.auto_decompose_buffer(bufnr)
          end, 200)
        else
          -- Prompt user for decomposition
          vim.defer_fn(function()
            local choice =
              vim.fn.confirm("Task detected in extracted note. Decompose with GTD AI?", "&Yes\n&No\n&Always", 1)

            if choice == 1 then
              M.auto_decompose_buffer(bufnr)
            elseif choice == 3 then
              -- Enable auto-decompose permanently
              vim.g.gtd_iwe_auto_decompose = true
              M.auto_decompose_buffer(bufnr)
              vim.notify("✅ GTD AI auto-decompose enabled", vim.log.levels.INFO)
            end
          end, 200)
        end
      end
    end,
    desc = "GTD-IWE Bridge: Auto-detect and decompose tasks in extracted notes",
  })

  -- Command to manually trigger decomposition
  vim.api.nvim_create_user_command("GtdDecomposeNote", function()
    M.auto_decompose_buffer(vim.api.nvim_get_current_buf())
  end, {
    desc = "GTD AI: Decompose all tasks in current note",
  })

  -- Command to toggle auto-decompose
  vim.api.nvim_create_user_command("GtdToggleAutoDecompose", function()
    local current = vim.g.gtd_iwe_auto_decompose or false
    vim.g.gtd_iwe_auto_decompose = not current

    if vim.g.gtd_iwe_auto_decompose then
      vim.notify("✅ GTD AI auto-decompose enabled", vim.log.levels.INFO)
    else
      vim.notify("❌ GTD AI auto-decompose disabled", vim.log.levels.INFO)
    end
  end, {
    desc = "GTD AI: Toggle automatic task decomposition",
  })
end

return M
