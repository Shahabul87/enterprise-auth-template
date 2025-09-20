#!/bin/bash

# Quick Test Runner - Simple, fast testing for immediate feedback
# Use this for quick validation during development

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚡ Quick Flutter Test Runner${NC}"
echo -e "${BLUE}Testing core functionality only...${NC}"
echo "=================================="

# Clean up any hanging processes first
pkill -f flutter_tester 2>/dev/null || true
pkill -f dart 2>/dev/null || true

# Test the most important files first
QUICK_TESTS=(
    "test/core/basic_test.dart"
    "test/unit/core"
    "test/services/auth_service_test.dart"
    "test/providers/auth_provider_test.dart"
)

TOTAL_PASSED=0
TOTAL_FAILED=0

for test_target in "${QUICK_TESTS[@]}"; do
    if [ -e "$test_target" ]; then
        echo -e "\n${YELLOW}🧪 Testing: $test_target${NC}"

        if flutter test "$test_target" \
            --concurrency=1 \
            --reporter=compact \
            --timeout=2m; then

            echo -e "${GREEN}✅ $test_target passed${NC}"
            TOTAL_PASSED=$((TOTAL_PASSED + 1))
        else
            echo -e "${RED}❌ $test_target failed${NC}"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi

        # Brief cleanup between tests
        pkill -f flutter_tester 2>/dev/null || true
        sleep 1
    else
        echo -e "${YELLOW}⚠️  Not found: $test_target${NC}"
    fi
done

echo ""
echo "=================================="
echo -e "${BLUE}📊 Quick Test Summary${NC}"
echo "=================================="
echo -e "Passed: ${GREEN}$TOTAL_PASSED${NC}"
echo -e "Failed: ${RED}$TOTAL_FAILED${NC}"

if [ "$TOTAL_FAILED" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Quick tests passed! Ready for full test suite.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some quick tests failed. Fix these before running full suite.${NC}"
    exit 1
fi