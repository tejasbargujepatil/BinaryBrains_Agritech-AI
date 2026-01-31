import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Modern Card Widget with Gradient and Shadow
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final double? height;
  
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.color,
    this.onTap,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color ?? AppTheme.cardBackground,
          borderRadius: AppTheme.largeRadius,
          boxShadow: AppTheme.cardShadow,
        ),
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        child: child,
      ),
    );
  }
}

/// Weather Widget Card
class WeatherCard extends StatelessWidget {
  final String location;
  final double temperature;
  final String condition;
  final double humidity;
  final double? windSpeed;
  final double? rainProbability;
  
  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    this.windSpeed,
    this.rainProbability,
  });
  
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      gradient: AppTheme.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Temperature & Condition
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      condition,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _buildWeatherIcon(condition),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          const Divider(color: Colors.white24),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Weather Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${humidity.toInt()}%',
              ),
              if (windSpeed != null)
                _buildWeatherDetail(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${windSpeed!.toInt()} km/h',
                ),
              if (rainProbability != null)
                _buildWeatherDetail(
                  icon: Icons.umbrella_outlined,
                  label: 'Rain',
                  value: '${rainProbability!.toInt()}%',
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeatherIcon(String condition) {
    IconData icon;
    if (condition.toLowerCase().contains('sun')) {
      icon = Icons.wb_sunny;
    } else if (condition.toLowerCase().contains('cloud')) {
      icon = Icons.cloud;
    } else if (condition.toLowerCase().contains('rain')) {
      icon = Icons.grain;
    } else {
      icon = Icons.wb_cloudy;
    }
    
    return Icon(icon, size: 64, color: Colors.white.withOpacity(0.3));
  }
}

/// Crop Card Widget
class CropCard extends StatelessWidget {
  final String cropName;
  final String? variety;
  final int daysAfterSowing;
  final double landArea;
  final String healthStatus;
  final String? imagePath;
  final VoidCallback? onTap;
  
  const CropCard({
    super.key,
    required this.cropName,
    this.variety,
    required this.daysAfterSowing,
    required this.landArea,
    required this.healthStatus,
    this.imagePath,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Image or Icon
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.veryLightGreen,
              borderRadius: AppTheme.mediumRadius,
            ),
            child: Center(
              child: imagePath != null
                  ? Image.asset(imagePath!, height: 80)
                  : Icon(
                      _getCropIcon(cropName),
                      size: 64,
                      color: AppTheme.primaryGreen,
                    ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Crop Name
          Text(
            cropName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (variety != null) ...[
            const SizedBox(height: 4),
            Text(
              variety!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // Metrics
          Row(
            children: [
              _buildMetric(
                icon: Icons.calendar_today,
                value: '$daysAfterSowing DAS',
              ),
              const SizedBox(width: AppTheme.spacingMd),
              _buildMetric(
                icon: Icons.landscape,
                value: '${landArea.toStringAsFixed(1)} acres',
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Health Status Badge
          _buildHealthBadge(healthStatus),
        ],
      ),
    );
  }
  
  Widget _buildMetric({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHealthBadge(String status) {
    Color color;
    String label;
    
    switch (status.toUpperCase()) {
      case 'EXCELLENT':
        color = AppTheme.success;
        label = 'Excellent';
        break;
      case 'GOOD':
        color = AppTheme.accentGreen;
        label = 'Good';
        break;
      case 'FAIR':
        color = AppTheme.warning;
        label = 'Fair';
        break;
      case 'POOR':
        color = AppTheme.error;
        label = 'Poor';
        break;
      default:
        color = AppTheme.textSecondary;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.smallRadius,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCropIcon(String cropName) {
    final name = cropName.toLowerCase();
    if (name.contains('cotton')) return Icons.grass;
    if (name.contains('wheat')) return Icons.agriculture;
    if (name.contains('rice')) return Icons.rice_bowl;
    if (name.contains('corn') || name.contains('maize')) return Icons.dinner_dining;
    if (name.contains('sugar')) return Icons.eco;
    return Icons.spa;
  }
}

/// Stat Card for displaying metrics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  });
  
  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryGreen;
    
    return ModernCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: AppTheme.mediumRadius,
            ),
            child: Icon(icon, color: cardColor, size: 28),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soil Health Card
class SoilHealthCard extends StatelessWidget {
  final String soilType;
  final double ph;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final VoidCallback? onTap;
  
  const SoilHealthCard({
    super.key,
    required this.soilType,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terrain, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Soil Health',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          Text(
            soilType,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: _buildNPKIndicator('pH', ph.toStringAsFixed(1), AppTheme.info),
              ),
              Expanded(
                child: _buildNPKIndicator('N', nitrogen.toInt().toString(), AppTheme.success),
              ),
              Expanded(
                child: _buildNPKIndicator('P', phosphorus.toInt().toString(), AppTheme.warning),
              ),
              Expanded(
                child: _buildNPKIndicator('K', potassium.toInt().toString(), AppTheme.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNPKIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppTheme.smallRadius,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
