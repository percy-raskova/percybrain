---
title: " UI Components  UI Components | nvim-lua/plenary.nvim"
author:
published:    UI Components | nvim-lua/plenary.nvim | DeepWiki
description: "   nvim-lua/plenary.nvim"
source: "https://deepwiki.com/nvim-lua/plenary.nvim/5-ui-components"
created: 2025-10-18
category: "category:   [\"nvim-lua\",\"plenary.nvim\",\"5-ui-components\"]"
tags:
  - "tags:"
image: "image:    "
cover: "cover: "
---
Menu

## UI Components

Relevant source files
- [POPUP.md](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/POPUP.md)
- [lua/plenary/nvim\_meta.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/nvim_meta.lua)
- [lua/plenary/popup/init.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua)
- [lua/plenary/popup/utils.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/utils.lua)
- [lua/plenary/run.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/run.lua)
- [lua/plenary/window/border.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua)
- [lua/plenary/window/float.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua)
- [tests/plenary/popup\_requires\_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/popup_requires_spec.lua)
- [tests/plenary/popup\_spec.lua](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/popup_spec.lua)

This page documents the user interface components provided by plenary.nvim. These components help plugin developers create rich and interactive UI elements in Neovim with minimal effort, handling common tasks like window creation, borders, and positioning.

