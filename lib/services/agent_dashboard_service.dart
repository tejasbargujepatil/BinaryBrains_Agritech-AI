import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/apiconfig.dart';
import 'backend_service.dart';

/// Service for all AI Agent interactions with backend
class AgentDashboardService {
  /// Get complete agent data for a specific crop
  static Future<Map<String, dynamic>> getCropAgentData(int cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/crops/$cropId', token: token);
  }

  /// Get irrigation schedule for a crop
  static Future<Map<String, dynamic>> getIrrigationSchedule(int cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/irrigation/$cropId', token: token);
  }

  /// Update soil moisture and get adjusted irrigation schedule
  static Future<Map<String, dynamic>> updateSoilMoisture({
    required int cropId,
    required double soilMoisture,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.post(
      '/irrigation/update-moisture',
      token: token,
      body: {
        'crop_id': cropId,
        'soil_moisture': soilMoisture,
      },
    );
  }

  /// Detect disease from image/symptoms
  static Future<Map<String, dynamic>> detectDisease({
    required int cropId,
    required String symptoms,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.post(
      '/disease/detect',
      token: token,
      body: {
        'crop_id': cropId,
        'symptoms': symptoms,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
  }

  /// Get disease detection history for a crop
  static Future<List<Map<String, dynamic>>> getDiseaseHistory(int cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await BackendService.get('/disease/$cropId', token: token);
    return List<Map<String, dynamic>>.from(response['detections'] ?? []);
  }

  /// Get harvest prediction for a crop
  static Future<Map<String, dynamic>> getHarvestPrediction(int cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/harvest/predict/$cropId', token: token);
  }

  /// Get combined harvest and price recommendations
  static Future<Map<String, dynamic>> getHarvestRecommendations(int cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/harvest/recommendations/$cropId', token: token);
  }

  /// Get dashboard with all crops and alerts
  static Future<Map<String, dynamic>> getDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/dashboard', token: token);
  }

  /// Get alerts only
  static Future<List<Map<String, dynamic>>> getAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await BackendService.get('/dashboard/alerts', token: token);
    return List<Map<String, dynamic>>.from(response['alerts'] ?? []);
  }

  /// Get agent analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendService.get('/dashboard/analytics', token: token);
  }
}
