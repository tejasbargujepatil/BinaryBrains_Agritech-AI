import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/weather_forecast_service.dart';
import '../../models/weather_forecast_model.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  List<DailyForecastModel> _forecast = [];
  bool _isLoading = true;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() => _isLoading = true);
    final forecast = await WeatherForecastService.get5DayForecast();
    setState(() {
      _forecast = forecast;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2196F3),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '5-Day Forecast',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.wb_sunny,
                    size: 100,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2196F3)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppTheme.spacingMd),

                // Daily forecast cards
                ..._forecast.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return _buildDayCard(day, index);
                }),

                const SizedBox(height: AppTheme.spacingXl),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyForecastModel day, int index) {
    final isSelected = _selectedDayIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.mediumRadius,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : AppTheme.cardShadow,
        border: isSelected
            ? Border.all(color: const Color(0xFF2196F3), width: 2)
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(AppTheme.spacingMd),
          leading: Text(
            day.weatherIcon,
            style: const TextStyle(fontSize: 40),
          ),
          title: Text(
            day.dayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            '${day.tempMin.toStringAsFixed(0)}° / ${day.tempMax.toStringAsFixed(0)}°C',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop, size: 16, color: Color(0xFF2196F3)),
                  const SizedBox(width: 4),
                  Text(
                    '${day.rainProbability}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                day.condition,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                children: [
                  // Weather details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                        Icons.water_drop,
                        'Humidity',
                        '${day.humidity}%',
                      ),
                      _buildDetailItem(
                        Icons.air,
                        'Wind',
                        '${day.windSpeed.toStringAsFixed(1)} km/h',
                      ),
                      _buildDetailItem(
                        Icons.grain,
                        'Rain',
                        '${day.rainProbability}%',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingMd),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),

                  // Hourly breakdown
                  const Text(
                    'Hourly Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: day.hourlyData.length,
                      itemBuilder: (context, index) {
                        final hour = day.hourlyData[index];
                        return _buildHourCard(hour);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHourCard(WeatherForecastModel hour) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: AppTheme.smallRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${hour.date.hour}:00',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hour.weatherIcon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            '${hour.tempMax.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
