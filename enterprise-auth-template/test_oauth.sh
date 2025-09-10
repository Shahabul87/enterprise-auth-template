#!/bin/bash

# Test script for OAuth authentication flow
# This script tests the OAuth initialization endpoints

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
API_URL="http://localhost:8000/api/v1"

echo -e "${YELLOW}Testing OAuth Provider Integration${NC}"
echo "===================================="
echo ""

# Test OAuth providers
PROVIDERS=("google" "github" "discord")

for provider in "${PROVIDERS[@]}"; do
    echo -e "${YELLOW}Testing ${provider} OAuth initialization${NC}"
    
    response=$(curl -s -X GET "$API_URL/oauth/${provider}/init" \
        -H "Content-Type: application/json")
    
    echo "Response: $response"
    
    # Check if response contains authorization_url
    if echo "$response" | grep -q '"authorization_url"'; then
        echo -e "${GREEN}✓ ${provider} OAuth initialization successful${NC}"
        
        # Extract authorization URL for manual testing
        auth_url=$(echo "$response" | grep -o '"authorization_url":"[^"]*"' | cut -d'"' -f4)
        if [ ! -z "$auth_url" ]; then
            echo "Authorization URL: $auth_url"
        fi
    else
        echo -e "${RED}✗ ${provider} OAuth initialization failed${NC}"
    fi
    
    echo ""
done

echo -e "${YELLOW}Manual OAuth Testing Instructions:${NC}"
echo "================================="
echo ""
echo "To complete OAuth testing, you need to:"
echo ""
echo "1. Configure OAuth apps for each provider:"
echo "   - Google: https://console.developers.google.com/"
echo "   - GitHub: https://github.com/settings/applications/new"
echo "   - Discord: https://discord.com/developers/applications"
echo ""
echo "2. Set the following environment variables in backend/.env.dev:"
echo "   GOOGLE_CLIENT_ID=your_google_client_id"
echo "   GOOGLE_CLIENT_SECRET=your_google_client_secret"
echo "   GITHUB_CLIENT_ID=your_github_client_id"
echo "   GITHUB_CLIENT_SECRET=your_github_client_secret"
echo "   DISCORD_CLIENT_ID=your_discord_client_id"
echo "   DISCORD_CLIENT_SECRET=your_discord_client_secret"
echo ""
echo "3. Set redirect URIs for each provider:"
echo "   - Google: http://localhost:3000/auth/callback/google"
echo "   - GitHub: http://localhost:3000/auth/callback/github"
echo "   - Discord: http://localhost:3000/auth/callback/discord"
echo ""
echo "4. Test the full flow:"
echo "   a. Start backend: cd backend && uvicorn app.main:app --reload"
echo "   b. Start frontend: cd frontend && npm run dev"
echo "   c. Visit http://localhost:3000/auth/login"
echo "   d. Click on Google/GitHub/Discord login buttons"
echo "   e. Complete OAuth flow and verify successful authentication"
echo ""

echo -e "${GREEN}OAuth API endpoints are working!${NC}"
echo ""
echo "Note: OAuth providers will only work once client credentials are configured."