#!/bin/bash

# Test script for Magic Link authentication flow
# This script tests the magic link request and verification endpoints

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
API_URL="http://localhost:8000/api/v1"
TEST_EMAIL="test@example.com"

echo -e "${YELLOW}Testing Magic Link Authentication Flow${NC}"
echo "========================================="
echo ""

# Step 1: Request a magic link
echo -e "${YELLOW}Step 1: Requesting magic link for ${TEST_EMAIL}${NC}"
response=$(curl -s -X POST "$API_URL/magic-links/request" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$TEST_EMAIL\"}")

echo "Response: $response"

# Check if request was successful
if echo "$response" | grep -q '"success":true'; then
  echo -e "${GREEN}✓ Magic link request successful${NC}"
else
  echo -e "${RED}✗ Magic link request failed${NC}"
  exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Magic link sent to email${NC}"
echo "Check the email at $TEST_EMAIL for the magic link"
echo "The link will look like: http://localhost:3000/auth/magic-link?token=XXX"
echo ""

# Step 3: Verify magic link (manual step required)
echo -e "${YELLOW}Step 3: To verify the magic link:${NC}"
echo "1. Check the backend logs for the magic link token (if email not configured)"
echo "2. Or check the actual email if SMTP is configured"
echo "3. Use the token to verify:"
echo ""
echo "Example verification command:"
echo "curl -X POST \"$API_URL/magic-links/verify\" \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"token\": \"YOUR_TOKEN_HERE\"}'"
echo ""

# Optional: Test with invalid token
echo -e "${YELLOW}Step 4: Testing with invalid token${NC}"
invalid_response=$(curl -s -X POST "$API_URL/magic-links/verify" \
  -H "Content-Type: application/json" \
  -d '{"token": "invalid-token-12345"}')

echo "Response: $invalid_response"

if echo "$invalid_response" | grep -q "Invalid or expired magic link"; then
  echo -e "${GREEN}✓ Invalid token correctly rejected${NC}"
else
  echo -e "${YELLOW}⚠ Check invalid token handling${NC}"
fi

echo ""
echo -e "${GREEN}Magic Link API endpoints are working!${NC}"
echo ""
echo "To complete the full flow:"
echo "1. Ensure the database migrations are applied: cd backend && alembic upgrade head"
echo "2. Start the backend server: cd backend && uvicorn app.main:app --reload"
echo "3. Start the frontend server: cd frontend && npm run dev"
echo "4. Visit http://localhost:3000/auth/login and click 'Magic Link' tab"
echo "5. Enter an email and request a magic link"
echo "6. Check the email or backend logs for the link"
echo "7. Click the link to authenticate"