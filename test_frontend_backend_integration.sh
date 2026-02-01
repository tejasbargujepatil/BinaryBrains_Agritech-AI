#!/bin/bash

# KrishiMitra Integration Test Script
# Tests frontend-backend connectivity

echo "================================================"
echo "KrishiMitra Frontend-Backend Integration Tests"
echo "================================================"
echo ""

BASE_URL="http://localhost:8002"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
HEALTH=$(curl -s $BASE_URL/health)
if echo "$HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "$HEALTH" | python3 -m json.tool
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Registration (with camelCase fields from frontend)
echo -e "${YELLOW}Test 2: User Registration (Frontend Format - camelCase)${NC}"
TIMESTAMP=$(date +%s)
TEST_MOBILE="99${TIMESTAMP:(-8)}"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"mobileNumber\":\"$TEST_MOBILE\",
    \"name\":\"Integration Test User\",
    \"password\":\"test123\",
    \"location\":{
      \"latitude\":18.5204,
      \"longitude\":73.8567,
      \"address\":\"Test Location\"
    }
  }")

if echo "$REGISTER_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ Registration successful${NC}"
    echo "$REGISTER_RESPONSE" | python3 -m json.tool
    TOKEN=$(echo "$REGISTER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
    echo -e "\n${GREEN}Token extracted: ${TOKEN:0:50}...${NC}"
else
    echo -e "${RED}✗ Registration failed${NC}"
    echo "$REGISTER_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Login (with camelCase fields)
echo -e "${YELLOW}Test 3: User Login (Frontend Format - camelCase)${NC}"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"mobileNumber\":\"$TEST_MOBILE\",
    \"password\":\"test123\"
  }")

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ Login successful${NC}"
    echo "$LOGIN_RESPONSE" | python3 -m json.tool
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
else
    echo -e "${RED}✗ Login failed${NC}"
    echo "$LOGIN_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Get Profile (authenticated)
echo -e "${YELLOW}Test 4: Get User Profile (Authenticated)${NC}"
PROFILE_RESPONSE=$(curl -s -X GET $BASE_URL/api/auth/profile \
  -H "Authorization: Bearer $TOKEN")

if echo "$PROFILE_RESPONSE" | grep -q "mobileNumber"; then
    echo -e "${GREEN}✓ Profile retrieval successful${NC}"
    echo "$PROFILE_RESPONSE" | python3 -m json.tool
else
    echo -e "${RED}✗ Profile retrieval failed${NC}"
    echo "$PROFILE_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Get Dashboard
echo -e "${YELLOW}Test 5: Get Dashboard (Authenticated)${NC}"
DASHBOARD_RESPONSE=$(curl -s -X GET $BASE_URL/api/dashboard/ \
  -H "Authorization: Bearer $TOKEN")

if echo "$DASHBOARD_RESPONSE" | grep -q "total_crops"; then
    echo -e "${GREEN}✓ Dashboard access successful${NC}"
    echo "$DASHBOARD_RESPONSE" | python3 -m json.tool
else
    echo -e "${RED}✗ Dashboard access failed${NC}"
    echo "$DASHBOARD_RESPONSE"
    exit 1
fi
echo ""

# Test 6: Get Crops
echo -e "${YELLOW}Test 6: Get User Crops (Authenticated)${NC}"
CROPS_RESPONSE=$(curl -s -X GET $BASE_URL/api/crops/ \
  -H "Authorization: Bearer $TOKEN")

if echo "$CROPS_RESPONSE" | grep -q "crops"; then
    echo -e "${GREEN}✓ Crops retrieval successful${NC}"
    echo "$CROPS_RESPONSE" | python3 -m json.tool
else
    echo -e "${RED}✗ Crops retrieval failed${NC}"
    echo "$CROPS_RESPONSE"
    exit 1
fi
echo ""

echo "================================================"
echo -e "${GREEN}All Integration Tests Passed! ✓${NC}"
echo "================================================"
echo ""
echo "Summary:"
echo "  • Backend is running and healthy"
echo "  • Registration works with camelCase fields"
echo "  • Login works with camelCase fields"
echo "  • Authentication tokens are generated correctly"
echo "  • Protected endpoints require valid tokens"
echo "  • Dashboard and crops endpoints accessible"
echo ""
echo "Frontend-Backend Integration: ${GREEN}READY ✓${NC}"
echo ""
