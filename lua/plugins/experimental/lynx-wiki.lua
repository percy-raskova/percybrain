-- Plugin: Lynx-Wiki
-- Purpose: Lynx browser integration with Wiki export, BibTeX, and AI features
-- Workflow: experimental
-- Config: full
-- Features:
--   1. Export webpages to Markdown for Wiki
--   2. Generate BibTeX citations
--   3. Local AI/Ollama integration (summary, extraction)

return {
  "mjbrownie/browser.vim",
  dependencies = {
    "jgm/pandoc", -- For HTML to Markdown conversion (external)
  },
  cmd = { "LynxOpen", "LynxExport", "LynxCite", "LynxSummarize", "LynxExtract" },
  keys = {
    { "<leader>lo", "<cmd>LynxOpen<cr>", desc = "Open URL in Lynx" },
    { "<leader>le", "<cmd>LynxExport<cr>", desc = "Export page to Wiki" },
    { "<leader>lc", "<cmd>LynxCite<cr>", desc = "Generate BibTeX citation" },
    { "<leader>ls", "<cmd>LynxSummarize<cr>", desc = "AI Summarize page" },
    { "<leader>lx", "<cmd>LynxExtract<cr>", desc = "AI Extract key points" },
  },
  config = function()
    -- Lynx configuration
    vim.g.lynx_wiki = {
      wiki_path = "~/Zettelkasten/",
      export_path = "~/Zettelkasten/web-clips/",
      bibtex_path = "~/Zettelkasten/bibliography.bib",
      ollama_model = "llama3.2",
      ollama_url = "http://localhost:11434",
    }

    -- Command: Open URL in Lynx browser
    vim.api.nvim_create_user_command("LynxOpen", function(opts)
      local url = opts.args
      if url == "" then
        url = vim.fn.input("Enter URL: ")
      end

      -- Open Lynx in terminal buffer
      vim.cmd("split")
      vim.cmd("terminal lynx " .. vim.fn.shellescape(url))
      vim.cmd("startinsert")
    end, { nargs = "?" })

    -- Command: Export webpage to Markdown for Wiki
    vim.api.nvim_create_user_command("LynxExport", function(opts)
      local url = opts.args
      if url == "" then
        url = vim.fn.input("Enter URL to export: ")
      end

      -- Generate filename from URL
      local filename = url:gsub("https?://", ""):gsub("[^%w]", "-")
      local timestamp = os.date("%Y%m%d-%H%M")
      local output_file = vim.g.lynx_wiki.export_path .. timestamp .. "-" .. filename .. ".md"

      -- Step 1: Get MIME headers for metadata (future use for enhanced metadata)
      -- local header_cmd = string.format("lynx -head -mime_header -dump %s 2>/dev/null", vim.fn.shellescape(url))
      -- local headers = vim.fn.system(header_cmd)

      -- Step 2: Fetch HTML source and convert to Markdown using pandoc
      local cmd = string.format(
        "lynx -source -stderr %s | pandoc -f html -t markdown -o %s",
        vim.fn.shellescape(url),
        vim.fn.shellescape(output_file)
      )

      -- Execute and notify
      vim.notify("📥 Fetching and converting...", vim.log.levels.INFO)
      vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        -- Prepend metadata header to the Markdown file
        local file_content = vim.fn.readfile(output_file)
        local metadata = string.format(
          [[---
title: "Web Clip"
source: %s
date: %s
tags: [web-clip, imported]
---

]],
          url,
          os.date("%Y-%m-%d %H:%M")
        )

        -- Write metadata + content
        local final_content = metadata .. table.concat(file_content, "\n")
        vim.fn.writefile(vim.split(final_content, "\n"), output_file)

        vim.notify("✅ Exported to: " .. output_file, vim.log.levels.INFO)
        -- Open the exported file
        vim.cmd("edit " .. vim.fn.fnameescape(output_file))
      else
        vim.notify("❌ Export failed", vim.log.levels.ERROR)
      end
    end, { nargs = "?" })

    -- Command: Generate BibTeX citation from webpage
    vim.api.nvim_create_user_command("LynxCite", function(opts)
      local url = opts.args
      if url == "" then
        url = vim.fn.input("Enter URL to cite: ")
      end

      -- Fetch page with Lynx dump (includes title in first line usually)
      local dump_cmd = string.format("lynx -dump -nolist -stderr %s | head -1", vim.fn.shellescape(url))
      local title = vim.fn.system(dump_cmd):gsub("^%s*(.-)%s*$", "%1")

      -- If title is empty, use URL as fallback
      if title == "" then
        title = url
      end

      -- Fetch MIME headers for additional metadata (future use for author, date extraction)
      -- local header_cmd = string.format("lynx -head -mime_header -dump %s 2>/dev/null", vim.fn.shellescape(url))
      -- local headers = vim.fn.system(header_cmd)

      -- Extract domain for cite key
      local domain = url:match("https?://([^/]+)") or "unknown"
      local clean_domain = domain:gsub("%.", ""):gsub("www", "")
      local citekey = clean_domain .. os.date("%Y")

      -- Generate BibTeX entry
      local bibtex = string.format(
        [[
@online{%s,
  title = {%s},
  url = {%s},
  urldate = {%s},
  note = {Accessed via Lynx text browser}
}
]],
        citekey,
        title,
        url,
        os.date("%Y-%m-%d")
      )

      -- Append to bibliography file
      local bib_file = io.open(vim.fn.expand(vim.g.lynx_wiki.bibtex_path), "a")
      if bib_file then
        bib_file:write("\n" .. bibtex .. "\n")
        bib_file:close()
        vim.notify("📚 Citation added: @" .. citekey, vim.log.levels.INFO)

        -- Copy citekey to clipboard
        vim.fn.setreg("+", "@" .. citekey)
      else
        vim.notify("❌ Failed to write to bibliography file", vim.log.levels.ERROR)
      end
    end, { nargs = "?" })

    -- Command: AI Summarize webpage using Ollama
    vim.api.nvim_create_user_command("LynxSummarize", function(opts)
      local url = opts.args
      if url == "" then
        url = vim.fn.input("Enter URL to summarize: ")
      end

      -- Fetch page content as formatted text (no link list)
      local content_cmd = string.format("lynx -dump -nolist -stderr -width=100 %s", vim.fn.shellescape(url))
      local content = vim.fn.system(content_cmd)

      -- Call Ollama API for summary
      local prompt = string.format(
        [[Summarize the following web page content in 3-5 bullet points:

%s]],
        content
      )

      local ollama_cmd = string.format(
        [[curl -s -X POST %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}' | jq -r '.response']],
        vim.g.lynx_wiki.ollama_url,
        vim.g.lynx_wiki.ollama_model,
        vim.fn.json_encode(prompt)
      )

      vim.notify("🤖 Generating AI summary...", vim.log.levels.INFO)
      local summary = vim.fn.system(ollama_cmd)

      -- Display summary in floating window
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(summary, "\n"))

      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.6)
      local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " AI Summary ",
        title_pos = "center",
      }

      vim.api.nvim_open_win(buf, true, win_opts)
      vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end, { nargs = "?" })

    -- Command: AI Extract key points using Ollama
    vim.api.nvim_create_user_command("LynxExtract", function(opts)
      local url = opts.args
      if url == "" then
        url = vim.fn.input("Enter URL to extract key points: ")
      end

      -- Fetch page content as formatted text (no link list, with width limit)
      local content_cmd = string.format("lynx -dump -nolist -stderr -width=100 %s", vim.fn.shellescape(url))
      local content = vim.fn.system(content_cmd)

      -- Call Ollama API for extraction
      local prompt = string.format(
        [[Extract the key facts, statistics, and important information from this webpage. Format as a structured list:

%s]],
        content
      )

      local ollama_cmd = string.format(
        [[curl -s -X POST %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}' | jq -r '.response']],
        vim.g.lynx_wiki.ollama_url,
        vim.g.lynx_wiki.ollama_model,
        vim.fn.json_encode(prompt)
      )

      vim.notify("🤖 Extracting key points...", vim.log.levels.INFO)
      local extraction = vim.fn.system(ollama_cmd)

      -- Create new note in Wiki with extracted content
      local timestamp = os.date("%Y%m%d-%H%M")
      local output_file = vim.g.lynx_wiki.export_path .. timestamp .. "-extracted.md"

      local note_content = string.format(
        [[---
title: "Extracted from %s"
source: %s
date: %s
tags: [web-clip, extracted]
---

# Extracted Key Points

%s

## Source
- URL: %s
- Extracted: %s
]],
        url,
        url,
        os.date("%Y-%m-%d %H:%M"),
        extraction,
        url,
        os.date("%Y-%m-%d %H:%M")
      )

      local file = io.open(vim.fn.expand(output_file), "w")
      if file then
        file:write(note_content)
        file:close()
        vim.notify("✅ Extracted to: " .. output_file, vim.log.levels.INFO)
        vim.cmd("edit " .. vim.fn.fnameescape(output_file))
      else
        vim.notify("❌ Failed to write extraction", vim.log.levels.ERROR)
      end
    end, { nargs = "?" })

    vim.notify("🌐 Lynx-Wiki loaded - Web clipping with AI ready", vim.log.levels.INFO)
  end,
}