For information about the HTTP client features that might be used within UI components, see [HTTP Client](https://deepwiki.com/nvim-lua/plenary.nvim/6-http-client).

## Component Overview

Plenary provides three main UI component systems:

1. **Border** - A system for creating and managing borders around windows
2. **Popup** - A wrapper for Vim's popup API in Neovim
3. **Float** - Utilities for creating floating windows with specific layouts
```
External UsageUI Component Hierarchyplenary.popup
Vim-compatible popup API wrapperplenary.window.border
Border renderer for windowsplenary.window.float
Floating window utilitiesNeovim Plugin
```

Sources: [lua/plenary/popup/init.lua 8-10](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L8-L10) [lua/plenary/window/float.lua 1-2](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L1-L2)

## Border System

The Border system provides a way to create and manage borders around windows in Neovim. It's a core building block used by both the popup and floating window systems.

### Border Class

The `Border` class is a metatable-based "class" that manages the creation and display of borders around content windows. It handles automatic cleanup when the content window is closed.

```
Border+bufnr: number+win_id: number+content_win_id: number+content_win_options: table+_border_win_options: table+contents: table+title_ranges: table+new(content_bufnr, content_win_id, content_win_options, border_win_options) : : Border+move(content_win_options, border_win_options) : : void+change_title(new_title, pos) : : void-__align_calc_config(content_win_options, border_win_options) : : table-_create_lines(content_win_id, content_win_options, border_win_options) : : table, table
```

Sources: [lua/plenary/window/border.lua 3-295](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L3-L295)

### Border Creation and Configuration

The Border constructor takes:

- A buffer number for the content window
- A window ID for the content window
- Content window options (positioning, size)
- Border window options (characters, thickness, title)

The border can be customized with different characters for each edge and corner:

```
topleft    top    topright
   ╔═══════════════╗
   ║               ║
left                right
   ║               ║
   ╚═══════════════╝
botleft    bot    botright
```

Border thickness can be configured for each side independently:

```
border_thickness = {
  top = 1,
  right = 1,
  bot = 1,
  left = 1
}
```

Sources: [lua/plenary/window/border.lua 7-12](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L7-L12) [lua/plenary/window/border.lua 196-211](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L196-L211)

### Title Support

The Border system supports adding titles at various positions:

- "N" (North/top)
- "S" (South/bottom)
- "NW", "NE", "SW", "SE" (corners)

The title text is displayed in the border with proper truncation if it's too long. Title highlighting can be applied separately from the border highlighting.

Sources: [lua/plenary/window/border.lua 14-56](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L14-L56) [lua/plenary/window/border.lua 176-194](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L176-L194)

## Popup System

The popup system provides a wrapper around Vim's popup API for Neovim. It aims to be compatible with Vim's `popup_*` functions while working with Neovim's floating window capabilities.

```
Popup Managementpopup.move(win_id, vim_options)Update window positionUpdate border if presentpopup.execute_callback(bufnr)Popup Creation Flowpopup.create(what, vim_options)Setup content bufferCalculate positionOpen content windowCreate border if requested
```

Sources: [lua/plenary/popup/init.lua 115-443](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L115-L443) [lua/plenary/popup/init.lua 455-487](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L455-L487)

### Creating Popups

The `popup.create` function takes:

1. Content (`what`) - Can be a string, list of strings, or a buffer number
2. Options (`vim_options`) - Configuration for the popup
```
local win_id = popup.create("Hello World", {
  line = 5,
  col = 10,
  width = 40,
  height = 5,
  border = true,
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  title = "My Popup",
  highlight = "MyHighlightGroup"
})
```

Sources: [lua/plenary/popup/init.lua 115-443](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L115-L443)

### Supported Options

The popup system supports many of the same options as Vim's popup API:

| Option | Description |
| --- | --- |
| `line`, `col` | Position of the popup (1-based) |
| `pos` | Position anchor ("topleft", "topright", "botleft", "botright", "center") |
| `width`, `height` | Size of the popup |
| `border` | Boolean or table specifying border thickness |
| `borderchars` | Characters to use for border edges and corners |
| `title` | Title text to display in the border |
| `highlight` | Highlight group for popup content |
| `borderhighlight` | Highlight group for border |
| `titlehighlight` | Highlight group for title |
| `padding` | Padding around content (similar to CSS padding) |
| `zindex` | Z-index for stacking order (1-32000) |
| `time` | Auto-close after specified milliseconds |
| `moved` | Close when cursor moves |
| `callback` | Function to call when popup item is selected |

Sources: [lua/plenary/popup/init.lua 28-372](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L28-L372) [POPUP.md 44-72](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/POPUP.md#L44-L72)

### Moving Popups

The `popup.move` function allows updating the position and size of an existing popup:

```
popup.move(win_id, {
  line = 10,
  col = 20,
  width = 30,
  height = 4
})
```

This will update both the content window and its border if present.

Sources: [lua/plenary/popup/init.lua 455-479](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L455-L479)

## Floating Window Utilities

The `plenary.window.float` module provides utilities for creating floating windows with specific layouts and behaviors.

```
Common FlowFloating Window Typeswin_float.centered(options)
Creates centered windowwin_float.percentage_range_window(col_range, row_range, win_opts, border_opts)
Creates window by screen percentageCalculate window optionsCreate bufferOpen windowAdd borderSetup auto-cleanup
```

Sources: [lua/plenary/window/float.lua 16-212](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L16-L212)

### Centered Windows

The `centered` function creates a floating window centered in the editor:

```
local win = win_float.centered({
  winblend = 10,  -- transparency level
  percentage = 0.8  -- percentage of screen to occupy
})
```

This returns a table with `bufnr` and `win_id` for the created window.

Sources: [lua/plenary/window/float.lua 44-61](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L44-L61)

### Windows with Header

The `centered_with_top_win` function creates two connected windows - one for a header and one for content:

```
local win = win_float.centered_with_top_win(
  {"Header line 1", "Header line 2"},
  {winblend = 10}
)
```

This is useful for creating split UIs with a title/information area and a content area.

Sources: [lua/plenary/window/float.lua 63-125](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L63-L125)

### Percentage-Based Windows

The `percentage_range_window` function creates a window based on percentage ranges of the screen:

```
local win = win_float.percentage_range_window(
  0.8,  -- width percentage (or [start, end] table)
  0.7,  -- height percentage (or [start, end] table)
  {winblend = 10},  -- window options
  {title = "My Window"}  -- border options
)
```

This is useful for creating windows with precise positioning relative to the screen size.

Sources: [lua/plenary/window/float.lua 138-196](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L138-L196)

## Integration Between Components

The UI components are designed to work together, with borders being a foundational component used by both popup and floating windows.

```
ImplementationHigh-Level APIsExternal PluginPlugin Codepopup.create()win_float.centered()win_float.centered_with_top_win()win_float.percentage_range_window()Border:new()nvim_open_win()
```

Sources: [lua/plenary/popup/init.lua 385-386](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L385-L386) [lua/plenary/window/float.lua 106-107](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L106-L107) [lua/plenary/window/float.lua 183](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L183-L183)

## Usage Examples

### Creating a Simple Popup

```
local popup = require("plenary.popup")

local win_id = popup.create("Hello, World!", {
  line = 5,
  col = 10,
  width = 20,
  height = 1,
  border = true,
  title = "Greeting"
})
```

### Creating a Floating Window with Border

```
local float = require("plenary.window.float")

local win = float.percentage_range_window(
  0.6,  -- width is 60% of screen
  0.4,  -- height is 40% of screen
  {winblend = 10},
  {title = "My Floating Window"}
)

-- Later, when done with the window
float.clear(win.bufnr)
```

### Creating a Two-Part Window

```
local float = require("plenary.window.float")

local win = float.centered_with_top_win(
  {"Title", "Subtitle"},  -- Header content
  {percentage = 0.8}  -- Options
)

-- Use win.bufnr for main content
-- Use win.minor_bufnr for header content
```

Sources: [tests/plenary/popup\_spec.lua 15-23](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/tests/plenary/popup_spec.lua#L15-L23) [lua/plenary/window/float.lua 44-61](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L44-L61) [lua/plenary/window/float.lua 63-125](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L63-L125)

## Autocleaning and Event Handling

All UI components have built-in autocleaning to prevent window/buffer leaks:

- Popup windows register autocmds to clean up when the buffer is deleted
- Floating windows register autocmds to clean up associated windows
- Borders automatically close when their content window closes
```
"Neovim API""UI Component""Plugin""Neovim API""UI Component""Plugin"User interaction periodCreate windowCreate buffer(s)Open window(s)Register autocmds for cleanupBuffer or window close eventTrigger cleanup autocmdClose remaining windowsClean up buffers
```

Sources: [lua/plenary/popup/init.lua 253-261](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/popup/init.lua#L253-L261) [lua/plenary/window/border.lua 273-288](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/border.lua#L273-L288) [lua/plenary/window/float.lua 6-14](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/lua/plenary/window/float.lua#L6-L14)

## Limitations and Future Work

As noted in the `POPUP.md` file, there are several features from Vim's popup API that are not yet implemented:

- Some mouse interactions (drag, resize, close)
- Scrollbars for floating windows
- Text property tracking
- Some advanced features like `flip` and `fixed`

For a detailed status of implementation, refer to the [POPUP.md file](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/POPUP.md%20file)

Sources: [POPUP.md 13-89](https://github.com/nvim-lua/plenary.nvim/blob/857c5ac6/POPUP.md#L13-L89)

<svg id="mermaid-o05b9awrxd" width="100%" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 2412 512" style="max-width: 512px;" role="graphics-document document" aria-roledescription="error"><g></g><g><path class="error-icon" d="m411.313,123.313c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32-9.375,9.375-20.688-20.688c-12.484-12.5-32.766-12.5-45.25,0l-16,16c-1.261,1.261-2.304,2.648-3.31,4.051-21.739-8.561-45.324-13.426-70.065-13.426-105.867,0-192,86.133-192,192s86.133,192 192,192 192-86.133 192-192c0-24.741-4.864-48.327-13.426-70.065 1.402-1.007 2.79-2.049 4.051-3.31l16-16c12.5-12.492 12.5-32.758 0-45.25l-20.688-20.688 9.375-9.375 32.001-31.999zm-219.313,100.687c-52.938,0-96,43.063-96,96 0,8.836-7.164,16-16,16s-16-7.164-16-16c0-70.578 57.422-128 128-128 8.836,0 16,7.164 16,16s-7.164,16-16,16z"></path><path class="error-icon" d="m459.02,148.98c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l16,16c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16.001-16z"></path><path class="error-icon" d="m340.395,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688 6.25-6.25 6.25-16.375 0-22.625l-16-16c-6.25-6.25-16.375-6.25-22.625,0s-6.25,16.375 0,22.625l15.999,16z"></path><path class="error-icon" d="m400,64c8.844,0 16-7.164 16-16v-32c0-8.836-7.156-16-16-16-8.844,0-16,7.164-16,16v32c0,8.836 7.156,16 16,16z"></path><path class="error-icon" d="m496,96.586h-32c-8.844,0-16,7.164-16,16 0,8.836 7.156,16 16,16h32c8.844,0 16-7.164 16-16 0-8.836-7.156-16-16-16z"></path><path class="error-icon" d="m436.98,75.605c3.125,3.125 7.219,4.688 11.313,4.688 4.094,0 8.188-1.563 11.313-4.688l32-32c6.25-6.25 6.25-16.375 0-22.625s-16.375-6.25-22.625,0l-32,32c-6.251,6.25-6.251,16.375-0.001,22.625z"></path><text class="error-text" x="1440" y="250" font-size="150px" style="text-anchor: middle;">Syntax error in text</text> <text class="error-text" x="1250" y="400" font-size="100px" style="text-anchor: middle;">mermaid version 11.6.0</text></g></svg>
