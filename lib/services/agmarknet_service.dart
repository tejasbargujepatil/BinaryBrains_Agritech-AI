import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/constants.dart';

class AgmarknetService {
  static Future<Map<String, dynamic>> fetchPrices({
    required String state,
    String? district,
    required String commodity,
    int limit = 50,
  }) async {
    try {
      final url = ApiConfig.getMarketPriceUrl(
        state: state,
        district: district,
        commodity: commodity,
        limit: limit,
      );
      
      print('DEBUG: Fetching prices from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: AppConstants.requestTimeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Price data fetched: ${data['records'].length} records');
        return {
          'success': true,
          'records': data['records'] ?? [],
          'total': data['total'] ?? 0,
          'updated_date': data['updated_date'],
        };
      } else {
        print('DEBUG: Fetch failed: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Failed to fetch prices: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('DEBUG: Agmarknet Exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
