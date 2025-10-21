-- Quick validation script for keymap test suite
-- Tests that all split test files load and execute correctly

local test_files = {
  "tests/unit/keymap/cleanup_spec.lua",
  "tests/unit/keymap/loading_spec.lua",
  "tests/unit/keymap/registry_spec.lua",
  "tests/unit/keymap/syntax_spec.lua",
  "tests/unit/keymap/namespace_spec.lua",
}

local success_count = 0
local total_count = #test_files

print("Validating Keymap Test Suite...")
print("================================")

for _, test_file in ipairs(test_files) do
  print("\nTesting: " .. test_file)

  -- Try to load the test file
  local success, err = pcall(dofile, test_file)

  if success then
    print("✓ PASSED - File loads and executes correctly")
    success_count = success_count + 1
  else
    print("✗ FAILED - Error: " .. tostring(err))
  end
end

print("\n================================")
print(string.format("Results: %d/%d tests passed", success_count, total_count))

if success_count == total_count then
  print("✓ All tests passed!")
  os.exit(0)
else
  print("✗ Some tests failed")
  os.exit(1)
end
