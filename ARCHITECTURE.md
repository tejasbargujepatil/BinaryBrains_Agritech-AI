# KrishiMitra - Complete System Architecture

## 🎯 System Overview

**KrishiMitra** is an AI-powered agricultural assistant platform designed for Indian farmers, featuring a multi-agent architecture that provides intelligent recommendations for crop planning, disease detection, irrigation scheduling, fertilization plans, and market predictions.

### Technology Stack

**Frontend (Mobile App)**
- **Framework**: Flutter/Dart
- **State Management**: Provider pattern with SharedPreferences
- **HTTP Client**: http package
- **AI Integration**: Google Gemini AI
- **Notifications**: flutter_local_notifications
- **Location**: geolocator
- **Image Processing**: google_mlkit_text_recognition

**Backend (API Server)**
- **Framework**: Flask (Python)
- **Database**: SQLAlchemy ORM + PostgressSQL/SQLite
- **Authentication**: Flask-JWT-Extended
- **AI Engine**: Google Gemini AI (gemini-1.5-pro)
- **Weather Data**: OpenWeatherMap API
- **Architecture Pattern**: Multi-Agent System

---

## 🏗️ High-Level Architecture

```mermaid
graph TB
    subgraph "Frontend - Flutter App"
        UI[User Interface]
        Services[Service Layer]
        Models[Data Models]
        LocalStorage[SharedPreferences]
    end
    
    subgraph "Backend - Flask API"
        Routes[API Routes]
        Controllers[Route Controllers]
        AgentCoordinator[Agent Orchestrator]
        DB[(PostgreSQL Database)]
    end
    
    subgraph "AI Multi-Agent System"
        CropAgent[Crop Planning Agent]
        FertAgent[Fertilization Agent]
        IrrAgent[Irrigation Agent]
        DiseaseAgent[Disease Detection Agent]
        HarvestAgent[Harvest Prediction Agent]
        PriceAgent[Price Prediction Agent]
    end
    
    subgraph "External Services"
        Gemini[Google Gemini AI]
        Weather[OpenWeatherMap API]
    end
    
    UI --> Services
    Services --> Models
    Services --> LocalStorage
    Services -->|HTTP/JSON| Routes
    
    Routes --> Controllers
    Controllers --> AgentCoordinator
    Controllers --> DB
    
    AgentCoordinator --> CropAgent
    AgentCoordinator --> FertAgent
    AgentCoordinator --> IrrAgent
    AgentCoordinator --> DiseaseAgent
    AgentCoordinator --> HarvestAgent
    AgentCoordinator --> PriceAgent
    
    CropAgent --> Gemini
    FertAgent --> Gemini
    IrrAgent --> Gemini
    DiseaseAgent --> Gemini
    HarvestAgent --> Gemini
    PriceAgent --> Gemini
    
    IrrAgent --> Weather
    Controllers --> Weather
```

---

## 🤖 Multi-Agent System Architecture

### Agent Hierarchy

```mermaid
classDiagram
    class BaseAgent {
        <<abstract>>
        +agent_type: str
        +execution_start: float
        +execute(**kwargs) dict*
        +log_execution()
        +run(**kwargs) dict
    }
    
    class CropPlanningAgent {
        +execute(soil_data, location, preferences) dict
        -_build_crop_planning_prompt() str
    }
    
    class FertilizationAgent {
        +execute(crop, soil_npk, stage, area) dict
        +find_cheaper_alternatives(fertilizer) dict
        -_build_fertilization_prompt() str
    }
    
    class IrrigationAgent {
        +execute(crop, stage, moisture, type, location) dict
        -_build_irrigation_prompt() str
    }
    
    class DiseaseDetectionAgent {
        +execute(crop, symptoms, image) dict
        -_build_disease_detection_prompt() str
    }
    
    class HarvestPredictionAgent {
        +execute(crop, sowing_date, growth, weather) dict
        -_build_harvest_prediction_prompt() str
    }
    
    class PricePredictionAgent {
        +execute(crop, harvest_date, price) dict
        -_build_price_prediction_prompt() str
    }
    
    BaseAgent <|-- CropPlanningAgent
    BaseAgent <|-- FertilizationAgent
    BaseAgent <|-- IrrigationAgent
    BaseAgent <|-- DiseaseDetectionAgent
    BaseAgent <|-- HarvestPredictionAgent
    BaseAgent <|-- PricePredictionAgent
```

