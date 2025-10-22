-- SemBr Integration Plugin
-- Loads semantic line breaks support for PercyBrain
-- Extends existing Git plugins (fugitive, gitsigns) rather than reinventing

return {
  "sembr",
  name = "percybrain-sembr",
  dir = vim.fn.stdpath("config") .. "/lua/percybrain",
  dependencies = {
    "tpope/vim-fugitive", -- Industry standard Git
    "lewis6991/gitsigns.nvim", -- Visual Git integration
  },
  ft = { "markdown", "vimwiki", "telekasten" },
  cmd = {
    "GSemBrDiff",
    "GSemBrBlame",
    "GSemBrStage",
    "GSemBrCommit",
    "GSemBrSetup",
    "GSemBrWordDiff",
    "GSemBrParaDiff",
  },
  config = function()
    -- Load our SemBr Git integration layer
    require("percybrain.sembr-git").setup({
      -- Configuration options
      auto_format = true,
      git_integration = true,
      hugo_compatible = true,
    })

    -- Check if sembr binary is available for formatting
    local sembr_available = vim.fn.executable("sembr") == 1

    if sembr_available then
      -- Create formatting commands that use the actual sembr tool
      vim.api.nvim_create_user_command("SemBrFormat", function(opts)
        local start_line = opts.line1
        local end_line = opts.line2

        if start_line == end_line then
          -- Format whole buffer
          vim.cmd("%!sembr")
        else
          -- Format selection
          vim.cmd(string.format("%d,%d!sembr", start_line, end_line))
        end

        vim.notify("📐 Formatted with semantic line breaks", vim.log.levels.INFO)
      end, {
        range = true,
        desc = "Format with semantic line breaks",
      })

      -- Toggle auto-format on save
      local auto_format_enabled = false
      vim.api.nvim_create_user_command("SemBrToggle", function()
        auto_format_enabled = not auto_format_enabled

        if auto_format_enabled then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("SemBrAutoFormat", { clear = true }),
            pattern = "*.md",
            callback = function()
              vim.cmd("silent %!sembr")
            end,
          })
          vim.notify("✅ SemBr auto-format enabled", vim.log.levels.INFO)
        else
          vim.api.nvim_clear_autocmds({
            group = "SemBrAutoFormat",
          })
          vim.notify("❌ SemBr auto-format disabled", vim.log.levels.INFO)
        end
      end, {
        desc = "Toggle SemBr auto-format on save",
      })

      -- ========================================================================
      -- IWE INTEGRATION HOOKS
      -- ========================================================================
      -- Auto-format with SemBr after IWE extract/inline operations

      -- Post-IWE-extract hook: Format newly extracted note
      vim.api.nvim_create_autocmd("User", {
        pattern = "IWEExtractComplete",
        callback = function(args)
          local bufnr = args.buf or vim.api.nvim_get_current_buf()

          vim.defer_fn(function()
            -- Format buffer with SemBr
            local buf_valid = vim.api.nvim_buf_is_valid(bufnr)
            if buf_valid then
              local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              local content = table.concat(lines, "\n")

              -- Format with sembr
              local handle = io.popen("sembr", "w")
              if handle then
                handle:write(content)
                handle:close()
              end

              -- Check if extracted content contains tasks
              if content:match("%- %[.%]") then
                vim.notify("📋 Task detected in extracted note. Use <leader>zrd to decompose.", vim.log.levels.INFO)
              end
            end
          end, 100)
        end,
        desc = "SemBr: Auto-format after IWE extract + detect tasks",
      })

      -- Post-IWE-inline hook: Preserve semantic formatting after inline
      vim.api.nvim_create_autocmd("User", {
        pattern = "IWEInlineComplete",
        callback = function(args)
          local bufnr = args.buf or vim.api.nvim_get_current_buf()

          vim.defer_fn(function()
            local buf_valid = vim.api.nvim_buf_is_valid(bufnr)
            if buf_valid then
              vim.cmd("silent %!sembr")
            end
          end, 100)
        end,
        desc = "SemBr: Re-format after IWE inline to preserve semantic breaks",
      })

      -- Keymaps for SemBr formatting
      vim.keymap.set({ "n", "v" }, "<leader>zs", "<cmd>SemBrFormat<cr>", { desc = "Format with semantic line breaks" })
      vim.keymap.set("n", "<leader>zt", "<cmd>SemBrToggle<cr>", { desc = "Toggle SemBr auto-format" })

      vim.notify("📐 SemBr binary found - formatting commands available", vim.log.levels.INFO)
    else
      vim.notify("⚠️  SemBr binary not found - install with: uv tool install sembr", vim.log.levels.WARN)

      -- Provide manual formatting as fallback
      vim.api.nvim_create_user_command("SemBrFormat", function()
        vim.notify("SemBr not installed. Install with: uv tool install sembr", vim.log.levels.ERROR)
        vim.notify("Or use manual formatting: one clause per line", vim.log.levels.INFO)
      end, {
        range = true,
        desc = "Format with semantic line breaks (requires sembr)",
      })
    end
  end,
}
