#!/bin/bash

# Test registration
echo "===== Testing Registration ====="
curl -X POST http://localhost:8000/api/v1/v1/register \
  -H "Content-Type: application/json" \
  -d @test_register.json

echo -e "\n\n===== Testing Login ====="
# Test login
curl -X POST http://localhost:8000/api/v1/v1/login \
  -H "Content-Type: application/json" \
  -d @test_login.json

echo -e "\n"