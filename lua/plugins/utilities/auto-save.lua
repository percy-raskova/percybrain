-- Auto-save.nvim: ADHD hyperfocus protection
-- Never lose work during deep focus sessions
-- Repository: https://github.com/pocco81/auto-save.nvim

return {
  "pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" }, -- Save on meaningful changes
  keys = {
    { "<leader>as", "<cmd>ASToggle<CR>", desc = "💾 Toggle auto-save" },
  },
  config = function()
    require("auto-save").setup({
      enabled = true, -- Start enabled

      -- Save triggers (ADHD-optimized)
      execution_message = {
        message = function()
          return "💾 Auto-saved at " .. vim.fn.strftime("%H:%M:%S")
        end,
        dim = 0.18, -- Subtle notification (not distracting)
        cleaning_interval = 1250, -- Clear message after 1.25s
      },

      -- Events that trigger save
      trigger_events = { "InsertLeave", "TextChanged" },

      -- Conditions
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        -- Don't save if:
        if
          fn.getbufvar(buf, "&modifiable") == 1 -- Buffer is modifiable
          and utils.not_in(fn.getbufvar(buf, "&filetype"), {
            -- Don't auto-save these filetypes
            "harpoon",
            "neo-tree",
            "oil",
            "TelescopePrompt",
            "DressingInput",
          })
        then
          return true -- Save this buffer
        end
        return false
      end,

      -- Writing behavior
      write_all_buffers = false, -- Only save current buffer (less disruptive)

      -- Debouncing (prevent too frequent saves)
      debounce_delay = 135, -- Wait 135ms after typing stops

      -- IMPORTANT: Don't auto-save during these
      callbacks = {
        enabling = nil,
        disabling = nil,
        before_asserting_save = nil,
        before_saving = function()
          -- Don't save if in command mode or visual mode
          local mode = vim.api.nvim_get_mode().mode
          if mode == "c" or mode:match("^[vV]") then
            return false
          end
        end,
        after_saving = nil,
      },
    })

    -- Visual indicator in statusline
    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePre",
      callback = function()
        -- Could add statusline indicator here if needed
        vim.g.autosave_status = "saving"
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePost",
      callback = function()
        vim.g.autosave_status = "saved"
        -- Clear status after a moment
        vim.defer_fn(function()
          vim.g.autosave_status = ""
        end, 2000)
      end,
    })

    -- Notification
    vim.notify("💾 Auto-save enabled! Never lose work during hyperfocus.", vim.log.levels.INFO)
  end,
}
