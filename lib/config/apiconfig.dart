/// API Configuration - Single source of truth for all API endpoints
/// 
/// IMPORTANT: API keys are now loaded from .env file
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL - Replace with your EC2 public IP
  static const String baseUrl = "http://YOUR_EC2_PUBLIC_IP:8000";
  
  // OpenWeatherMap API (for weather forecasts)
  static String get openWeatherMapApiKey => 
      dotenv.env['OPENWEATHER_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  static const String openWeatherMapBaseUrl = "https://api.openweathermap.org/data/2.5";
  
  // Google Gemini AI API
  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  
  // Authentication Endpoints
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String verifyToken = "/auth/verify";
  static const String logout = "/auth/logout";
  
  // Crop Endpoints
  static const String crops = "/crops";
  static const String addCrop = "/crops/add";
  static String cropDetails(String cropId) => "/crops/$cropId";
  static String updateCrop(String cropId) => "/crops/$cropId/update";
  static String deleteCrop(String cropId) => "/crops/$cropId/delete";
  
  // Agent Endpoints
  static String agentPlan(String cropId) => "/agent/plan/$cropId";
  static String agentRecommendations(String cropId) => "/agent/recommendations/$cropId";
  static const String uploadDiseasePhoto = "/agent/disease/upload";
  static const String uploadFertilizerBill = "/agent/fertilizer/upload";
  
  // Weather Endpoints
  static const String currentWeather = "/weather/current";
  static const String weatherForecast = "/weather/forecast";
  static String weatherByLocation(double lat, double lon) => 
      "/weather?lat=$lat&lon=$lon";
  
  // Soil Endpoints
  static const String soilData = "/soil";
  static String soilByLocation(double lat, double lon) => 
      "/soil?lat=$lat&lon=$lon";
  static const String soilAnalysis = "/soil/analysis";
  
  // Alerts Endpoints
  static const String alerts = "/alerts";
  static String markAlertRead(String alertId) => "/alerts/$alertId/read";
  
  // Profile Endpoints
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/profile/update";
  static const String deleteAccount = "/user/delete";
  
  // File Upload
  static const String uploadPhoto = "/upload/photo";
  static const String uploadDocument = "/upload/document";
  
  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
