import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/soil_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class SoilService {
  // Get soil data by location
  static Future<Map<String, dynamic>> getSoilData(
    double latitude,
    double longitude,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(
          ApiConfig.soilByLocation(latitude, longitude),
        )),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'soil': SoilModel.fromJson(data['soil']),
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch soil data'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get soil analysis
  static Future<Map<String, dynamic>> getSoilAnalysis(
    double latitude,
    double longitude,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.soilAnalysis)),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'analysis': data['analysis'],
          'recommendations': data['recommendations'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch soil analysis'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get soil data for user's location (from profile)
  static Future<Map<String, dynamic>> getUserSoilData() async {
    // Demo mode: return mock data
    if (AppConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return {'success': true, 'soil': MockDataService.getMockSoil()};
    }
    
    try {
      final userData = await AuthService.getUserData();
      if (userData == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }
      
      return await getSoilData(
        userData.location.latitude,
        userData.location.longitude,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
