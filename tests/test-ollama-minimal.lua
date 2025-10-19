-- Minimal diagnostic test for Ollama vim.inspect issue
print("=== Ollama Test Diagnostic ===")

-- Check vim.inspect availability
print("1. vim.inspect type:", type(vim.inspect))

if type(vim.inspect) == "function" then
  print("2. ✅ vim.inspect is a function")
  print("3. Test: vim.inspect({a=1})")
  print(vim.inspect({a=1, b=2}))
else
  print("2. ❌ vim.inspect is NOT a function, it's:", type(vim.inspect))
end

-- Check vim.cmd availability
print("4. vim.cmd type:", type(vim.cmd))

-- Try creating a mock vim
print("\n=== Creating Mock Vim ===")
local mock_vim = {
  inspect = function(obj)
    return tostring(obj)
  end,
  cmd = function(cmd)
    print("Mock cmd:", cmd)
  end
}

print("5. mock_vim.inspect type:", type(mock_vim.inspect))
print("6. mock_vim.cmd type:", type(mock_vim.cmd))

-- Try loading Plenary
print("\n=== Loading Plenary ===")
local ok, plenary = pcall(require, 'plenary')
if ok then
  print("7. ✅ Plenary loaded successfully")
else
  print("7. ❌ Plenary failed to load:", plenary)
end

print("\n=== Test Complete ===")
