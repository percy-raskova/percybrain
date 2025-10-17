#!/bin/bash
# Fix nested plugin specs that have only one plugin
# Converts: return { { "repo" } } → return { "repo" }

set -euo pipefail

echo "🔧 Fixing nested plugin specs..."

for file in lua/plugins/*.lua; do
  # Skip init.lua and lsp directory
  [[ "$file" == "lua/plugins/init.lua" ]] && continue
  [[ "$file" == lua/plugins/lsp/* ]] && continue

  # Check if file has pattern: return { \n  { "..." }, \n}
  # with exactly ONE plugin spec

  if grep -Pzq 'return \{\s*\{\s*"[^"]+"\s*\},\s*\}' "$file"; then
    # Count number of inner specs
    spec_count=$(grep -c '{\s*"' "$file" || true)

    if [[ $spec_count -eq 1 ]]; then
      echo "  Fixing: $file"
      # Use sed to unwrap the nested table
      sed -i -E 's/^return \{$/return /' "$file"
      sed -i -E 's/^\s*\{\s*(".*")\s*\},?$/  \1,/' "$file"
      sed -i -E 's/^  \},?$/}/' "$file"
      # Clean up extra blank lines
      sed -i '/^$/N;/^\n$/D' "$file"
    fi
  fi
done

echo "✅ Done!"
