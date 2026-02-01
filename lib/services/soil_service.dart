import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/soil_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class SoilService {
  // Get soil data by location (using ISRIC SoilGrids)
  static Future<Map<String, dynamic>> getSoilData(
    double latitude,
    double longitude,
  ) async {
    try {
      // Construct ISRIC Query URL
      // Layers: pH (phh2o), Nitrogen (nitrogen), Phosphorus (extractable P - probably not available directly, guessing), Organic Carbon (soc)
      // Note: ISRIC v2.0 properties: nitrogen, phh2o, soc, clay, silt, sand
      final url = "${ApiConfig.isricSoilApiUrl}?lon=$longitude&lat=$latitude&properties=nitrogen&properties=phh2o&properties=soc&properties=clay&properties=sand&depths=0-5cm&depths=5-15cm&values=mean";
      
      print('DEBUG: Fetching Soil from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: AppConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final properties = data['properties'] as Map; // layers

        // Helper to get mean value for first depth (0-30cm roughly)
        double getValue(String prop) {
          try {
             final layer = data['properties']['layers'].firstWhere((l) => l['name'] == prop, orElse: () => null);
             if (layer == null) return 0.0;
             final depth = layer['depths'].firstWhere((d) => d['label'] == '0-5cm', orElse: () => null);
             if (depth == null) return 0.0;
             return (depth['values']['mean'] as num).toDouble();
          } catch (e) {
            return 0.0;
          }
        }
        
        // pH is usually scaled by 10 in SoilGrids (e.g. 65 -> 6.5)
        final phRaw = getValue('phh2o');
        final ph = phRaw / 10.0; 
        
        // Nitrogen (cg/kg) -> convert to % or kg/ha? 
        // Nitrogen is 'nitrogen' in SoilGrids (centigrams/kg)
        // 100 cg/kg = 1 g/kg = 0.1%
        final nitrogenRaw = getValue('nitrogen'); 
        final nitrogen = '${(nitrogenRaw / 100).toStringAsFixed(2)}%'; // Display as percentage

        // Organic Carbon (dg/kg) -> decigrams/kg
        // 10 dg/kg = 1 g/kg = 0.1%
        final socRaw = getValue('soc'); 
        
        // Clay/Sand for Texture
        final clay = getValue('clay');
        final sand = getValue('sand');
        
        String soilType = "Loam"; // Default
        if (clay > 40) soilType = "Clay";
        else if (sand > 50) soilType = "Sandy";
        
        // Phosphorus & Potassium are NOT in standard SoilGrids, use mock/default or estimate
        // We will leave them as 'N/A' or estimates for now
        
        return {
          'success': true,
          'soil': SoilModel(
            soilType: soilType,
            ph: ph,
            nitrogen: nitrogen,
            phosphorus: "Estimated", // Not in SoilGrids
            potassium: "Estimated", // Not in SoilGrids
            moisture: "Moderate",
            organicCarbon: '${(socRaw / 100).toStringAsFixed(2)}%',
            timestamp: DateTime.now(),
          ),
        };
      } else {
        print('ISRIC Error: ${response.statusCode}');
        // Fallback to mock on error? Or return error
        return {'success': false, 'error': 'Failed to fetch soil data'};
      }
    } catch (e) {
      print('SoilService Exception: $e');
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
