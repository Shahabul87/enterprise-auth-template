#!/bin/bash

# Optimized Flutter Test Runner - Runs tests folder by folder with results
# This prevents resource exhaustion and provides clear progress feedback

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONCURRENCY=2
TIMEOUT="5m"
RESULTS_DIR="test_results"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Create results directory
mkdir -p $RESULTS_DIR

# Initialize summary
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
FAILED_FOLDERS=()

echo -e "${BLUE}🚀 Starting Organized Flutter Test Runner${NC}"
echo -e "${BLUE}Timestamp: $(date)${NC}"
echo -e "${BLUE}Configuration: Concurrency=$CONCURRENCY, Timeout=$TIMEOUT${NC}"
echo "==============================================="

# Function to run tests for a specific folder
run_folder_tests() {
    local folder=$1
    local folder_name=$(basename "$folder")

    echo -e "\n${YELLOW}📁 Testing folder: $folder${NC}"
    echo "-----------------------------------------------"

    # Check if folder has test files
    if ! find "$folder" -name "*.dart" -type f | grep -q .; then
        echo -e "${YELLOW}⚠️  No test files found in $folder${NC}"
        return 0
    fi

    # Run tests with timeout and capture output
    local output_file="$RESULTS_DIR/${folder_name}_${TIMESTAMP}.txt"
    local start_time=$(date +%s)

    if timeout $TIMEOUT flutter test "$folder" \
        --concurrency=$CONCURRENCY \
        --reporter=expanded \
        2>&1 | tee "$output_file"; then

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Parse results
        local passed=$(grep -c "PASS" "$output_file" 2>/dev/null || echo "0")
        local failed=$(grep -c "FAIL" "$output_file" 2>/dev/null || echo "0")

        TOTAL_PASSED=$((TOTAL_PASSED + passed))
        TOTAL_FAILED=$((TOTAL_FAILED + failed))

        echo -e "${GREEN}✅ $folder completed in ${duration}s${NC}"
        echo -e "${GREEN}   Passed: $passed, Failed: $failed${NC}"

        if [ "$failed" -gt 0 ]; then
            FAILED_FOLDERS+=("$folder")
        fi

    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo -e "${RED}❌ $folder failed or timed out after ${duration}s${NC}"
        FAILED_FOLDERS+=("$folder")
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi

    # Clean up any hanging processes
    pkill -f flutter_tester 2>/dev/null || true
    pkill -f dart 2>/dev/null || true

    # Brief pause to let system recover
    sleep 2
}

# Function to run tests for individual files in a folder
run_individual_files() {
    local folder=$1
    echo -e "\n${YELLOW}📄 Running individual files in $folder${NC}"

    find "$folder" -name "*_test.dart" -type f | while read -r test_file; do
        local file_name=$(basename "$test_file" .dart)
        echo -e "${BLUE}  Testing: $test_file${NC}"

        local output_file="$RESULTS_DIR/${file_name}_${TIMESTAMP}.txt"

        if timeout 2m flutter test "$test_file" \
            --concurrency=1 \
            --reporter=compact \
            2>&1 | tee "$output_file"; then
            echo -e "${GREEN}    ✅ $test_file passed${NC}"
        else
            echo -e "${RED}    ❌ $test_file failed${NC}"
        fi

        # Clean up after each file
        pkill -f flutter_tester 2>/dev/null || true
        sleep 1
    done
}

# Main test folders to run (organized by priority and complexity)
TEST_FOLDERS=(
    "test/core/basic_test.dart"
    "test/unit/core"
    "test/unit/data"
    "test/unit/domain"
    "test/core/error"
    "test/core/network"
    "test/core/security"
    "test/core/services"
    "test/data/models"
    "test/data/services"
    "test/services"
    "test/providers"
    "test/unit/providers"
    "test/widget/pages"
    "test/widget/auth"
    "test/widgets/common"
    "test/screens/auth"
    "test/presentation/pages"
    "test/presentation/widgets"
    "test/integration"
)

# Run pub get first
echo -e "${BLUE}📦 Running flutter pub get...${NC}"
flutter pub get

# Run tests folder by folder
for folder in "${TEST_FOLDERS[@]}"; do
    if [ -e "$folder" ]; then
        run_folder_tests "$folder"
    else
        echo -e "${YELLOW}⚠️  Folder not found: $folder${NC}"
    fi
done

# Generate final summary
echo ""
echo "==============================================="
echo -e "${BLUE}📊 FINAL TEST SUMMARY${NC}"
echo "==============================================="
echo -e "Total Passed: ${GREEN}$TOTAL_PASSED${NC}"
echo -e "Total Failed: ${RED}$TOTAL_FAILED${NC}"
echo -e "Success Rate: $(( TOTAL_PASSED * 100 / (TOTAL_PASSED + TOTAL_FAILED) 2>/dev/null || echo 0 ))%"

if [ ${#FAILED_FOLDERS[@]} -gt 0 ]; then
    echo -e "\n${RED}❌ Failed Folders:${NC}"
    for folder in "${FAILED_FOLDERS[@]}"; do
        echo -e "  - ${RED}$folder${NC}"
    done

    echo -e "\n${YELLOW}🔄 Re-running failed folders with individual file testing...${NC}"
    for folder in "${FAILED_FOLDERS[@]}"; do
        run_individual_files "$folder"
    done
fi

# Save summary to file
{
    echo "Flutter Test Summary - $TIMESTAMP"
    echo "=================================="
    echo "Total Passed: $TOTAL_PASSED"
    echo "Total Failed: $TOTAL_FAILED"
    echo "Failed Folders: ${FAILED_FOLDERS[*]}"
    echo "Results saved in: $RESULTS_DIR/"
} > "$RESULTS_DIR/summary_${TIMESTAMP}.txt"

echo -e "\n${BLUE}📁 All results saved in: $RESULTS_DIR/${NC}"
echo -e "${BLUE}📄 Summary saved in: $RESULTS_DIR/summary_${TIMESTAMP}.txt${NC}"

if [ "$TOTAL_FAILED" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some tests failed. Check individual result files for details.${NC}"
    exit 1
fi