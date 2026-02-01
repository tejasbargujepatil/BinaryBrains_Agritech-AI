import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import 'auth_service.dart';

/// Service for disease detection-related API calls
class DiseaseService {
  
  /// Detect disease from symptoms and image
  static Future<Map<String, dynamic>> detectDisease({
    required String cropId,
    required String symptoms,
    String? imageUrl,
    Map<String, dynamic>? imageAnalysis,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.detectDisease)),
        headers: headers,
        body: jsonEncode({
          'crop_id': cropId,
          'symptoms': symptoms,
          'image_url': imageUrl,
          'image_analysis': imageAnalysis,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'diagnosis': data['diagnosis'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to detect disease',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Get all disease detections for a crop
  static Future<Map<String, dynamic>> getCropDiseases(String cropId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.getCropDiseases(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'crop': data['crop'],
          'detections': data['detections'] ?? [],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch disease history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
