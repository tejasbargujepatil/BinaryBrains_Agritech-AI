import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_cards.dart';
import '../../services/weather_service.dart';
import '../../services/soil_service.dart';
import '../../services/crop_service.dart';
import '../../services/auth_service.dart';
import '../../services/agent_service.dart';
import '../../models/weather_model.dart';
import '../../models/soil_model.dart';
import '../../models/crop_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart'; // Added import

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});
  
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  WeatherModel? _weather;
  SoilModel? _soil;
  List<CropModel> _crops = [];
  bool _isFetchingLive = false; 
  bool _isLoading = true; // Restored
  String _userName = 'Farmer'; // Restored
  List<Map<String, dynamic>> _smartAlerts = []; // Restored
  
  @override
  void initState() {
    super.initState();
    _loadInitialData(); 
  }

  /// Determine the current position of the device.
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null; // Location services are disabled.
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null; // Permissions are denied
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null; // Permissions are denied forever
      } 

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Location Error: $e");
      return null;
    }
  }

  // Alias for legacy calls
  Future<void> _loadData() => _loadInitialData();
  
  // Fast: Load locally cached data
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user data
      final user = await AuthService.getUserData();
      if (user != null) {
        setState(() => _userName = user.name);
      }
      
      // Load Crops (Local DB - Fast)
      final cropResult = await CropService.getCrops();
      if (cropResult['success']) {
        setState(() => _crops = cropResult['crops'] ?? []);
      }
    } catch (e) {
      print("Error loading local data: $e");
    } finally {
      // Unblock UI immediately after local data
      setState(() => _isLoading = false);
    }

    // Trigger background fetch
    if (mounted) _fetchLiveData();
  }

  // Slow: Fetch Remote APIs
  Future<void> _fetchLiveData() async {
    setState(() => _isFetchingLive = true);
    
    try {
      // Get Live Location
      Position? position = await _determinePosition();
      double lat = 0.0;
      double lon = 0.0;
      
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
      } else {
         // Fallback: Try to get user's stored location
         final user = await AuthService.getUserData();
         if (user != null) {
           lat = user.location.latitude;
           lon = user.location.longitude;
         }
      }

      // Load weather and soil in parallel
      final results = await Future.wait([
        WeatherService.getCurrentWeather(lat, lon), 
        SoilService.getSoilData(lat, lon),     
        AgentService.triggerDailyCheck(), // Agent also network bound
      ]);

      if (!mounted) return;
      
      setState(() {
        if (results[0]['success']) {
          _weather = results[0]['weather'];
        }
        if (results[1]['success']) {
          _soil = results[1]['soil'];
        }
        if (results[2]['success']) {
          _smartAlerts = List<Map<String, dynamic>>.from(results[2]['alerts']);
        }
      });
    } catch (e) {
      print("Background fetch error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLive = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialData, // Triggers full reload
          color: AppTheme.primaryGreen,
          child: CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                floating: true,
                stretch: true,
                expandedHeight: 100,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alerts');
                    },
                  ),
                ],
              ),
              
              // Content
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Smart Alerts (Continuous Guidance)
                    if (_smartAlerts.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Daily Insights 🤖",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                                if (_smartAlerts.length > 1)
                                  Text(
                                    "${_smartAlerts.length} updates",
                                    style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 90,
                              child: PageView(
                                controller: PageController(viewportFraction: 1.0),
                                padEnds: false, // Ensure full width alignment
                                children: _smartAlerts.map((alert) => Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    border: Border.all(color: Colors.orange[200]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        alert['icon'] == 'cloud_off' ? Icons.cloud_off : Icons.info,
                                        color: Colors.orange[800],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              alert['type'] == 'stage_update' ? 'Stage Update' : 'Advisory',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[900],
                                              ),
                                            ),
                                            Text(
                                              alert['message'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: AppTheme.spacingLg),

                    // Carousel: Weather & Soil Banners
                    _buildDataCarousel(),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Action Cards: Agent View & Add Crop
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: _buildActionCards(),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // My Crops Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Crops (${_crops.length})',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add-crop');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Crops Grid or Empty State
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: _crops.isEmpty
                          ? _buildEmptyState()
                          : _buildCropsGrid(isMobile),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Carousel for Weather and Soil Data
  Widget _buildDataCarousel() {
    // Show loading skeleton/spinner if fetching live data but no data yet
    if (_isFetchingLive && _weather == null && _soil == null) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 12),
              Text(
                "Updating weather & soil...",
                 style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          ),
        ),
      );
    }

    if (_weather == null && _soil == null) return const SizedBox.shrink();

    final List<Widget> pages = [];
    
    // Weather Page
    if (_weather != null) {
      pages.add(Container(
        margin: const EdgeInsets.only(right: AppTheme.spacingSm), // Gap between cards
        child: WeatherCard(
          location: _weather!.location,
          temperature: _weather!.temperature,
          condition: _weather!.condition,
          humidity: _weather!.humidity,
          windSpeed: _weather!.windSpeed,
          rainProbability: _weather!.rainProbability,
        ),
      ));
    }
    
    // Soil Page
    if (_soil != null) {
      pages.add(Container(
        margin: const EdgeInsets.only(right: AppTheme.spacingSm), // Gap between cards
        child: SoilHealthCard(
          soilType: _soil!.soilType,
          ph: _soil!.ph ?? 0,
          nitrogen: _soil!.nitrogen, // Now dynamic, handled safe by widget
          phosphorus: _soil!.phosphorus,
          potassium: _soil!.potassium,
          onTap: () {
            // TODO: Navigate to soil details
          },
        ),
      ));
    }

    if (pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180, 
          child: PageView(
            // Align left (padEnds: false) and allow next card to peek (viewportFraction < 1)
            // Padding added to PageView to start the first card exactly at 16px
            controller: PageController(viewportFraction: 0.93),
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            children: pages.map((p) => Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacingMd), // Apply left padding to each item? No.
              // If we put left padding here, every item has it.
              // Correct approach for PageView with start-alignment:
              // Use viewportFraction + padEnds: false.
              // Wrap the child in padding ONLY if necessary for spacing between items.
              // But we need the FIRST item to start at 16px.
              // PageView doesn't support 'contentPadding'.
              // We will apply padding to the PageView itself?
              // YES: Padded PageView + padEnds: false.
              child: p,
            )).toList(),
          ),
        ),
      ],
    );
  }
  
  /// Action cards for AI Agent and Add Crop
  Widget _buildActionCards() {
    return Row(
      children: [
        // AI Agent Card
        Expanded(
          child: _buildActionCard(
            icon: Icons.psychology_outlined,
            title: 'AI Agent',
            subtitle: 'Get smart recommendations',
            gradient: AppTheme.lightGradient,
            onTap: () {
              // Navigate to crops list to select crop for AI recommendations
              Navigator.pushNamed(context, '/crops-list');
            },
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMd),
        
        // Add New Crop Card
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_circle_outline,
            title: 'Add Crop',
            subtitle: 'Start tracking new crop',
            gradient: const LinearGradient(
              colors: [Color(0xFF6BBF7A), Color(0xFF4A8B5C)],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/add-crop');
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingXl),
          Icon(
            Icons.agriculture_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No crops yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Add your first crop to get started',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-crop');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Crop'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCropsGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: _crops.length,
      itemBuilder: (context, index) {
        final crop = _crops[index];
        return CropCard(
          cropName: crop.cropName,
          variety: crop.cropVariety,
          daysAfterSowing: crop.getDaysSinceSowing(),
          landArea: crop.landArea,
          healthStatus: crop.healthStatus,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/crop-agent-dashboard',
              arguments: crop.id,
            );
          },
          onDelete: () => _confirmDeleteCrop(crop),
        );
      },
    );
  }

  Future<void> _confirmDeleteCrop(CropModel crop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Crop?'),
        content: Text('Are you sure you want to remove ${crop.cropName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final result = await CropService.deleteCrop(crop.id);
      
      if (result['success'] == true) {
        // Refresh list
        _loadData();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crop removed successfully')),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove: ${result['error']}')),
          );
        }
      }
    }
  }
}
