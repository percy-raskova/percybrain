-- Privacy Configuration for Neovim
-- Prevents sensitive data from persisting in registers and history

local M = {}

function M.setup()
  -- Clear all numbered registers (0-9)
  local function clear_registers()
    for i = 0, 9 do
      vim.fn.setreg(tostring(i), '')
    end
    -- Also clear the unnamed register
    vim.fn.setreg('"', '')
    -- Clear the clipboard registers
    vim.fn.setreg('+', '')
    vim.fn.setreg('*', '')
  end

  -- Clear registers on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      clear_registers()
    end,
    desc = "Clear all registers before exiting Neovim"
  })

  -- Clear sensitive registers after operations
  vim.api.nvim_create_autocmd({"BufWritePost", "BufLeave"}, {
    pattern = {"*.ssh/*", "*.env", "*credentials*", "*secret*", "*.key", "*.pem"},
    callback = function()
      vim.defer_fn(function()
        clear_registers()
        vim.notify("Sensitive registers cleared", vim.log.levels.INFO)
      end, 100)
    end,
    desc = "Clear registers after working with sensitive files"
  })

  -- Command to manually clear all registers
  vim.api.nvim_create_user_command('ClearRegisters', function()
    clear_registers()
    vim.notify("All registers cleared!", vim.log.levels.INFO)
  end, { desc = "Clear all Neovim registers" })

  -- Keybinding for quick clearing
  vim.keymap.set('n', '<leader>cr', clear_registers, { desc = "Clear all registers" })

  -- Disable persistent undo for sensitive files
  vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = {"*.env", "*.key", "*.pem", "*credentials*", "*secret*"},
    callback = function()
      vim.opt_local.undofile = false
      vim.opt_local.swapfile = false
      vim.opt_local.backup = false
      vim.opt_local.writebackup = false
    end,
    desc = "Disable persistence for sensitive files"
  })

  -- Limit command history
  vim.opt.history = 50  -- Reduce from default 10000

  -- Disable viminfo for registers (optional - uncomment if you want NO persistence)
  -- vim.opt.viminfo = "'100,f0,<0,:50,@0,/0"
  -- This means:
  -- '100 = remember marks for 100 files
  -- f0 = don't store file marks
  -- <0 = don't save registers
  -- :50 = save 50 lines of command history
  -- @0 = don't save input line history
  -- /0 = don't save search history
end

-- Clear registers right now on load
M.setup()

return M