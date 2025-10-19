---
title: " Logging System  Logging System | nvim-lua/plenary.nvim"
author:
published:    Logging System | nvim-lua/plenary.nvim | DeepWiki
description: "   nvim-lua/plenary.nvim"
source: "https://deepwiki.com/nvim-lua/plenary.nvim/10.2-logging-system"
created: 2025-10-18
category: "category:   [\"nvim-lua\",\"plenary.nvim\",\"10.2-logging-system\"]"
tags:
  - "tags:"
image: "image:    "
cover: "cover: "
---
Menu

## Logging System

Relevant source files
- [lua/plenary/log.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua)

This document covers the configurable logging system provided by plenary.nvim for Neovim plugin development. The logging system enables developers to record, trace, and debug their plugins with various output options including console output, log files, and the quickfix list.

For information about testing capabilities, see [Testing Framework](https://deepwiki.com/nvim-lua/plenary.nvim/10.1-testing-framework). For performance profiling tools, see [Profiling](https://deepwiki.com/nvim-lua/plenary.nvim/10.3-profiling).

## Overview

The plenary logging system is a flexible and feature-rich logging utility inspired by rxi/log.lua and modified for Neovim plugin development. It supports multiple log levels, different output targets, and customizable formatting.

```
Output TargetsLog MethodsLogging ConfigurationConfiguration Optionslog.trace/debug/info/warn/error/fatallog.fmt_*log.lazy_*log.file_*Neovim ConsoleLog FileQuickfix ListLog Level FilterFormat MessageOutput Router
```

Sources: [lua/plenary/log.lua 1-235](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L1-L235)

## Core Features

The plenary logging system provides:

1. **Multiple Logging Levels**: trace, debug, info, warn, error, and fatal
2. **Flexible Output Destinations**: Console, file, or quickfix list
3. **Source Location Tracking**: Automatically includes file and line number information
4. **Customizable Formatting**: Control how messages are formatted
5. **Multiple Logging Methods**: Regular, formatted, lazy, and file-only variants

Sources: [lua/plenary/log.lua 192-226](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L192-L226)

## Configuration

The logging system is highly configurable. Here are the available configuration options:

| Option | Default | Description |
| --- | --- | --- |
| `plugin` | `"plenary"` | Name of the plugin (prepended to log messages) |
| `use_console` | `"async"` | Whether to print output to Neovim console (`"sync"`, `"async"`, or `false`) |
| `highlights` | `true` | Whether to use highlighting in console output |
| `use_file` | `true` | Whether to write logs to a file |
| `outfile` | `stdpath("log")/plugin.log` | Path to the log file |
| `use_quickfix` | `false` | Whether to write logs to the quickfix list |
| `level` | `"info"` or `"debug"` | Minimum level to log (messages below this level are ignored) |
| `modes` | See code | Configuration for each log level, including name and highlight group |
| `float_precision` | `0.01` | Precision for floating-point values in logs |
| `fmt_msg` | Function | Function to format log messages |

Sources: [lua/plenary/log.lua 18-71](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L18-L71)

## Creating a Logger

You can use the default logger provided by plenary or create a custom one with specific configuration:

```
-- Use the default logger
local log = require('plenary.log')
log.info("Using the default logger")

-- Create a custom logger
local custom_log = require('plenary.log').new({
  plugin = "my_plugin",
  level = "debug",
  use_console = "sync",
  use_file = true,
  outfile = "my_plugin.log"
})
custom_log.debug("Using a custom logger")
```
```
Logger Creation.new(config)Default LoggerDefault ConfigurationCustom LoggerCustom Configurationrequire('plenary.log')Standard Log MethodsCustom-configured Log MethodsOutput with Default SettingsOutput with Custom Settings
```

Sources: [lua/plenary/log.lua 79-230](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L79-L230)

## Logging Methods

The logging system provides several types of logging methods for different use cases:

### Standard Logging Methods

These methods accept any number of arguments, which are converted to strings and concatenated with spaces:

```
log.trace("Detailed", "trace", "information")
log.debug("Debug", "message")
log.info("Informational message")
log.warn("Warning:", "something", "might", "be", "wrong")
log.error("Error occurred:", err)
log.fatal("Fatal error:", err)
```

Sources: [lua/plenary/log.lua 108-124](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L108-L124) [lua/plenary/log.lua 194-196](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L194-L196)

### Formatted Logging Methods

These methods accept a format string followed by arguments, similar to `string.format`:

```
log.fmt_info("User %s logged in with role %s", username, role)
log.fmt_error("Failed to process %s: %s", filename, err)
```

Sources: [lua/plenary/log.lua 199-209](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L199-L209)

### Lazy Logging Methods

These methods accept a function that will only be called if the log level is enabled, useful for expensive operations:

```
log.lazy_debug(function()
  return "Result of expensive calculation: " .. calculate_expensive_value()
end)
```

Sources: [lua/plenary/log.lua 212-216](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L212-L216)

### File-only Logging Methods

These methods log only to the file (not to console), useful for very verbose logging:

```
log.file_debug({"Verbose", "debug", "output"}, {info_level = 2})
```

Sources: [lua/plenary/log.lua 219-226](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L219-L226)

## Log Message Flow

```
"Quickfix List""Log File""Neovim Console""Message Formatter""Level Filter""Plenary Logger""Plugin Code""Quickfix List""Log File""Neovim Console""Message Formatter""Level Filter""Plenary Logger""Plugin Code"alt[Console outputenabled]alt[File output enabled]alt[Quickfix output enabled]log.info("message")Check if info >= configured levelLevel is enabledGet source info (file, line)Format messageFormatted messageFormatted messageAdd entry
```

Sources: [lua/plenary/log.lua 126-190](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L126-L190)

## Internal Implementation

The logging system is built around a central `log_at_level` function that:

1. Checks if the requested log level is enabled
2. Formats the message using a message maker function
3. Gets debug information to identify the source location
4. Outputs the formatted message to enabled targets (console, file, quickfix)

The log object methods are dynamically created for each configured log level, with variants for different logging approaches (standard, formatted, lazy, file-only).

Sources: [lua/plenary/log.lua 126-190](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L126-L190) [lua/plenary/log.lua 192-227](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L192-L227)

## Example Usage in a Plugin

Here's how a plugin might use the plenary logging system:

```
-- In your plugin's setup
local log = require('plenary.log').new({
  plugin = "my_awesome_plugin",
  level = vim.env.PLUGIN_DEBUG and "debug" or "info"
})

-- Throughout your plugin code
local function process_file(filename)
  log.debug("Processing file:", filename)
  
  if not vim.fn.filereadable(filename) then
    log.error("File not readable:", filename)
    return false
  end
  
  log.info("Successfully processed", filename)
  return true
end
```

## Best Practices

1. **Create a custom logger** for your plugin with a specific name to distinguish your logs
2. **Set appropriate log levels** - use debug/trace during development, info/warn in production
3. **Use lazy logging** for expensive operations
4. **Use formatted logging** for complex messages to improve readability
5. **Allow users to configure the log level** through environment variables or plugin settings

Sources: [lua/plenary/log.lua 1-235](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/log.lua#L1-L235)

<svg id="mermaid-o05b9awrxd" width="100%" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 2412 512" style="max-width: 512px;" role="graphics-document document" aria-roledescription="error"><g></g><g><path class="error-icon" d="m411.313,123.313c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32-9.375,9.375-20.688-20.688c-12.484-12.5-32.766-12.5-45.25,0l-16,16c-1.261,1.261-2.304,2.648-3.31,4.051-21.739-8.561-45.324-13.426-70.065-13.426-105.867,0-192,86.133-192,192s86.133,192 192,192 192-86.133 192-192c0-24.741-4.864-48.327-13.426-70.065 1.402-1.007 2.79-2.049 4.051-3.31l16-16c12.5-12.492 12.5-32.758 0-45.25l-20.688-20.688 9.375-9.375 32.001-31.999zm-219.313,100.687c-52.938,0-96,43.063-96,96 0,8.836-7.164,16-16,16s-16-7.164-16-16c0-70.578 57.422-128 128-128 8.836,0 16,7.164 16,16s-7.164,16-16,16z"></path><path class="error-icon" d="m459.02,148.98c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l16,16c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16.001-16z"></path><path class="error-icon" d="m340.395,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16-16c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l15.999,16z"></path><path class="error-icon" d="m400,64c8.844,0 16-7.164 16-16v-32c0-8.836-7.156-16-16-16-8.844,0-16,7.164-16,16v32c0,8.836 7.156,16 16,16z"></path><path class="error-icon" d="m496,96.586h-32c-8.844,0-16,7.164-16,16 0,8.836 7.156,16 16,16h32c8.844,0 16-7.164 16-16 0-8.836-7.156-16-16-16z"></path><path class="error-icon" d="m436.98,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688l32-32c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32c-6.251,6.25-6.251,16.375-0.001,22.625z"></path><text class="error-text" x="1440" y="250" font-size="150px" style="text-anchor: middle;">Syntax error in text</text> <text class="error-text" x="1250" y="400" font-size="100px" style="text-anchor: middle;">mermaid version 11.6.0</text></g></svg>
