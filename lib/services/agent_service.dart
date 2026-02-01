import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/agent_plan_model.dart';
import 'crop_service.dart';
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
      // 1. Fetch crop details first to get the name
      final cropResult = await CropService.getCropDetails(cropId);
      if (!cropResult['success']) {
        return {'success': false, 'error': cropResult['error'] ?? 'Failed to fetch crop details'};
      }
      
      final cropData = cropResult['crop']; // CropModel
      final String cropName = cropData.cropName;
      
      final headers = await AuthService.getAuthHeaders();
      
      // 2. Call New Rule-Based Analysis Endpoint
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.agentAnalyze)),
        headers: headers,
        body: jsonEncode({
          'crop_name': cropName,
          'soil_data': {}, // Add actual soil data if available in future
          'location': {},  // Backend defaults to Vidarbha if empty
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data structure: { status: 'success', data: { crop: '...', overall_summary: '...', ... } }
        
        if (data['status'] == 'success') {
           print("DEBUG: Backend response data type: ${data['data'].runtimeType}");
           print("DEBUG: Backend response data: ${data['data']}");
           if (data['data'] != null) {
             final backendData = Map<String, dynamic>.from(data['data']);
             return {
              'success': true,
              'plan': AgentPlanModel.fromBackendResponse(backendData),
            };
           } else {
             return {'success': false, 'error': 'Analysis returned no data'};
           }       
        } else {
           return {'success': false, 'error': data['message'] ?? 'Analysis failed'};
        }

      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to analyze crop'};
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

  /// Triggers proactive daily analysis for all crops
  static Future<Map<String, dynamic>> triggerDailyCheck() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.agentDailyCheck)),
        headers: headers,
      );

      print('DEBUG: Daily Check Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Alerts found: ${data['alerts']}');
        return {
          'success': true, 
          'alerts': data['alerts'] ?? [],
          'stage_updates': data['stage_updates'] ?? []
        };
      } else {
        return {'success': false, 'error': 'Daily check failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  // Cache Key Prefix
  static const String _paramCachePrefix = 'smart_plan_';

  // Get Cached Plan (Offline Friendly)
  static Future<AgentPlanModel?> getCachedSmartPlan(String cropId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedJson = prefs.getString('$_paramCachePrefix$cropId');
      
      if (cachedJson != null) {
        print('DEBUG: Loading plan from cache for $cropId');
        final Map<String, dynamic> jsonMap = jsonDecode(cachedJson);
        return AgentPlanModel.fromJson(jsonMap);
      }
    } catch (e) {
      print('DEBUG: Cache load error: $e');
    }
    return null;
  }

  // Direct Gemini Generation (Bypassing Backend)
  static Future<Map<String, dynamic>> generateSmartPlan({
    required String cropName,
    required String location,
    Map<String, dynamic>? weatherData,
    Map<String, dynamic>? soilData,
    String? cropId, // Added for caching
  }) async {
    try {
      final apiKey = ApiConfig.geminiApiKey;
      print('DEBUG: Loaded API Key: ${apiKey.substring(0, 5)}... (Length: ${apiKey.length})');
      
      // if (apiKey.isEmpty || apiKey == 'AIzaSyAyQANnY_3sgxRWNKq6sXqm1Myc7e0rmIo') {
      //   return {'success': false, 'error': ' API Key not found'};
      // }

      print('DEBUG: Generating Smart Plan for $cropName in $location using Gemini...');

      // Construct Prompt
      final systemPrompt = '''
You are an expert agronomist advisor for Indian farmers. 
Analyze the given crop, location, weather, and soil conditions to generate a comprehensive farming plan.
Output MUST be strict JSON matching this structure exactly (do not wrap in markdown):
{
  "cropId": "generated_id",
  "suitability": {
    "isSuitable": true,
    "suitabilityScore": "85%",
    "soilValidation": "Soil is compatible...",
    "recommendations": ["Tip 1", "Tip 2"]
  },
  "governmentSchemes": [
    { "name": "Scheme Name", "description": "Desc", "eligibility": "Criteria", "applicationLink": "url" }
  ],
  "sowingPlan": {
    "bestSowingWindow": "June 15 - July 10",
    "weatherConsiderations": "Ensure monsoon onset...",
    "tips": ["Treat seeds", "Spacing 30x10cm"]
  },
  "fertilization": {
    "schedule": [
      { "stage": "Basal", "fertilizer": "Urea", "quantity": "50kg/acre", "method": "Broadcasting" }
    ],
    "lowCostAlternatives": []
  },
  "irrigation": {
    "schedule": [
      { "stage": "Vegetative", "frequency": "Every 10 days", "amount": "50mm" }
    ],
    "waterRequirement": "500-700mm total"
  },
  "disease": {
    "timeline": [
      { "stage": "Flowering", "diseaseName": "Rust", "probability": "High", "symptoms": "Yellow spots" }
    ],
    "preventiveMeasures": ["Use resistant variety"]
  },
  "harvest": {
    "expectedHarvestDate": "2024-10-15",
    "yieldPrediction": "15-20 quintals/acre",
    "harvestIndicators": ["Yellowing leaves"]
  },
  "residue": {
    "utilizationMethods": ["Mulching"],
    "environmentalImpact": "Reduces pollution"
  },
  "storage": {
    "storageMethod": "Gunny bags",
    "storageDuration": "6-8 months",
    "pricePrediction": "Rising trend",
    "bestSellingTime": "December"
  },
  "valueAddedProducts": [
    { "name": "Product", "description": "Desc", "marketPotential": "High" }
  ],
  "directSelling": {
    "platforms": [
      { "name": "Platform", "description": "Desc" }
    ],
    "tips": ["Clean produce"]
  },
  "alliedBusinessIdeas": [
    { "name": "Idea", "description": "Desc", "investment": "Low" }
  ],
  "fertilizerCost": {
    "comparison": [],
    "recommendations": "Use bio-fertilizers"
  },
  "lastUpdated": "${DateTime.now().toIso8601String()}"
}
''';

      final userPrompt = '''
Crop: $cropName
Location: $location
Weather: ${jsonEncode(weatherData ?? {})}
Soil: ${jsonEncode(soilData ?? {})}
Generate a highly specific plan for this farmer.
''';

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': '$systemPrompt\n\n$userPrompt'}]
          }],
          'generationConfig': {
             'responseMimeType': 'application/json',
          }
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var content = data['candidates'][0]['content']['parts'][0]['text'];
        print('DEBUG: Gemini Response Raw: $content');
        
        // Clean Markdown if present
        content = content.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
        content = content.trim(); // Clean whitespace
        
        final jsonPlan = jsonDecode(content);
        
        if (jsonPlan is! Map<String, dynamic>) {
           throw Exception("AI returned ${jsonPlan.runtimeType} instead of Map<String, dynamic>");
        }
        
        // Cache on success if cropId provided
        if (cropId != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('$_paramCachePrefix$cropId', jsonEncode(jsonPlan));
            print('DEBUG: Plan cached for $cropId');
          } catch (e) {
            print('DEBUG: Cache save failed: $e');
          }
        }

        return {
          'success': true,
          'plan': AgentPlanModel.fromJson(jsonPlan),
        };
      } else {
        print('DEBUG: Krishimitra Error: ${response.body}');
        return {
          'success': false, 
          'error': 'Krishimitra Generation Failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('DEBUG: Generator Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
