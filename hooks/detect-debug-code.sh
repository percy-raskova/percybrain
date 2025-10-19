#!/bin/bash

# Debug Code Detector
# Catches leftover print statements, debug code, and incomplete TODOs
# Run: bash hooks/detect-debug-code.sh <file1.lua> <file2.lua> ...

exit_code=0
files=("$@")

if [ ${#files[@]} -eq 0 ]; then
  echo "❌ No files provided"
  exit 1
fi

for file in "${files[@]}"; do
  issues=()

  # Check for print() statements
  if grep -n "print(" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: print() statement found")
    done < <(grep -n "print(" "$file")
  fi

  # Check for vim.notify with DEBUG level
  if grep -n "vim\.notify.*DEBUG" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: DEBUG vim.notify found")
    done < <(grep -n "vim\.notify.*DEBUG" "$file")
  fi

  # Check for TODO/FIXME without issue reference
  if grep -n -e "-- TODO:" "$file" | grep -v "#[0-9]" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: TODO without issue reference (add #123)")
    done < <(grep -n -e "-- TODO:" "$file" | grep -v "#[0-9]")
  fi

  if grep -n -e "-- FIXME:" "$file" | grep -v "#[0-9]" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: FIXME without issue reference (add #123)")
    done < <(grep -n -e "-- FIXME:" "$file" | grep -v "#[0-9]")
  fi

  # Check for XXX markers
  if grep -n -e "-- XXX" "$file" > /dev/null 2>&1; then
    while IFS=: read -r line_num line_content; do
      issues+=("Line $line_num: XXX marker found (remove or convert to TODO #123)")
    done < <(grep -n -e "-- XXX" "$file")
  fi

  # Report issues
  if [ ${#issues[@]} -gt 0 ]; then
    echo "⚠️  $file: ${#issues[@]} debug code issue(s)"
    for issue in "${issues[@]}"; do
      echo "   ❌ $issue"
    done
    exit_code=1
  fi
done

exit $exit_code
