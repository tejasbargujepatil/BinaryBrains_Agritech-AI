import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import 'auth_service.dart';

/// Service for fertilization-related API calls
class FertilizationService {
  
  /// Get AI-generated fertilization plan for a crop
  static Future<Map<String, dynamic>> getFertilizationPlan(String cropId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.fertilizationPlan(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'plan': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch fertilization plan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Find cheaper fertilizer alternatives based on NPK values
  static Future<Map<String, dynamic>> findCheaperAlternatives({
    required Map<String, int> npk,
    String? currentBrand,
    double? currentPrice,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.findCheaperAlternatives)),
        headers: headers,
        body: jsonEncode({
          'npk': npk,
          'brand': currentBrand ?? 'Unknown',
          'price': currentPrice ?? 0,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'alternatives': data['alternatives'] ?? data['cheaper_alternatives'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to find alternatives',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Analyze fertilizer bill (with OCR data)
  static Future<Map<String, dynamic>> analyzeFertilizerBill({
    required Map<String, int> npk,
    required double price,
    String? brand,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.analyzeFertilizerBill)),
        headers: headers,
        body: jsonEncode({
          'npk': npk,
          'price': price,
          'brand': brand ?? 'Unknown',
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'extractedNpk': data['extracted_npk'],
          'alternatives': data['cheaper_alternatives'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to analyze bill',
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
