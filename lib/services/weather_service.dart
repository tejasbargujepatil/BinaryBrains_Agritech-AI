import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/weather_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class WeatherService {
  // Get current weather (Direct OpenWeatherMap)
  static Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiKey = ApiConfig.openWeatherMapApiKey;
      final url = "${ApiConfig.openWeatherMapBaseUrl}/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric";
      
      print('DEBUG: Fetching Weather from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: AppConstants.requestTimeout),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Map OWM response to WeatherModel
        return {
          'success': true,
          'weather': WeatherModel(
            temperature: (data['main']['temp'] as num).toDouble(),
            condition: (data['weather'] as List).isNotEmpty ? data['weather'][0]['main'] : 'Clear',
            humidity: (data['main']['humidity'] as num).toDouble(),
            windSpeed: (data['wind']['speed'] as num).toDouble(),
            rainProbability: 0.0, // OWM Current API doesn't provide POP, requires OneCall
            location: data['name'] ?? 'Unknown',
            timestamp: DateTime.now(),
          ),
        };
      } else {
        print('OWM Error: ${response.statusCode}');
        return {'success': false, 'error': 'Failed to fetch weather: ${response.body}'};
      }
    } catch (e) {
      print('WeatherService Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get 7-day weather forecast
  static Future<Map<String, dynamic>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.weatherForecast)),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecast = (data['forecast'] as List?)
            ?.map((e) => WeatherForecast.fromJson(e))
            .toList() ?? [];
        return {'success': true, 'forecast': forecast};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Failed to fetch forecast'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get weather for user's location (from profile)
  static Future<Map<String, dynamic>> getUserWeather() async {
    // Demo mode: return mock data
    if (AppConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return {'success': true, 'weather': MockDataService.getMockWeather()};
    }
    
    try {
      final userData = await AuthService.getUserData();
      if (userData == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }
      
      return await getCurrentWeather(
        userData.location.latitude,
        userData.location.longitude,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