### Agent Coordination Flow

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant API
    participant BaseAgent
    participant SpecificAgent
    participant GeminiAI
    participant Database
    
    User->>Frontend: Request (e.g., Add Crop)
    Frontend->>API: POST /api/crops/add
    API->>BaseAgent: run(**kwargs)
    BaseAgent->>BaseAgent: Start execution timing
    BaseAgent->>SpecificAgent: execute(**kwargs)
    SpecificAgent->>SpecificAgent: Build AI prompt
    SpecificAgent->>GeminiAI: generate_json_response(prompt)
    GeminiAI-->>SpecificAgent: JSON response
    SpecificAgent-->>BaseAgent: Processed result
    BaseAgent->>Database: Log agent execution
    Database-->>BaseAgent: Log saved
    BaseAgent-->>API: Return result
    API-->>Frontend: JSON response
    Frontend-->>User: Display recommendations
```

---

## 📊 Data Flow Architecture

### User Registration & Authentication Flow

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Auth as Auth Service
    participant API as Backend API
    participant DB as Database
    participant Weather as Weather API
    participant Soil as Soil Service
    
    App->>Auth: register(name, mobile, password, location)
    Auth->>Weather: Get current weather for location
    Weather-->>Auth: Weather data
    Auth->>Soil: Get soil data for location
    Soil-->>Auth: Soil data
    Auth->>API: POST /api/auth/register
    API->>DB: Create user record
    DB-->>API: User created (ID: int)
    API->>API: Generate JWT token
    API-->>Auth: {user, token, weatherData, soilData}
    Auth->>App: Save token + user data locally
    Auth-->>App: Registration successful
```

### Crop Management Flow

```mermaid
flowchart TD
    Start([User Adds Crop]) --> Input[Input: crop_name, sowing_date, land_area, irrigation_type]
    Input --> AutoPlanAPI[Optional: Call Auto-Plan API]
    AutoPlanAPI --> CropPlanAgent[Crop Planning Agent]
    CropPlanAgent --> GeminiCrop[Gemini AI Analysis]
    GeminiCrop --> CropRec[Receive Crop Recommendations]
    
    CropRec --> SelectCrop[User Selects Crop]
    SelectCrop --> SaveCrop[POST /api/crops/add]
    SaveCrop --> DBSave[Save to Database]
    
    DBSave --> InitAgents{Initialize Multi-Agents}
    
    InitAgents --> FertAgent[Fertilization Agent]
    InitAgents --> IrrigAgent[Irrigation Agent]
    InitAgents --> DiseaseAgent[Disease Agent]
    InitAgents --> HarvestAgent[Harvest Agent]
    InitAgents --> PriceAgent[Price Agent]
    
    FertAgent --> FertPlan[Generate Fertilization Plan]
    IrrigAgent --> IrrigSchedule[Generate Irrigation Schedule]
    DiseaseAgent --> DiseaseMonitor[Set up Disease Monitoring]
    HarvestAgent --> HarvestPred[Predict Harvest Date]
    PriceAgent --> PricePred[Predict Optimal Selling Time]
    
    FertPlan --> Dashboard[Update Dashboard]
    IrrigSchedule --> Dashboard
    DiseaseMonitor --> Dashboard
    HarvestPred --> Dashboard
    PricePred --> Dashboard
    
    Dashboard --> Notify[Send Notifications to User]
    Notify --> End([Complete])
```

---

## 🔄 Multi-Agent Collaboration

### Inter-Agent Communication

Agents work independently but their outputs inform each other:

