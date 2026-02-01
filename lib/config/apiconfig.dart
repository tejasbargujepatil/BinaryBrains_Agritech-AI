/// API Configuration - Single source of truth for all API endpoints
/// 
/// IMPORTANT: API keys are now loaded from .env file
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL - Local IP for USB-connected device on same network
  static const String baseUrl = "http://20.20.23.128:8002";
  
  // Backend API base URL (for AI agents)
  static const String backendBaseUrl = "http://20.20.23.128:8002/api";
  
  // Backend integration settings
  static const bool useBackendForFertilizers = true;
  
  // Demo mode
  static bool get isDemoMode => dotenv.env['DEMO_MODE']?.toLowerCase() == 'true';
  
  // OpenWeatherMap API (for weather forecasts)
  static String get openWeatherMapApiKey => 
      dotenv.env['OPENWEATHER_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  static const String openWeatherMapBaseUrl = "https://api.openweathermap.org/data/2.5";
  
  // Google Gemini AI API
  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_API_KEY_HERE';
      
  static String get openAiApiKey => 
      dotenv.env['OPENAI_API_KEY'] ?? '';

  static String get dataGovApiKey => dotenv.env['DATA_GOV_API_KEY'] ?? '';
  static String get datasetId => dotenv.env['DATASET_ID'] ?? '';

  // Market Price API (Agmarknet via Data.gov.in)
  static String getMarketPriceUrl({
    required String state,
    String? district,
    required String commodity,
    int limit = 50,
  }) {
    // Trimming inputs to avoid mismatch
    final cleanState = state.trim();
    final cleanCommodity = commodity.trim();
    final cleanDistrict = district?.trim();

    String url = "https://api.data.gov.in/resource/$datasetId?api-key=$dataGovApiKey&format=json&filters[state.keyword]=$cleanState&filters[commodity.keyword]=$cleanCommodity&limit=$limit";
    
    if (cleanDistrict != null && cleanDistrict.isNotEmpty) {
      url += "&filters[district.keyword]=$cleanDistrict";
    }
    return url;
  }
  
  // Authentication Endpoints
  static const String login = "/api/auth/login";
  static const String register = "/api/auth/register";
  static const String profile = "/api/auth/profile";
  static const String updateProfile = "/api/auth/profile";
  static const String verifyToken = "/api/auth/verify";
  static const String logout = "/api/auth/logout";
  
  // Crop Endpoints
  static const String autoPlanCrop = "/api/crops/auto-plan";
  static const String addCrop = "/api/crops/add";
  static const String getCrops = "/api/crops/";
  static String cropDetails(String cropId) => "/api/crops/$cropId";
  static String updateCrop(String cropId) => "/api/crops/$cropId";
  static String deleteCrop(String cropId) => "/api/crops/$cropId";
  
  // Fertilization Endpoints
  static String fertilizationPlan(String cropId) => "/api/fertilization/$cropId";
  static const String findCheaperAlternatives = "/api/fertilization/alternatives";
  static const String analyzeFertilizerBill = "/api/fertilization/analyze-bill";
  
  // Irrigation Endpoints
  static String irrigationSchedule(String cropId) => "/api/irrigation/$cropId";
  static const String updateSoilMoisture = "/api/irrigation/update-moisture";
  
  // Disease Detection Endpoints
  static const String detectDisease = "/api/disease/detect";
  static String getCropDiseases(String cropId) => "/api/disease/$cropId";
  
  // Harvest & Price Prediction Endpoints
  static String predictHarvest(String cropId) => "/api/harvest/predict/$cropId";
  static String harvestRecommendations(String cropId) => "/api/harvest/recommendations/$cropId";
  
  // Dashboard Endpoints
  static const String dashboard = "/api/dashboard/";
  static const String dashboardAlerts = "/api/dashboard/alerts";
  static const String dashboardAnalytics = "/api/dashboard/analytics";
  
  // Marketplace Endpoints
  static const String compareFertilizers = "/api/marketplace/fertilizers/compare";
  
  // Legacy Agent Endpoints (for backward compatibility)
  static const String agentBase = "/api/v1/agent";
  static const String agentAnalyze = '$agentBase/analyze'; // New comprehensive endpoint
  static const String agentDailyCheck = '$agentBase/daily_check';
  static String agentPlan(String cropId) => "/api/crops/$cropId";
  static String agentRecommendations(String cropId) => harvestRecommendations(cropId);
  static const String uploadDiseasePhoto = "/api/disease/detect";
  static const String uploadFertilizerBill = "/api/fertilization/analyze-bill";
  
  // Weather Endpoints (external API)
  static const String currentWeather = "/weather/current";
  static const String weatherForecast = "/weather/forecast";
  static String weatherByLocation(double lat, double lon) => 
      "/weather?lat=$lat&lon=$lon";
  
  // Soil Endpoints (external API)
  static const String soilData = "/soil";
  static String soilByLocation(double lat, double lon) => 
      "/soil?lat=$lat&lon=$lon";
  static const String soilAnalysis = "/soil/analysis";
  
  // File Upload
  static const String uploadPhoto = "/upload/photo";
  static const String uploadDocument = "/upload/document";
  
  // ISRIC SoilGrids API
  static const String isricSoilApiUrl = "https://rest.isric.org/soilgrids/v2.0/properties/query";

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
