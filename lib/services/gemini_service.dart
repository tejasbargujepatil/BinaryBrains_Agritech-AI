import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../config/apiconfig.dart';
import '../config/app_config.dart';
import '../models/fertilizer_recommendation.dart';

/// Gemini AI Service for intelligent fertilizer recommendations
class GeminiService {
  static GenerativeModel? _model;

  /// Initialize Gemini model
  static GenerativeModel _getModel() {
    if (_model == null) {
      final apiKey = ApiConfig.geminiApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        throw Exception('Gemini API key not configured. Please add GEMINI_API_KEY to .env file');
      }
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
    }
    return _model!;
  }

  /// Search fertilizers based on NPK requirements
  static Future<FertilizerAnalysisResponse> searchFertilizers({
    required int nitrogen,
    required int phosphorus,
    required int potassium,
    String? location,
    String? cropType,
    String? token,  // For backend authentication
  }) async {
    // Try backend first if configured
    if (ApiConfig.useBackendForFertilizers && token != null) {
      try {
        return await _searchFertilizersViaBackend(
          nitrogen: nitrogen,
          phosphorus: phosphorus,
          potassium: potassium,
          token: token,
        );
      } catch (e) {
        print('Backend request failed, falling back to direct Gemini: $e');
        // Fall through to direct Gemini call
      }
    }

    // Fallback to direct Gemini call
    try {
      final model = _getModel();
      
      final prompt = _buildFertilizerSearchPrompt(
        nitrogen: nitrogen,
        phosphorus: phosphorus,
        potassium: potassium,
        location: location ?? 'India',
        cropType: cropType ?? 'General',
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text == null) {
        throw Exception('No response from Gemini AI');
      }

      return _parseGeminiResponse(response.text!);
    } catch (e) {
      print('Gemini AI Error: $e');
      // Fallback to demo data only on error
      print('⚠️ Falling back to demo data due to error');
      return _getDemoRecommendations();
    }
  }

  /// Search fertilizers via backend API
  static Future<FertilizerAnalysisResponse> _searchFertilizersViaBackend({
    required int nitrogen,
    required int phosphorus,
    required int potassium,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.backendBaseUrl}/fertilization/alternatives'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'npk': {'n': nitrogen, 'p': phosphorus, 'k': potassium},
        'current_brand': 'Unknown',
        'current_price': 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Backend returns the agent's output
      return _parseBackendResponse(data);
    } else {
      throw Exception('Backend API error: ${response.statusCode}');
    }
  }

  /// Parse backend response
  static FertilizerAnalysisResponse _parseBackendResponse(Map<String, dynamic> data) {
    try {
      // Backend returns: {"cheaper_alternatives": [...], "analysis": {...}}
      if (data.containsKey('cheaper_alternatives')) {
        final alternatives = data['cheaper_alternatives'];
        return FertilizerAnalysisResponse.fromJson(alternatives);
      } else {
        throw Exception('Invalid backend response format');
      }
    } catch (e) {
      print('Error parsing backend response: $e');
      return _getDemoRecommendations();
    }
  }

  /// Build prompt for fertilizer search
  static String _buildFertilizerSearchPrompt({
    required int nitrogen,
    required int phosphorus,
    required int potassium,
    required String location,
    required String cropType,
  }) {
    return '''
You are Krishidnya, an agricultural AI assistant helping Indian farmers find cheaper fertilizer alternatives.

A farmer has a fertilizer with this composition:
- Nitrogen (N): $nitrogen%
- Phosphorus (P): $phosphorus%
- Potassium (K): $potassium%
- Location: $location
- Crop Type: $cropType

Your Task:
Find 5 CHEAPER alternatives available in India with similar or better NPK composition.

Focus on:
1. Lower-priced options (₹ per 50kg bag)
2. Government-subsidized brands (IFFCO, NFL, etc.)
3. Local cooperatives
4. Comparable NPK ratios that work for the same purpose
5. Explain why each alternative is cheaper

IMPORTANT: Return ONLY a valid JSON object, no markdown formatting, no code blocks.

Format your response EXACTLY like this JSON structure:
{
  "summary": "We found 5 cheaper alternatives that can save you money",
  "recommendations": [
    {
      "brand": "IFFCO",
      "productName": "IFFCO Urea",
      "npkRatio": "46-0-0",
      "estimatedPrice": 242.00,
      "priceRange": "₹240-₹250",
      "availability": "In Stock",
      "reasoning": "Government cooperative price. ₹24.50 cheaper than market rate. Same nitrogen content for crop growth.",
      "alternatives": ["NFL Urea (₹245/50kg)", "RCF Urea (₹248/50kg)"]
    }
  ]
}

Prioritize government-subsidized and cooperative brands. Return ONLY the JSON, nothing else.
''';
  }

  /// Parse Gemini AI response
  static FertilizerAnalysisResponse _parseGeminiResponse(String responseText) {
    try {
      // Clean response - remove markdown code blocks if present
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      final json = jsonDecode(cleanedResponse);
      return FertilizerAnalysisResponse.fromJson(json);
    } catch (e) {
      print('Error parsing Gemini response: $e');
      print('Response text: $responseText');
      // Return demo data on parsing error
      return _getDemoRecommendations();
    }
  }

  /// Get demo recommendations for offline/testing
  static FertilizerAnalysisResponse _getDemoRecommendations() {
    return FertilizerAnalysisResponse(
      summary: 'Found 5 cheaper alternatives that match your NPK requirements and can save you money.',
      recommendations: [
        FertilizerRecommendation(
          brand: 'IFFCO',
          productName: 'IFFCO Urea',
          npkRatio: '46-0-0',
          estimatedPrice: 242.00,
          priceRange: '₹240-₹250',
          availability: 'In Stock',
          reasoning: 'Cooperative society ensures lowest prices. Government-subsidized. Save ₹24/bag compared to branded options. Excellent quality control.',
          alternatives: ['NFL Urea (₹245/50kg)', 'RCF Urea (₹248/50kg)'],
        ),
        FertilizerRecommendation(
          brand: 'NFL (National Fertilizers)',
          productName: 'NFL Urea',
          npkRatio: '46-0-0',
          estimatedPrice: 245.00,
          priceRange: '₹242-₹248',
          availability: 'In Stock',
          reasoning: 'Government PSU pricing. Marginally higher than IFFCO but widely available. Still ₹21/bag cheaper than private brands.',
          alternatives: ['IFFCO Urea (₹242/50kg)', 'GSFC Urea (₹250/50kg)'],
        ),
        FertilizerRecommendation(
          brand: 'IFFCO',
          productName: 'IFFCO DAP',
          npkRatio: '18-46-0',
          estimatedPrice: 1310.00,
          priceRange: '₹1,300-₹1,320',
          availability: 'In Stock',
          reasoning: 'Lowest DAP price in market. Cooperative pricing saves ₹40/bag. Same phosphorus content, trusted quality.',
          alternatives: ['Paradeep DAP (₹1,315/50kg)', 'GSFC DAP (₹1,325/50kg)'],
        ),
        FertilizerRecommendation(
          brand: 'GSFC',
          productName: 'GSFC NPK 19-19-19',
          npkRatio: '19-19-19',
          estimatedPrice: 1080.00,
          priceRange: '₹1,070-₹1,100',
          availability: 'Limited Stock',
          reasoning: 'Balanced NPK at cooperative rate. ₹70/bag cheaper than private brands. One application serves all nutrient needs.',
          alternatives: ['IFFCO NPK 20-20-20 (₹1,100/50kg)', 'Cooperative NPK 17-17-17 (₹1,050/50kg)'],
        ),
        FertilizerRecommendation(
          brand: 'RCF (Rashtriya Chemicals)',
          productName: 'RCF Urea',
          npkRatio: '46-0-0',
          estimatedPrice: 248.00,
          priceRange: '₹245-₹252',
          availability: 'In Stock',
          reasoning: 'Government company ensures fair pricing. ₹18/bag cheaper than branded urea. Good availability in most regions.',
          alternatives: ['IFFCO Urea (₹242/50kg)', 'NFL Urea (₹245/50kg)'],
        ),
      ],
    );
  }
}
