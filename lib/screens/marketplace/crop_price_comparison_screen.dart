import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../config/app_theme.dart';
import '../../models/market_place.dart';
import '../../models/crop_model.dart';
import '../../services/agmarknet_service.dart';
import '../../services/marketplace_service.dart';
import '../../services/crop_service.dart';

class CropPriceComparisonScreen extends StatefulWidget {
  const CropPriceComparisonScreen({super.key});

  @override
  State<CropPriceComparisonScreen> createState() => _CropPriceComparisonScreenState();
}

class _CropPriceComparisonScreenState extends State<CropPriceComparisonScreen> {
  bool _loading = false;
  String _status = 'बाजारभाव तुलना - Market Price Comparison';
  List<MarketPlace> _markets = [];
  List<CropModel> _userCrops = [];
  String? _selectedCrop;
  String? _detectedState;
  String? _detectedDistrict;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _loadUserCrops();
  }

  Future<void> _loadUserCrops() async {
    setState(() => _loading = true);
    try {
      final result = await CropService.getCrops();
      if (result['success'] == true) {
        setState(() {
          _userCrops = result['crops'] ?? [];
          if (_userCrops.isNotEmpty) {
            _selectedCrop = _userCrops.first.cropName;
          }
        });
      }
    } catch (e) {
      _showError('Failed to load crops: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchPrices() async {
    if (_selectedCrop == null) {
      _showError('कृपया पीक निवडा - Please select a crop');
      return;
    }

    setState(() {
      _loading = true;
      _status = 'तुमचे स्थान शोधत आहे... Finding location...';
      _markets.clear();
      _aiAnalysis = null;
    });

    try {
      // Get user location
      final position = await _getCurrentPosition();
      
      setState(() => _status = 'जिल्हा शोधत आहे... Detecting district...');
      
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isEmpty) {
        throw Exception('Could not detect location');
      }

      // Restore GPS Logic with Fallback
      final place = placemarks.first;
      _detectedState = place.administrativeArea ?? '';
      _detectedDistrict = place.subAdministrativeArea ?? place.locality ?? '';

      if (_detectedState == null || _detectedState!.isEmpty) {
        _detectedState = "Maharashtra"; // Default fallback
      }
      
      // Clean district name (remove 'District' or 'Division' suffix)
      if (_detectedDistrict != null) {
        _detectedDistrict = _detectedDistrict!
            .replaceAll(' District', '')
            .replaceAll(' Division', '') // Fix for 'Pune Division'
            .trim();
      }

      setState(() => _status = 'बाजारभाव मिळवत आहे... Fetching prices...');

      // 1. Try Specific District Search
      // Important: Trim commodity name to avoid mismatches (e.g. "Wheat " vs "Wheat")
      final cleanCommodity = _selectedCrop!.trim();
      
      var result = await AgmarknetService.fetchPrices(
        state: _detectedState!,
        district: _detectedDistrict,
        commodity: cleanCommodity,
      );

      List<dynamic> rawRecords = [];
      
      if (result['success'] == true) {
        rawRecords = result['records'] as List;
      } else {
         // If API fails, try broader search immediately instead of throwing
         print('District fetch failed: ${result['error']}');
      }

      // 2. Fallback: If no markets in district, search entire state
      if (rawRecords.isEmpty) {
        setState(() => _status = 'ह्या जिल्ह्यात बाजारभाव नाहीत, राज्यभरात शोधत आहे...\nSearching State...');
        
        result = await AgmarknetService.fetchPrices(
          state: _detectedState!,
          district: null, // Search entire state
          commodity: cleanCommodity,
          limit: 100, // Fetch more for state level
        );
        
        if (result['success'] == true) {
          rawRecords = result['records'] as List;
        }
      }

      final markets = rawRecords.map((r) => MarketPlace.fromJson(r)).toList();

      if (markets.isEmpty) {
        // 3. MSP Fallback (No live data found)
        setState(() {
          _status = 'स्थानिक बाजार माहिती उपलब्ध नाही - Local data unavailable';
          _loading = false;
          // Add Reference Price (MSP) as a fallback market entry
          _markets = [
            MarketPlace(
              state: "India (Reference)",
              district: "MSP / Reference",
              market: "Government MSP",
              commodity: cleanCommodity,
              variety: "FAQ",
              arrivalDate: DateTime.now().toString().split(' ')[0],
              modalPrice: 2275, // Approx Wheat MSP 2024-25 as placeholder
              minPrice: 2125,
              maxPrice: 2400,
            )
          ];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Showing Reference Price (MSP) as live data is unavailable'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // If we have user location, try to calculate distances (Mock/Approximate)
      // Since API doesn't give lat/long, we can't do real geofencing 50km without geocoding each market.
      // For now, we just show all results but indicate they might be far.
      
      setState(() {
        _markets = markets;
        _status = '${markets.length} बाजार सापडले - Found ${markets.length} markets';
      });

      // Get AI analysis if we have markets
      // await _getAIAnalysis(); 

    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('स्थान सेवा बंद आहे - Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('स्थान परवानगी नाकारली - Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('स्थान परवानगी कायमची नाकारली - Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAIAnalysis() async {
    if (_markets.isEmpty) return;

    setState(() => _status = 'AI विश्लेषण करत आहे... AI analyzing prices...');

    try {
      final result = await MarketplaceService.analyzePrices(
        cropName: _selectedCrop!,
        markets: _markets.take(10).toList(), // Top 10 markets
      );

      if (result['success'] == true) {
        setState(() {
          _aiAnalysis = result['analysis'];
          _status = 'विश्लेषण पूर्ण ✓ - Analysis complete ✓';
        });
      }
    } catch (e) {
      print('AI Analysis error: $e');
      // Don't show error, just skip AI analysis
    }
  }

  void _showError(String message) {
    setState(() {
      _status = 'त्रुटी: $message';
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with crop selector and fetch button
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildCropDropdown(),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _fetchPrices,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_loading ? 'शोधत आहे...' : 'किंमत शोधा'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                    ),
                  ),
                ],
              ),
              if (_detectedState != null && _detectedDistrict != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingSm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '$_detectedDistrict, $_detectedState',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _markets.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  children: [
                    // AI Recommendations (if available)
                    if (_aiAnalysis != null) _buildAIRecommendations(),
                    
                    // Market list
                    _buildMarketsList(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCropDropdown() {
    // If no crops, show message
    if (_userCrops.isEmpty && !_loading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'कृपया आधी पीक जोडा - Please add a crop first',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCrop,
          hint: const Text('पीक निवडा - Select Crop'),
          isExpanded: true,
          items: _userCrops.map((e) => e.cropName).toSet().map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCrop = value);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store,
                size: 60,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'बाजारभाव तुलना',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              'तुमच्या पिकाची बाजारभाव तुलना पाहण्यासाठी वरील बटण दाबा',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              'Compare prices from nearby markets',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendations() {
    final bestMarket = _aiAnalysis?['best_market'] as Map<String, dynamic>?;
    final recommendation = _aiAnalysis?['final_recommendation'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Text(
                  'AI शिफारस - AI Recommendation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (bestMarket != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'सर्वोत्तम बाजार - Best: ${bestMarket['market_name']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              _infoRow('किंमत - Price', '₹${bestMarket['modal_price']}/quintal'),
              _infoRow('अंतर - Distance', '${bestMarket['distance_km']} km'),
              _infoRow('अंदाजित नफा - Expected Profit', 
                  '₹${bestMarket['expected_profit_per_quintal']}/quintal'),
            ],
            if (recommendation != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  recommendation,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMarketsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          child: Text(
            'सर्व बाजार - All Markets (${_markets.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._markets.map((market) => _buildMarketCard(market)).toList(),
      ],
    );
  }

  Widget _buildMarketCard(MarketPlace market) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    market.market,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                if (market.distanceKm != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${market.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${market.district}, ${market.state}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            if (market.variety.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Variety: ${market.variety}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceColumn('किमान\nMin', market.minPrice),
                _priceColumn('सरासरी\nModal', market.modalPrice, isMain: true),
                _priceColumn('कमाल\nMax', market.maxPrice),
              ],
            ),
            if (market.arrivalDate.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    market.arrivalDate,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _priceColumn(String label, double price, {bool isMain = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMain ? 18 : 15,
            color: isMain ? AppTheme.primaryGreen : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