```mermaid
graph LR
    subgraph "User Input"
        CropData[Crop Added]
        SoilUpdate[Soil Moisture Updated]
        DiseaseReport[Disease Reported]
    end
    
    subgraph "Agent Processing"
        CropAgent[Crop Planning<br/>Agent]
        FertAgent[Fertilization<br/>Agent]
        IrrAgent[Irrigation<br/>Agent]
        DiseaseAgent[Disease<br/>Agent]
        HarvestAgent[Harvest<br/>Agent]
        PriceAgent[Price<br/>Agent]
    end
    
    subgraph "Shared Context"
        CropContext[Crop Profile]
        SoilContext[Soil Status]
        WeatherContext[Weather Data]
        GrowthContext[Growth Stage]
    end
    
    CropData --> CropAgent
    CropAgent --> CropContext
    
    CropContext --> FertAgent
    CropContext --> IrrAgent
    SoilContext --> FertAgent
    SoilContext --> IrrAgent
    
    SoilUpdate --> IrrAgent
    IrrAgent --> SoilContext
    
    DiseaseReport --> DiseaseAgent
    DiseaseAgent --> GrowthContext
    
    CropContext --> HarvestAgent
    GrowthContext --> HarvestAgent
    WeatherContext --> HarvestAgent
    
    HarvestAgent --> PriceAgent
    CropContext --> PriceAgent
```

### Agent Decision Making Process

Each agent follows this standardized process:

```mermaid
stateDiagram-v2
    [*] --> ReceiveInput: Agent triggered
    ReceiveInput --> ValidateInput: Validate parameters
    ValidateInput --> GatherContext: Fetch additional data
    GatherContext --> BuildPrompt: Construct AI prompt
    BuildPrompt --> CallGemini: Request Gemini AI
    CallGemini --> ParseResponse: Parse JSON response
    ParseResponse --> ValidateOutput: Validate response
    ValidateOutput --> LogExecution: Log to database
    LogExecution --> ReturnResult: Return to caller
    ReturnResult --> [*]
    
    ValidateInput --> Error: Invalid input
    CallGemini --> Error: AI request fails
    ParseResponse --> Error: Invalid JSON
    Error --> LogExecution
    Error --> ReturnResult
```

---

## 💾 Database Schema

### Core Models

```mermaid
erDiagram
    USER ||--o{ CROP : owns
    USER {
        int id PK
        string name
        string mobile_number UK
        string password_hash
        float latitude
        float longitude
        string address
        datetime created_at
    }
    
    CROP ||--o{ AGENT_LOG : generates
    CROP ||--o{ DISEASE_DETECTION : has
    CROP {
        int id PK
        int user_id FK
        string crop_name
        string variety
        date sowing_date
        float land_area
        string irrigation_type
        string current_stage
        boolean active
        datetime created_at
    }
    
    AGENT_LOG {
        int id PK
        string agent_type
        int user_id FK
        int crop_id FK
        string action
        json input_data
        json output_data
        string status
        float execution_time
        datetime created_at
    }
    
    DISEASE_DETECTION {
        int id PK
        int crop_id FK
        string disease_name
        string symptoms
        int confidence_score
        json treatment_plan
        string severity
        datetime detected_at
    }
```

---

## 🔐 Security Architecture

### Authentication Flow

```mermaid
sequenceDiagram
    participant App
    participant AuthService
    participant API
    participant JWT
    participant DB
    
    App->>AuthService: Login request
    AuthService->>API: POST /api/auth/login
    API->>DB: Verify credentials
    DB-->>API: User found
    API->>JWT: Generate access_token
    JWT-->>API: JWT token (valid 1 day)
    API->>JWT: Generate refresh_token
    JWT-->>API: Refresh token (valid 30 days)
    API-->>AuthService: {user, access_token, refresh_token}
    AuthService->>App: Save to SharedPreferences
    AuthService-->>App: Login successful
    
    Note over App,DB: Subsequent requests include JWT in header
    App->>API: GET /api/crops (Authorization: Bearer <token>)
    API->>JWT: Verify token
    JWT-->>API: Token valid, user_id extracted
    API->>DB: Fetch user's crops
    DB-->>API: Crop data
    API-->>App: Response with crop data
```

### Network Security

- **Android**: Network Security Config allows HTTP for development IPs
- **HTTPS**: Production deployment uses HTTPS with Let's Encrypt
- **CORS**: Configured for mobile app origins
- **JWT**: Tokens expire after 24 hours, refresh tokens after 30 days

---

## 📱 Frontend Architecture

### Service Layer Pattern

