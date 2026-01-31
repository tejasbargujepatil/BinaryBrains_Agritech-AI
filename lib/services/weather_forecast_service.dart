import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../config/apiconfig.dart';
import '../config/app_config.dart';
import '../models/weather_forecast_model.dart';

class WeatherForecastService {
  /// Get 5-day weather forecast for user's location
  static Future<List<DailyForecastModel>> get5DayForecast() async {
    if (AppConfig.isDemoMode) {
      return _getDemoForecast();
    }

    try {
      // Get user location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final url = Uri.parse(
        '${ApiConfig.openWeatherMapBaseUrl}/forecast?'
        'lat=${position.latitude}&lon=${position.longitude}'
        '&appid=${ApiConfig.openWeatherMapApiKey}&units=metric',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecastData(data);
      } else {
        print('Weather forecast API error: ${response.statusCode}');
        return _getDemoForecast();
      }
    } catch (e) {
      print('Error fetching forecast: $e');
      return _getDemoForecast();
    }
  }

  /// Parse forecast data from API response
  static List<DailyForecastModel> _parseForecastData(
    Map<String, dynamic> data,
  ) {
    final List<dynamic> list = data['list'] ?? [];
    final Map<String, List<WeatherForecastModel>> dailyMap = {};

    // Group hourly forecasts by day
    for (var item in list) {
      final forecast = WeatherForecastModel.fromJson(item);
      final dateKey =
          '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';

      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = [];
      }
      dailyMap[dateKey]!.add(forecast);
    }

    // Aggregate hourly data into daily forecasts
    final List<DailyForecastModel> dailyForecasts = [];
    dailyMap.forEach((key, hourly) {
      if (hourly.isEmpty) return;

      final tempMin = hourly.map((h) => h.tempMin).reduce((a, b) => a < b ? a : b);
      final tempMax = hourly.map((h) => h.tempMax).reduce((a, b) => a > b ? a : b);
      final avgRainProb = hourly.map((h) => h.rainProbability).reduce((a, b) => a + b) ~/ hourly.length;
      final avgHumidity = hourly.map((h) => h.humidity).reduce((a, b) => a + b) ~/ hourly.length;
      final avgWindSpeed = hourly.map((h) => h.windSpeed).reduce((a, b) => a + b) / hourly.length;

      // Most common condition during the day
      final conditionCounts = <String, int>{};
      for (var h in hourly) {
        conditionCounts[h.condition] = (conditionCounts[h.condition] ?? 0) + 1;
      }
      final condition = conditionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      dailyForecasts.add(
        DailyForecastModel(
          date: hourly.first.date,
          tempMin: tempMin,
          tempMax: tempMax,
          condition: condition,
          rainProbability: avgRainProb,
          humidity: avgHumidity,
          windSpeed: avgWindSpeed,
          hourlyData: hourly,
        ),
      );
    });

    // Return only 5 days
    return dailyForecasts.take(5).toList();
  }

  /// Demo forecast data
  static List<DailyForecastModel> _getDemoForecast() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final date = now.add(Duration(days: index));
      return DailyForecastModel(
        date: date,
        tempMin: 18.0 + (index * 0.5),
        tempMax: 32.0 + (index * 0.3),
        condition: _getDemoCondition(index),
        rainProbability: index == 2 ? 80 : (20 + index * 10),
        humidity: 65 + (index * 2),
        windSpeed: 8.0 + (index * 0.5),
        hourlyData: _getDemoHourlyData(date),
      );
    });
  }

  static String _getDemoCondition(int index) {
    const conditions = ['Clear', 'Clouds', 'Rain', 'Clear', 'Clouds'];
    return conditions[index % conditions.length];
  }

  static List<WeatherForecastModel> _getDemoHourlyData(DateTime date) {
    return List.generate(8, (hour) {
      return WeatherForecastModel(
        date: DateTime(date.year, date.month, date.day, hour * 3),
        tempMin: 20.0 + hour,
        tempMax: 25.0 + hour,
        condition: hour % 2 == 0 ? 'Clear' : 'Clouds',
        icon: '01d',
        humidity: 60 + hour,
        windSpeed: 5.0 + hour * 0.5,
        rainProbability: hour == 4 ? 60 : 20,
        description: 'Partly cloudy',
      );
    });
  }
}
