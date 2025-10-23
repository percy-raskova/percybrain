-- SemBr Integration for PercyBrain
-- Automatic semantic line breaks for better git diffs and version control

return {
  "nvim-lua/plenary.nvim", -- Required for async operations
  keys = {
    { "<leader>sb", "<cmd>SemBrFormat<CR>", desc = "🧠 SemBr: Format buffer" },
    { "<leader>ss", "<cmd>SemBrFormatSelection<CR>", mode = "v", desc = "🧠 SemBr: Format selection" },
    { "<leader>st", "<cmd>SemBrToggle<CR>", desc = "🔄 SemBr: Toggle auto-format" },
  },
  config = function()
    local M = {}

    -- Configuration
    M.config = {
      model = "bert-small", -- Options: bert-small, bert-base, bert-large
      auto_format = false, -- Auto-format on save (disabled by default)
      enable_mcp = false, -- Use MCP server mode (future enhancement)
    }

    -- Format current buffer with SemBr
    function M.format_buffer()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- Write buffer content to temporary file
      local tmpfile = vim.fn.tempname()
      vim.fn.writefile(lines, tmpfile)

      -- Run SemBr
      local cmd = string.format("sembr --model %s %s", M.config.model, tmpfile)

      vim.notify("🔄 Running SemBr semantic line break analysis...", vim.log.levels.INFO)

      local output = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        -- Parse output and update buffer
        local formatted = vim.split(output, "\n", { trimempty = false })

        -- Remove last empty line if present (system adds trailing newline)
        if formatted[#formatted] == "" then
          table.remove(formatted)
        end

        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
        vim.notify("✅ SemBr formatting complete", vim.log.levels.INFO)
      else
        vim.notify("❌ SemBr error: " .. output, vim.log.levels.ERROR)
      end

      -- Clean up temporary file
      vim.fn.delete(tmpfile)
    end

    -- Format visual selection with SemBr
    function M.format_selection()
      -- Get visual selection range
      local start_line = vim.fn.line("'<") - 1
      local end_line = vim.fn.line("'>")

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

      -- Write selection to temporary file
      local tmpfile = vim.fn.tempname()
      vim.fn.writefile(lines, tmpfile)

      -- Run SemBr
      local cmd = string.format("sembr --model %s %s", M.config.model, tmpfile)

      vim.notify("🔄 Running SemBr on selection...", vim.log.levels.INFO)

      local output = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        local formatted = vim.split(output, "\n", { trimempty = false })

        -- Remove last empty line if present
        if formatted[#formatted] == "" then
          table.remove(formatted)
        end

        vim.api.nvim_buf_set_lines(bufnr, start_line, end_line, false, formatted)
        vim.notify("✅ SemBr selection formatted", vim.log.levels.INFO)
      else
        vim.notify("❌ SemBr error: " .. output, vim.log.levels.ERROR)
      end

      vim.fn.delete(tmpfile)
    end

    -- Toggle auto-format on save
    function M.toggle_auto_format()
      M.config.auto_format = not M.config.auto_format

      if M.config.auto_format then
        vim.notify("✅ SemBr auto-format enabled", vim.log.levels.INFO)
      else
        vim.notify("⏸️  SemBr auto-format disabled", vim.log.levels.INFO)
      end
    end

    -- User commands
    vim.api.nvim_create_user_command("SemBrFormat", M.format_buffer, {
      desc = "Format buffer with semantic line breaks",
    })

    vim.api.nvim_create_user_command("SemBrFormatSelection", M.format_selection, {
      range = true,
      desc = "Format visual selection with semantic line breaks",
    })

    vim.api.nvim_create_user_command("SemBrToggle", M.toggle_auto_format, {
      desc = "Toggle auto-format on save",
    })

    -- NOTE: Keybindings defined in keys = {} spec above (lazy.nvim native)
    -- <leader>sb (format buffer), <leader>ss (format selection), <leader>st (toggle)

    -- Auto-format on save (if enabled)
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.md",
      callback = function()
        if M.config.auto_format then
          M.format_buffer()
        end
      end,
    })

    vim.notify("🧠 SemBr loaded - <leader>sb to format", vim.log.levels.INFO)
  end,
}
