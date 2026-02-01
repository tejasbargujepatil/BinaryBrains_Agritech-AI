import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../models/market_place.dart';
import 'auth_service.dart';

/// Service for marketplace-related API calls
class MarketplaceService {
  
  /// Compare fertilizers and find cheaper alternatives
  static Future<Map<String, dynamic>> compareFertilizers({
    required Map<String, int> npk,
    String? currentBrand,
    double? currentPrice,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.compareFertilizers)),
        headers: headers,
        body: jsonEncode({
          'npk': npk,
          'current_brand': currentBrand ?? 'Unknown',
          'current_price': currentPrice ?? 0,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'currentFertilizer': data['current_fertilizer'],
          'recommendations': data['recommendations'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to compare fertilizers',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get crop prices from data.gov.in for specific crops and location
  static Future<Map<String, dynamic>> getCropPrices({
    required String state,
    required String district,
    List<String>? commodities,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/marketplace/crop-prices'),
        headers: headers,
        body: jsonEncode({
          'state': state,
          'district': district,
          'commodities': commodities ?? [],
        }),
      ).timeout(Duration(seconds: 45)); // Longer timeout for data fetching
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final markets = (data['markets'] as List)
            .map((m) => MarketPlace.fromJson(m))
            .toList();
        
        return {
          'success': true,
          'markets': markets,
          'count': data['markets_found'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch prices',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get nearby markets based on user location
  static Future<Map<String, dynamic>> getNearbyMarkets({
    String? commodity,
    String? state,
    String? district,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/marketplace/nearby-markets')
          .replace(queryParameters: {
        if (commodity != null) 'commodity': commodity,
        if (state != null) 'state': state,
        if (district != null) 'district': district,
      });
      
      final response = await http.get(uri, headers: headers)
          .timeout(Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final markets = (data['markets'] as List)
            .map((m) => MarketPlace.fromJson(m))
            .toList();
        
        return {
          'success': true,
          'markets': markets,
          'userLocation': data['user_location'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get nearby markets',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get AI-powered price analysis for a crop
  static Future<Map<String, dynamic>> analyzePrices({
    required String cropName,
    required List<MarketPlace> markets,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final marketsJson = markets.map((m) => m.toJson()).toList();
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/marketplace/analyze-prices'),
        headers: headers,
        body: jsonEncode({
          'crop_name': cropName,
          'markets': marketsJson,
        }),
      ).timeout(Duration(seconds: 60)); // AI analysis takes longer
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'analysis': data['analysis'],
          'crop': data['crop'],
        };
      } else {
        return {
          'success': false,
          'error': 'Analysis failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
