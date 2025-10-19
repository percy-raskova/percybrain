-- PercyBrain Mock Factories
-- Mock objects for testing plugins and features

local M = {}

-- Mock LSP client
function M.lsp_client(options)
  options = options or {}

  return {
    name = options.name or "test_lsp",
    id = options.id or 1,
    server_capabilities = options.capabilities or {
      completionProvider = true,
      hoverProvider = true,
      definitionProvider = true,
      referencesProvider = true,
      renameProvider = true,
    },
    request = function(method, params, callback)
      if options.responses and options.responses[method] then
        callback(nil, options.responses[method])
      else
        callback(nil, { result = "mock_response" })
      end
    end,
    notify = function(method, params)
      -- Mock notify
    end,
    stop = function()
      -- Mock stop
    end,
  }
end

-- Mock Zettelkasten vault
function M.vault(path)
  path = path or vim.fn.tempname() .. "/test_vault"

  local vault = {
    path = path,
    notes = {},
  }

  function vault:setup()
    vim.fn.mkdir(self.path, "p")
    vim.fn.mkdir(self.path .. "/daily", "p")
    vim.fn.mkdir(self.path .. "/inbox", "p")
    vim.fn.mkdir(self.path .. "/templates", "p")
    vim.fn.mkdir(self.path .. "/.iwe", "p")

    -- Create default templates
    self:create_template(
      "default",
      [[
---
title: {{title}}
date: {{date}}
tags: []
---

# {{title}}
]]
    )

    self:create_template(
      "daily",
      [[
---
title: Daily Note - {{date}}
date: {{date}}
type: daily
---

# Daily Note - {{date}}

## Tasks
- [ ]

## Notes
]]
    )
  end

  function vault:teardown()
    vim.fn.delete(self.path, "rf")
  end

  function vault:create_note(name, content)
    local note_path = self.path .. "/" .. name .. ".md"
    vim.fn.writefile(vim.split(content or "", "\n"), note_path)
    table.insert(self.notes, note_path)
    return note_path
  end

  function vault:create_template(name, content)
    local template_path = self.path .. "/templates/" .. name .. ".md"
    vim.fn.writefile(vim.split(content, "\n"), template_path)
    return template_path
  end

  function vault:create_daily_note(date)
    date = date or os.date("%Y%m%d")
    local note_path = self.path .. "/daily/" .. date .. ".md"
    local content = string.format(
      [[
---
title: Daily Note - %s
date: %s
type: daily
---

# Daily Note - %s
]],
      date,
      date,
      date
    )
    vim.fn.writefile(vim.split(content, "\n"), note_path)
    return note_path
  end

  function vault:get_backlinks(note_id)
    -- Mock backlinks
    return {
      { path = self.path .. "/note1.md", line = 5 },
      { path = self.path .. "/note2.md", line = 10 },
    }
  end

  return vault
end

-- Mock Ollama LLM with comprehensive vim API mocking
function M.ollama(options)
  options = options or {}

  local mock = {
    model = options.model or "llama3.2:latest",
    is_running = options.is_running ~= false, -- Default to true
    responses = options.responses or {},
  }

  -- Create comprehensive vim mock for Ollama tests
  function mock:setup_vim()
    local original_vim = _G.vim
    local preserved_inspect = original_vim.inspect
    local preserved_cmd = original_vim.cmd

    _G.vim = vim.tbl_extend("force", _G.vim or {}, {
      -- API mocks
      api = vim.tbl_extend("force", vim.api or {}, {
        nvim_get_current_buf = function()
          return 1
        end,
        nvim_win_get_cursor = function()
          return { 10, 0 }
        end,
        nvim_buf_line_count = function()
          return 100
        end,
        nvim_buf_get_lines = function(buf, start_line, end_line)
          local lines = {}
          for i = start_line + 1, end_line do
            table.insert(lines, "Test line " .. i)
          end
          return lines
        end,
        nvim_create_buf = function()
          return 2
        end,
        nvim_buf_set_lines = function() end,
        nvim_buf_set_option = function() end,
        nvim_open_win = function()
          return 1001
        end,
        nvim_win_set_option = function() end,
        nvim_buf_set_keymap = function() end,
        nvim_create_user_command = function() end,
        nvim_exec2 = function(cmd, opts)
          return { output = "" }
        end,
      }),

      -- Function mocks
      fn = vim.tbl_extend("force", vim.fn or {}, {
        mode = function()
          return "n"
        end,
        getpos = function(mark)
          if mark == "'<" then
            return { 0, 5, 0, 0 }
          elseif mark == "'>" then
            return { 0, 10, 0, 0 }
          end
        end,
        jobstart = function(cmd, opts)
          if opts and opts.on_stdout then
            vim.defer_fn(function()
              local response = mock.responses[cmd]
                or '{"model":"llama3.2:latest","response":"Mock AI response","done":true}'
              opts.on_stdout(nil, { response })
            end, 10)
          end
          return 123
        end,
        json_decode = vim.json and vim.json.decode or function(str)
          if str:match('"response":"([^"]+)"') then
            return {
              model = "llama3.2:latest",
              response = str:match('"response":"([^"]+)"'),
              done = true,
            }
          end
          return nil
        end,
      }),

      -- Other vim globals
      log = vim.log or { levels = { INFO = 2, WARN = 3, ERROR = 4 } },
      o = { columns = 120, lines = 40 },
      loop = { sleep = function(ms) end },
      defer_fn = function(fn, timeout)
        fn()
      end,
      split = function(str, sep)
        local result = {}
        for line in str:gmatch("[^\n]+") do
          table.insert(result, line)
        end
        return result
      end,
      tbl_extend = function(behavior, ...)
        local result = {}
        for _, tbl in ipairs({ ... }) do
          for k, v in pairs(tbl) do
            result[k] = v
          end
        end
        return result
      end,
      inspect = preserved_inspect or function(obj, opts)
        if type(obj) == "table" then
          local items = {}
          for k, v in pairs(obj) do
            table.insert(items, tostring(k) .. "=" .. tostring(v))
          end
          return "{" .. table.concat(items, ", ") .. "}"
        end
        return tostring(obj)
      end,
      cmd = preserved_cmd or function(command) end,
    })

    return original_vim
  end

  -- Mock io.popen for service detection
  function mock:mock_io_popen()
    local original = io.popen
    io.popen = function(cmd) -- luacheck: ignore
      return {
        read = function(_, _)
          if cmd:match("pgrep.-ollama") then
            return mock.is_running and "12345\n" or ""
          end
          return ""
        end,
        close = function() end,
      }
    end
    return original
  end

  -- Basic API methods
  function mock:generate(prompt, callback)
    vim.defer_fn(function()
      callback({
        response = "Mock AI response to: " .. prompt:sub(1, 50),
        model = self.model,
        created_at = os.date("%Y-%m-%d %H:%M:%S"),
        done = true,
      })
    end, 100)
  end

  function mock:list()
    return {
      models = {
        { name = "llama3.2", size = "2.0 GB" },
        { name = "codellama", size = "3.8 GB" },
      },
    }
  end

  return mock
