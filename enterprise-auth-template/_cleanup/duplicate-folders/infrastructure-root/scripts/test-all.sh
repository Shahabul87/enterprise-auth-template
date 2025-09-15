#!/bin/bash

# Comprehensive Testing Script for Backend and Frontend
# This script runs all tests in an isolated test environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
BACKEND_UNIT_PASS=false
BACKEND_INTEGRATION_PASS=false
FLUTTER_UNIT_PASS=false
FLUTTER_WIDGET_PASS=false
FLUTTER_INTEGRATION_PASS=false

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_fail() {
    echo -e "${RED}[✗]${NC} $1"
}

# Setup test environment
setup_test_env() {
    print_header "Setting up test environment"
    
    cd ../docker
    
    # Stop any existing test containers
    docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true
    
    # Start test infrastructure
    docker-compose -f docker-compose.test.yml up -d postgres-test redis-test mailhog
    
    print_info "Waiting for test databases..."
    sleep 10
}

# Run backend unit tests
test_backend_unit() {
    print_header "Running Backend Unit Tests"
    
    cd ../../backend
    
    # Run unit tests in Docker
    docker-compose -f ../infrastructure/docker/docker-compose.test.yml run --rm backend-test \
        pytest tests/unit -v --cov=app --cov-report=term-missing
    
    if [ $? -eq 0 ]; then
        BACKEND_UNIT_PASS=true
        print_success "Backend unit tests passed"
    else
        print_fail "Backend unit tests failed"
    fi
}

# Run backend integration tests
test_backend_integration() {
    print_header "Running Backend Integration Tests"
    
    cd ../backend
    
    # Run integration tests
    docker-compose -f ../infrastructure/docker/docker-compose.test.yml run --rm backend-test \
        pytest tests/integration -v
    
    if [ $? -eq 0 ]; then
        BACKEND_INTEGRATION_PASS=true
        print_success "Backend integration tests passed"
    else
        print_fail "Backend integration tests failed"
    fi
}

# Run Flutter unit tests
test_flutter_unit() {
    print_header "Running Flutter Unit Tests"
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not installed, skipping Flutter tests"
        return
    fi
    
    cd ../enterprise-auth-template/flutter_auth_template
    
    # Run unit tests
    flutter test test/unit --coverage
    
    if [ $? -eq 0 ]; then
        FLUTTER_UNIT_PASS=true
        print_success "Flutter unit tests passed"
    else
        print_fail "Flutter unit tests failed"
    fi
}

# Run Flutter widget tests
test_flutter_widget() {
    print_header "Running Flutter Widget Tests"
    
    if ! command -v flutter &> /dev/null; then
        return
    fi
    
    cd ../enterprise-auth-template/flutter_auth_template
    
    # Run widget tests
    flutter test test/widgets
    
    if [ $? -eq 0 ]; then
        FLUTTER_WIDGET_PASS=true
        print_success "Flutter widget tests passed"
    else
        print_fail "Flutter widget tests failed"
    fi
}

# Run Flutter integration tests
test_flutter_integration() {
    print_header "Running Flutter Integration Tests"
    
    if ! command -v flutter &> /dev/null; then
        return
    fi
    
    cd ../enterprise-auth-template/flutter_auth_template
    
    # Make sure backend is running for integration tests
    docker-compose -f ../../infrastructure/docker/docker-compose.test.yml up -d backend-test
    
    # Run integration tests (headless Chrome)
    flutter test integration_test --device-id web-server --headless
    
    if [ $? -eq 0 ]; then
        FLUTTER_INTEGRATION_PASS=true
        print_success "Flutter integration tests passed"
    else
        print_fail "Flutter integration tests failed"
    fi
}

