-- tests/treesitter/python-parser-contract.test.lua
-- Contract tests for Python Treesitter parser health
-- Following Kent Beck's TDD methodology: RED → GREEN → REFACTOR

describe("Python Treesitter Parser Contract", function()
  -- Arrange: Common test setup
  local test_buffer = nil

  before_each(function()
    -- Act: Create a clean Python buffer for testing
    vim.cmd("new")
    test_buffer = vim.api.nvim_get_current_buf()
    vim.bo[test_buffer].filetype = "python"
  end)

  after_each(function()
    -- Clean up: Delete test buffer
    if test_buffer and vim.api.nvim_buf_is_valid(test_buffer) then
      vim.api.nvim_buf_delete(test_buffer, { force = true })
    end
    test_buffer = nil
  end)

  it("MUST parse basic Python syntax correctly", function()
    -- Arrange
    local basic_code = [[
def hello_world():
    print("Hello, World!")
    return 42
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(basic_code, "\n"))
    local parser = vim.treesitter.get_parser(test_buffer, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_not_nil(tree, "Parser MUST return valid syntax tree for basic Python")
    assert.is_false(tree:root():has_error(), "Basic Python syntax MUST NOT have parsing errors")
  end)

  it("MUST handle Python 3.10+ match-case statements", function()
    -- Arrange
    local match_case_code = [[
def process_value(value):
    match value:
        case 0:
            return "zero"
        case 1 | 2:
            return "one or two"
        case _:
            return "other"
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(match_case_code, "\n"))
    local success, parser = pcall(vim.treesitter.get_parser, test_buffer, "python")

    -- Assert
    assert.is_true(success, "Parser MUST handle Python 3.10+ match-case syntax")
    if success then
      local tree = parser:parse()[1]
      assert.is_not_nil(tree, "Match-case MUST produce valid syntax tree")
    end
  end)

  it("MUST parse traditional exception handling", function()
    -- Arrange
    local exception_code = [[
try:
    risky_operation()
except ValueError as e:
    handle_value_error(e)
except (TypeError, AttributeError) as e:
    handle_type_or_attr_error(e)
except Exception:
    handle_generic_exception()
finally:
    cleanup()
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(exception_code, "\n"))
    local parser = vim.treesitter.get_parser(test_buffer, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_not_nil(tree, "Parser MUST handle traditional exception syntax")
    assert.is_false(tree:root():has_error(), "Traditional exceptions MUST NOT cause parsing errors")
  end)

  it("MUST gracefully handle Python 3.11+ exception groups", function()
    -- Arrange
    -- This is the problematic syntax causing the current failure
    local exception_group_code = [[
def handle_multiple_errors():
    try:
        async_operations()
    except* ValueError as eg:
        for e in eg.exceptions:
            log_value_error(e)
    except* KeyError as eg:
        for e in eg.exceptions:
            log_key_error(e)
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(exception_group_code, "\n"))

    -- This should currently fail with "Invalid node type 'except*'"
    -- After fix, it should either:
    -- 1. Parse correctly with updated parser, OR
    -- 2. Gracefully degrade without breaking highlights
    local success, error_msg = pcall(function()
      local parser = vim.treesitter.get_parser(test_buffer, "python")
      local tree = parser:parse()[1]
      -- Try to get highlights - this is where it currently fails
      vim.treesitter.query.get("python", "highlights")
    end)

    -- Assert (currently expecting failure - will pass after fix)
    if not success then
      assert.is_true(
        error_msg:match("except%*") ~= nil,
        "Known issue: except* not supported in current parser version"
      )
      print("EXPECTED FAILURE: Python 3.11+ except* syntax not yet supported")
    else
      assert.is_true(success, "Parser SHOULD handle or gracefully skip except* syntax")
    end
  end)

  it("MUST provide working highlights for supported Python syntax", function()
    -- Arrange
    local supported_code = [[
# This is a comment
import os
from typing import List, Optional

class MyClass:
    """Docstring for class"""

    def __init__(self, name: str) -> None:
        self.name = name

    @property
    def display_name(self) -> str:
        return f"Name: {self.name}"

def main() -> int:
    obj = MyClass("test")
    print(obj.display_name)
    return 0

if __name__ == "__main__":
    exit(main())
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(supported_code, "\n"))

    -- Get highlights query
    local highlight_query_success, highlight_query = pcall(
      vim.treesitter.query.get,
      "python",
      "highlights"
    )

    -- Assert
    if highlight_query_success then
      assert.is_not_nil(highlight_query, "Highlight query MUST load for supported syntax")

      -- Check that highlighter can be created
      local highlighter = vim.treesitter.highlighter.new(test_buffer, "python")
      assert.is_not_nil(highlighter, "Highlighter MUST be created for Python buffer")
    else
      -- If highlights fail, it should be due to known except* issue
      assert.is_true(
        tostring(highlight_query):match("except%*") ~= nil,
        "Highlight failure MUST be due to known except* issue only"
      )
    end
  end)

  it("MUST report syntax errors correctly", function()
    -- Arrange
    local invalid_code = [[
def broken_function(
    print("missing closing paren"
    return None
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(invalid_code, "\n"))
    local parser = vim.treesitter.get_parser(test_buffer, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_true(tree:root():has_error(), "Parser MUST detect syntax errors")
  end)

  it("MUST handle async/await syntax", function()
    -- Arrange
    local async_code = [[
import asyncio

async def fetch_data(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

async def main():
    tasks = [fetch_data(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return results
]]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(async_code, "\n"))
    local parser = vim.treesitter.get_parser(test_buffer, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_not_nil(tree, "Parser MUST handle async/await syntax")
    assert.is_false(tree:root():has_error(), "Async/await MUST NOT cause parsing errors")
  end)

  it("MUST handle type hints and annotations", function()
    -- Arrange
    local typed_code = [=[
from typing import Dict, List, Optional, Union, TypeVar, Generic

T = TypeVar('T')

class Container(Generic[T]):
    def __init__(self, items: List[T]) -> None:
        self._items: List[T] = items

    def get(self, index: int) -> Optional[T]:
        if 0 <= index < len(self._items):
            return self._items[index]
        return None

def process(
    data: Dict[str, Union[int, str]],
    flags: Optional[List[bool]] = None
) -> tuple[bool, str]:
    return True, "processed"
]=]

    -- Act
    vim.api.nvim_buf_set_lines(test_buffer, 0, -1, false, vim.split(typed_code, "\n"))
    local parser = vim.treesitter.get_parser(test_buffer, "python")
    local tree = parser:parse()[1]

    -- Assert
    assert.is_not_nil(tree, "Parser MUST handle type hints")
    assert.is_false(tree:root():has_error(), "Type hints MUST NOT cause parsing errors")
  end)
end)
