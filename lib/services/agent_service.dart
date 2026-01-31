import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/agent_plan_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class AgentService {
  // Get comprehensive agent plan for a crop
  static Future<Map<String, dynamic>> getAgentPlan(String cropId) async {
    // Demo mode: return mock data with realistic delay
    if (AppConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate AI processing
      return {'success': true, 'plan': MockDataService.getMockAgentPlan(cropId)};
    }
    
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.agentPlan(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'plan': AgentPlanModel.fromJson(data['plan']),
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch agent plan'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get recommendations for a crop
  static Future<Map<String, dynamic>> getRecommendations(String cropId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.agentRecommendations(cropId))),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'recommendations': data['recommendations']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch recommendations'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Upload disease photo
  static Future<Map<String, dynamic>> uploadDiseasePhoto(
    String cropId,
    File imageFile,
  ) async {
    try {
      final token = await AuthService.getAuthToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.buildUrl(ApiConfig.uploadDiseasePhoto)),
      );
      
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      request.fields['cropId'] = cropId;
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        imageFile.path,
      ));
      
      final streamedResponse = await request.send()
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'diagnosis': data['diagnosis'],
          'recommendations': data['recommendations'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to upload photo'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Upload fertilizer bill
  static Future<Map<String, dynamic>> uploadFertilizerBill(
    String cropId,
    File billFile,
  ) async {
    try {
      final token = await AuthService.getAuthToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.buildUrl(ApiConfig.uploadFertilizerBill)),
      );
      
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      request.fields['cropId'] = cropId;
      request.files.add(await http.MultipartFile.fromPath(
        'bill',
        billFile.path,
      ));
      
      final streamedResponse = await request.send()
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'analysis': data['analysis'],
          'costComparison': data['costComparison'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to upload bill'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
