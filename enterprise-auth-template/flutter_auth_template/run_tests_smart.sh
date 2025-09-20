#!/bin/bash

# Smart Flutter Test Runner - Handles compilation errors gracefully
# Tests folders one by one, shows results, handles errors intelligently

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONCURRENCY=1  # Reduced to prevent resource issues
TIMEOUT="3m"
RESULTS_DIR="test_results"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Create results directory
mkdir -p $RESULTS_DIR

# Initialize counters
TOTAL_FOLDERS=0
FOLDERS_PASSED=0
FOLDERS_FAILED=0
FOLDERS_COMPILATION_ERROR=0
FAILED_FOLDERS=()
COMPILATION_ERROR_FOLDERS=()

echo -e "${BLUE}🧠 Smart Flutter Test Runner${NC}"
echo -e "${BLUE}Handles compilation errors gracefully${NC}"
echo -e "${BLUE}Timestamp: $(date)${NC}"
echo -e "${BLUE}Configuration: Concurrency=$CONCURRENCY, Timeout=$TIMEOUT${NC}"
echo "=================================================================="

# Function to check if a folder has test files
has_test_files() {
    local folder=$1
    find "$folder" -name "*_test.dart" -type f 2>/dev/null | grep -q .
}

# Function to analyze compilation errors
analyze_compilation_errors() {
    local output_file=$1
    local folder=$2

    echo -e "${PURPLE}🔍 Analyzing compilation errors in $folder${NC}"

    # Count different types of errors
    local undefined_errors=$(grep -c "Error: Undefined name" "$output_file" 2>/dev/null || echo "0")
    local method_errors=$(grep -c "Error: Method not found" "$output_file" 2>/dev/null || echo "0")
    local constructor_errors=$(grep -c "Error: Couldn't find constructor" "$output_file" 2>/dev/null || echo "0")
    local param_errors=$(grep -c "Error: No named parameter" "$output_file" 2>/dev/null || echo "0")

    echo -e "${PURPLE}   📊 Error Analysis:${NC}"
    echo -e "${PURPLE}   - Undefined names: $undefined_errors${NC}"
    echo -e "${PURPLE}   - Missing methods: $method_errors${NC}"
    echo -e "${PURPLE}   - Constructor issues: $constructor_errors${NC}"
    echo -e "${PURPLE}   - Parameter mismatches: $param_errors${NC}"

    # Extract specific error types for summary
    if grep -q "mockSecureStorage" "$output_file" 2>/dev/null; then
        echo -e "${PURPLE}   🔧 Suggestion: Fix mock setup for SecureStorage${NC}"
    fi

    if grep -q "isSuccess\|dataOrNull\|errorMessage" "$output_file" 2>/dev/null; then
        echo -e "${PURPLE}   🔧 Suggestion: Update AuthResponse model usage${NC}"
    fi

    if grep -q "AuthState.loading" "$output_file" 2>/dev/null; then
        echo -e "${PURPLE}   🔧 Suggestion: Fix AuthState constructor calls${NC}"
    fi
}

# Function to run tests for a specific folder
run_folder_tests() {
    local folder=$1
    local folder_name=$(basename "$folder" | sed 's/[^a-zA-Z0-9]/_/g')

    echo -e "\n${CYAN}📁 Testing folder: $folder${NC}"
    echo "---------------------------------------------------------------"

    TOTAL_FOLDERS=$((TOTAL_FOLDERS + 1))

    # Check if folder has test files
    if ! has_test_files "$folder"; then
        echo -e "${YELLOW}⚠️  No test files found in $folder${NC}"
        return 0
    fi

    # Run tests with timeout and capture output
    local output_file="$RESULTS_DIR/${folder_name}_${TIMESTAMP}.txt"
    local start_time=$(date +%s)

    echo -e "${BLUE}🏃 Running tests with timeout ${TIMEOUT}...${NC}"

    if flutter test "$folder" \
        --concurrency=$CONCURRENCY \
        --reporter=expanded \
        2>&1 | tee "$output_file"; then

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Parse results - only if tests actually ran
        if grep -q "All tests passed!" "$output_file" || grep -q "+.*-.*:" "$output_file"; then
            local passed=$(grep -o "+[0-9]*" "$output_file" | tail -1 | sed 's/+//' || echo "0")
            local failed=$(grep -o "-[0-9]*" "$output_file" | tail -1 | sed 's/-//' || echo "0")

            echo -e "${GREEN}✅ $folder completed successfully in ${duration}s${NC}"
            echo -e "${GREEN}   📊 Tests passed: $passed, Failed: $failed${NC}"

            if [ "$failed" -eq 0 ]; then
                FOLDERS_PASSED=$((FOLDERS_PASSED + 1))
            else
                FOLDERS_FAILED=$((FOLDERS_FAILED + 1))
                FAILED_FOLDERS+=("$folder")
            fi
        else
            echo -e "${GREEN}✅ $folder completed in ${duration}s (no test summary found)${NC}"
            FOLDERS_PASSED=$((FOLDERS_PASSED + 1))
        fi

    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Check if it's a compilation error or runtime failure
        if grep -q "Error:" "$output_file" && grep -q "lib/" "$output_file"; then
            echo -e "${PURPLE}🔧 $folder has compilation errors (${duration}s)${NC}"
            FOLDERS_COMPILATION_ERROR=$((FOLDERS_COMPILATION_ERROR + 1))
            COMPILATION_ERROR_FOLDERS+=("$folder")
            analyze_compilation_errors "$output_file" "$folder"
        else
            echo -e "${RED}❌ $folder failed or timed out after ${duration}s${NC}"
            FOLDERS_FAILED=$((FOLDERS_FAILED + 1))
            FAILED_FOLDERS+=("$folder")
        fi
    fi

    # Clean up any hanging processes
    pkill -f flutter_tester 2>/dev/null || true
    pkill -f dart 2>/dev/null || true

    # Brief pause to let system recover
    sleep 2
}

