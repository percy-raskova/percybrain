return {
  "phelipetls/jsonpath.nvim", -- Dependency for Hugo
  ft = { "markdown", "md" },
  config = function()
    -- Hugo commands
    vim.api.nvim_create_user_command("HugoNew", function(opts)
      local title = opts.args
      if title == "" then
        vim.ui.input({ prompt = "Post title: " }, function(input)
          if input then
            vim.cmd("!hugo new posts/" .. input:gsub(" ", "-"):lower() .. ".md")
          end
        end)
      else
        vim.cmd("!hugo new posts/" .. title:gsub(" ", "-"):lower() .. ".md")
      end
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("HugoServer", function()
      vim.cmd("terminal hugo server -D")
    end, {})

    vim.api.nvim_create_user_command("HugoBuild", function()
      vim.cmd("!hugo --cleanDestinationDir")
    end, {})

    vim.api.nvim_create_user_command("HugoPublish", function()
      vim.cmd("!hugo && git add . && git commit -m 'Publish' && git push")
    end, {})

    -- Keymaps
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>zp", ":HugoPublish<CR>", opts)
    vim.keymap.set("n", "<leader>zv", ":HugoServer<CR>", opts)
    vim.keymap.set("n", "<leader>zb", ":HugoBuild<CR>", opts)
  end,
}
