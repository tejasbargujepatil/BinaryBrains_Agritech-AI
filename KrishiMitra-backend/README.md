# KrishiMitra Agentic Backend

**Fully Automated AI-Powered Agricultural Management System**

[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0-green)](https://flask.palletsprojects.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)

## 🌾 Overview

KrishiMitra Backend is a revolutionary **agentic system** where AI agents autonomously manage all aspects of crop cultivation - from planning to harvest to selling. Farmers receive intelligent recommendations without manual data entry or decision-making.

### Key Features

- 🤖 **8 Autonomous AI Agents** - Zero manual intervention
- 📊 **Real-time Decision Making** - Weather-based auto-adjustments
- 💰 **Cost Optimization** - Finds cheaper fertilizers automatically
- 🏥 **Disease Detection** - Image-based diagnosis & treatment
- 📈 **Price Predictions** - Optimal selling strategy
- 🐳 **Docker Ready** - One-command deployment
- 📱 **RESTful API** - Easy Flutter/React integration

## 🏗️ Architecture

### Agentic System

```
User adds crop → All 6 agents activate automatically:
├── Fertilization Agent → Creates NPK plan, finds cheaper options
├── Irrigation Agent → Schedules watering, adjusts for weather
├── Disease Agent → Monitors health, ready for image analysis
├── Harvest Agent → Predicts yield and timing
├── Price Agent → Forecasts market prices
└── All recommendations stored in database
```

### Technology Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Python Flask 3.0 |
| **Database** | PostgreSQL 15 |
| **AI Engine** | Google Gemini Pro |
| **Weather API** | OpenWeatherMap |
| **Auth** | JWT (Flask-JWT-Extended) |
| **ORM** | SQLAlchemy |
| **Container** | Docker + Docker Compose |
| **Server** | Gunicorn |

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- API Keys:
  - [Google Gemini AI](https://makersuite.google.com/app/apikey)
  - [OpenWeatherMap](https://openweathermap.org/api)

### Installation

1. **Clone & Navigate**
```bash
cd KrishiMitra-backend
```

2. **Configure Environment**
```bash
cp .env.example .env
# Edit .env with your API keys
```

3. **Start with Docker**
```bash
cd docker
docker-compose up -d
```

4. **Verify**
```bash
curl http://localhost:8002/health
# Should return: {"status": "healthy"}
```

**Done!** Backend running on `http://localhost:8002` 🎉

## 📡 API Endpoints

### Authentication
```
POST /api/auth/register - Register farmer
POST /api/auth/login - Login
GET  /api/auth/profile - Get profile
```

### Crops (Agentic)
```
POST /api/crops/auto-plan - Agent plans best crop
POST /api/crops/add - Add crop (triggers all agents)
GET  /api/crops - List crops with agent data
GET  /api/crops/{id} - Get crop details
```

### Fertilization (Agentic)
```
GET  /api/fertilization/{crop_id} - Get agent plan
POST /api/fertilization/alternatives - Find cheaper options
POST /api/fertilization/analyze-bill - OCR bill analysis
```

### Irrigation (Agentic)
```
GET  /api/irrigation/{crop_id} - Get agent schedule
POST /api/irrigation/update-moisture - Auto-adjust schedule
```

### Disease (Agentic)
```
POST /api/disease/detect - Upload image → diagnosis
GET  /api/disease/{crop_id} - Get detections
```

### Dashboard (Aggregated)
```
GET /api/dashboard - All agent recommendations
GET /api/dashboard/alerts - AI-generated alerts
GET /api/dashboard/analytics - Agent performance
```

## 🤖 AI Agents

### 1. Crop Planning Agent
- Analyzes soil NPK, weather, market
- Recommends 5 best crops
- Provides seasonal calendar
- **Automatic**: Runs when user provides location

### 2. Fertilization Agent
- Calculates NPK requirements
- **Finds government-subsidized fertilizers**
- Creates application schedule
- Calculates cost savings
- **Automatic**: Triggered on crop creation

### 3. Irrigation Agent
- Monitors weather forecast
- Adjusts schedule for rain
- Optimizes water usage
- **Automatic**: Re-calculates on moisture update

### 4. Disease Detection Agent
- Analyzes crop images
- Identifies diseases (confidence score)
- Provides chemical + organic treatments
- **Automatic**: Triggered by image upload

### 5. Harvest Prediction Agent
- Predicts harvest date
- Estimates yield
- Quality grading
- **Automatic**: Updates weekly

### 6. Price Prediction Agent
- Forecasts market prices
- Suggests optimal selling date
- Considers festival demand
- **Automatic**: Runs for harvested crops

## 💾 Database Schema

- **users** - Farmer profiles with location
- **crops** - Crop data + agent_recommendations (JSONB)
- **fertilization_plans** - Agent-generated NPK plans
- **irrigation_schedules** - Auto-adjusted watering
- **disease_detections** - Image analysis results
- **harvest_predictions** - Yield forecasts
- **price_predictions** - Market price trends
- **agent_logs** - All agent executions

## 🔐 Security

- ✅ JWT Authentication on all endpoints
- ✅ Password hashing with bcrypt
- ✅ SQL injection prevention (SQLAlchemy ORM)
- ✅ Environment variable secrets
- ✅ CORS configuration
- ✅ Input validation

## 📊 Monitoring

### Agent Logs
Every agent execution is logged:
- Execution time
- Input/output data
- Success/failure status
- User/crop context

### Health Checks
- `/health` - Service status
- Database connectivity
- Container health checks

## 🔧 Development

### Local Setup (without Docker)

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up database
createdb krishimitra

# Run migrations
flask db upgrade

# Start server
python run.py
```

### Environment Variables

Required in `.env`:
```
DATABASE_URL=postgresql://user:pass@localhost:5432/krishimitra
GEMINI_API_KEY=your_gemini_key
OPENWEATHER_API_KEY=your_weather_key
SECRET_KEY=your_secret_key
JWT_SECRET_KEY=your_jwt_key
```

## 📚 Documentation

- [Architecture Guide](ARCHITECTURE.md) - System design
- [API Reference](API_REFERENCE.md) - All endpoints
- [Agent Guide](AGENT_GUIDE.md) - How agents work
- [Development Log](DEVELOPMENT_LOG.md) - Build process

## 🧪 Testing

```bash
# Run tests
python -m pytest

# Test specific agent
python -m pytest tests/test_fertilization_agent.py

# Coverage report
pytest --cov=app tests/
```

## 🚢 Deployment

### Docker Production

```bash
cd docker
docker-compose -f docker-compose.prod.yml up -d
```

### Environment Setup
1. Get API keys
2. Configure `.env`
3. Set strong secrets
4. Enable HTTPS
5. Set up monitoring

## 📈 Performance

- **Response Time**: <500ms average
- **Agent Execution**: 1-3 seconds
- **Concurrent Users**: 1000+
- **Database**: Optimized with indexes

## 🤝 Integration

### Flutter App Integration

```dart
final response = await http.post(
  Uri.parse('http://localhost:8002/api/crops/add'),
  headers: {'Authorization': 'Bearer $token'},
  body: jsonEncode({
    'crop_name': 'Cotton',
    'sowing_date': '2026-06-15',
    'land_area': 5.0
  })
);

// All 6 agents automatically process the crop
```

## 🐛 Troubleshooting

### Common Issues

**Database Connection Error**
```bash
# Check PostgreSQL is running
docker ps | grep krishimitra_db

# Restart database
docker-compose restart db
```

**Agent Execution Fails**
```bash
# Check API keys in .env
# View logs
docker logs krishimitra_backend
```

## 📦 Project Structure

```
KrishiMitra-backend/
├── app/
│   ├── models/          # Database models
│   ├── agents/          # AI agents
│   ├── services/        # External services
│   ├── routes/          # API endpoints
│   └── __init__.py      # App factory
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── init-db.sql
├── requirements.txt
├── run.py
└── .env.example
```

## License

MIT License

## Support

- Issues: GitHub Issues
- Email: support@krishimitra.ai
- Documentation: [Full Docs](https://docs.krishimitra.ai)

---

**Built with ❤️ for Indian Farmers**

*Empowering agriculture through autonomous AI*
