#!/bin/bash
# KrishiMitra Backend Quick Setup Script

echo "🌾 KrishiMitra Agentic Backend Setup"
echo "===================================="
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

echo "✅ Docker found"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker Compose found"
echo ""

# Create .env if doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    echo "⚠️  IMPORTANT: Edit .env file and add your API keys:"
    echo "   - GEMINI_API_KEY"
    echo "   - OPENWEATHER_API_KEY"
    echo ""
    read -p "Press Enter After adding API keys to .env file..."
fi

echo "✅ Environment file ready"
echo ""

# Start Docker services
echo "🚀 Starting Docker services..."
cd docker
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check health
echo "🏥 Checking backend health..."
curl -f http://localhost:8002/health > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Backend is running!"
    echo ""
    echo "📡 API available at: http://localhost:8002"
    echo "🗄️  Database running on port: 5432"
    echo ""
    echo "📚 Quick Test:"
    echo "   curl http://localhost:8002/health"
    echo ""
    echo "📖 Documentation:"
    echo "   README.md - Quick start guide"
    echo "   DEVELOPMENT_LOG.md - Complete build log"
    echo ""
    echo "🎉 Happy Coding!"
else
    echo ""
    echo "⚠️  Backend health check failed. Check logs:"
    echo "   docker logs krishimitra_backend"
fi
