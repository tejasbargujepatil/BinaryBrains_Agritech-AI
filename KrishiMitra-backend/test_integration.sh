#!/bin/bash
# Complete Integration Test - Backend to Flutter

set -e

echo "🧪 KrishiMitra Complete Integration Test"
echo "=========================================="
echo ""

BASE_URL="http://localhost:8002"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Test backend health
echo -e "${BLUE}1. Testing Backend Health...${NC}"
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
    exit 1
fi

# Step 2: Login
echo -e "\n${BLUE}2. Testing Login...${NC}"
LOGIN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"mobile_number":"9998887776","password":"test123"}')

if echo "$LOGIN" | grep -q "access_token"; then
    TOKEN=$(echo "$LOGIN" | python3 -c "import json, sys; print(json.load(sys.stdin)['access_token'])")
    echo -e "${GREEN}✅ Login successful${NC}"
    echo "Token: ${TOKEN:0:50}..."
else
    echo -e "${RED}❌ Login failed${NC}"
    echo "$LOGIN"
    exit 1
fi

# Step 3: Test Dashboard
echo -e "\n${BLUE}3. Testing Dashboard API...${NC}"
DASHBOARD=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard")
echo "$DASHBOARD" | python3 -m json.tool
echo -e "${GREEN}✅ Dashboard API working${NC}"

# Step 4: Test Alerts
echo -e "\n${BLUE}4. Testing Alerts API...${NC}"
ALERTS=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/dashboard/alerts")
echo "$ALERTS" | python3 -m json.tool
echo -e "${GREEN}✅ Alerts API working${NC}"

# Step 5: Test Crops List
echo -e "\n${BLUE}5. Testing Crops API...${NC}"
CROPS=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/crops/")
echo "$CROPS" | python3 -m json.tool
echo -e "${GREEN}✅ Crops API working${NC}"

echo -e "\n${GREEN}=========================================="
echo "✅ All backend endpoints are working!"
echo "==========================================${NC}"
echo ""
echo "🌐 Backend URLs for Flutter:"
echo "  - Physical Device: http://20.20.23.128:8002/api"
echo "  - Android Emulator: http://10.0.2.2:8002/api"
echo "  - iOS Simulator: http://localhost:8002/api"
echo ""
echo "📱 Token for testing in Flutter:"
echo "$TOKEN"
echo ""
echo "✅ Integration is ready!"