```mermaid
graph TD
    subgraph "Presentation Layer"
        Screens[Screens/Widgets]
    end
    
    subgraph "Service Layer"
        AuthService[Auth Service]
        CropService[Crop Service]
        FertService[Fertilization Service]
        IrrigService[Irrigation Service]
        DiseaseService[Disease Service]
        HarvestService[Harvest Service]
        DashboardService[Dashboard Service]
        WeatherService[Weather Service]
        SoilService[Soil Service]
    end
    
    subgraph "Configuration"
        ApiConfig[API Config]
        AppConfig[App Config<br/>isDemoMode]
    end
    
    subgraph "Data Layer"
        Models[Data Models]
        LocalStorage[Shared Preferences]
    end
    
    Screens --> AuthService
    Screens --> CropService
    Screens --> FertService
    Screens --> DashboardService
    
    AuthService --> ApiConfig
    CropService --> ApiConfig
    FertService --> ApiConfig
    
    AuthService --> Models
    CropService --> Models
    
    AuthService --> LocalStorage
    CropService --> LocalStorage
    
    ApiConfig --> AppConfig
```

### Demo Mode vs Production Mode

```mermaid
flowchart TD
    AppStart([App Starts]) --> CheckMode{AppConfig.isDemoMode?}
    
    CheckMode -->|true| DemoPath[Use Mock Data]
    CheckMode -->|false| RealPath[Use Backend API]
    
    DemoPath --> MockAuth[Mock Authentication]
    DemoPath --> MockCrops[Mock Crop Data]
    DemoPath --> MockAgents[Mock Agent Responses]
    
    RealPath --> LiveAuth[Real API Calls]
    RealPath --> LiveDB[Database Queries]
    RealPath --> LiveAI[Gemini AI Agents]
    
    MockAuth --> Display[Display in UI]
    MockCrops --> Display
    MockAgents --> Display
    
    LiveAuth --> Display
    LiveDB --> Display
    LiveAI --> Display
```

---

## 🚀 Deployment Architecture

### Development Setup

```
┌─────────────────────────────────────┐
│   Developer Laptop                  │
├─────────────────────────────────────┤
│  Backend (localhost:8002)           │
│  ├── Flask API                      │
│  ├── SQLite DB                      │
│  └──  Multi-Agent System            │
│                                     │
│  Frontend (USB Device)              │
│  └── Flutter App                    │
│      ├── ADB Reverse: port 8002     │
│      └── or Local IP: 20.20.23.128  │
└─────────────────────────────────────┘
```

### Production Setup (Planned)

```
┌──────────────────────────────────────────┐
│  AWS EC2 Instance (16.170.246.4)         │
├──────────────────────────────────────────┤
│  ├── Gunicorn WSGI Server                │
│  ├── Nginx Reverse Proxy (HTTPS)         │
│  ├── PostgreSQL Database                 │
│  └── Supervisor (Process Management)     │
└──────────────────────────────────────────┘
           ↑ HTTPS
           │
┌──────────┴──────────┐
│  Mobile Devices     │
│  (Android App)      │
└─────────────────────┘
```

---

## 📈 Performance & Scalability

### Caching Strategy

- **Frontend**: SharedPreferences for user data, tokens, and last known crop states
- **Backend**: Agent execution logs cached in database
- **AI Responses**: No caching (always fresh recommendations based on latest data)

### Rate Limiting

- **Gemini AI**: 60 requests per minute limit
- **Weather API**: 1000 requests per day limit
- **Agent Execution**: Throttled by request timeout (30 seconds)

---

## 🛠️ Agent Prompt Engineering

Each agent uses specialized prompts:

### 1. **Crop Planning Agent**
- **Input**: Soil NPK, location, farmer preferences
- **Output**: Top 5 recommended crops with suitability scores
- **Temperature**: 0.7 (creative recommendations)

### 2. **Fertilization Agent**
- **Input**: Crop type, soil NPK, growth stage, land area
- **Output**: NPK requirements, fertilizer schedule, cost-effective options
- **Temperature**: 0.6 (balanced precision)

### 3. **Irrigation Agent**
- **Input**: Crop, growth stage, soil moisture, weather forecast
- **Output**: Next 7-day irrigation schedule, auto-adjusted for rain
- **Temperature**: 0.5 (precise scheduling)

