import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR Service for extracting text from fertilizer bills
class OcrService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract NPK values from fertilizer bill image
  static Future<Map<String, String>> extractNPKFromImage(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _parseNPKFromText(recognizedText.text);
    } catch (e) {
      print('OCR Error: $e');
      return {'error': 'Failed to extract text from image'};
    }
  }

  /// Parse NPK values from extracted text
  static Map<String, String> _parseNPKFromText(String text) {
    final Map<String, String> result = {
      'n': '',
      'p': '',
      'k': '',
    };

    // Common patterns for NPK values
    // Examples: "NPK 20-20-20", "N:20 P:20 K:20", "20:20:20", "20-20-20"
    
    final patterns = [
      // Pattern 1: NPK 20-20-20 or N-P-K 20-20-20
      RegExp(r'NPK[\s:]*(\d+)[\s:-]+(\d+)[\s:-]+(\d+)', caseSensitive: false),
      
      // Pattern 2: N:20 P:20 K:20
      RegExp(r'N[\s:]+(\d+)[\s,]+P[\s:]+(\d+)[\s,]+K[\s:]+(\d+)', caseSensitive: false),
      
      // Pattern 3: 20:20:20 or 20-20-20 (standalone numbers)
      RegExp(r'(\d{1,2})[\s:-]+(\d{1,2})[\s:-]+(\d{1,2})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 3) {
        result['n'] = match.group(1) ?? '';
        result['p'] = match.group(2) ?? '';
        result['k'] = match.group(3) ?? '';
        
        if (result['n']!.isNotEmpty && 
            result['p']!.isNotEmpty && 
            result['k']!.isNotEmpty) {
          break; // Found valid NPK values
        }
      }
    }

    return result;
  }

  /// Dispose text recognizer
  static void dispose() {
    _textRecognizer.close();
  }
}
