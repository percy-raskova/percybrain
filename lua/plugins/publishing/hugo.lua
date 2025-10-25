-- Plugin: Hugo Integration
-- Purpose: Publish Zettelkasten notes to Hugo static site (blog, digital garden, knowledge wiki)
-- Workflow: publishing
-- Why: Transforms private notes into public knowledge sharing. Hugo's speed and simplicity match
--      Zettelkasten's plain-text philosophy. Commands streamline the publish workflow (new post,
--      preview, build, deploy). Bridges personal knowledge management with audience engagement.
--      Supports neurodiversity advocacy through accessible knowledge sharing.
-- Config: full - custom commands for Hugo workflow
--
-- NOTE: Hugo is being replaced with Quartz for static site generation.
--
-- Usage:
--   :HugoNew [title] - Create new post in content/posts/
--   :HugoServer - Start local preview server (http://localhost:1313)
--   :HugoBuild - Build static site to public/
--   :HugoPublish - Build + git commit + push (full deployment)
--
-- Dependencies:
--   External: hugo (install with package manager or from gohugo.io)
--
-- Configuration Notes:
--   - Assumes Hugo project structure (content/, themes/, config.toml)
--   - Posts created in content/posts/ with kebab-case naming
--   - HugoPublish does full CI/CD: build + commit + push (customize as needed)
--   - Works with YAML frontmatter from Zettelkasten templates
--   - Supports Hugo's markdown extensions and shortcodes

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
  end,
}
