import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';

class BackendService {
  static Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${ApiConfig.backendBaseUrl}$endpoint');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Backend request failed: $e');
      rethrow;
    }
  }

  // Helper methods
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) {
    return request(method: 'GET', endpoint: endpoint, token: token);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) {
    return request(method: 'POST', endpoint: endpoint, token: token, body: body);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) {
    return request(method: 'PUT', endpoint: endpoint, token: token, body: body);
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {String? token}) {
    return request(method: 'DELETE', endpoint: endpoint, token: token);
  }
}