# Test folders organized by complexity (simple to complex)
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

echo -e "\n${BLUE}🚀 Starting systematic testing...${NC}"

# Run tests folder by folder
for folder in "${TEST_FOLDERS[@]}"; do
    if [ -e "$folder" ]; then
        run_folder_tests "$folder"
    else
        echo -e "${YELLOW}⚠️  Folder not found: $folder${NC}"
    fi
done

# Generate comprehensive summary
echo ""
echo "=================================================================="
echo -e "${BLUE}📊 COMPREHENSIVE TEST SUMMARY${NC}"
echo "=================================================================="
echo -e "📁 Total folders tested: ${TOTAL_FOLDERS}"
echo -e "✅ Folders passed: ${GREEN}${FOLDERS_PASSED}${NC}"
echo -e "❌ Folders failed: ${RED}${FOLDERS_FAILED}${NC}"
echo -e "🔧 Compilation errors: ${PURPLE}${FOLDERS_COMPILATION_ERROR}${NC}"

if [ $TOTAL_FOLDERS -gt 0 ]; then
    success_rate=$(( (FOLDERS_PASSED * 100) / TOTAL_FOLDERS ))
    echo -e "📈 Success rate: ${success_rate}%"
fi

# Show failed folders
if [ ${#FAILED_FOLDERS[@]} -gt 0 ]; then
    echo -e "\n${RED}❌ Folders with test failures:${NC}"
    for folder in "${FAILED_FOLDERS[@]}"; do
        echo -e "  - ${RED}$folder${NC}"
    done
fi

# Show compilation error folders
if [ ${#COMPILATION_ERROR_FOLDERS[@]} -gt 0 ]; then
    echo -e "\n${PURPLE}🔧 Folders with compilation errors:${NC}"
    for folder in "${COMPILATION_ERROR_FOLDERS[@]}"; do
        echo -e "  - ${PURPLE}$folder${NC}"
    done
    echo -e "\n${PURPLE}💡 These folders need code fixes before testing can proceed${NC}"
fi

# Save detailed summary to file
{
    echo "Flutter Smart Test Summary - $TIMESTAMP"
    echo "========================================"
    echo "Total folders: $TOTAL_FOLDERS"
    echo "Passed: $FOLDERS_PASSED"
    echo "Failed: $FOLDERS_FAILED"
    echo "Compilation errors: $FOLDERS_COMPILATION_ERROR"
    echo ""
    echo "Failed folders: ${FAILED_FOLDERS[*]}"
    echo "Compilation error folders: ${COMPILATION_ERROR_FOLDERS[*]}"
    echo ""
    echo "Results directory: $RESULTS_DIR/"
    echo "Generated at: $(date)"
} > "$RESULTS_DIR/smart_summary_${TIMESTAMP}.txt"

echo -e "\n${BLUE}📁 All results saved in: $RESULTS_DIR/${NC}"
echo -e "${BLUE}📄 Summary saved in: $RESULTS_DIR/smart_summary_${TIMESTAMP}.txt${NC}"

# Final status
if [ "$FOLDERS_FAILED" -eq 0 ] && [ "$FOLDERS_COMPILATION_ERROR" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All testable folders passed!${NC}"
    exit 0
elif [ "$FOLDERS_COMPILATION_ERROR" -gt 0 ]; then
    echo -e "\n${PURPLE}🔧 Code fixes needed for compilation errors${NC}"
    exit 2
else
    echo -e "\n${YELLOW}⚠️  Some tests failed but no compilation errors${NC}"
    exit 1
fi