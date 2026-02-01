#!/bin/bash
# KrishiMitra Backend API Testing Script

echo "🧪 Testing KrishiMitra Agentic Backend APIs"
echo "============================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8002"

# Test 1: Health Check
echo "${BLUE}Test 1: Health Check${NC}"
curl -s "$BASE_URL/health" | python3 -m json.tool
echo ""

# Test 2: Register User
echo "${BLUE}Test 2: Register New User${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"mobile_number":"9999888877","password":"test123","name":"Test Farmer","location":"Mumbai","latitude":19.0760,"longitude":72.8777}')
echo "$REGISTER_RESPONSE" | python3 -m json.tool
TOKEN=$(echo "$REGISTER_RESPONSE" | python3 -c "import json, sys; print(json.load(sys.stdin).get('access_token', ''))")
echo ""

if [ -z "$TOKEN" ]; then
    echo "${RED}❌ Registration failed, trying login...${NC}"
    # Try login instead
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"mobile_number":"9876543210","password":"farmer123"}')
    echo "$LOGIN_RESPONSE" | python3 -m json.tool
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import json, sys; print(json.load(sys.stdin).get('access_token', ''))")
    echo ""
fi

echo "${GREEN}Token: ${TOKEN:0:50}...${NC}"
echo ""

# Test 3: Get Profile
echo "${BLUE}Test 3: Get User Profile${NC}"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/auth/profile" | python3 -m json.tool
echo ""

# Test 4: Get Crops (should be empty initially)
echo "${BLUE}Test 4: Get All Crops${NC}"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/crops" | python3 -m json.tool
echo ""

# Test 5: Test Fertilizer Alternatives (without crop)
echo "${BLUE}Test 5: Find Cheaper Fertilizer Alternatives${NC}"
curl -s -X POST "$BASE_URL/api/fertilization/alternatives" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"npk":{"n":46,"p":0,"k":0},"current_brand":"Branded Urea","current_price":280}' | python3 -m json.tool
echo ""

# Test 6: Dashboard
echo "${BLUE}Test 6: Get Dashboard${NC}"
curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard" | python3 -m json.tool
echo ""

echo "${GREEN}✅ Basic API tests complete!${NC}"
echo ""
echo "Note: Full agent testing requires actual crop creation which may take 10-15 seconds due to Gemini AI calls."
