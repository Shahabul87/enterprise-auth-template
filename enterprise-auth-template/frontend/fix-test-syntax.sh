#!/bin/bash

# Script to fix common syntax errors in test files

echo "Fixing common syntax errors in test files..."

# Find all test files with potential issues
TEST_FILES=$(find src/__tests__ -name "*.test.ts" -o -name "*.test.tsx")

for file in $TEST_FILES; do
  echo "Checking $file..."

  # Check for unmatched jest.mock calls
  if grep -q "^jest.mock(" "$file"; then
    # Count opening and closing parentheses for jest.mock
    OPEN_COUNT=$(grep -o "jest.mock(" "$file" | wc -l)
    CLOSE_COUNT=$(grep -o "}));" "$file" | wc -l)

    if [ $OPEN_COUNT -ne $CLOSE_COUNT ]; then
      echo "  - Found unmatched jest.mock in $file"
    fi
  fi

  # Check for unmatched describe blocks
  DESCRIBE_COUNT=$(grep "^describe(" "$file" | wc -l)
  NESTED_DESCRIBE_COUNT=$(grep "^  describe(" "$file" | wc -l)
  TOTAL_DESCRIBE=$((DESCRIBE_COUNT + NESTED_DESCRIBE_COUNT))

  # Count closing });
  CLOSE_COUNT=$(grep "^});" "$file" | wc -l)
  NESTED_CLOSE_COUNT=$(grep "^  });" "$file" | wc -l)
  TOTAL_CLOSE=$((CLOSE_COUNT + NESTED_CLOSE_COUNT))

  if [ $TOTAL_DESCRIBE -ne $TOTAL_CLOSE ]; then
    echo "  - Found unmatched describe blocks in $file (describes: $TOTAL_DESCRIBE, closes: $TOTAL_CLOSE)"
  fi
done

echo "Analysis complete. Please manually review and fix the identified issues."