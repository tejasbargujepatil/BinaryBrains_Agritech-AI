import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../services/ocr_service.dart';
import '../../services/gemini_service.dart';
import '../../models/fertilizer_recommendation.dart';

class FertilizerComparisonScreen extends StatefulWidget {
  const FertilizerComparisonScreen({super.key});

  @override
  State<FertilizerComparisonScreen> createState() =>
      _FertilizerComparisonScreenState();
}

class _FertilizerComparisonScreenState
    extends State<FertilizerComparisonScreen> {
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<FertilizerRecommendation> _recommendations = [];
  bool _showResults = false;
  bool _isLoading = false;
  String _summary = '';
  File? _selectedImage;

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    super.dispose();
  }

  /// Capture image from camera
  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        setState(() => _selectedImage = File(photo.path));
        await _processImage(File(photo.path));
      }
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Gallery error: $e');
    }
  }

  /// Process image with OCR
  Future<void> _processImage(File image) async {
    setState(() => _isLoading = true);

    try {
      final npkValues = await OcrService.extractNPKFromImage(image);
      
      if (npkValues.containsKey('error')) {
        _showError(npkValues['error']!);
      } else if (npkValues['n']!.isNotEmpty &&
                 npkValues['p']!.isNotEmpty &&
                 npkValues['k']!.isNotEmpty) {
        // Auto-fill NPK fields
        setState(() {
          _nController.text = npkValues['n']!;
          _pController.text = npkValues['p']!;
          _kController.text = npkValues['k']!;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ NPK values extracted successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        
        // Automatically search fertilizers
        await _searchFertilizers();
      } else {
        _showError('Could not extract NPK values. Please enter manually.');
      }
    } catch (e) {
      _showError('OCR processing failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Search fertilizers using Gemini AI
  Future<void> _searchFertilizers() async {
    // Validate input
    if (_nController.text.isEmpty ||
        _pController.text.isEmpty ||
        _kController.text.isEmpty) {
      _showError('Please enter N, P, and K values');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await GeminiService.searchFertilizers(
        nitrogen: int.tryParse(_nController.text) ?? 0,
        phosphorus: int.tryParse(_pController.text) ?? 0,
        potassium: int.tryParse(_kController.text) ?? 0,
      );

      setState(() {
        _recommendations = response.recommendations;
        _summary = response.summary;
        _showResults = true;
      });
    } catch (e) {
      _showError('Fertilizer search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              gradient: AppTheme.lightGradient,
              borderRadius: AppTheme.mediumRadius,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 48,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                const Text(
                  'Find Cheaper Fertilizer Alternatives',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Powered by',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🌾 Krishidnya AI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Upload Bill Card
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.mediumRadius,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_file, color: AppTheme.primaryGreen),
                    const SizedBox(width: AppTheme.spacingSm),
                    const Expanded(
                      child: Text(
                        'Upload Fertilizer Bill Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'AI OCR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                const Text(
                  'Our AI will analyze your fertilizer and find cheaper alternatives with the same NPK composition',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                
                // Preview selected image
                if (_selectedImage != null)
                  Container(
                    height: 150,
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.smallRadius,
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _captureFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_showResults) ...[
            const SizedBox(height: AppTheme.spacingLg),
            
            // AI Summary
            if (_summary.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: AppTheme.smallRadius,
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppTheme.spacingMd),
            
            // Results Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_recommendations.length} Cheaper Alternatives Found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Sort options
                  },
                  icon: const Icon(Icons.sort, size: 18),
                  label: const Text('Sort by Price'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Recommendation Cards
            ..._recommendations.map((rec) => _buildRecommendationCard(rec)),
          ],
        ],
      ),
    );
  }

  Widget _buildNPKInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        border: OutlineInputBorder(
          borderRadius: AppTheme.smallRadius,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingSm,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecommendationCard(FertilizerRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: rec.availability == 'In Stock'
              ? AppTheme.success.withOpacity(0.3)
              : rec.availability == 'Limited Stock'
                  ? AppTheme.warning.withOpacity(0.3)
                  : AppTheme.textHint,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(AppTheme.spacingMd),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
          ),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.lightGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rec.brand.substring(0, 1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rec.brand,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rec.productName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rec.availability == 'In Stock'
                        ? AppTheme.success.withOpacity(0.1)
                        : rec.availability == 'Limited Stock'
                            ? AppTheme.warning.withOpacity(0.1)
                            : AppTheme.textHint.withOpacity(0.1),
                    borderRadius: AppTheme.smallRadius,
                  ),
                  child: Text(
                    rec.availability,
                    style: TextStyle(
                      fontSize: 11,
                      color: rec.availability == 'In Stock'
                          ? AppTheme.success
                          : rec.availability == 'Limited Stock'
                              ? AppTheme.warning
                              : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NPK: ${rec.npkRatio}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${rec.estimatedPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                'per 50kg',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          children: [
            // Reasoning
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: AppTheme.smallRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      const Text(
                        'Why this fertilizer?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rec.reasoning,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Price Range
            if (rec.priceRange.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  const Text(
                    'Price Range: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    rec.priceRange,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],

            // Alternatives
            if (rec.alternatives.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMd),
              const Text(
                'Cheaper Alternatives:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              ...rec.alternatives.map((alt) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right, size: 16, color: AppTheme.primaryGreen),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            alt,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