### 4. **Disease Detection Agent**
- **Input**: Crop, symptoms description, optional image analysis
- **Output**: Disease diagnosis, treatment plan (chemical + organic)
- **Temperature**: 0.6 (accurate diagnosis)

### 5. **Harvest Prediction Agent**
- **Input**: Crop, sowing date, growth data, weather history
- **Output**: Predicted harvest date, yield estimate, optimal window
- **Temperature**: 0.6 (data-driven prediction)

### 6. **Price Prediction Agent**
- **Input**: Crop, harvest date, current market price
- **Output**: Price predictions (1 week, 2 weeks, 1 month), selling strategy
- **Temperature**: 0.7 (market trend analysis)

---

## 🔧 Configuration Management

### Environment Variables

**Frontend (.env)**
```
OPENWEATHER_API_KEY=<key>
GEMINI_API_KEY=<key>
DEMO_MODE=false
```

**Backend (.env)**
```
DATABASE_URL=postgresql://user:pass@localhost/krishimitra
SECRET_KEY=<secret>
JWT_SECRET_KEY=<secret>
GEMINI_API_KEY=<key>
FLASK_ENV=development
```

### API Configuration (Flutter)

```dart
class ApiConfig {
  static const String baseUrl = "http://20.20.23.128:8002";
  static const bool useBackendForFertilizers = true;
  static bool get isDemoMode => AppConfig.isDemoMode;
}
```

---

## 📊 Monitoring & Logging

### Agent Execution Logs

Every agent execution is logged with:
- Agent type
- User ID & Crop ID
- Input parameters
- Output results
- Execution time
- Status (success/error)
- Timestamp

### Frontend Logging

- Network errors captured and displayed to user
- Timeout errors (30 seconds) show appropriate messages
- Demo mode clearly indicated in UI

---

## 🎯 Future Enhancements

1. **Agent Orchestration Layer**: Coordinate multiple agents for complex queries
2. **ML Model Integration**: Custom trained models for disease detection
3. **Real-time Collaboration**: Multiple agents working simultaneously
4. **Blockchain Integration**: Transparent crop tracking
5. **IoT Sensor Integration**: Real-time soil moisture, temperature sensors
6. **Voice Interface**: Regional language voice commands
7. **Offline Mode**: Local AI models for areas with poor connectivity

---

## 📝 API Endpoints Summary

### Authentication
- `POST /api/auth/register` - Register new farmer
- `POST /api/auth/login` - Login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update profile
- `POST /api/auth/logout` - Logout

### Crop Management
- `POST /api/crops/auto-plan` - AI crop recommendations
- `POST /api/crops/add` - Add new crop
- `GET /api/crops/` - Get all user crops
- `GET /api/crops/<id>` - Get crop details
- `PUT /api/crops/<id>` - Update crop
- `DELETE /api/crops/<id>` - Delete crop

### Fertilization
- `GET /api/fertilization/<crop_id>` - Get fertilization plan
- `POST /api/fertilization/alternatives` - Find cheaper alternatives
- `POST /api/fertilization/analyze-bill` - Analyze fertilizer bill (OCR)

### Irrigation
- `GET /api/irrigation/<crop_id>` - Get irrigation schedule
- `POST /api/irrigation/update-moisture` - Update soil moisture

### Disease Detection
- `POST /api/disease/detect` - Detect disease from image/symptoms
- `GET /api/disease/<crop_id>` - Get disease history

### Harvest & Price
- `GET /api/harvest/predict/<crop_id>` - Predict harvest date
- `GET /api/harvest/recommendations/<crop_id>` - Get harvest + price recommendations

### Dashboard
- `GET /api/dashboard/` - Get aggregated dashboard data
- `GET /api/dashboard/alerts` - Get active alerts
- `GET /api/dashboard/analytics` - Get analytics

### Marketplace
- `POST /api/marketplace/fertilizers/compare` - Compare fertilizer prices

---

## 👥 Contributors

- **Backend Development**: Multi-agent system, Flask API, database design
- **Frontend Development**: Flutter app, service integration, UI/UX
- **AI Integration**: Gemini AI prompt engineering, agent design
- **DevOps**: AWS deployment, CI/CD, monitoring

---

**Last Updated**: February 1, 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅
