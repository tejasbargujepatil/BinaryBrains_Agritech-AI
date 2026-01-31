import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_cards.dart';
import '../../widgets/charts.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';
import '../../l10n/app_localizations.dart';

class FullWeatherScreen extends StatefulWidget {
  const FullWeatherScreen({super.key});
  
  @override
  State<FullWeatherScreen> createState() => _FullWeatherScreenState();
}

class _FullWeatherScreenState extends State<FullWeatherScreen> {
  WeatherModel? _weather;
  bool _isLoading = true;
  
 @override
  void initState() {
    super.initState();
    _loadWeather();
  }
  
  Future<void> _loadWeather() async {
    final result = await WeatherService.getUserWeather();
    setState(() {
      if (result['success']) {
        _weather = result['weather'];
      }
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Weather Forecast',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: _weather != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              _getWeatherIcon(_weather!.condition),
                              size: 60,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_weather!.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _weather!.condition,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
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
          else if (_weather == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: AppTheme.textHint,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'Unable to load weather',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ElevatedButton(
                      onPressed: _loadWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current Conditions Card
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Conditions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherMetric(
                                icon: Icons.water_drop,
                                label: 'Humidity',
                                value: '${_weather!.humidity.toInt()}%',
                                color: AppTheme.info,
                              ),
                            ),
                            if (_weather!.windSpeed != null)
                              Expanded(
                                child: _buildWeatherMetric(
                                  icon: Icons.air,
                                  label: 'Wind Speed',
                                  value: '${_weather!.windSpeed!.toInt()} km/h',
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            if (_weather!.rainProbability != null)
                              Expanded(
                                child: _buildWeatherMetric(
                                  icon: Icons.umbrella,
                                  label: 'Rain Chance',
                                  value: '${_weather!.rainProbability!.toInt()}%',
                                  color: AppTheme.info,
                                ),
                              ),
                            if (_weather!.rainfall != null)
                              Expanded(
                                child: _buildWeatherMetric(
                                  icon: Icons.water,
                                  label: 'Rainfall',
                                  value: '${_weather!.rainfall!.toStringAsFixed(1)} mm',
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // 7-Day Forecast (placeholder for now)
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7-Day Forecast',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        // Sample forecast items
                        ..._buildMockForecast(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXl),
                ]),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildWeatherMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.mediumRadius,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildMockForecast() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((day) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.wb_sunny,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LinearProgressBar(
                percentage: 70,
                height: 6,
                color: AppTheme.warning,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '28°C',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  IconData _getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun')) return Icons.wb_sunny;
    if (lower.contains('rain')) return Icons.grain;
    if (lower.contains('cloud')) return Icons.cloud;
    if (lower.contains('storm')) return Icons.thunderstorm;
    return Icons.wb_cloudy;
  }
}
