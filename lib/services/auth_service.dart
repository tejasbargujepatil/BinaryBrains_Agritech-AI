import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/apiconfig.dart';
import '../config/constants.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(String mobileNumber, String password) async {
    // Demo mode: bypass API and use dummy credentials
    if (AppConfig.isDemoMode) {
      if (mobileNumber == AppConfig.demoMobileNumber && password == AppConfig.demoPassword) {
        // Create demo user data
        final demoUserData = {
          'id': 'demo_user_001',
          'name': AppConfig.demoUserName,
          'mobileNumber': AppConfig.demoMobileNumber,
          'location': {
            'latitude': AppConfig.demoLatitude,
            'longitude': AppConfig.demoLongitude,
            'address': AppConfig.demoAddress,
          },
        };
        
        // Save demo token and user data
        await saveAuthToken('demo_token_12345');
        await saveUserData(demoUserData);
        
        return {'success': true, 'data': {'token': 'demo_token_12345', 'user': demoUserData}};
      } else {
        return {'success': false, 'error': 'Invalid credentials. Use:\nNumber: ${AppConfig.demoMobileNumber}\nPassword: ${AppConfig.demoPassword}'};
      }
    }
    
    // Real API call
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.login)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'password': password,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save auth token
        if (data['token'] != null) {
          await saveAuthToken(data['token']);
        }
        
        // Save user data
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String mobileNumber,
    required String password,
    required double latitude,
    required double longitude,
    String? address,
    Map<String, dynamic>? weatherData,
    Map<String, dynamic>? soilData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.register)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'mobileNumber': mobileNumber,
          'password': password,
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
          },
          'weatherData': weatherData,
          'soilData': soilData,
        }),
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Save auth token
        if (data['token'] != null) {
          await saveAuthToken(data['token']);
        }
        
        // Save user data
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Save auth token
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }
  
  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }
  
  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(userData));
    if (userData['id'] != null || userData['_id'] != null) {
      await prefs.setString(AppConstants.keyUserId, userData['id'] ?? userData['_id']);
    }
  }
  
  // Get user data
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.keyUserData);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
  
  // Verify token
  static Future<bool> verifyToken() async {
    // Demo mode: always valid
    if (AppConfig.isDemoMode) {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    }
    
    try {
      final token = await getAuthToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl(ApiConfig.verifyToken)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: AppConstants.requestTimeout));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyUserId);
  }
  
  // Get auth headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
}
