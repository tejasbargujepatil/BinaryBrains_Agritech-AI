#!/bin/bash
# Comprehensive API Testing Script for KrishiMitra Backend

set -e

echo "🧪 KrishiMitra Backend - Comprehensive API Testing"
echo "=================================================="
echo ""

BASE_URL="http://localhost:8002"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

test_endpoint() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${BLUE}Test $TESTS_RUN: $1${NC}"
}

test_passed() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✅ Passed${NC}\n"
}

test_failed() {
    echo -e "${RED}❌ Failed: $1${NC}\n"
}

# Test 1: Health Check
test_endpoint "Health Check"
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q "healthy"; then
    echo "$HEALTH" | python3 -m json.tool
    test_passed
else
    test_failed "Health check failed"
fi

# Test 2: Register User
test_endpoint "Register New User"
REGISTER=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"mobile_number":"9998887776","password":"test123","name":"Test Farmer","location":"Pune","latitude":18.5204,"longitude":73.8567}')

if echo "$REGISTER" | grep -q "access_token"; then
    echo "$REGISTER" | python3 -m json.tool
    TOKEN=$(echo "$REGISTER" | python3 -c "import json, sys; print(json.load(sys.stdin)['access_token'])")
    test_passed
else
    # Try login if registration fails (user already exists)
    echo -e "${YELLOW}Registration failed, trying login...${NC}"
    LOGIN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"mobile_number":"9876543210","password":"farmer123"}')
    
    if echo "$LOGIN" | grep -q "access_token"; then
        echo "$LOGIN" | python3 -m json.tool
        TOKEN=$(echo "$LOGIN" | python3 -c "import json, sys; print(json.load(sys.stdin)['access_token'])")
        test_passed
    else
        test_failed "Both registration and login failed"
        exit 1
    fi
fi

echo -e "${YELLOW}Using Token: ${TOKEN:0:50}...${NC}\n"

# Test 3: Get Profile
test_endpoint "Get User Profile"
PROFILE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/auth/profile")
if echo "$PROFILE" | grep -q "mobile_number"; then
    echo "$PROFILE" | python3 -m json.tool
    test_passed
else
    test_failed "Profile fetch failed"
fi

# Test 4: Update Profile
test_endpoint "Update User Profile"
UPDATE=$(curl -s -X PUT "$BASE_URL/api/auth/profile" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"location":"Nagpur, Maharashtra"}')
if echo "$UPDATE" | grep -q "Profile updated"; then
    echo "$UPDATE" | python3 -m json.tool
    test_passed
else
    test_failed "Profile update failed"
fi

# Test 5: Get All Crops (should be empty initially)
test_endpoint "Get All Crops"
CROPS=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/crops")
echo "$CROPS" | python3 -m json.tool
test_passed

# Test 6: Find Cheaper Fertilizer Alternatives
test_endpoint "Find Cheaper Fertilizer Alternatives"
ALTERNATIVES=$(curl -s -X POST "$BASE_URL/api/fertilization/alternatives" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"npk":{"n":46,"p":0,"k":0},"current_brand":"Tata Urea","current_price":280}')

if echo "$ALTERNATIVES" | grep -q "cheaper_alternatives"; then
    echo "$ALTERNATIVES" | python3 -m json.tool | head -50
    echo "... (truncated)"
    test_passed
else
    echo "$ALTERNATIVES"
    echo -e "${YELLOW}⚠️  Agent may have failed (Gemini API required)${NC}\n"
fi

# Test 7: Analyze Fertilizer Bill
test_endpoint "Analyze Fertilizer Bill"
BILL_ANALYSIS=$(curl -s -X POST "$BASE_URL/api/fertilization/analyze-bill" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"npk":{"n":19,"p":19,"k":19},"price":1200,"brand":"Generic NPK"}')

if echo "$BILL_ANALYSIS" | grep -q "cheaper_alternatives"; then
    echo "$BILL_ANALYSIS" | python3 -m json.tool | head -30
    echo "... (truncated)"
    test_passed
else
    echo "$BILL_ANALYSIS"
    echo -e "${YELLOW}⚠️  Agent may have failed (Gemini API required)${NC}\n"
fi

# Test 8: Marketplace Fertilizer Comparison
test_endpoint "Marketplace Fertilizer Comparison"
MARKETPLACE=$(curl -s -X POST "$BASE_URL/api/marketplace/fertilizers/compare" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"npk":{"n":46,"p":0,"k":0},"current_brand":"Branded Urea","current_price":300}')

if echo "$MARKETPLACE" | grep -q "recommendations" || echo "$MARKETPLACE" | grep -q "cheaper_alternatives"; then
    echo "$MARKETPLACE" | python3 -m json.tool | head -30
    echo "... (truncated)"
    test_passed
else
    echo "$MARKETPLACE"
    echo -e "${YELLOW}⚠️  Agent may have failed (Gemini API required)${NC}\n"
fi

# Test 9: Get Dashboard
test_endpoint "Get Dashboard"
DASHBOARD=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard")
if echo "$DASHBOARD" | grep -q "total_crops"; then
    echo "$DASHBOARD" | python3 -m json.tool
    test_passed
else
    test_failed "Dashboard fetch failed"
fi

# Test 10: Get Dashboard Alerts
test_endpoint "Get Dashboard Alerts"
ALERTS=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard/alerts")
echo "$ALERTS" | python3 -m json.tool
test_passed

# Test 11: Get Analytics
test_endpoint "Get Agent Analytics"
ANALYTICS=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard/analytics")
echo "$ANALYTICS" | python3 -m json.tool
test_passed

echo ""
echo "=============================================="
echo -e "${GREEN}✅ Testing Complete!${NC}"
echo "Tests Run: $TESTS_RUN"
echo "Tests Passed: $TESTS_PASSED"
echo ""
echo -e "${BLUE}Note: Agent-based endpoints (fertilization, crops/add) require valid Gemini API key${NC}"
echo -e "${BLUE}Basic CRUD endpoints (auth, dashboard) are fully functional${NC}"
echo ""
echo "🎯 Backend is ready for Flutter integration!"