end

-- Mock auto-save module
function M.auto_save()
  local state = {
    enabled = true,
    saves = 0,
    last_save = nil,
  }

  return {
    setup = function(config)
      state.config = config
        or {
          enabled = true,
          execution_message = "AutoSave: saved",
          events = { "InsertLeave", "TextChanged" },
          conditions = {
            exists = true,
            filename_is_not = {},
            filetype_is_not = {},
            modifiable = true,
          },
          write_all_buffers = false,
          debounce_delay = 135,
        }
    end,
    save = function()
      state.saves = state.saves + 1
      state.last_save = os.time()
      return true
    end,
    toggle = function()
      state.enabled = not state.enabled
      return state.enabled
    end,
    off = function()
      state.enabled = false
    end,
    on = function()
      state.enabled = true
    end,
    get_state = function()
      return state
    end,
  }
end

-- Mock window manager
function M.window_manager()
  local windows = {}

  return {
    setup = function()
      -- Initialize window manager
    end,
    navigate = function(direction)
      return true
    end,
    split_horizontal = function()
      local win = vim.api.nvim_get_current_win()
      table.insert(windows, win)
      return win
    end,
    split_vertical = function()
      local win = vim.api.nvim_get_current_win()
      table.insert(windows, win)
      return win
    end,
    close = function()
      if #windows > 0 then
        table.remove(windows)
      end
      return true
    end,
    get_windows = function()
      return windows
    end,
  }
end

-- Mock Telescope picker
function M.telescope_picker(options)
  options = options or {}

  return {
    find = function()
      -- Mock find operation
      if options.on_select then
        options.on_select({ "mock_selection" })
      end
    end,
    results = options.results or {
      "result1.md",
      "result2.md",
      "result3.md",
    },
  }
end

-- Mock Hugo site
function M.hugo_site(path)
  path = path or vim.fn.tempname() .. "/test_site"

  return {
    path = path,
    setup = function()
      vim.fn.mkdir(path, "p")
      vim.fn.mkdir(path .. "/content", "p")
      vim.fn.mkdir(path .. "/content/posts", "p")
      vim.fn.mkdir(path .. "/static", "p")
      vim.fn.mkdir(path .. "/themes", "p")

      -- Create config.toml
      vim.fn.writefile({
        'baseURL = "http://example.org/"',
        'languageCode = "en-us"',
        'title = "Test Site"',
        'theme = "test-theme"',
      }, path .. "/config.toml")
    end,
    teardown = function()
      vim.fn.delete(path, "rf")
    end,
    new_post = function(title)
      local filename = title:lower():gsub(" ", "-") .. ".md"
      local post_path = path .. "/content/posts/" .. filename
      local content = string.format(
        [[
---
title: "%s"
date: %s
draft: false
---

# %s
]],
        title,
        os.date("%Y-%m-%dT%H:%M:%S"),
        title
      )
      vim.fn.writefile(vim.split(content, "\n"), post_path)
      return post_path
    end,
  }
end

-- Mock vim.notify for capturing notifications
function M.notifications()
  local messages = {}
  local original = vim.notify

  local mock = {
    messages = messages,
    capture = function()
      vim.notify = function(msg, level, opts)
        table.insert(messages, {
          message = msg,
          level = level,
          opts = opts,
        })
      end
    end,
    restore = function()
      vim.notify = original
    end,
    clear = function()
      for i = #messages, 1, -1 do
        messages[i] = nil
      end
    end,
    has = function(pattern)
      for _, msg in ipairs(messages) do
        if msg.message:match(pattern) then
          return true
        end
      end
      return false
    end,
    count = function()
      return #messages
    end,
  }

  return mock
end

-- Mock timer for testing time-based features
function M.timer()
  local callbacks = {}
  local time = 0

  return {
    defer_fn = function(fn, delay)
      table.insert(callbacks, {
        fn = fn,
        time = time + delay,
      })
    end,
    advance = function(ms)
      time = time + ms
      for i = #callbacks, 1, -1 do
        if callbacks[i].time <= time then
          callbacks[i].fn()
          table.remove(callbacks, i)
        end
      end
    end,
    reset = function()
      callbacks = {}
      time = 0
    end,
    get_time = function()
      return time
    end,
  }
end

return M