# Run API tests with curl
test_api_endpoints() {
    print_header "Testing API Endpoints"
    
    BASE_URL="http://localhost:8001"
    
    print_info "Testing health endpoint..."
    curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health | grep -q "200" && \
        print_success "Health endpoint OK" || print_fail "Health endpoint failed"
    
    print_info "Testing registration endpoint..."
    RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/auth/register \
        -H "Content-Type: application/json" \
        -d '{"email":"test@test.com","password":"Test123!@#","name":"Test User"}' \
        -w "\n%{http_code}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [[ "$HTTP_CODE" == "201" ]] || [[ "$HTTP_CODE" == "409" ]]; then
        print_success "Registration endpoint OK"
    else
        print_fail "Registration endpoint failed (HTTP $HTTP_CODE)"
    fi
    
    print_info "Testing login endpoint..."
    RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username":"admin@example.com","password":"Admin123!@#"}' \
        -w "\n%{http_code}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    if [[ "$HTTP_CODE" == "200" ]]; then
        print_success "Login endpoint OK"
    else
        print_fail "Login endpoint failed (HTTP $HTTP_CODE)"
    fi
}

# Load testing with simple benchmark
run_load_test() {
    print_header "Running Load Tests"
    
    if ! command -v ab &> /dev/null; then
        print_error "Apache Bench (ab) not installed, skipping load tests"
        return
    fi
    
    BASE_URL="http://localhost:8001"
    
    print_info "Running load test on health endpoint..."
    ab -n 100 -c 10 -q $BASE_URL/health 2>&1 | grep "Requests per second"
}

# Cleanup test environment
cleanup_test_env() {
    print_header "Cleaning up test environment"
    
    cd ../infrastructure/docker
    docker-compose -f docker-compose.test.yml down -v
    
    print_info "Test environment cleaned up"
}

# Generate test report
generate_report() {
    print_header "TEST RESULTS SUMMARY"
    
    echo ""
    echo "Backend Tests:"
    [[ $BACKEND_UNIT_PASS == true ]] && print_success "Unit Tests: PASSED" || print_fail "Unit Tests: FAILED"
    [[ $BACKEND_INTEGRATION_PASS == true ]] && print_success "Integration Tests: PASSED" || print_fail "Integration Tests: FAILED"
    
    echo ""
    echo "Flutter Tests:"
    [[ $FLUTTER_UNIT_PASS == true ]] && print_success "Unit Tests: PASSED" || print_fail "Unit Tests: FAILED"
    [[ $FLUTTER_WIDGET_PASS == true ]] && print_success "Widget Tests: PASSED" || print_fail "Widget Tests: FAILED"
    [[ $FLUTTER_INTEGRATION_PASS == true ]] && print_success "Integration Tests: PASSED" || print_fail "Integration Tests: FAILED"
    
    echo ""
    
    # Calculate overall result
    if [[ $BACKEND_UNIT_PASS == true ]] && \
       [[ $BACKEND_INTEGRATION_PASS == true ]] && \
       [[ $FLUTTER_UNIT_PASS == true ]] && \
       [[ $FLUTTER_WIDGET_PASS == true ]] && \
       [[ $FLUTTER_INTEGRATION_PASS == true ]]; then
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}ALL TESTS PASSED! ✨${NC}"
        echo -e "${GREEN}========================================${NC}"
        exit 0
    else
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}SOME TESTS FAILED! ❌${NC}"
        echo -e "${RED}========================================${NC}"
        exit 1
    fi
}

# Main execution
main() {
    print_header "Enterprise Auth Template - Comprehensive Test Suite"
    
    # Parse arguments
    if [[ "$1" == "--quick" ]]; then
        print_info "Running quick tests only (unit tests)..."
        setup_test_env
        test_backend_unit
        test_flutter_unit
    elif [[ "$1" == "--backend" ]]; then
        print_info "Running backend tests only..."
        setup_test_env
        test_backend_unit
        test_backend_integration
        test_api_endpoints
    elif [[ "$1" == "--flutter" ]]; then
        print_info "Running Flutter tests only..."
        test_flutter_unit
        test_flutter_widget
        test_flutter_integration
    else
        # Run all tests
        setup_test_env
        test_backend_unit
        test_backend_integration
        test_flutter_unit
        test_flutter_widget
        test_flutter_integration
        test_api_endpoints
        run_load_test
    fi
    
    cleanup_test_env
    generate_report
}

# Handle script arguments
case "$1" in
    --help)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --quick     Run only unit tests"
        echo "  --backend   Run only backend tests"
        echo "  --flutter   Run only Flutter tests"
        echo "  --help      Show this help message"
        echo ""
        echo "Without options, all tests will be run."
        exit 0
        ;;
    *)
        main $1
        ;;
esac