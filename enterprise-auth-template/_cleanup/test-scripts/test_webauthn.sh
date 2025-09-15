#!/bin/bash

#############################################
# WebAuthn Implementation Test Script
#
# This script tests the WebAuthn/Passkeys implementation
# by verifying endpoints and checking integration
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="http://localhost:8000"
FRONTEND_URL="http://localhost:3000"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}WebAuthn Implementation Test Script${NC}"
echo -e "${BLUE}=====================================${NC}"

# Function to check if a service is running
check_service() {
    local port=$1
    local service=$2
    
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $service is running on port $port"
        return 0
    else
        echo -e "${RED}✗${NC} $service is not running on port $port"
        return 1
    fi
}

# Function to test an API endpoint
test_endpoint() {
    local endpoint=$1
    local method=$2
    local description=$3
    
    echo -n "Testing $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X $method "$BACKEND_URL$endpoint")
    
    if [ $response -eq 200 ] || [ $response -eq 405 ] || [ $response -eq 401 ] || [ $response -eq 422 ]; then
        echo -e "${GREEN}✓${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗${NC} (HTTP $response)"
        return 1
    fi
}

# Check Python WebAuthn package
echo -e "\n${YELLOW}Checking Python Dependencies:${NC}"
echo -n "Checking if webauthn package is installed... "
if cd backend && python -c "import webauthn" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Please install: pip install webauthn==1.11.1"
fi
cd ..

# Check if services are running
echo -e "\n${YELLOW}Checking Services:${NC}"
BACKEND_RUNNING=false
FRONTEND_RUNNING=false

if check_service 8000 "Backend (FastAPI)"; then
    BACKEND_RUNNING=true
fi

if check_service 3000 "Frontend (Next.js)"; then
    FRONTEND_RUNNING=true
fi

# Test WebAuthn API endpoints
if [ "$BACKEND_RUNNING" = true ]; then
    echo -e "\n${YELLOW}Testing WebAuthn API Endpoints:${NC}"
    
    test_endpoint "/api/v1/webauthn/status" "GET" "WebAuthn Status"
    test_endpoint "/api/v1/webauthn/register/options" "POST" "Registration Options"
    test_endpoint "/api/v1/webauthn/register/verify" "POST" "Registration Verify"
    test_endpoint "/api/v1/webauthn/authenticate/options" "POST" "Authentication Options"
    test_endpoint "/api/v1/webauthn/authenticate/verify" "POST" "Authentication Verify"
    test_endpoint "/api/v1/webauthn/credentials" "GET" "Get Credentials"
    
    echo -e "\n${YELLOW}Testing WebAuthn Service Status:${NC}"
    status=$(curl -s "$BACKEND_URL/api/v1/webauthn/status")
    
    if echo "$status" | grep -q "webauthn_enabled"; then
        echo -e "${GREEN}✓${NC} WebAuthn service is responding correctly"
        echo "Response: $status" | head -c 200
        echo "..."
    else
        echo -e "${RED}✗${NC} WebAuthn service is not responding correctly"
    fi
else
    echo -e "\n${RED}Cannot test API endpoints - Backend is not running${NC}"
fi

# Check frontend files
echo -e "\n${YELLOW}Checking Frontend Files:${NC}"

frontend_files=(
    "frontend/src/lib/webauthn-client.ts"
    "frontend/src/components/auth/webauthn-setup.tsx"
    "frontend/src/components/auth/webauthn-login.tsx"
    "frontend/src/components/auth/enhanced-login-form.tsx"
    "frontend/src/hooks/use-toast.ts"
)

for file in "${frontend_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file exists"
    else
        echo -e "${RED}✗${NC} $file is missing"
    fi
done

# Check backend files
echo -e "\n${YELLOW}Checking Backend Files:${NC}"

backend_files=(
    "backend/app/services/webauthn_service.py"
    "backend/app/api/v1/webauthn.py"
    "backend/tests/test_webauthn_endpoints.py"
)

for file in "${backend_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file exists"
    else
        echo -e "${RED}✗${NC} $file is missing"
    fi
done

# Integration check
echo -e "\n${YELLOW}Checking Integration:${NC}"

# Check if API router includes WebAuthn
if grep -q "webauthn_router" backend/app/api/__init__.py 2>/dev/null; then
    echo -e "${GREEN}✓${NC} WebAuthn router is integrated in API"
else
    echo -e "${RED}✗${NC} WebAuthn router not found in API integration"
fi

# Check if login page uses enhanced form
if grep -q "EnhancedLoginForm" frontend/src/app/auth/login/page.tsx 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Login page uses enhanced form with WebAuthn"
else
    echo -e "${RED}✗${NC} Login page not using enhanced form"
fi

# Check if profile includes WebAuthn setup
if grep -q "WebAuthnSetup" frontend/src/app/profile/page.tsx 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Profile page includes WebAuthn setup"
else
    echo -e "${RED}✗${NC} Profile page missing WebAuthn setup"
fi

# Summary
echo -e "\n${BLUE}=====================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}=====================================${NC}"

if [ "$BACKEND_RUNNING" = true ] && [ "$FRONTEND_RUNNING" = true ]; then
    echo -e "${GREEN}✓ Both services are running${NC}"
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "1. Open browser to $FRONTEND_URL"
    echo "2. Navigate to login page"
    echo "3. Try the 'Passkey' tab for WebAuthn login"
    echo "4. After login, go to Profile > Security tab"
    echo "5. Look for 'Passkeys' section to register a new passkey"
else
    echo -e "${YELLOW}⚠ Services not running${NC}"
    echo -e "\n${YELLOW}To start services:${NC}"
    echo "1. Backend: cd backend && uvicorn app.main:app --reload"
    echo "2. Frontend: cd frontend && npm run dev"
fi

echo -e "\n${GREEN}WebAuthn implementation test complete!${NC}"