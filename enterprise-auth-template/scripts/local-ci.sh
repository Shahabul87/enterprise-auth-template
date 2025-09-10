#!/bin/bash
# Local CI/CD Pipeline Script
# Simulates GitHub Actions/GitLab CI locally

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CI_MODE=${CI_MODE:-"full"}
PARALLEL=${PARALLEL:-"true"}

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

run_stage() {
    local stage_name=$1
    local command=$2
    
    echo "===========================================" 
    echo -e "${BLUE}🚀 STAGE: $stage_name${NC}"
    echo "==========================================="
    
    if eval "$command"; then
        log_success "✅ $stage_name completed successfully"
        return 0
    else
        log_error "❌ $stage_name failed"
        return 1
    fi
}

# Pipeline Stages
stage_setup() {
    log_info "Setting up CI environment..."
    
    # Check prerequisites
    command -v docker >/dev/null 2>&1 || { log_error "Docker is required"; exit 1; }
    command -v node >/dev/null 2>&1 || { log_error "Node.js is required"; exit 1; }
    command -v python3 >/dev/null 2>&1 || { log_error "Python 3 is required"; exit 1; }
    
    # Set environment variables for CI
    export NODE_ENV=test
    export ENVIRONMENT=test
    export CI=true
    
    log_success "Environment setup complete"
}

stage_backend_deps() {
    log_info "Installing backend dependencies..."
    cd backend
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install --quiet -r requirements.txt
    pip install --quiet pytest-xdist  # For parallel testing
    cd ..
}

stage_frontend_deps() {
    log_info "Installing frontend dependencies..."
    cd frontend
    npm ci --silent
    cd ..
}

stage_backend_lint() {
    log_info "Running backend code quality checks..."
    cd backend
    source venv/bin/activate
    
    # Type checking
    python -m mypy app/ || return 1
    
    # Linting
    python -m flake8 app/ tests/ || return 1
    
    # Security check
    python -m safety check || return 1
    
    cd ..
}

stage_frontend_lint() {
    log_info "Running frontend code quality checks..."
    cd frontend
    
    # TypeScript check
    npm run typecheck || return 1
    
    # ESLint
    npm run lint || return 1
    
    # Security audit
    npm audit --audit-level=moderate || return 1
    
    cd ..
}

stage_backend_tests() {
    log_info "Running backend tests..."
    cd backend
    source venv/bin/activate
    
    # Run tests with coverage
    if [ "$PARALLEL" = "true" ]; then
        python -m pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=xml -n auto || return 1
    else
        python -m pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=xml || return 1
    fi
    
    cd ..
}

stage_frontend_tests() {
    log_info "Running frontend tests..."
    cd frontend
    
    # Run Jest tests
    npm run test:coverage || return 1
    
    cd ..
}

stage_integration_tests() {
    log_info "Running integration tests..."
    
    # Start services for integration testing
    make dev-up
    sleep 30  # Wait for services to be ready
    
    # Health check
    curl -f http://localhost:8000/health || return 1
    
    # Run API tests
    cd backend
    source venv/bin/activate
    python -m pytest tests/test_auth_endpoints.py -v || return 1
    cd ..
    
    # Cleanup
    make dev-down
}

stage_security_scan() {
    log_info "Running security scans..."
    
    # Backend security
    cd backend
    source venv/bin/activate
    python -m safety check || return 1
    cd ..
    
    # Frontend security
    cd frontend
    npm audit --audit-level=high || return 1
    cd ..
    
    # Docker security (if available)
    if command -v trivy >/dev/null 2>&1; then
        log_info "Running Docker security scan..."
        trivy image --exit-code 1 --severity HIGH,CRITICAL python:3.11-slim || log_warning "Docker scan failed"
        trivy image --exit-code 1 --severity HIGH,CRITICAL node:18-alpine || log_warning "Docker scan failed"
    fi
}

stage_build_test() {
    log_info "Testing production builds..."
    
    # Build backend Docker image
    docker build -t enterprise-auth-backend:test backend/ || return 1
    
    # Build frontend
    cd frontend
    npm run build || return 1
    cd ..
    
    log_success "Build test completed"
}

# Main pipeline execution
main() {
    echo "=========================================="
    echo -e "${GREEN}🚀 LOCAL CI/CD PIPELINE${NC}"
    echo "Mode: $CI_MODE"
    echo "Parallel: $PARALLEL"
    echo "=========================================="
    
    local start_time=$(date +%s)
    
    # Execute pipeline stages
    case $CI_MODE in
        "quick")
            run_stage "Setup" "stage_setup" &&
            run_stage "Backend Lint" "stage_backend_lint" &&
            run_stage "Frontend Lint" "stage_frontend_lint" &&
            run_stage "Backend Tests" "stage_backend_tests" &&
            run_stage "Frontend Tests" "stage_frontend_tests"
            ;;
        "security")
            run_stage "Setup" "stage_setup" &&
            run_stage "Backend Dependencies" "stage_backend_deps" &&
            run_stage "Frontend Dependencies" "stage_frontend_deps" &&
            run_stage "Security Scan" "stage_security_scan"
            ;;
        "full"|*)
            run_stage "Setup" "stage_setup" &&
            run_stage "Backend Dependencies" "stage_backend_deps" &&
            run_stage "Frontend Dependencies" "stage_frontend_deps" &&
            
            if [ "$PARALLEL" = "true" ]; then
                # Run linting in parallel
                (run_stage "Backend Lint" "stage_backend_lint") &
                (run_stage "Frontend Lint" "stage_frontend_lint") &
                wait
                
                # Run tests in parallel
                (run_stage "Backend Tests" "stage_backend_tests") &
                (run_stage "Frontend Tests" "stage_frontend_tests") &
                wait
            else
                run_stage "Backend Lint" "stage_backend_lint" &&
                run_stage "Frontend Lint" "stage_frontend_lint" &&
                run_stage "Backend Tests" "stage_backend_tests" &&
                run_stage "Frontend Tests" "stage_frontend_tests"
            fi &&
            
            run_stage "Security Scan" "stage_security_scan" &&
            run_stage "Integration Tests" "stage_integration_tests" &&
            run_stage "Build Test" "stage_build_test"
            ;;
    esac
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "=========================================="
    if [ $exit_code -eq 0 ]; then
        log_success "🎉 CI PIPELINE COMPLETED SUCCESSFULLY"
        log_info "⏱️  Duration: ${duration}s"
    else
        log_error "💥 CI PIPELINE FAILED"
        log_info "⏱️  Duration: ${duration}s"
    fi
    echo "=========================================="
    
    exit $exit_code
}

# Handle script arguments
case "${1:-}" in
    "quick")
        CI_MODE="quick"
        ;;
    "security")
        CI_MODE="security"
        ;;
    "full")
        CI_MODE="full"
        ;;
    "--help"|"-h")
        echo "Usage: $0 [quick|security|full]"
        echo "  quick    - Run basic linting and tests"
        echo "  security - Run security scans only"
        echo "  full     - Run complete CI pipeline (default)"
        exit 0
        ;;
esac

# Run the pipeline
main