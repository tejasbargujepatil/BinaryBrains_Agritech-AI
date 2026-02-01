import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/crop_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class CropService {
  // Get all crops for user
  static Future<Map<String, dynamic>> getCrops() async {
    // Demo mode: return mock data
    if (AppConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'crops': MockDataService.getMockCrops()};
    }
    
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.getCrops)),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final crops = (data['crops'] as List?)
            ?.map((e) => CropModel.fromJson(e))
            .toList() ?? [];
        return {'success': true, 'crops': crops};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ??'Failed to fetch crops'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // AI Auto-plan best crop for farmer
  static Future<Map<String, dynamic>> autoPlanCrop({
    Map<String, dynamic>? soilData,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.autoPlanCrop)),
        headers: headers,
        body: jsonEncode({
          'soil_data': soilData ?? {},
          'preferences': preferences ?? {},
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'recommendations': data['recommendations'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to get crop recommendations',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Add new crop
  static Future<Map<String, dynamic>> addCrop({
    required String cropName,
    required DateTime sowingDate,
    required double landArea,
    required String irrigationType,
    String? cropVariety,
  }) async {
    // Demo mode: simulate success
    if (AppConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {'success': true, 'message': 'Crop added successfully (Demo Mode)'};
    }
    
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.addCrop)),
        headers: headers,
        body: jsonEncode({
          'crop_name': cropName,
          'sowing_date': sowingDate.toIso8601String(),
          'land_area': landArea,
          'irrigation_type': irrigationType,
          'crop_variety': cropVariety,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'crop': CropModel.fromJson(data['crop'])};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to add crop'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get crop details
  static Future<Map<String, dynamic>> getCropDetails(String cropId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.cropDetails(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'crop': CropModel.fromJson(data['crop'])};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch crop details'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Update crop
  static Future<Map<String, dynamic>> updateCrop(
    String cropId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.updateCrop(cropId))),
        headers: headers,
        body: jsonEncode(updates),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'crop': CropModel.fromJson(data['crop'])};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to update crop'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Delete crop
  static Future<Map<String, dynamic>> deleteCrop(String cropId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.deleteCrop(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to delete crop'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
