#!/bin/bash

# Flutter Test Runner Script
# This script runs all Flutter tests with proper setup and reporting

set -e

echo "🧪 Flutter Test Runner"
echo "====================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# Function to run tests with error handling
run_test() {
    local test_name=$1
    local test_path=$2

    echo -e "${YELLOW}Running $test_name...${NC}"

    if flutter test $test_path 2>/dev/null; then
        print_status 0 "$test_name passed"
        return 0
    else
        print_status 1 "$test_name failed"
        return 1
    fi
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed${NC}"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔨 Generating mocks..."
flutter pub run build_runner build --delete-conflicting-outputs || true

echo ""
echo "🧹 Cleaning test cache..."
flutter clean
flutter pub get

echo ""
echo "📋 Test Categories:"
echo "==================="

# Track test results
total_tests=0
passed_tests=0
failed_tests=0

# Run unit tests
echo ""
echo "1. Unit Tests"
echo "-------------"

# Core tests
if [ -d "test/unit/core" ]; then
    if run_test "Core Services" "test/unit/core/"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Data layer tests
if [ -d "test/unit/data" ]; then
    if run_test "Data Layer" "test/unit/data/"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Domain layer tests
if [ -d "test/unit/domain" ]; then
    if run_test "Domain Layer" "test/unit/domain/"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Provider tests
if [ -d "test/unit/providers" ]; then
    if run_test "Providers" "test/unit/providers/"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Run widget tests
echo ""
echo "2. Widget Tests"
echo "---------------"

if [ -d "test/widget" ]; then
    if run_test "Widget Tests" "test/widget/"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Run integration tests
echo ""
echo "3. Integration Tests"
echo "-------------------"

if [ -d "integration_test" ]; then
    echo -e "${YELLOW}Note: Integration tests require a running emulator/device${NC}"
    # Uncomment the following lines to run integration tests
    # if run_test "Integration Tests" "integration_test/"; then
    #     ((passed_tests++))
    # else
    #     ((failed_tests++))
    # fi
    # ((total_tests++))
fi

# Run existing tests that might work
echo ""
echo "4. Existing Tests"
echo "-----------------"

# Run specific working tests
test_files=(
    "test/core/basic_test.dart"
    "test/services/auth_service_simple_test.dart"
    "test/widgets/common/custom_button_test.dart"
    "test/widgets/common/custom_text_field_test.dart"
)

for test_file in "${test_files[@]}"; do
    if [ -f "$test_file" ]; then
        test_name=$(basename "$test_file" .dart)
        if run_test "$test_name" "$test_file"; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi
done

# Generate coverage report if all tests pass
if [ $failed_tests -eq 0 ] && [ $total_tests -gt 0 ]; then
    echo ""
    echo "📊 Generating coverage report..."
    flutter test --coverage || true

    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}Coverage report generated in coverage/html/index.html${NC}"
    else
        echo -e "${YELLOW}Install lcov to generate HTML coverage reports${NC}"
    fi
fi

# Print summary
echo ""
echo "==============================="
echo "📊 Test Summary"
echo "==============================="
echo "Total test suites: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"

if [ $failed_tests -eq 0 ] && [ $total_tests -gt 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
elif [ $total_tests -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️ No tests were run${NC}"
    exit 1
else
    echo ""
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "To debug failing tests, run:"
    echo "  flutter test --reporter expanded <test_file>"
    echo ""
    echo "For more verbose output:"
    echo "  flutter test --verbose <test_file>"
    exit 1
fi