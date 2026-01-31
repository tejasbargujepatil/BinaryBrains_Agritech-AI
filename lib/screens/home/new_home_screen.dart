import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_cards.dart';
import '../../services/weather_service.dart';
import '../../services/soil_service.dart';
import '../../services/crop_service.dart';
import '../../services/auth_service.dart';
import '../../models/weather_model.dart';
import '../../models/soil_model.dart';
import '../../models/crop_model.dart';
import '../../l10n/app_localizations.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});
  
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  WeatherModel? _weather;
  SoilModel? _soil;
  List<CropModel> _crops = [];
  bool _isLoading = true;
  String _userName = 'Farmer';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load user data
    final user = await AuthService.getUserData();
    if (user != null) {
      setState(() => _userName = user.name);
    }
    
    // Load weather, soil, and crops in parallel
    final results = await Future.wait([
      WeatherService.getUserWeather(),
      SoilService.getUserSoilData(),
      CropService.getCrops(),
    ]);
    
    setState(() {
      if (results[0]['success']) {
        _weather = results[0]['weather'];
      }
      if (results[1]['success']) {
        _soil = results[1]['soil'];
      }
      if (results[2]['success']) {
        _crops = results[2]['crops'] ?? [];
      }
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                    
                    // Horizontal Scroll: Weather & Soil Banners
                    _buildBannerScroll(),
                    
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
  
  /// Horizontal scroll banner for Weather and Soil
  Widget _buildBannerScroll() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        children: [
          // Weather Banner
          if (_weather != null)
            SizedBox(
              width: 300,
              child: WeatherCard(
                location: 'Pune, Maharashtra',
                temperature: _weather!.temperature,
                condition: _weather!.condition,
                humidity: _weather!.humidity,
                windSpeed: _weather!.windSpeed,
                rainProbability: _weather!.rainProbability,
              ),
            ),
          
          const SizedBox(width: AppTheme.spacingMd),
          
          // Soil Banner
          if (_soil != null)
            SizedBox(
              width: 300,
              child: SoilHealthCard(
                soilType: _soil!.soilType,
                ph: _soil!.ph ?? 0,
                nitrogen: _soil!.nitrogen,
                phosphorus: _soil!.phosphorus,
                potassium: _soil!.potassium,
                onTap: () {
                  // TODO: Navigate to soil details
                },
              ),
            ),
        ],
      ),
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
        );
      },
    );
  }
}
